import 'money.dart';

class ForecasterPublicProfile {
  const ForecasterPublicProfile({
    required this.id,
    required this.name,
    this.imagePath,
    required this.averageRate,
    required this.reviewCount,
    required this.money,
    required this.type,
    required this.availabilitySettings,
  });

  final String id;
  final String name;
  final String? imagePath;
  final double averageRate;
  final int reviewCount;
  final Money money;
  final int type;
  final AvailabilitySettings availabilitySettings;

  factory ForecasterPublicProfile.fromJson(Map<String, dynamic> json) {
    final amount = (json['sessionPrice'] as num?)?.toDouble() ??
        (json['money'] is Map
            ? ((json['money'] as Map)['amount'] as num?)?.toDouble()
            : null) ??
        0;
    final currency = json['currency'] as String? ??
        (json['money'] is Map
            ? (json['money'] as Map)['currency'] as String?
            : null) ??
        'USD';

    return ForecasterPublicProfile(
      id: (json['forecasterId'] ?? json['id'] ?? '').toString(),
      name: ((json['fullName'] ?? json['name'] ?? '') as String).trim(),
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

  bool hasType(int flag) => type & flag != 0;
}

class ForecasterDashboard {
  const ForecasterDashboard({
    required this.id,
    required this.totalPredictions,
    required this.averageRate,
    required this.reviewCount,
    required this.bookings,
    this.email,
    this.fullName,
  });

  final String id;
  final int totalPredictions;
  final int averageRate;
  final int reviewCount;
  final List<Object> bookings;
  final String? email;
  final String? fullName;

  factory ForecasterDashboard.fromJson(Map<String, dynamic> json) {
    return ForecasterDashboard(
      id: (json['forecasterId'] ?? json['id'] ?? '').toString(),
      totalPredictions: json['totalPredictions'] as int? ?? 0,
      averageRate: (json['averageRate'] as num?)?.round() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      bookings: json['bookings'] as List<Object>? ?? const [],
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
    );
  }
}
