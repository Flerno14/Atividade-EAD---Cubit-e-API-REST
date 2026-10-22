import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistema_financeiro/main.dart';
import 'package:sistema_financeiro/models/transacao.dart';
import 'package:sistema_financeiro/repositories/local_repositories.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Login local aceita somente as credenciais configuradas', () async {
    final auth = LocalAuthRepository();
    expect((await auth.login(email: 'admin', senha: 'admin123')).id, 'admin');
    await expectLater(
        auth.login(email: 'admin', senha: 'errada'), throwsException);
    await expectLater(
        auth.login(email: 'outro', senha: 'admin123'), throwsException);
  });

  test(
      'Dados persistem entre instâncias; categoria, edição e exclusão funcionam',
      () async {
    final categoria =
        await LocalCategoriaRepository().criarCategoria('Mercado');
    expect((await LocalCategoriaRepository().buscarCategorias()).single.id,
        categoria.id);
    await expectLater(LocalCategoriaRepository().criarCategoria(' mercado '),
        throwsException);
    final repo = LocalTransacaoRepository();
    final data = DateTime(2026, 10, 20);
    final transacao = await repo.criarTransacao(Transacao(
        id: '',
        descricao: 'Compra',
        valor: 15,
        tipo: TipoTransacao.despesa,
        data: data,
        categoriaId: categoria.id));
    expect(
        (await LocalTransacaoRepository().buscarTransacoes())
            .single
            .categoriaId,
        categoria.id);
    await repo.atualizarTransacao(Transacao(
        id: transacao.id,
        descricao: 'Alterada',
        valor: 30,
        tipo: TipoTransacao.despesa,
        data: DateTime.now(),
        categoriaId: categoria.id));
    final atualizada = (await repo.buscarTransacoes()).single;
    expect(atualizada.valor, 30);
    expect(atualizada.data, data);
    await expectLater(
        repo.criarTransacao(Transacao(
            id: '',
            descricao: 'Inválida',
            valor: 10,
            tipo: TipoTransacao.despesa,
            data: data)),
        throwsException);
    await repo.excluirTransacao(transacao.id);
    expect(await LocalTransacaoRepository().buscarTransacoes(), isEmpty);
  });

  testWidgets('Admin entra no aplicativo sem Supabase', (tester) async {
    await tester.pumpWidget(const FinanceiroApp());
    expect(find.text('Usuário'), findsOneWidget);
    expect(find.text('Criar nova conta'), findsNothing);
    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'admin123');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Extrato Financeiro'), findsOneWidget);
    await tester.tap(find.text('Categorias').last);
    await tester.pumpAndSettle();
    expect(find.text('Salvar categoria'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
