/// Matches backend `Forcasting.Shared.ZodiacSign` enum order.
enum ZodiacSign {
  aries(0),
  taurus(1),
  gemini(2),
  cancer(3),
  leo(4),
  virgo(5),
  libra(6),
  scorpio(7),
  sagittarius(8),
  capricorn(9),
  aquarius(10),
  pisces(11);

  const ZodiacSign(this.value);

  final int value;

  static const _symbols = [
    '♈',
    '♉',
    '♊',
    '♋',
    '♌',
    '♍',
    '♎',
    '♏',
    '♐',
    '♑',
    '♒',
    '♓',
  ];

  static const _en = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  static const _ar = [
    'الحمل',
    'الثور',
    'الجوزاء',
    'السرطان',
    'الأسد',
    'العذراء',
    'الميزان',
    'العقرب',
    'القوس',
    'الجدي',
    'الدلو',
    'الحوت',
  ];

  String get symbol => _symbols[value];

  String label(String languageCode) =>
      languageCode.toLowerCase().startsWith('ar') ? _ar[value] : _en[value];

  String display(String languageCode) => '$symbol ${label(languageCode)}';

  static ZodiacSign? tryParse(Object? raw) {
    if (raw is int) {
      if (raw < 0 || raw > 11) return null;
      return ZodiacSign.values[raw];
    }
    if (raw is num) {
      final value = raw.toInt();
      if (value < 0 || value > 11) return null;
      return ZodiacSign.values[value];
    }
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;
      final asInt = int.tryParse(trimmed);
      if (asInt != null) return tryParse(asInt);
      final lower = trimmed.toLowerCase();
      for (final sign in ZodiacSign.values) {
        if (sign.name == lower || _en[sign.value].toLowerCase() == lower) {
          return sign;
        }
      }
    }
    return null;
  }

  static ZodiacSign from(Object? raw) =>
      tryParse(raw) ?? ZodiacSign.aries;
}
