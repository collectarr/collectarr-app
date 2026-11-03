import 'package:collectarr_app/ui/adaptive/native_system_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native system bars use the dark kind chrome and canvas contrast', () {
    final style = nativeSystemUiStyle(
      accent: const Color(0xff0081a6),
      darkAccent: const Color(0xff00577f),
      palette: kDefaultAppThemePalette,
    );
    expect(style.statusBarColor, const Color(0xff00577f));
    expect(style.statusBarIconBrightness, Brightness.light);
    expect(style.systemNavigationBarColor, const Color(0xff131313));
    expect(style.systemNavigationBarIconBrightness, Brightness.light);
  });

  test('light skin keeps dark navigation icons', () {
    final style = nativeSystemUiStyle(
      accent: const Color(0xff0081a6),
      palette: kLightAppThemePalette,
    );
    expect(style.statusBarColor, isNot(const Color(0xff0081a6)));
    expect(style.systemNavigationBarColor, kLightAppThemePalette.canvas);
    expect(style.systemNavigationBarIconBrightness, Brightness.dark);
  });
}
