class Money {
  const Money({required this.amount, required this.currency});

  final double amount;
  final String currency;

  factory Money.fromJson(Map<String, dynamic> json) => Money(
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'USD',
      );

  String get label => '$amount $currency';
}

class AvailabilitySettings {
  const AvailabilitySettings({
    required this.sessionDurationInMinutes,
    required this.bufferMinutesBetweenSessions,
    required this.minimumNoticeInMinutes,
  });

  final int sessionDurationInMinutes;
  final int bufferMinutesBetweenSessions;
  final int minimumNoticeInMinutes;

  factory AvailabilitySettings.fromJson(Map<String, dynamic> json) {
    return AvailabilitySettings(
      sessionDurationInMinutes: json['sessionDurationInMinutes'] as int? ?? 0,
      bufferMinutesBetweenSessions:
          json['bufferMinutesBetweenSessions'] as int? ?? 0,
      minimumNoticeInMinutes: json['minimumNoticeInMinutes'] as int? ?? 0,
    );
  }
}
