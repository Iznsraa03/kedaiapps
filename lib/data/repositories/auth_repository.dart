import '../../core/logger.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    AppLogger.info('login() called', 'AuthRepository');
    final request = LoginRequest(email: email, password: password);
    final response = await _authService.login(request);
    AppLogger.success('login() successful', 'AuthRepository');
    return response;
  }

  Future<AuthResponse> register({
    required String email,
    required String fullName,
    required String password,
    String? nra,
  }) async {
    AppLogger.info('register() called', 'AuthRepository');
    final request = RegisterRequest(
      email: email,
      fullName: fullName,
      password: password,
      nra: nra,
    );
    final response = await _authService.register(request);
    AppLogger.success('register() successful', 'AuthRepository');
    return response;
  }
}
