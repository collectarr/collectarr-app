import 'package:collectarr_app/ui/theme/theme_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Android/iOS system bars stay darker than the library header.
SystemUiOverlayStyle nativeSystemUiStyle({
  required Color accent,
  required AppThemePalette palette,
  Color? darkAccent,
}) {
  final status = darkAccent ?? Color.lerp(accent, Colors.black, .32)!;
  final navigation = palette.isDark ? const Color(0xff131313) : palette.canvas;
  return SystemUiOverlayStyle(
    statusBarColor: status,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: navigation,
    systemNavigationBarDividerColor: navigation,
    systemNavigationBarIconBrightness:
        palette.isDark ? Brightness.light : Brightness.dark,
  );
}
