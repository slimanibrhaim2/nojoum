import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/api_routes.dart';
import '../domain/availability.dart';
import '../domain/forecaster.dart';
import '../domain/forecaster_me_profile.dart';
import '../domain/forecaster_profile_update.dart';
import 'forecaster_repository.dart';

class ForecasterRepositoryApi implements ForecasterRepository {
  ForecasterRepositoryApi(this._api);

  final ApiClient _api;

  @override
  Future<List<ForecasterPublicProfile>> listPublicProfiles() async {
    final value = await _api.get(
      ApiRoutes.forecasters,
      queryParameters: {
        'PageNumber': 1,
        'PageSize': AppConfig.defaultPageSize,
      },
    );
    final items = value is List ? value : const [];
    return items
        .whereType<Map>()
        .map(
          (item) =>
              ForecasterPublicProfile.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<ForecasterPublicProfile> getPublicProfile(String id) async {
    final value = await _api.get(ApiRoutes.forecaster(id));
    if (value is! Map) {
      throw const ApiException('Forecaster not found');
    }
    return ForecasterPublicProfile.fromJson(Map<String, dynamic>.from(value));
  }

  @override
  Future<ForecasterMeProfile> getMe() async {
    final value = await _api.get(ApiRoutes.me);
    if (value is! Map) {
      throw const ApiException('Profile was empty');
    }
    return ForecasterMeProfile.fromJson(Map<String, dynamic>.from(value));
  }

  @override
  Future<ForecasterMeProfile> updateMe(ForecasterProfileUpdate update) async {
    final map = <String, dynamic>{
      'FullName': update.fullName,
      'SessionPrice': update.sessionPrice.toString(),
      'Currency': update.currency,
      'Type': update.type.toString(),
      'SessionDurationInMinutes': update.sessionDurationInMinutes.toString(),
      'BufferMinutesBetweenSessions':
          update.bufferMinutesBetweenSessions.toString(),
      'MinimumNoticeInMinutes': update.minimumNoticeInMinutes.toString(),
      'TimeZoneId': update.timeZoneId,
    };
    if (update.imageFilePath != null && update.imageFilePath!.isNotEmpty) {
      final name = update.imageFilePath!.split(RegExp(r'[\\/]')).last;
      map['ImageFile'] = await MultipartFile.fromFile(
        update.imageFilePath!,
        filename: name,
      );
    }
    await _api.putForm(ApiRoutes.me, FormData.fromMap(map));
    return getMe();
  }

  @override
  Future<ForecasterAvailability> getAvailability() async {
    final value = await _api.get(ApiRoutes.meAvailability);
    if (value is! Map) {
      throw const ApiException('Availability was empty');
    }
    return ForecasterAvailability.fromJson(Map<String, dynamic>.from(value));
  }

  @override
  Future<ForecasterAvailability> updateAvailability(
    ForecasterAvailability update,
  ) async {
    final value = await _api.put(
      ApiRoutes.meAvailability,
      data: update.toUpdateJson(),
    );
    if (value is Map) {
      return ForecasterAvailability.fromJson(Map<String, dynamic>.from(value));
    }
    return getAvailability();
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

}
