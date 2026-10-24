class FakeIds {
  FakeIds._();

  static const layla = '11111111-1111-4111-8111-111111111111';
  static const nader = '22222222-2222-4222-8222-222222222222';
  static const rania = '33333333-3333-4333-8333-333333333333';
  static const publicUser = '44444444-4444-4444-8444-444444444444';
}

/// Bit flags from the API `ForecastingType` enum.
class ForecastingType {
  ForecastingType._();

  static const none = 0;
  static const palm = 1;
  static const coffeeCup = 2;
  static const astrology = 4;
  static const flag8 = 8;
  static const flag16 = 16;
  static const flag32 = 32;
  static const flag64 = 64;
  static const flag128 = 128;

  static const flags = [
    palm,
    coffeeCup,
    astrology,
    flag8,
    flag16,
    flag32,
    flag64,
    flag128,
  ];
}
