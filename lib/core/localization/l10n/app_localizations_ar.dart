// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'نجوم';

  @override
  String get welcomeBack => 'أهلاً بعودتك';

  @override
  String get signInToContinue => 'سجّل الدخول للمتابعة';

  @override
  String get switchToArabic => 'العربية';

  @override
  String get switchToEnglish => 'English';

  @override
  String get splashTagline => 'نجوم، كف، وفنجان';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get invalidEmail => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get passwordTooShort => 'كلمة المرور قصيرة جداً';

  @override
  String get invalidCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String forecasterLoginTip(String email) {
    return 'للتجربة: استخدم $email للدخول كمنجّم';
  }

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navExplore => 'استكشاف';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get comingSoonMessage => 'هذه الصفحة جاهزة للميزة التالية.';

  @override
  String get homeEmptyTitle => 'توقعات اليوم';

  @override
  String get homeEmptyMessage => 'سيظهر هنا موجز التوقعات للعامة.';

  @override
  String get account => 'الحساب';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String loggedInAs(String name) {
    return 'مسجّل الدخول باسم $name';
  }

  @override
  String get guestAccountHint => 'سجّل الدخول للإعجاب بالتوقعات وحجز الجلسات.';

  @override
  String get exploreMessage => 'تعرّف إلى منجّمي نجوم.';

  @override
  String get likes => 'إعجابات';

  @override
  String get reviews => 'التقييمات';

  @override
  String get rating => 'النجوم';

  @override
  String get totalPredictions => 'التوقعات';

  @override
  String get noBookings => 'لا حجوزات بعد. ستظهر هنا من لوحة /me.';

  @override
  String get typePalm => 'قراءة الكف';

  @override
  String get typeCoffee => 'الفنجان';

  @override
  String get typeAstrology => 'النجوم';

  @override
  String sessionMinutes(int minutes) {
    return 'جلسة $minutes دقيقة';
  }
}
