import '../../../core/mock/fake_ids.dart';
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

    if (password == 'wrong') {
      throw Exception('invalidCredentials');
    }

    final isForecaster = email.toLowerCase().contains('fore');

    _current = User(
      id: isForecaster ? FakeIds.layla : FakeIds.publicUser,
      email: email,
      fullName: isForecaster ? 'ليلى النجمي' : 'سامي القارئ',
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