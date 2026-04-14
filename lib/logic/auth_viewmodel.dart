import 'package:flutter/material.dart';
import '../core/logger.dart';
import '../data/models/auth_model.dart';
import '../data/repositories/auth_repository.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  AuthResponse? _lastResponse;
  UserModel? _currentUser;

  AuthViewModel({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AuthResponse? get lastResponse => _lastResponse;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login({required String email, required String password}) async {
    AppLogger.info('login() called', 'AuthViewModel');
    _setLoading();

    try {
      _lastResponse = await _repository.login(email: email, password: password);
      _currentUser = _lastResponse?.user;
      _status = AuthStatus.success;
      _errorMessage = null;
      AppLogger.success('Login success, notifying listeners', 'AuthViewModel');
      notifyListeners();
      return true;
    } catch (e, st) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      AppLogger.error('Login failed: $_errorMessage', error: e, stackTrace: st, name: 'AuthViewModel');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String fullName,
    required String password,
    String? nra,
  }) async {
    AppLogger.info('register() called', 'AuthViewModel');
    _setLoading();

    try {
      _lastResponse = await _repository.register(
        email: email,
        fullName: fullName,
        password: password,
        nra: nra,
      );
      _status = AuthStatus.success;
      _errorMessage = null;
      AppLogger.success('Register success, notifying listeners', 'AuthViewModel');
      notifyListeners();
      return true;
    } catch (e, st) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      AppLogger.error('Register failed: $_errorMessage', error: e, stackTrace: st, name: 'AuthViewModel');
      notifyListeners();
      return false;
    }
  }

  void reset() {
    AppLogger.info('State reset', 'AuthViewModel');
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    AppLogger.info('logout() called, clearing user state', 'AuthViewModel');
    _currentUser = null;
    _lastResponse = null;
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    AppLogger.info('State set to loading', 'AuthViewModel');
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }
}
