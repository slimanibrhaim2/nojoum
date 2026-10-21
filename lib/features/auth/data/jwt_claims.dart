import 'dart:convert';

class JwtClaims {
  const JwtClaims(this.raw);

  final Map<String, dynamic> raw;

  static JwtClaims decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid token');
    }
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final json = jsonDecode(payload);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid token payload');
    }
    return JwtClaims(json);
  }

  String? operator [](String key) {
    final value = raw[key];
    return value?.toString();
  }

  String? first(List<String> keys) {
    for (final key in keys) {
      final value = this[key];
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String get subject =>
      first(const ['Sub', 'sub', 'nameid']) ?? '';

  String get email => first(const ['Email', 'email']) ?? '';

  String? get forecasterId => first(const ['ForecasterId', 'forecasterId']);

  String get roles => first(const ['Roles', 'role', 'roles']) ?? '';
}
