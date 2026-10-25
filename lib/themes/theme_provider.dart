import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:reminder/themes/dark_mode.dart';
import 'package:reminder/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;
  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData == darkMode;
  final _settings = Hive.box("settings");

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      _themeData = darkMode;
      _settings.put("isDarkMode", true);
    } else {
      _themeData = lightMode;
      _settings.put("isDarkMode", false);
    }
    notifyListeners();
  }

  void loadTheme() {
    _themeData = _settings.get("isDarkMode") == true 
    ? darkMode 
    : lightMode;
  }

  ThemeProvider() {
    loadTheme();
  }
}