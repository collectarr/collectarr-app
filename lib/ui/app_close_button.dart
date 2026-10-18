import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';

/// The close icon of dialog and panel headers. Like the reference it has no
/// hover, press or ripple effect.
class AppCloseButton extends StatelessWidget {
  const AppCloseButton({
    super.key,
    required this.onPressed,
    this.color,
    this.size = 24,
    this.iconSize = 16,
  });

  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'Close',
        onPressed: onPressed,
        constraints: BoxConstraints.tightFor(width: size, height: size),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.standard,
        style: IconButton.styleFrom(
          foregroundColor: color,
          backgroundColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          side: BorderSide.none,
          padding: EdgeInsets.zero,
          minimumSize: Size(size, size),
          maximumSize: Size(size, size),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ).copyWith(
            overlayColor: const WidgetStatePropertyAll(Colors.transparent)),
        icon: Icon(AppIcons.close, size: iconSize),
      );
}
