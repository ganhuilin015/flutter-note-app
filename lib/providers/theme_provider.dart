import 'package:flutter/material.dart';
import 'package:notepad/utils/hive_keys.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'themeMode';
  final themeBox = HiveKeys.themeBox;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadFromHive();
  }

  void _loadFromHive() {
    final stored = themeBox.get(_key, defaultValue: 'system');

    switch (stored) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
  }

  bool isDark(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    _saveToHive();
    notifyListeners();
  }

  void _saveToHive() {
    String value;

    switch (_themeMode) {
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.light:
        value = 'light';
        break;
      default:
        value = 'system';
    }

    themeBox.put(_key, value);
  }
}
