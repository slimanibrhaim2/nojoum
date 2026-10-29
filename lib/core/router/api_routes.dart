/// Backend HTTP paths. These are not app screens.
/// Screen paths live in [AppRoutes].
class ApiRoutes {
  ApiRoutes._();

  static const String login = '/api/v1/forecasters/login';
  static const String me = '/api/v1/forecasters/me';
  static const String meAvailability = '/api/v1/forecasters/me/availability';
  static const String forecasters = '/api/v1/forecasters';
  static const String predictions = '/api/v1/predictions';

  static String forecaster(String id) => '$forecasters/$id';
  static String prediction(String id) => '$predictions/$id';
  static String predictionLike(String id) => '$predictions/$id/like';
  static String predictionDislike(String id) => '$predictions/$id/dislike';
  static String predictionSeen(String id) => '$predictions/$id/seen';
  static String predictionShare(String id) => '$predictions/$id/share';
}
