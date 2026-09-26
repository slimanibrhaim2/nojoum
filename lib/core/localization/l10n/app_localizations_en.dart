// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nojoum';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get switchToArabic => 'العربية';

  @override
  String get switchToEnglish => 'English';

  @override
  String get splashTagline => 'Stars, palms, and the cup';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Log in';

  @override
  String get logout => 'Log out';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get passwordTooShort => 'Password is too short';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String forecasterLoginTip(String email) {
    return 'Tip: use $email to log in as a forecaster';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navSettings => 'Settings';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonMessage => 'This page is ready for the next feature.';

  @override
  String get homeEmptyTitle => 'Today\'s predictions';

  @override
  String get homeEmptyMessage => 'The public feed will live here.';

  @override
  String get account => 'Account';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String loggedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get guestAccountHint =>
      'Log in to like predictions and book sessions.';

  @override
  String get exploreMessage => 'Meet the forecasters of Nojoum.';

  @override
  String get likes => 'Likes';

  @override
  String get reviews => 'Reviews';

  @override
  String get rating => 'Rating';

  @override
  String get totalPredictions => 'Predictions';

  @override
  String get noBookings => 'No bookings yet. They will appear here from /me.';

  @override
  String get typePalm => 'Palm';

  @override
  String get typeCoffee => 'Coffee cup';

  @override
  String get typeAstrology => 'Stars';

  @override
  String sessionMinutes(int minutes) {
    return '$minutes-minute session';
  }
}
