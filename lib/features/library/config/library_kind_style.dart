import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const Color kLibraryFallbackAccent = kAppAccent;

Color libraryAccentForKind(Object? kind) {
  if (cachedLibraryAccentHexForKind(kind) case final accentHex?) {
    return Color(accentHex);
  }
  return libraryDefaultAccentForKind(kind);
}

Color libraryDefaultAccentForKind(Object? kind) {
  return collectarrLibraryTypes.byKind(kind)?.workspace.accent ??
      kLibraryFallbackAccent;
}

LinearGradient libraryChromeGradient(
  Color accent, {
  AlignmentGeometry begin = Alignment.topLeft,
  AlignmentGeometry end = Alignment.bottomRight,
  Brightness brightness = Brightness.dark,
}) {
  final isDark = brightness == Brightness.dark;
  return LinearGradient(
    begin: begin,
    end: end,
    colors: [
      Color.alphaBlend(
        isDark
            ? Colors.black.withValues(alpha: 0.34)
            : Colors.white.withValues(alpha: 0.42),
        accent,
      ),
      Color.alphaBlend(
        isDark
            ? Colors.black.withValues(alpha: 0.62)
            : Colors.white.withValues(alpha: 0.20),
        accent,
      ),
    ],
  );
}

Color libraryChromeBorderColor(
  Color accent, {
  Brightness brightness = Brightness.dark,
}) {
  return Color.alphaBlend(
    brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.24)
        : Colors.white.withValues(alpha: 0.46),
    accent,
  );
}

IconData libraryIconForKind(Object? kind) {
  return collectarrLibraryTypes.byKind(kind)?.workspace.icon ??
      Icons.category_outlined;
}
