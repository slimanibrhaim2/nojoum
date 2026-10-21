import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/api_routes.dart';
import '../domain/forecaster.dart';
import '../domain/money.dart';
import 'forecaster_repository.dart';

class ForecasterRepositoryApi implements ForecasterRepository {
  ForecasterRepositoryApi(this._api);

  final ApiClient _api;

  @override
  Future<List<ForecasterPublicProfile>> listPublicProfiles() async {
    final value = await _api.get(
      ApiRoutes.forecasters,
      queryParameters: {'PageNumber': 1, 'PageSize': AppConfig.defaultPageSize},
    );
    final items = value is List ? value : const [];
    return items
        .whereType<Map>()
        .map((item) => _profileFromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<ForecasterPublicProfile> getPublicProfile(String id) async {
    final value = await _api.get(ApiRoutes.forecaster(id));
    if (value is! Map) {
      throw const ApiException('Forecaster not found');
    }
    return _profileFromJson(Map<String, dynamic>.from(value));
  }

  @override
  Future<ForecasterDashboard> getMyDashboard(String forecasterId) async {
    final value = await _api.get(ApiRoutes.me);
    if (value is! Map) {
      throw const ApiException('Dashboard was empty');
    }
    final json = Map<String, dynamic>.from(value);
    return ForecasterDashboard(
      id: (json['forecasterId'] ?? forecasterId).toString(),
      totalPredictions: json['totalPredictions'] as int? ?? 0,
      averageRate: (json['averageRate'] as num?)?.round() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      bookings: const [],
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
    );
  }

  ForecasterPublicProfile _profileFromJson(Map<String, dynamic> json) {
    final amount = (json['sessionPrice'] as num?)?.toDouble() ??
        (json['money'] is Map
            ? ((json['money'] as Map)['amount'] as num?)?.toDouble()
            : null) ??
        0;
    final currency = json['currency'] as String? ??
        (json['money'] is Map ? (json['money'] as Map)['currency'] as String? : null) ??
        'USD';
    return ForecasterPublicProfile(
      id: (json['forecasterId'] ?? json['id']).toString(),
      name: (json['fullName'] ?? json['name'] ?? '') as String,
      imagePath: json['imagePath'] as String?,
      averageRate: (json['averageRate'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      money: Money(amount: amount, currency: currency),
      type: json['type'] as int? ?? 0,
      availabilitySettings: AvailabilitySettings.fromJson(
        Map<String, dynamic>.from(
          json['availabilitySettings'] as Map? ?? const {},
        ),
      ),
    );
  }
}
