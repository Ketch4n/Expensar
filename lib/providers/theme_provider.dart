import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

/// Manages the app's theme mode (light or dark).
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await DatabaseService.getSetting('themeMode');
    state = _parseThemeMode(saved);
  }

  void setThemeMode(String mode) {
    // Update state immediately for responsive UI
    state = _parseThemeMode(mode);
    // Persist in background
    DatabaseService.setSetting('themeMode', mode);
  }

  /// Toggle between light and dark.
  void toggle() {
    final newMode = state == ThemeMode.dark ? 'light' : 'dark';
    setThemeMode(newMode);
  }

  bool get isDark => state == ThemeMode.dark;

  static ThemeMode _parseThemeMode(String? mode) {
    return switch (mode) {
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light,
    };
  }

  /// Returns the string value for persistence.
  String get themeModeString => switch (state) {
    ThemeMode.dark => 'dark',
    _ => 'light',
  };
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);
