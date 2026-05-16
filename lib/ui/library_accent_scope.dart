import 'package:collectarr_app/features/library/library_kind_style.dart';
import 'package:flutter/material.dart';

class LibraryAccentScope extends InheritedWidget {
  const LibraryAccentScope({
    super.key,
    required this.accent,
    required this.animationsEnabled,
    required super.child,
  });

  final Color accent;
  final bool animationsEnabled;

  Duration get animationDuration =>
      animationsEnabled ? const Duration(milliseconds: 320) : Duration.zero;

  static LibraryAccentScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LibraryAccentScope>();
  }

  static Color accentOf(BuildContext context, {Color? fallback}) {
    return maybeOf(context)?.accent ??
        fallback ??
        Theme.of(context).colorScheme.primary;
  }

  static Duration animationDurationOf(BuildContext context) {
    return maybeOf(context)?.animationDuration ??
        const Duration(milliseconds: 320);
  }

  @override
  bool updateShouldNotify(LibraryAccentScope oldWidget) {
    return accent != oldWidget.accent ||
        animationsEnabled != oldWidget.animationsEnabled;
  }
}

ThemeData buildLibraryAccentTheme(ThemeData base, Color accent) {
  final actionAccent = libraryAccentActionColor(accent);
  const onAccent = Colors.white;
  final scheme = base.colorScheme.copyWith(
    primary: accent,
    secondary: accent,
    tertiary: accent,
    primaryContainer: accent.withValues(alpha: 0.36),
    secondaryContainer: accent.withValues(alpha: 0.24),
  );
  return base.copyWith(
    colorScheme: scheme,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: libraryAccentChromeFallbackColor(accent),
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      backgroundColor: actionAccent,
      foregroundColor: onAccent,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _accentFilledButtonStyle(
        base.filledButtonTheme.style,
        actionAccent,
        onAccent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _accentOutlinedButtonStyle(
        base.outlinedButtonTheme.style,
        accent,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _accentTextButtonStyle(base.textButtonTheme.style, accent),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: _accentIconButtonStyle(base.iconButtonTheme.style, accent),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: _accentSegmentedButtonStyle(
        base.segmentedButtonTheme.style,
        accent,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return base.colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return states.contains(WidgetState.selected)
            ? accent
            : base.colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return base.colorScheme.onSurface.withValues(alpha: 0.12);
        }
        return states.contains(WidgetState.selected)
            ? accent.withValues(alpha: 0.42)
            : base.colorScheme.surfaceContainerHighest;
      }),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accent),
      ),
      floatingLabelStyle: TextStyle(color: accent),
    ),
    tabBarTheme: base.tabBarTheme.copyWith(
      dividerColor: Colors.white.withValues(alpha: 0.16),
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withValues(alpha: 0.66),
      overlayColor: WidgetStatePropertyAll(
        Colors.white.withValues(alpha: 0.10),
      ),
    ),
    progressIndicatorTheme: base.progressIndicatorTheme.copyWith(
      color: accent,
    ),
  );
}

ButtonStyle _accentFilledButtonStyle(
  ButtonStyle? base,
  Color accent,
  Color onAccent,
) {
  return (base ?? const ButtonStyle()).copyWith(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      return accent;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      return onAccent;
    }),
    overlayColor: WidgetStatePropertyAll(
      onAccent.withValues(alpha: 0.12),
    ),
  );
}

ButtonStyle _accentOutlinedButtonStyle(ButtonStyle? base, Color accent) {
  return (base ?? const ButtonStyle()).copyWith(
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      return Colors.white;
    }),
    side: WidgetStateProperty.resolveWith((states) {
      final color = states.contains(WidgetState.disabled)
          ? accent.withValues(alpha: 0.24)
          : accent.withValues(alpha: 0.72);
      return BorderSide(color: color);
    }),
    overlayColor: WidgetStatePropertyAll(
      accent.withValues(alpha: 0.12),
    ),
  );
}

ButtonStyle _accentTextButtonStyle(ButtonStyle? base, Color accent) {
  return (base ?? const ButtonStyle()).copyWith(
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      return accent;
    }),
    overlayColor: WidgetStatePropertyAll(
      accent.withValues(alpha: 0.12),
    ),
  );
}

ButtonStyle _accentIconButtonStyle(ButtonStyle? base, Color accent) {
  return (base ?? const ButtonStyle()).copyWith(
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      return accent;
    }),
    overlayColor: WidgetStatePropertyAll(
      accent.withValues(alpha: 0.14),
    ),
  );
}

ButtonStyle _accentSegmentedButtonStyle(ButtonStyle? base, Color accent) {
  return (base ?? const ButtonStyle()).copyWith(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected)
          ? accent.withValues(alpha: 0.48)
          : null;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) ? Colors.white : null;
    }),
    side: WidgetStatePropertyAll(
      BorderSide(color: accent.withValues(alpha: 0.58)),
    ),
  );
}

Color libraryAccentActionColor(Color accent) {
  const targetContrast = 4.5;
  if (_contrastRatio(Colors.white, accent) >= targetContrast) {
    return accent;
  }
  var candidate = accent;
  for (var alpha = 0.18; alpha <= 0.64; alpha += 0.06) {
    candidate = Color.alphaBlend(
      Colors.black.withValues(alpha: alpha),
      accent,
    );
    if (_contrastRatio(Colors.white, candidate) >= targetContrast) {
      return candidate;
    }
  }
  return candidate;
}

Color libraryAccentChromeFallbackColor(Color accent) {
  return Color.alphaBlend(
    Colors.black.withValues(alpha: 0.48),
    accent,
  );
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance() + 0.05;
  final backgroundLuminance = background.computeLuminance() + 0.05;
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return lighter / darker;
}

class LibraryAccentChrome extends StatelessWidget {
  const LibraryAccentChrome({
    super.key,
    required this.accent,
    required this.animationDuration,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  final Color accent;
  final Duration animationDuration;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: accent),
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      builder: (context, color, child) {
        final animatedAccent = color ?? accent;
        return SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: libraryChromeGradient(
                animatedAccent,
                begin: begin,
                end: end,
              ),
              border: Border(
                bottom: BorderSide(
                  color: Color.alphaBlend(
                    Colors.white.withValues(alpha: 0.12),
                    animatedAccent,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
