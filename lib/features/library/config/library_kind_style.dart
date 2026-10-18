import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

ThemeData libraryAccentTheme(BuildContext context, Color accent) {
  final theme = Theme.of(context);
  final palette = appPalette(context);
  return theme.copyWith(
    colorScheme: theme.colorScheme
        .copyWith(primary: accent, onPrimary: appContrastingTextColor(accent)),
    extensions: [
      ...theme.extensions.values.where((value) => value is! AppThemePalette),
      palette.copyWith(
          accent: accent,
          selection:
              Color.alphaBlend(accent.withValues(alpha: 0.22), palette.panel)),
    ],
  );
}

Color libraryAccentForKind(CatalogMediaKind kind) {
  if (cachedLibraryAccentHexForKind(kind) case final accentHex?) {
    return Color(accentHex);
  }
  return libraryDefaultAccentForKind(kind);
}

Color libraryDefaultAccentForKind(CatalogMediaKind kind) {
  return libraryKindRegistrationForKind(kind).identity.accent;
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

class AnimatedLibraryChrome extends StatelessWidget {
  const AnimatedLibraryChrome({
    super.key,
    required this.accent,
    required this.child,
    this.duration,
    this.curve = Curves.easeOutCubic,
    this.borderBuilder,
  });

  final Color accent;
  final Duration? duration;
  final Curve curve;
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
          // Flat kind accent, as in the reference chrome.
          decoration: BoxDecoration(
            color: animatedAccent,
            border: borderBuilder?.call(animatedAccent, palette.brightness),
          ),
          child: child,
        );
      },
    );
  }
}

IconData libraryIconForKind(CatalogMediaKind kind) {
  return libraryKindRegistrationForKind(kind).identity.icon;
}
