import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum for different theme modes
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Extension to get display names for theme modes
extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  // Map to ThemeMode
  ThemeMode get toThemeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Theme provider that manages app theme state
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  /// Load theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null) {
        state = AppThemeMode.values[themeIndex];
      }
    } catch (e) {
      // If there's an error loading, keep the default (system)
      print('Error loading theme preference: $e');
    }
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveTheme(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  /// Set the theme mode
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    state = themeMode;
    await _saveTheme(themeMode);
  }
}

/// Provider for theme management
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});
