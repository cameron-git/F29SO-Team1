// Provides theme changing and saves theme preferences to device

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  get themeMode => _themeMode;

  String get themeName {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'Error';
    }
  }

  initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (prefs.getString('theme')) {
      case 'System':
        setThemeSystem();
        break;
      case 'Light':
        setThemeLight();
        break;
      case 'Dark':
        setThemeDark();
        break;
      default:
    }
  }

  setThemeSystem() async {
    _themeMode = ThemeMode.system;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeName);
    notifyListeners();
  }

  setThemeLight() async {
    _themeMode = ThemeMode.light;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeName);
    notifyListeners();
  }

  setThemeDark() async {
    _themeMode = ThemeMode.dark;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeName);
    notifyListeners();
  }
}
