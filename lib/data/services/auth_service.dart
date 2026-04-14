import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../core/logger.dart';
import '../models/auth_model.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthResponse> login(LoginRequest request) async {
    final uri = Uri.https(AppConstants.baseUrl, AppConstants.loginPath);
    AppLogger.info('Sending POST to $uri for email: ${request.email}', 'AuthService');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(request.toJson()),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      AppLogger.success('Login response OK: 200', 'AuthService');
      return AuthResponse.fromJson(body);
    } else if (response.statusCode == 401) {
      AppLogger.warning('Login failed: 401 Unauthorized', 'AuthService');
      throw Exception(body['message'] ?? 'Email atau password salah');
    } else {
      AppLogger.error('Login error with status: ${response.statusCode}', error: body, name: 'AuthService');
      throw Exception(body['message'] ?? 'Login gagal');
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final uri = Uri.https(AppConstants.baseUrl, AppConstants.registerPath);
    AppLogger.info('Sending POST to $uri for full_name: ${request.fullName}', 'AuthService');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(request.toJson()),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppLogger.success('Register response OK: ${response.statusCode}', 'AuthService');
      return AuthResponse.fromJson(body);
    } else {
      AppLogger.error('Register error with status: ${response.statusCode}', error: body, name: 'AuthService');
      throw Exception(body['message'] ?? 'Registrasi gagal');
    }
  }
}
