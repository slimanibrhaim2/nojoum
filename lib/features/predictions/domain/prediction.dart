class Prediction {
  const Prediction({
    required this.id,
    required this.forecasterId,
    required this.forecasterName,
    this.forecasterImageUrl,
    required this.forecasterAverageRate,
    required this.date,
    required this.summary,
    this.details,
    this.resolvedMediaUrl,
    required this.viewCount,
    required this.likeCount,
    required this.dislikeCount,
    required this.sharingCount,
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
  final int viewCount;
  final int likeCount;
  final int dislikeCount;
  final int sharingCount;

  Prediction copyWith({
    int? viewCount,
    int? likeCount,
    int? sharingCount,
    String? summary,
    String? details,
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
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount,
      sharingCount: sharingCount ?? this.sharingCount,
    );
  }
}
