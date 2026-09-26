import '../domain/prediction.dart';

abstract class PredictionRepository {
  Future<List<Prediction>> list({
    String? forecasterId,
    required String languageCode,
    int page = 1,
    int pageSize = 20,
  });

  Future<Prediction> getById(String id, {required String languageCode});

  Future<void> like(String id);
  Future<void> view(String id);
  Future<void> share(String id);
}
