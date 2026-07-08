import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
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

class AnimatedLibraryChromeGradient extends StatelessWidget {
  const AnimatedLibraryChromeGradient({
    super.key,
    required this.accent,
    required this.child,
    this.duration,
    this.curve = Curves.easeOutCubic,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.borderBuilder,
  });

  final Color accent;
  final Duration? duration;
  final Curve curve;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final Widget child;
  final BoxBorder Function(Color animatedAccent, Brightness brightness)?
      borderBuilder;

  @override
  Widget build(BuildContext context) {
    final resolvedDuration =
        duration ?? LibraryAccentScope.animationDurationOf(context);
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: accent),
      duration: resolvedDuration,
      curve: curve,
      child: child,
      builder: (context, color, child) {
        final animatedAccent = color ?? accent;
        final palette = appPalette(context);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: libraryChromeGradient(
              animatedAccent,
              brightness: palette.brightness,
              begin: begin,
              end: end,
            ),
            border: borderBuilder?.call(animatedAccent, palette.brightness),
          ),
          child: child,
        );
      },
    );
  }
}

IconData libraryIconForKind(Object? kind) {
  return collectarrLibraryTypes.byKind(kind)?.workspace.icon ??
      Icons.category_outlined;
}
