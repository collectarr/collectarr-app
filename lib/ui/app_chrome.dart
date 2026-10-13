import 'package:flutter/material.dart';

const double shellAppBarHeight = 38;
const double secondaryHeaderHeight = 38;
const double drawerHeaderHeight = secondaryHeaderHeight;

ButtonStyle appChromeIconButtonStyle(BuildContext context) {
  // The persistent kind bar keeps white action glyphs in both application skins.
  const foreground = Colors.white;
  return IconButton.styleFrom(
    foregroundColor: foreground,
    disabledForegroundColor: foreground.withValues(alpha: .54),
    backgroundColor: Colors.transparent,
    disabledBackgroundColor: Colors.transparent,
    side: BorderSide.none,
  );
}
