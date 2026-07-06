import 'package:flutter/material.dart';

class LibrarySquareCloseButton extends StatelessWidget {
  const LibrarySquareCloseButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Close',
    this.borderColor,
    this.foregroundColor,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final Color? borderColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedBorderColor = borderColor ?? theme.dividerColor;
    final resolvedForegroundColor =
        foregroundColor ?? theme.colorScheme.onSurface;
    return SizedBox(
      width: 32,
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(32, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          side: BorderSide(color: resolvedBorderColor),
          foregroundColor: resolvedForegroundColor,
        ),
        child: const Icon(Icons.close, size: 18),
      ),
    );
  }
}
