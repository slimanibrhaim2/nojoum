class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String publicHome = '/home';
  static const String forecasterDashboard = '/dashboard';
  static const String settings = '/settings';
  static const String forecasters = '/forecasters';
  static const String predictions = '/predictions';

  static String prediction(String id) => '$predictions/$id';
}
