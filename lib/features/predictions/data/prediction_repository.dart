import '../domain/prediction.dart';

abstract class PredictionRepository {
  Future<List<Prediction>> list({
    String? forecasterId,
    required String languageCode,
    int page = 1,
    int pageSize = 20,
  });

  Future<Prediction> getById(String id, {required String languageCode});

  /// Toggles like. Returns the updated like count from the server.
  Future<int> like(String id);

  /// Toggles dislike. Returns the updated dislike count from the server.
  Future<int> dislike(String id);

  Future<void> view(String id);
  Future<void> share(String id);
}
