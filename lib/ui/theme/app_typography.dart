import 'package:collectarr_app/core/fonts/local_font_controller.dart';
import 'package:flutter/material.dart';

/// The requested local face; appFontFamily resolves the current engine alias.
const kAppFontFamily = 'Gilroy';
String get appFontFamily => LocalFontController.instance.activeFamily;
const kAppFontFamilyFallback = ['Plus Jakarta Sans'];
const kAppBodyFontSize = 14.0;
const kAppCaptionFontSize = 13.0;
const kAppNormalFontWeight = FontWeight.w400;
const kAppMediumFontWeight = FontWeight.w500;
const kAppSemiBoldFontWeight = FontWeight.w600;
const kAppBoldFontWeight = FontWeight.w700;
const kAppExtraBoldFontWeight = FontWeight.w800;

/// Bold for titles of 18 px and more. Local Gilroy's 700 slot carries Black
/// outlines so 14 px bold matches the reference, which Flutter paints
/// lighter; at title sizes that gap closes, and ExtraBold matches the
/// reference's Gilroy Bold (measured on the 18 px editor title).
FontWeight get appTitleBoldFontWeight =>
    appTitleBoldFontWeightFor(LocalFontController.instance);

FontWeight appTitleBoldFontWeightFor(LocalFontController fonts) =>
    fonts.isGilroyActive && fonts.faces.containsKey(800)
        ? kAppExtraBoldFontWeight
        : kAppBoldFontWeight;

TextTheme buildAppTextTheme(TextTheme base, Color foreground) {
  final themed = base.apply(
    fontFamily: appFontFamily,
    fontFamilyFallback: kAppFontFamilyFallback,
    bodyColor: foreground,
    displayColor: foreground,
  );
  TextStyle role(TextStyle? baseStyle, double size, FontWeight weight) =>
      (baseStyle ?? TextStyle()).copyWith(
        fontFamily: appFontFamily,
        fontFamilyFallback: kAppFontFamilyFallback,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: 0,
        height: 20 / 14,
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
        role(themed.labelMedium, kAppCaptionFontSize, kAppSemiBoldFontWeight),
    labelSmall:
        role(themed.labelSmall, kAppCaptionFontSize, kAppSemiBoldFontWeight),
  );
}
