import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../config/supabase_config.dart';

class AuthRepository {
  static const String _baseUrl = '${SupabaseConfig.url}/auth/v1';
  static const String _publishableKey = SupabaseConfig.publishableKey;

  Map<String, String> get _headers => {
        'apikey': _publishableKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };

  Future<void> cadastrar({required String email, required String senha}) async {
    final response = await http.post(Uri.parse('$_baseUrl/signup'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': senha}));

    if (response.statusCode != 200) {
      final erro = jsonDecode(response.body);
      throw Exception(erro['msg'] ?? 'Erro ao realizar o cadastro.');
    }
  }

  Future<Usuario> login({required String email, required String senha}) async {
    final response = await http.post(
        Uri.parse('$_baseUrl/token?grant_type=password'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': senha}));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Usuario.fromJson(data);
    } else {
      throw Exception(
          data['error_description'] ?? 'Falha ao realizar o login.');
    }
  }
}
