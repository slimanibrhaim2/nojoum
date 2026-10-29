class Prediction {
  const Prediction({
    required this.id,
    required this.forecasterId,
    required this.forecasterName,
    this.forecasterImageUrl,
    this.forecasterAverageRate = 0,
    required this.date,
    required this.summary,
    this.details,
    this.resolvedMediaUrl,
    this.zodiacSign = 0,
    required this.viewCount,
    required this.likeCount,
    required this.dislikeCount,
    required this.sharingCount,
    this.isLikedByCurrentUser = false,
    this.isDislikedByCurrentUser = false,
  });

  final String id;
  final String forecasterId;
  final String forecasterName;
  final String? forecasterImageUrl;
  final double forecasterAverageRate;
  final DateTime date;
  final String summary;
  final String? details;
  final String? resolvedMediaUrl;
  final int zodiacSign;
  final int viewCount;
  final int likeCount;
  final int dislikeCount;
  final int sharingCount;
  final bool isLikedByCurrentUser;
  final bool isDislikedByCurrentUser;

  factory Prediction.fromJson(
    Map<String, dynamic> json, {
    required String languageCode,
  }) {
    final localizations = json['localizations'];
    Map<String, dynamic>? picked;
    if (localizations is List) {
      final maps = localizations
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      for (final item in maps) {
        final code = (item['languageCode'] as String?)?.toLowerCase();
        if (code == languageCode.toLowerCase()) {
          picked = item;
          break;
        }
      }
      picked ??= maps.isEmpty ? null : maps.first;
    }

    final dateRaw = json['date']?.toString();
    final createdRaw = json['createdAt']?.toString();
    final date = DateTime.tryParse(dateRaw ?? '') ??
        DateTime.tryParse(createdRaw ?? '') ??
        DateTime.now();

    return Prediction(
      id: (json['id'] ?? '').toString(),
      forecasterId: (json['forecasterId'] ?? '').toString(),
      forecasterName: (json['forecasterName'] as String?)?.trim() ?? '',
      forecasterImageUrl: json['forecasterImagePath'] as String?,
      forecasterAverageRate: (json['forecasterAverageRate'] as num?)?.toDouble() ??
          0,
      date: date,
      summary: picked?['summary'] as String? ?? '',
      details: picked?['details'] as String?,
      zodiacSign: json['zodiacSign'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      dislikeCount: json['dislikeCount'] as int? ?? 0,
      sharingCount: json['sharingCount'] as int? ?? 0,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool? ?? false,
      isDislikedByCurrentUser: json['isDislikedByCurrentUser'] as bool? ?? false,
    );
  }

  Prediction copyWith({
    int? viewCount,
    int? likeCount,
    int? dislikeCount,
    int? sharingCount,
    String? summary,
    String? details,
    bool? isLikedByCurrentUser,
    bool? isDislikedByCurrentUser,
  }) {
    return Prediction(
      id: id,
      forecasterId: forecasterId,
      forecasterName: forecasterName,
      forecasterImageUrl: forecasterImageUrl,
      forecasterAverageRate: forecasterAverageRate,
      date: date,
      summary: summary ?? this.summary,
      details: details ?? this.details,
      resolvedMediaUrl: resolvedMediaUrl,
      zodiacSign: zodiacSign,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      sharingCount: sharingCount ?? this.sharingCount,
      isLikedByCurrentUser:
          isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isDislikedByCurrentUser:
          isDislikedByCurrentUser ?? this.isDislikedByCurrentUser,
    );
  }
}
