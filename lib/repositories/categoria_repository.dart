import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';
import '../models/categoria.dart';

class CategoriaRepository {
  final String accessToken;
  final http.Client? _client;

  CategoriaRepository({required this.accessToken, http.Client? client})
      : _client = client;

  Map<String, String> get _headers => {
        'apikey': SupabaseConfig.publishableKey,
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  Future<List<Categoria>> buscarCategorias() async {
    final uri = Uri.parse('${SupabaseConfig.url}/rest/v1/categorias')
        .replace(queryParameters: {'select': 'id,nome', 'order': 'nome.asc'});
    final response = await (_client?.get(uri, headers: _headers) ??
        http.get(uri, headers: _headers));
    if (response.statusCode != 200) {
      throw Exception(
          'Não foi possível carregar as categorias. Tente novamente.');
    }
    return (jsonDecode(response.body) as List)
        .map((item) => Categoria.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Categoria> criarCategoria(String nome) async {
    final uri = Uri.parse('${SupabaseConfig.url}/rest/v1/categorias');
    final body = jsonEncode({'nome': nome.trim()});
    final response = await (_client?.post(uri, headers: _headers, body: body) ??
        http.post(uri, headers: _headers, body: body));
    if (response.statusCode == 409) {
      throw Exception('Já existe uma categoria com esse nome.');
    }
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Não foi possível salvar a categoria. Tente novamente.');
    }
    return Categoria.fromJson((jsonDecode(response.body) as List).first);
  }
}
