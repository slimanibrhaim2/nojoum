import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_storage.dart';
import '../../../core/router/api_routes.dart';
import '../domain/user.dart';
import 'auth_repository.dart';
import 'jwt_claims.dart';

class AuthRepositoryApi implements AuthRepository {
  AuthRepositoryApi(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final value = await _api.post(
      ApiRoutes.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    if (value is! Map) {
      throw const ApiException('Unexpected login response');
    }
    final token = value['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ApiException('Login did not return a token');
    }
    final expiration = DateTime.tryParse(value['expiration'] as String? ?? '');
    final isOnboarded = value['isOnboarded'] as bool? ?? false;
    await _tokens.save(
      token: token,
      expiration: expiration,
      isOnboarded: isOnboarded,
    );
    return await _userFromSession(
      emailFallback: email,
      isOnboarded: isOnboarded,
    );
  }

  @override
  Future<void> logout() => _tokens.clear();

  @override
  Future<User?> currentUser() async {
    await _tokens.load();
    if (!_tokens.hasValidToken) {
      await _tokens.clear();
      return null;
    }
    return await _userFromSession(isOnboarded: _tokens.isOnboarded);
  }

  Future<User> _userFromSession({
    String? emailFallback,
    required bool isOnboarded,
  }) async {
    final token = _tokens.token;
    if (token == null) {
      throw const ApiException('Missing token');
    }
    final claims = JwtClaims.decode(token);
    final email = claims.email.isEmpty ? (emailFallback ?? '') : claims.email;
    var fullName = _nameFromEmail(email);
    try {
      final me = await _api.get(ApiRoutes.me);
      if (me is Map && me['fullName'] is String && (me['fullName'] as String).isNotEmpty) {
        fullName = me['fullName'] as String;
      }
    } catch (_) {
      // JWT claims are enough to stay signed in if /me is unavailable.
    }
    return User(
      id: claims.forecasterId ?? claims.subject,
      email: email,
      fullName: fullName,
      role: UserRole.fromString(claims.roles),
      isOnboarded: isOnboarded,
    );
  }

  static String _nameFromEmail(String email) {
    if (email.isEmpty) return '';
    final local = email.split('@').first;
    return local
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
