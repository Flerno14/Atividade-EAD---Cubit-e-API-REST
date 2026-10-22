import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sistema_financeiro/cubits/categoria_cubit.dart';
import 'package:sistema_financeiro/cubits/transacao_cubit.dart';
import 'package:sistema_financeiro/cubits/transacao_form_cubit.dart';
import 'package:sistema_financeiro/cubits/transacao_form_state.dart';
import 'package:sistema_financeiro/models/transacao.dart';
import 'package:sistema_financeiro/repositories/categoria_repository.dart';
import 'package:sistema_financeiro/repositories/transacao_repository.dart';
import 'package:sistema_financeiro/views/cadastro_categoria_page.dart';
import 'package:sistema_financeiro/views/cadastro_transacao_page.dart';

class TransacaoRepositoryFake extends TransacaoRepository {
  TransacaoRepositoryFake() : super(accessToken: 'teste');
  Transacao? salva;
  bool falhar = false;
  @override
  Future<Transacao> criarTransacao(Transacao transacao) async {
    salva = transacao;
    return transacao;
  }

  @override
  Future<Transacao> atualizarTransacao(Transacao transacao) async {
    await Future<void>.delayed(Duration.zero);
    if (falhar) throw Exception('Falha no servidor');
    salva = transacao;
    return transacao;
  }

  @override
  Future<List<Transacao>> buscarTransacoes() async =>
      [if (salva != null) salva!];
}

void main() {
  test('Repository busca categorias e envia nome e autenticação no cadastro',
      () async {
    final client = MockClient((request) async {
      expect(request.headers['Authorization'], 'Bearer teste');
      expect(request.url.path, '/rest/v1/categorias');
      if (request.method == 'POST') {
        expect(jsonDecode(request.body), {'nome': 'Alimentação'});
        return http.Response('[{"id":"cat-1","nome":"Alimentação"}]', 201,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      expect(request.url.queryParameters['order'], 'nome.asc');
      return http.Response('[{"id":"cat-1","nome":"Alimentação"}]', 200,
          headers: {'content-type': 'application/json; charset=utf-8'});
    });
    final repository =
        CategoriaRepository(accessToken: 'teste', client: client);
    expect((await repository.buscarCategorias()).single.nome, 'Alimentação');
    expect((await repository.criarCategoria(' Alimentação ')).id, 'cat-1');
    client.close();
  });
  test('Cubit valida nome e mantém a lista após falha de cadastro', () async {
    var chamadas = 0;
    final client = MockClient((request) async {
      chamadas++;
      if (request.method == 'GET') {
        return http.Response('[{"id":"1","nome":"Saude"}]', 200);
      }
      return http.Response('{}', 409);
    });
    final cubit = CategoriaCubit(
        repository: CategoriaRepository(accessToken: 'teste', client: client));
    await cubit.salvarCategoria('  ');
    expect(chamadas, 0);
    expect(cubit.state.erro, isNotNull);
    await cubit.carregarCategorias();
    await cubit.salvarCategoria('Saude');
    expect(cubit.state.erro, contains('Já existe'));
    expect(cubit.state.categorias.single.nome, 'Saude');
    expect(cubit.state.salvando, isFalse);
    await cubit.close();
    client.close();
  });
  test('Transação exige categoria e envia o ID; edição aguarda erro', () async {
    final repository = TransacaoRepositoryFake();
    final transacoes = TransacaoCubit(repository: repository);
    final form = TransacaoFormCubit(transacaoCubit: transacoes);
    await form.salvarTransacao(
        descricao: 'Compra',
        valorText: '12,50',
        tipo: TipoTransacao.despesa,
        categoriaId: null);
    expect(form.state, isA<TransacaoFormError>());
    expect(repository.salva, isNull);
    await form.salvarTransacao(
        descricao: 'Compra',
        valorText: '12,50',
        tipo: TipoTransacao.despesa,
        categoriaId: 'cat-1');
    expect(form.state, isA<TransacaoFormSuccess>());
    expect(repository.salva!.toJson()['categoria_id'], 'cat-1');
    expect(repository.salva!.valor, 12.5);
    repository.falhar = true;
    await form.salvarTransacao(
        id: '1',
        descricao: 'Compra',
        valorText: '13',
        tipo: TipoTransacao.despesa,
        categoriaId: 'cat-1');
    expect(form.state, isA<TransacaoFormError>());
    await form.close();
    await transacoes.close();
  });
  test('Leitura aceita transação antiga e preserva categoria existente', () {
    final json = <String, dynamic>{
      'id': '1',
      'descricao': 'Compra',
      'valor': 10,
      'tipo': 'TipoTransacao.despesa',
      'created_at': '2026-10-20T12:00:00Z'
    };
    expect(Transacao.fromJson(json).categoriaId, isNull);
    json['categoria_id'] = 'cat-1';
    expect(Transacao.fromJson(json).categoriaId, 'cat-1');
  });
  testWidgets('Cadastro disponibiliza a categoria do banco no formulário',
      (tester) async {
    final client = MockClient((request) async {
      if (request.method == 'GET') return http.Response('[]', 200);
      return http.Response('[{"id":"cat-1","nome":"Mercado"}]', 201);
    });
    final categorias = CategoriaCubit(
        repository: CategoriaRepository(accessToken: 'teste', client: client));
    final repository = TransacaoRepositoryFake();
    final transacoes = TransacaoCubit(repository: repository);
    final form = TransacaoFormCubit(transacaoCubit: transacoes);
    Widget app(Widget page) => MultiBlocProvider(providers: [
          BlocProvider.value(value: categorias),
          BlocProvider.value(value: form),
        ], child: MaterialApp(home: page));
    await categorias.carregarCategorias();
    await tester.pumpWidget(app(const CadastroCategoriaPage()));
    expect(find.textContaining('Nenhuma categoria cadastrada'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Mercado');
    await tester.tap(find.text('Salvar categoria'));
    await tester.pumpAndSettle();
    expect(find.text('Mercado'), findsOneWidget);
    await tester.pumpWidget(app(const CadastroTransacaoPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mercado').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Compra');
    await tester.enterText(find.byType(TextField).at(1), '25,00');
    await tester.ensureVisible(find.text('Salvar Transação'));
    await tester.tap(find.text('Salvar Transação'));
    await tester.pumpAndSettle();
    expect(repository.salva!.categoriaId, 'cat-1');
    expect(form.state, isA<TransacaoFormInitial>());
    await tester.pumpWidget(const SizedBox.shrink());
    await categorias.close();
    await form.close();
    await transacoes.close();
    client.close();
  });
}
