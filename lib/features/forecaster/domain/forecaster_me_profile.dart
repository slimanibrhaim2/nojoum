import 'money.dart';

class ForecasterMeProfile {
  const ForecasterMeProfile({
    required this.forecasterId,
    required this.fullName,
    required this.email,
    this.imagePath,
    required this.averageRate,
    required this.reviewCount,
    required this.sessionPrice,
    required this.currency,
    required this.type,
    required this.timeZoneId,
    required this.isOnboarded,
    required this.availabilitySettings,
  });

  final String forecasterId;
  final String fullName;
  final String email;
  final String? imagePath;
  final double averageRate;
  final int reviewCount;
  final double sessionPrice;
  final String currency;
  final int type;
  final String timeZoneId;
  final bool isOnboarded;
  final AvailabilitySettings availabilitySettings;

  factory ForecasterMeProfile.fromJson(Map<String, dynamic> json) {
    return ForecasterMeProfile(
      forecasterId: (json['forecasterId'] ?? json['id'] ?? '').toString(),
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      averageRate: (json['averageRate'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      sessionPrice: (json['sessionPrice'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      type: json['type'] as int? ?? 0,
      timeZoneId: json['timeZoneId'] as String? ?? '',
      isOnboarded: json['isOnboarded'] as bool? ?? false,
      availabilitySettings: AvailabilitySettings.fromJson(
        Map<String, dynamic>.from(
          json['availabilitySettings'] as Map? ?? const {},
        ),
      ),
    );
  }

  bool hasType(int flag) => type & flag != 0;

  ForecasterMeProfile copyWith({
    String? fullName,
    String? imagePath,
    double? sessionPrice,
    String? currency,
    int? type,
    String? timeZoneId,
    AvailabilitySettings? availabilitySettings,
  }) {
    return ForecasterMeProfile(
      forecasterId: forecasterId,
      fullName: fullName ?? this.fullName,
      email: email,
      imagePath: imagePath ?? this.imagePath,
      averageRate: averageRate,
      reviewCount: reviewCount,
      sessionPrice: sessionPrice ?? this.sessionPrice,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      isOnboarded: isOnboarded,
      availabilitySettings: availabilitySettings ?? this.availabilitySettings,
    );
  }
}
