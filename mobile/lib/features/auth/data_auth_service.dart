import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  static Future<void> login(String email, String password) => _authenticate(
    '/login',
    {'username': email, 'password': password},
    form: true,
  );
  static Future<void> signup(String email, String password) =>
      _authenticate('/signup', {'email': email, 'password': password});
  static Future<void> _authenticate(
    String path,
    Map<String, String> body, {
    bool form = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': form
            ? 'application/x-www-form-urlencoded'
            : 'application/json',
      },
      body: form ? body : jsonEncode(body),
    );
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['detail'] ?? 'Connexion impossible');
    }
    await _storage.write(key: 'jwt', value: data['access_token'] as String);
  }

  static Future<String?> token() => _storage.read(key: 'jwt');
  static Future<void> logout() => _storage.delete(key: 'jwt');
}
