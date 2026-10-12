import 'package:flutter/material.dart';

const double shellAppBarHeight = 40;
const double secondaryHeaderHeight = 38;
const double drawerHeaderHeight = secondaryHeaderHeight;

ButtonStyle appChromeIconButtonStyle(BuildContext context) {
  final foreground =
      Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;
  return IconButton.styleFrom(
    foregroundColor: foreground,
    disabledForegroundColor: foreground.withValues(alpha: .54),
    backgroundColor: Colors.transparent,
    disabledBackgroundColor: Colors.transparent,
    side: BorderSide.none,
  );
}
