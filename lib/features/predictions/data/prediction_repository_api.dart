import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/api_routes.dart';
import '../domain/prediction.dart';
import 'prediction_repository.dart';

class PredictionRepositoryApi implements PredictionRepository {
  PredictionRepositoryApi(this._api);

  final ApiClient _api;

  Prediction _map(Map<String, dynamic> json, String languageCode) {
    final prediction = Prediction.fromJson(json, languageCode: languageCode);
    return Prediction(
      id: prediction.id,
      forecasterId: prediction.forecasterId,
      forecasterName: prediction.forecasterName,
      forecasterImageUrl: AppConfig.mediaUrl(prediction.forecasterImageUrl),
      forecasterAverageRate: prediction.forecasterAverageRate,
      date: prediction.date,
      summary: prediction.summary,
      details: prediction.details,
      resolvedMediaUrl: prediction.resolvedMediaUrl,
      zodiacSign: prediction.zodiacSign,
      viewCount: prediction.viewCount,
      likeCount: prediction.likeCount,
      dislikeCount: prediction.dislikeCount,
      sharingCount: prediction.sharingCount,
      isLikedByCurrentUser: prediction.isLikedByCurrentUser,
      isDislikedByCurrentUser: prediction.isDislikedByCurrentUser,
    );
  }

  @override
  Future<List<Prediction>> list({
    String? forecasterId,
    required String languageCode,
    int page = 1,
    int pageSize = 20,
  }) async {
    final value = await _api.get(
      ApiRoutes.predictions,
      queryParameters: {
        if (forecasterId != null && forecasterId.isNotEmpty)
          'ForecasterId': forecasterId,
        'LanguageCode': languageCode,
        'PageNumber': page,
        'PageSize': pageSize > 0 ? pageSize : AppConfig.defaultPageSize,
      },
    );
    final items = value is List ? value : const [];
    return items
        .whereType<Map>()
        .map(
          (item) => _map(Map<String, dynamic>.from(item), languageCode),
        )
        .toList();
  }

  @override
  Future<Prediction> getById(String id, {required String languageCode}) async {
    final value = await _api.get(ApiRoutes.prediction(id));
    if (value is! Map) {
      throw const ApiException('Prediction was empty');
    }
    return _map(Map<String, dynamic>.from(value), languageCode);
  }

  int _newCount(dynamic value) {
    if (value is Map) {
      final count = value['newCount'];
      if (count is num) return count.toInt();
    }
    throw const ApiException('Engagement response was empty');
  }

  @override
  Future<int> like(String id) async {
    return _newCount(await _api.post(ApiRoutes.predictionLike(id)));
  }

  @override
  Future<int> dislike(String id) async {
    return _newCount(await _api.post(ApiRoutes.predictionDislike(id)));
  }

  @override
  Future<void> view(String id) async {
    await _api.post(ApiRoutes.predictionSeen(id));
  }

  @override
  Future<void> share(String id) async {
    await _api.post(ApiRoutes.predictionShare(id));
  }
}
