import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A muted icon + text line used across kind inspector panels (e.g. play time,
/// player count, format notes). Previously each kind reimplemented an identical
/// widget; they now share this one.
class LibraryInspectorInfoLine extends StatelessWidget {
  const LibraryInspectorInfoLine({
    super.key,
    required this.icon,
    required this.text,
    this.bottomSpacing = 4,
    this.iconSize = 14,
    this.fontWeight = FontWeight.w700,
  });

  final IconData icon;
  final String text;
  final double bottomSpacing;
  final double iconSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: iconSize, color: palette.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: fontWeight),
            ),
          ),
        ],
      ),
    );
  }
}
