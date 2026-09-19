import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{
    ThemeMode _mode = ThemeMode.system;

    ThemeMode get mode => _mode;

    bool get isSystem => _mode == ThemeMode.system;
    bool get isLight => _mode == ThemeMode.light;
    bool get isDark => _mode == ThemeMode.dark;

    void setMode(ThemeMode mode){
      if(_mode==mode)return;
      _mode =mode;
      notifyListeners();
    }

    void setSystem() => setMode(ThemeMode.system);
    void setLight() => setMode(ThemeMode.light);
    void setDark() => setMode(ThemeMode.dark);

    void cycle() {
      switch (_mode) {
        case ThemeMode.system:
          setMode(ThemeMode.light);
          break;
        case ThemeMode.light:
          setMode(ThemeMode.dark);
          break;
        case ThemeMode.dark:
          setMode(ThemeMode.system);
          break;
      }
    }

}