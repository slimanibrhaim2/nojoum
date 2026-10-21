import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth.jwt';
  static const _expirationKey = 'auth.expiration';
  static const _onboardedKey = 'auth.isOnboarded';

  final FlutterSecureStorage _storage;
  String? _token;
  DateTime? _expiration;
  bool _isOnboarded = false;
  void Function()? onCleared;

  String? get token => _token;
  DateTime? get expiration => _expiration;
  bool get isOnboarded => _isOnboarded;

  bool get hasValidToken {
    if (_token == null || _token!.isEmpty) return false;
    if (_expiration == null) return true;
    return _expiration!.isAfter(DateTime.now().toUtc());
  }

  Future<void> load() async {
    _token = await _storage.read(key: _tokenKey);
    final rawExpiration = await _storage.read(key: _expirationKey);
    _expiration = rawExpiration == null ? null : DateTime.tryParse(rawExpiration);
    _isOnboarded = await _storage.read(key: _onboardedKey) == 'true';
  }

  Future<void> save({
    required String token,
    DateTime? expiration,
    bool isOnboarded = false,
  }) async {
    _token = token;
    _expiration = expiration?.toUtc();
    _isOnboarded = isOnboarded;
    await _storage.write(key: _tokenKey, value: token);
    if (_expiration != null) {
      await _storage.write(key: _expirationKey, value: _expiration!.toIso8601String());
    }
    await _storage.write(key: _onboardedKey, value: isOnboarded.toString());
  }

  Future<void> clear() async {
    final hadToken = _token != null;
    _token = null;
    _expiration = null;
    _isOnboarded = false;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expirationKey);
    await _storage.delete(key: _onboardedKey);
    if (hadToken) onCleared?.call();
  }
}
