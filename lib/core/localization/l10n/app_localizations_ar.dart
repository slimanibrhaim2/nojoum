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
}
