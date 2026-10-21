/// Backend HTTP paths. These are not app screens.
/// Screen paths live in [AppRoutes].
class ApiRoutes {
  ApiRoutes._();

  static const String login = '/api/v1/forecasters/login';
  static const String me = '/api/v1/forecasters/me';
  static const String forecasters = '/api/v1/forecasters';

  static String forecaster(String id) => '$forecasters/$id';
}
