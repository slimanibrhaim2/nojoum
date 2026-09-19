
import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier{
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode =='ar';

  void setLocale(Locale local){
    if(_locale == local) return;
    _locale = local;
    notifyListeners();
  }

  void setArabic() => setLocale(const Locale('ar'));
  void setEnglish()=> setLocale(const Locale('en'));

  void toggle(){
    setLocale(isArabic? const Locale('en') : const Locale('ar') );
  }

}