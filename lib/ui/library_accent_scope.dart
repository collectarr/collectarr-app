import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryAccentData {
  const LibraryAccentData({
    required this.kind,
    required this.accent,
    required this.animationsEnabled,
  });

  final String kind;
  final Color accent;
  final bool animationsEnabled;

  Duration get animationDuration =>
      animationsEnabled ? kAppAnimNormal : Duration.zero;

  Color get actionAccent => libraryAccentActionColor(accent);

  LinearGradient chromeGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    Brightness brightness = Brightness.dark,
  }) {
    return libraryChromeGradient(
      accent,
      begin: begin,
      end: end,
      brightness: brightness,
    );
  }

  Color chromeBorderColor({Brightness brightness = Brightness.dark}) {
    return libraryChromeBorderColor(accent, brightness: brightness);
  }

  Color get selectedFill => accent.withValues(alpha: 0.10);
}

class LibraryAccentScope extends InheritedWidget {
  const LibraryAccentScope({
    super.key,
    required this.kind,
    required this.accent,
    required this.animationsEnabled,
    required super.child,
  });

  final String kind;
  final Color accent;
  final bool animationsEnabled;

  LibraryAccentData get data => LibraryAccentData(
        kind: kind,
        accent: accent,
        animationsEnabled: animationsEnabled,
      );

  static LibraryAccentScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LibraryAccentScope>();
  }

  static LibraryAccentData of(BuildContext context) {
    return maybeOf(context)?.data ??
        LibraryAccentData(
          kind: '',
          accent: Theme.of(context).colorScheme.primary,
          animationsEnabled: true,
        );
  }

  static Color accentOf(BuildContext context, {Color? fallback}) {
    return maybeOf(context)?.accent ??
        fallback ??
        Theme.of(context).colorScheme.primary;
  }

  static Duration animationDurationOf(BuildContext context) {
    return maybeOf(context)?.data.animationDuration ?? kAppAnimNormal;
  }

  @override
  bool updateShouldNotify(LibraryAccentScope oldWidget) {
    return kind != oldWidget.kind ||
        accent != oldWidget.accent ||
        animationsEnabled != oldWidget.animationsEnabled;
  }
}

ThemeData buildLibraryAccentTheme(ThemeData base, Color accent) {
  final actionAccent = libraryAccentActionColor(accent);
  final actionForeground = appContrastingTextColor(actionAccent);
  final chromeBackground = libraryAccentChromeFallbackColor(accent);
  final chromeForeground = appContrastingTextColor(chromeBackground);
  final readableAccent =
      libraryAccentTextColor(accent, base.colorScheme.surface);
  final primaryContainer = Color.alphaBlend(
    accent.withValues(alpha: 0.20),
    base.colorScheme.surface,
  );
  final secondaryContainer = Color.alphaBlend(
    accent.withValues(alpha: 0.14),
    base.colorScheme.surface,
  );
  final scheme = base.colorScheme.copyWith(
    primary: accent,
    onPrimary: appContrastingTextColor(accent),
    secondary: accent,
    onSecondary: appContrastingTextColor(accent),
    tertiary: accent,
    onTertiary: appContrastingTextColor(accent),
    primaryContainer: primaryContainer,
    onPrimaryContainer: appContrastingTextColor(primaryContainer),
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: appContrastingTextColor(secondaryContainer),
  );
  return base.copyWith(
    colorScheme: scheme,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: chromeBackground,
      foregroundColor: chromeForeground,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      backgroundColor: actionAccent,
      foregroundColor: actionForeground,
      mouseCursor: WidgetStateMouseCursor.clickable,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _accentFilledButtonStyle(
        base.filledButtonTheme.style,
        actionAccent,
        actionForeground,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _accentOutlinedButtonStyle(
        base.outlinedButtonTheme.style,
        readableAccent,
        base.colorScheme.onSurface,
        base.colorScheme.outline,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _accentTextButtonStyle(base.textButtonTheme.style, readableAccent),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: _accentIconButtonStyle(
        base.iconButtonTheme.style,
        readableAccent,
        base.colorScheme.onSurface,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: _accentSegmentedButtonStyle(
        base.segmentedButtonTheme.style,
        actionAccent,
        actionForeground,
      ),
    ),
    switchTheme: SwitchThemeData(
      mouseCursor: WidgetStateMouseCursor.clickable,
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return base.colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return states.contains(WidgetState.selected)
            ? readableAccent
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
        borderSide: BorderSide(color: readableAccent),
      ),
      floatingLabelStyle: TextStyle(color: readableAccent),
    ),
    tabBarTheme: base.tabBarTheme.copyWith(
      dividerColor: base.colorScheme.outline.withValues(alpha: 0.55),
      indicatorColor: readableAccent,
      labelColor: base.colorScheme.onSurface,
      unselectedLabelColor: base.colorScheme.onSurface.withValues(alpha: 0.66),
      overlayColor: WidgetStatePropertyAll(
        accent.withValues(alpha: 0.06),
      ),
    ),
    progressIndicatorTheme: base.progressIndicatorTheme.copyWith(
      color: readableAccent,
    ),
    datePickerTheme: buildAppDatePickerTheme(
      palette: base.extension<AppThemePalette>() ?? kDefaultAppThemePalette,
      accent: accent,
      surface: base.datePickerTheme.backgroundColor ??
          base.dialogTheme.backgroundColor ??
          base.colorScheme.surface,
    ),
  );
}

ButtonStyle _accentFilledButtonStyle(
  ButtonStyle? base,
  Color accent,
  Color onAccent,
) {
  return (base ?? const ButtonStyle()).copyWith(
    mouseCursor: WidgetStateMouseCursor.clickable,
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

ButtonStyle _accentOutlinedButtonStyle(
  ButtonStyle? base,
  Color accent,
  Color textColor,
  Color dividerColor,
) {
  return (base ?? const ButtonStyle()).copyWith(
    mouseCursor: WidgetStateMouseCursor.clickable,
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      return states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)
          ? accent
          : textColor;
    }),
    side: WidgetStateProperty.resolveWith((states) {
      final color = states.contains(WidgetState.disabled)
          ? accent.withValues(alpha: 0.24)
          : states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused) ||
                  states.contains(WidgetState.pressed)
              ? accent.withValues(alpha: 0.58)
              : dividerColor;
      return BorderSide(color: color);
    }),
    overlayColor: WidgetStatePropertyAll(
      accent.withValues(alpha: 0.08),
    ),
  );
}

ButtonStyle _accentTextButtonStyle(ButtonStyle? base, Color accent) {
  return (base ?? const ButtonStyle()).copyWith(
    mouseCursor: WidgetStateMouseCursor.clickable,
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

ButtonStyle _accentIconButtonStyle(
  ButtonStyle? base,
  Color accent,
  Color textColor,
) {
  return (base ?? const ButtonStyle()).copyWith(
    mouseCursor: WidgetStateMouseCursor.clickable,
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      return states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.selected)
          ? accent
          : textColor;
    }),
    overlayColor: WidgetStatePropertyAll(
      accent.withValues(alpha: 0.08),
    ),
  );
}

ButtonStyle _accentSegmentedButtonStyle(
  ButtonStyle? base,
  Color accent,
  Color foreground,
) {
  return (base ?? const ButtonStyle()).copyWith(
    mouseCursor: WidgetStateMouseCursor.clickable,
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) ? accent : null;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) ? foreground : null;
    }),
    side: WidgetStatePropertyAll(
      BorderSide(color: accent.withValues(alpha: 0.30)),
    ),
  );
}

Color libraryAccentChromeFallbackColor(Color accent) {
  return libraryAccentActionColor(accent);
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
    return AnimatedLibraryChromeGradient(
      accent: accent,
      duration: animationDuration,
      begin: begin,
      end: end,
      borderBuilder: (animatedAccent, _) => Border(
        bottom: BorderSide(
          color: Color.alphaBlend(
            Colors.white.withValues(alpha: 0.12),
            animatedAccent,
          ),
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
