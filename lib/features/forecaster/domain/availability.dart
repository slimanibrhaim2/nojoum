class ForecasterAvailability {
  const ForecasterAvailability({
    this.forecasterId,
    this.rules = const [],
    this.overrides = const [],
  });

  final String? forecasterId;
  final List<AvailabilityRule> rules;
  final List<AvailabilityOverride> overrides;

  factory ForecasterAvailability.fromJson(Map<String, dynamic> json) {
    return ForecasterAvailability(
      forecasterId: json['forecasterId']?.toString(),
      rules: _mapList(json['availabilityRules'], AvailabilityRule.fromJson),
      overrides: _mapList(
        json['availabilityOverrides'],
        AvailabilityOverride.fromJson,
      ),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'availabilityRules': rules.map((rule) => rule.toJson()).toList(),
      'availabilityOverrides':
          overrides.map((item) => item.toJson()).toList(),
    };
  }

  static List<T> _mapList<T>(
    dynamic raw,
    T Function(Map<String, dynamic> json) map,
  ) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => map(Map<String, dynamic>.from(item)))
        .toList();
  }
}

class AvailabilityRule {
  const AvailabilityRule({
    this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  final String? id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isActive;

  factory AvailabilityRule.fromJson(Map<String, dynamic> json) {
    return AvailabilityRule(
      id: json['id']?.toString(),
      dayOfWeek: _dayOfWeek(json['dayOfWeek']),
      startTime: _time(json['startTimeLocal'] ?? json['startTime']),
      endTime: _time(json['endTimeLocal'] ?? json['endTime']),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty && id != '00000000-0000-0000-0000-000000000000')
        'id': id,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isActive': isActive,
    };
  }

  AvailabilityRule copyWith({
    String? id,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
  }) {
    return AvailabilityRule(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
    );
  }

  static int _dayOfWeek(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    const names = {
      'sunday': 0,
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
    };
    return names[value?.toString().toLowerCase()] ?? 0;
  }

  static String _time(dynamic value) {
    if (value == null) return '10:00:00';
    final text = value.toString();
    if (text.length >= 8 && text.contains(':')) {
      return text.substring(0, 8);
    }
    if (text.length >= 5) return '${text.substring(0, 5)}:00';
    return '10:00:00';
  }
}

class AvailabilityOverride {
  const AvailabilityOverride({
    this.id,
    required this.dateLocal,
    required this.startTimeLocal,
    required this.endTimeLocal,
  });

  final String? id;
  final String dateLocal;
  final String startTimeLocal;
  final String endTimeLocal;

  factory AvailabilityOverride.fromJson(Map<String, dynamic> json) {
    final start = json['startTimeLocal'] ?? json['startTime'];
    final end = json['endTimeLocal'] ?? json['endTime'];
    final startText = start?.toString() ?? '';
    final parsed = DateTime.tryParse(startText);
    final date = json['dateLocal']?.toString() ??
        (parsed == null
            ? startText.length >= 10
                ? startText.substring(0, 10)
                : ''
            : '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}');
    return AvailabilityOverride(
      id: json['id']?.toString(),
      dateLocal: date,
      startTimeLocal: startText,
      endTimeLocal: end?.toString() ?? startText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'dateLocal': dateLocal,
      'startTimeLocal': startTimeLocal,
      'endTimeLocal': endTimeLocal,
    };
  }
}
