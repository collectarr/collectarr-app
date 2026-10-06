import 'package:flutter/material.dart';

/// Primary font family priority:
/// 1. 'Gilroy' if installed on the host operating system.
/// 2. 'Collectarr Sans' (our bundled 1:1 geometric SIL OFL face).
/// 3. Standard system fallbacks ('Segoe UI', 'Roboto').
const kAppFontFamily = 'Gilroy';
const kAppFontFamilyFallback = ['Collectarr Sans', 'Segoe UI', 'Roboto'];
const kAppBodyFontSize = 14.0;
const kAppCaptionFontSize = 13.0;
const kAppNormalFontWeight = FontWeight.w500;
const kAppBoldFontWeight = FontWeight.w700;
const kAppExtraBoldFontWeight = FontWeight.w800;

TextTheme buildAppTextTheme(TextTheme base, Color foreground) {
  final themed = base.apply(
    fontFamily: kAppFontFamily,
    fontFamilyFallback: kAppFontFamilyFallback,
    bodyColor: foreground,
    displayColor: foreground,
  );
  TextStyle role(TextStyle? baseStyle, double size, FontWeight weight) =>
      (baseStyle ?? const TextStyle()).copyWith(
        fontFamily: kAppFontFamily,
        fontFamilyFallback: kAppFontFamilyFallback,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: 0,
        height: 20 / 14,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  return themed.copyWith(
    titleLarge: role(themed.titleLarge, 18, kAppBoldFontWeight),
    titleMedium: role(themed.titleMedium, 16, kAppBoldFontWeight),
    titleSmall: role(themed.titleSmall, 14, kAppBoldFontWeight),
    bodyLarge: role(themed.bodyLarge, 16, kAppNormalFontWeight),
    bodyMedium: role(themed.bodyMedium, kAppBodyFontSize, kAppNormalFontWeight),
    bodySmall:
        role(themed.bodySmall, kAppCaptionFontSize, kAppNormalFontWeight),
    labelLarge: role(themed.labelLarge, kAppBodyFontSize, kAppNormalFontWeight),
    labelMedium:
        role(themed.labelMedium, kAppCaptionFontSize, kAppBoldFontWeight),
    labelSmall:
        role(themed.labelSmall, kAppCaptionFontSize, kAppNormalFontWeight),
  );
}
