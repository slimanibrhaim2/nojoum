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
  String get forecasterLoginTip => 'سجّل الدخول بحساب المنجّم من الـ API.';

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

  @override
  String get navForecasters => 'المنجمين';

  @override
  String get forecastingProfile => 'ملف التنجيم';

  @override
  String get timeZone => 'المنطقة الزمنية';

  @override
  String get sessionPrice => 'سعر الجلسة';

  @override
  String get sessionDuration => 'مدة الجلسة';

  @override
  String get bufferMinutes => 'فاصل بين الجلسات';

  @override
  String get minimumNotice => 'حد أدنى للإشعار';

  @override
  String get onboarded => 'اكتمل الإعداد';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String minutesValue(int minutes) {
    return '$minutes د';
  }

  @override
  String get edit => 'تعديل';

  @override
  String get cancel => 'إلغاء';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get currency => 'العملة';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get forecastingType => 'نوع التنجيم';

  @override
  String get profileSaved => 'تم تحديث الملف';

  @override
  String get availability => 'أوقات التوفر';

  @override
  String get availabilityHint =>
      'اختر الأيام والساعات التي يمكنك استقبال الجلسات فيها.';

  @override
  String get availabilitySaved => 'تم تحديث أوقات التوفر';

  @override
  String get noAvailability =>
      'لا توجد ساعات أسبوعية بعد. اضغط تعديل لإضافتها.';

  @override
  String get startTime => 'من';

  @override
  String get endTime => 'إلى';

  @override
  String get applyHours => 'استخدم هذه الساعات لكل يوم محدد';

  @override
  String get hourLabel => 'الساعة';

  @override
  String get minuteLabel => 'الدقائق';

  @override
  String forecastingTypeCode(int value) {
    return 'النوع $value';
  }
}
