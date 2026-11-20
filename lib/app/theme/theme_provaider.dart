import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the current theme mode and saves the user's choice on the phone.
class ThemeProvider extends ChangeNotifier {
  static const String _key = 'isDarkMode';

  // Dark is the default until the user chooses otherwise.
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Call once in main() before runApp().
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_key);

      if (saved != null) {
        _themeMode = saved ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      debugPrint('Theme load error: $e');
    }

    notifyListeners();
  }

  /// true = dark, false = light.
  Future<void> setDarkMode(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, value);
    } catch (e) {
      debugPrint('Theme save error: $e');
    }
  }
}