class FakeIds {
  FakeIds._();

  static const layla = '11111111-1111-4111-8111-111111111111';
  static const nader = '22222222-2222-4222-8222-222222222222';
  static const rania = '33333333-3333-4333-8333-333333333333';
  static const publicUser = '44444444-4444-4444-8444-444444444444';
}

/// Bit flags matching backend `Forcasting.Shared.ForecastingType`.
class ForecastingType {
  ForecastingType._();

  static const notSpecified = 0;
  static const westernAstrology = 1 << 0; // 1
  static const vedicAstrology = 1 << 1; // 2
  static const chineseAstrology = 1 << 2; // 4
  static const tarotReading = 1 << 3; // 8
  static const numerology = 1 << 4; // 16
  static const palmistry = 1 << 5; // 32
  static const mediumship = 1 << 6; // 64
  static const clairvoyance = 1 << 7; // 128

  /// Legacy aliases used by older UI code.
  static const palm = palmistry;
  static const coffeeCup = vedicAstrology;
  static const astrology = westernAstrology;

  static const flags = [
    westernAstrology,
    vedicAstrology,
    chineseAstrology,
    tarotReading,
    numerology,
    palmistry,
    mediumship,
    clairvoyance,
  ];

  static List<int> activeFlags(int type) =>
      flags.where((flag) => type & flag != 0).toList();
}
