import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// Set true to keep the local fake repositories.
  static const bool useMockApi = false;

  static const int apiPort = 5136;

  /// Windows / macOS / web / iOS simulator.
  static const String localhostUrl = 'http://localhost:$apiPort';

  /// Android emulator loopback to the host machine.
  static const String androidEmulatorUrl = 'http://10.0.2.2:$apiPort';

  /// Your PC Wi-Fi IPv4. A real phone cannot use localhost.
  /// Update this if `ipconfig` shows a new address.
  /// Override at run time: `--dart-define=API_BASE_URL=http://192.168.x.x:5136`
  static const String lanUrl = 'http://10.12.89.92:$apiPort';

  static const int defaultPageSize = 20;
  static const double tabletBreakpoint = 600;

  /// Public web base used in share links.
  static const String webSiteUrl = 'https://nojoum.com';

  static String predictionShareUrl(String id) =>
      '$webSiteUrl/predictions/$id';

  /// Turns an API `imagePath` into a URL the phone can request.
  /// Keep storing `/uploads/profiles/file.jpg` on the server — never a disk path.
  static String mediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    var normalized = path.trim().replaceAll('\\', '/');
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }
    final uploadsAt = normalized.toLowerCase().indexOf('/uploads/');
    if (uploadsAt >= 0) {
      normalized = normalized.substring(uploadsAt);
    } else if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }
    final origin = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$origin$normalized';
  }

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) return localhostUrl;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return lanUrl;
      default:
        return localhostUrl;
    }
  }
}
