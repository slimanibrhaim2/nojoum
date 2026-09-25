import '../domain/user.dart';
import 'auth_repository.dart';

class AuthRepositoryMock implements AuthRepository {
  User? _current;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Any password works except "wrong" — lets us test the error path.
    if (password == 'wrong') {
      throw Exception('invalidCredentials');
    }

    // Role is decided by email: contains "fore" → forecaster.
    final isForecaster = email.toLowerCase().contains('fore');

    _current = User(
      id: isForecaster ? 'f-001' : 'u-001',
      email: email,
      fullName: isForecaster ? 'Test Forecaster' : 'Test Public User',
      role: isForecaster ? UserRole.forecaster : UserRole.publicUser,
    );
    return _current!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _current = null;
  }

  @override
  Future<User?> currentUser() async => _current;
}