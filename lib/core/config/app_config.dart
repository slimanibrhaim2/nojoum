class AppConfig{
  AppConfig._();
  static const String baseUrl = 'http://localhost:5000';
  /// Base URL for the API.
  /// For Android emulator use http://10.0.2.2:PORT
  /// For iOS simulator / web  use http://localhost:PORT

  /// Prefix used to build full media URLs.
  /// If backend returns "/uploads/foo.jpg", we prepend this.
  static const String mediaBaseUrl = 'http://localhost:5000';

  /// Default pagination size.
  static const int defaultPageSize = 20;

  /// Breakpoint for "large screen" (web/tablet) layout.
  static const double tabletBreakpoint = 600;
}