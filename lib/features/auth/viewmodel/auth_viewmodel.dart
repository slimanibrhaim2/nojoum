import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../domain/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo);

  final AuthRepository _repo;

  AuthStatus _status = AuthStatus.unknown;
  User? _currentUser;
  String? _error;
  bool _busy = false;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get error => _error;
  bool get busy => _busy;
  bool get isLoggedIn => _currentUser != null;
  bool get isForecaster => _currentUser?.role == UserRole.forecaster;

  Future<void> init() async {
    final existing = await _repo.currentUser();
    _currentUser = existing;
    _status = existing == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _repo.login(email: email, password: password);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}