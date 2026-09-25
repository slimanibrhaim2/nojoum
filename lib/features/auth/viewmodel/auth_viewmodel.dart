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
    final results = await Future.wait([
      _repo.currentUser(),
      Future<void>.delayed(const Duration(milliseconds: 5000)),
    ]);
    final existing = results[0] as User?;
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
      _busy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      _busy = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}