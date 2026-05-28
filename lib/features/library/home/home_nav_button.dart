import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MediaLibraryNavButton extends StatelessWidget {
  const MediaLibraryNavButton({
    super.key,
    required this.type,
    required this.color,
    required this.icon,
    required this.selected,
    required this.count,
    required this.onPressed,
    this.animationDuration = kAppAnimNormal,
  });

  final CatalogMediaType type;
  final Color color;
  final IconData icon;
  final bool selected;
  final int count;
  final VoidCallback onPressed;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final textColor = palette.isDark ? Colors.white : palette.textPrimary;
    final countColor =
      palette.isDark ? Colors.white.withValues(alpha: 0.84) : palette.textMuted;
    final borderColor = selected
      ? (palette.isDark
        ? Colors.white.withValues(alpha: 0.72)
        : Color.alphaBlend(color.withValues(alpha: 0.18), palette.divider))
      : (palette.isDark
        ? color
        : Color.alphaBlend(color.withValues(alpha: 0.28), palette.divider));
    final selectedStart = palette.isDark
      ? color.withValues(alpha: 0.38)
      : Color.alphaBlend(color.withValues(alpha: 0.16), palette.surfaceSubtle);
    final selectedEnd = palette.isDark
      ? color.withValues(alpha: 0.14)
      : Color.alphaBlend(color.withValues(alpha: 0.06), palette.panel);
    final unselectedFill = palette.isDark
      ? Colors.black.withValues(alpha: 0.28)
      : Color.alphaBlend(color.withValues(alpha: 0.04), palette.surfaceSubtle);
    return Tooltip(
      message: type.pluralLabel,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(3),
          onTap: selected ? null : onPressed,
          child: AnimatedContainer(
            duration: animationDuration,
            curve: Curves.easeOutCubic,
            height: 30,
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        selectedStart,
                        selectedEnd,
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        unselectedFill,
                        unselectedFill,
                      ],
                    ),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 4, height: double.infinity, color: color),
                const SizedBox(width: 8),
                Icon(icon, size: 17, color: selected ? textColor : color),
                const SizedBox(width: 7),
                Text(
                  libraryNavLabel(type),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: countColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
