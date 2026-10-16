import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService storage;
  ThemeMode _themeMode;

  ThemeProvider({required this.storage}) : _themeMode = _loadMode(storage);

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    storage.saveString(
      'theme_mode',
      mode == ThemeMode.light ? 'light' : 'dark',
    );
    notifyListeners();
  }

  static ThemeMode _loadMode(StorageService storage) {
    final saved = storage.getString('theme_mode');
    if (saved == 'light') return ThemeMode.light;
    return ThemeMode.dark;
  }
}
