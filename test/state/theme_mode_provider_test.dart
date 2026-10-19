import 'package:collectarr_app/state/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('the saved light skin applies from the first frame', () async {
    SharedPreferences.setMockInitialValues({'app.themeMode': 'light'});
    await loadStartupThemeMode();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(appThemeModeProvider), ThemeMode.light);
  });

  test('without a saved skin the app starts dark', () async {
    SharedPreferences.setMockInitialValues({});
    await loadStartupThemeMode();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(appThemeModeProvider), ThemeMode.dark);
  });
}
