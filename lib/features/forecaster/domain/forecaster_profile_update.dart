class ForecasterProfileUpdate {
  const ForecasterProfileUpdate({
    required this.fullName,
    required this.sessionPrice,
    required this.currency,
    required this.type,
    required this.sessionDurationInMinutes,
    required this.bufferMinutesBetweenSessions,
    required this.minimumNoticeInMinutes,
    required this.timeZoneId,
    this.imageFilePath,
  });

  final String fullName;
  final double sessionPrice;
  final String currency;
  final int type;
  final int sessionDurationInMinutes;
  final int bufferMinutesBetweenSessions;
  final int minimumNoticeInMinutes;
  final String timeZoneId;
  final String? imageFilePath;
}
