import 'package:flutter/material.dart';

const double shellAppBarHeight = 38;
const double secondaryHeaderHeight = 38;
const double drawerHeaderHeight = secondaryHeaderHeight;

ButtonStyle appChromeIconButtonStyle(BuildContext context) {
  // The persistent kind bar keeps white action glyphs in both application skins.
  const foreground = Colors.white;
  // The reference's header buttons are 36 px circles that hover in white
  // at 15 %.
  return IconButton.styleFrom(
    foregroundColor: foreground,
    disabledForegroundColor: foreground.withValues(alpha: .54),
    backgroundColor: Colors.transparent,
    disabledBackgroundColor: Colors.transparent,
    side: BorderSide.none,
    shape: const CircleBorder(),
    fixedSize: const Size.square(36),
    minimumSize: const Size.square(36),
    padding: EdgeInsets.zero,
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.pressed)
            ? Colors.white.withValues(alpha: .25)
            : states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.focused)
                ? Colors.white.withValues(alpha: .15)
                : null),
  );
}
