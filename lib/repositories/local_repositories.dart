import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/categoria.dart';
import '../models/transacao.dart';
import '../models/usuario.dart';
import 'auth_repository.dart';
import 'categoria_repository.dart';
import 'transacao_repository.dart';

// Acesso de demonstração local, sem autenticação em servidor.
class LocalAuthRepository extends AuthRepository {
  @override
  Future<Usuario> login({required String email, required String senha}) async {
    if (email.trim() != 'admin' || senha != 'admin123') {
      throw Exception('Usuário ou senha inválidos.');
    }
    return Usuario(id: 'admin', email: 'admin', accessToken: 'local');
  }

  @override
  Future<void> cadastrar({required String email, required String senha}) async {
    throw Exception('Use a conta local admin.');
  }
}

class LocalStore {
  static Future<List<Map<String, dynamic>>> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return (jsonDecode(prefs.getString(key) ?? '[]') as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<void> write(
      String key, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(key, jsonEncode(items))) {
      throw Exception('Não foi possível salvar os dados neste dispositivo.');
    }
  }

  static int _sequence = 0;
  static String newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';
}

class LocalCategoriaRepository extends CategoriaRepository {
  LocalCategoriaRepository() : super(accessToken: 'local');
  static const storageKey = 'financeiro.local.categorias';

  @override
  Future<List<Categoria>> buscarCategorias() async {
    final items = await LocalStore.read(storageKey);
    return items.map(Categoria.fromJson).toList()
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  }

  @override
  Future<Categoria> criarCategoria(String nome) async {
    nome = nome.trim();
    if (nome.isEmpty || nome.length > 100) {
      throw Exception('Informe um nome entre 1 e 100 caracteres.');
    }
    final items = await LocalStore.read(storageKey);
    if (items.any((item) =>
        (item['nome'] as String).toLowerCase() == nome.toLowerCase())) {
      throw Exception('Já existe uma categoria com esse nome.');
    }
    final categoria = Categoria(id: LocalStore.newId(), nome: nome);
    await LocalStore.write(storageKey, [
      ...items,
      {'id': categoria.id, ...categoria.toJson()}
    ]);
    return categoria;
  }
}

class LocalTransacaoRepository extends TransacaoRepository {
  LocalTransacaoRepository() : super(accessToken: 'local');
  static const storageKey = 'financeiro.local.transacoes';

  @override
  Future<List<Transacao>> buscarTransacoes() async =>
      (await LocalStore.read(storageKey)).map(Transacao.fromJson).toList();

  Future<void> _validarCategoria(Transacao transacao) async {
    final categorias = await LocalCategoriaRepository().buscarCategorias();
    if (!categorias.any((c) => c.id == transacao.categoriaId)) {
      throw Exception('Selecione uma categoria cadastrada.');
    }
  }

  @override
  Future<Transacao> criarTransacao(Transacao transacao) async {
    await _validarCategoria(transacao);
    final items = await LocalStore.read(storageKey);
    final item = {
      ...transacao.toJson(),
      'id': LocalStore.newId(),
      'created_at': transacao.data.toIso8601String()
    };
    await LocalStore.write(storageKey, [item, ...items]);
    return Transacao.fromJson(item);
  }

  @override
  Future<Transacao> atualizarTransacao(Transacao transacao) async {
    await _validarCategoria(transacao);
    final items = await LocalStore.read(storageKey);
    final index = items.indexWhere((item) => item['id'] == transacao.id);
    if (index < 0) throw Exception('Transação não encontrada.');
    items[index] = {...items[index], ...transacao.toJson()};
    await LocalStore.write(storageKey, items);
    return Transacao.fromJson(items[index]);
  }

  @override
  Future<void> excluirTransacao(String id) async {
    final items = await LocalStore.read(storageKey);
    items.removeWhere((item) => item['id'] == id);
    await LocalStore.write(storageKey, items);
  }
}
