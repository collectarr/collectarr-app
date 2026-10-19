import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'app.themeMode';

final appThemeModeProvider =
    NotifierProvider<AppThemeModeNotifier, ThemeMode>(AppThemeModeNotifier.new);

ThemeMode _startupThemeMode = ThemeMode.dark;

/// Reads the saved skin before the first frame, so a light library does not
/// start dark and switch.
Future<void> loadStartupThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  _startupThemeMode = prefs.getString(_kThemeModeKey) == 'light'
      ? ThemeMode.light
      : ThemeMode.dark;
}

class AppThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => _startupThemeMode;

  Future<void> toggle() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, state.name);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.name);
  }
}

AppThemePalette paletteForThemeMode(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => kLightAppThemePalette,
    _ => kDefaultAppThemePalette,
  };
}
