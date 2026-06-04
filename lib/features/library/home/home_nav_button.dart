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
    this.label,
    this.tooltip,
    this.showsDisclosure = false,
    this.enableWhenSelected = false,
    this.animationDuration = kAppAnimNormal,
  });

  final CatalogMediaType type;
  final Color color;
  final IconData icon;
  final bool selected;
  final int count;
  final VoidCallback onPressed;
  final String? label;
  final String? tooltip;
  final bool showsDisclosure;
  final bool enableWhenSelected;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final borderColor = selected
        ? Color.alphaBlend(color.withValues(alpha: 0.24), palette.divider)
        : palette.divider;
    final fillColor = selected
        ? Color.alphaBlend(color.withValues(alpha: 0.06), palette.surface)
        : Colors.transparent;
    final selectedTextColor = palette.textPrimary;
    final selectedCountColor = palette.textMuted;
    final unselectedTextColor = palette.textMuted;
    final unselectedCountColor = palette.textMuted;
    final resolvedLabel = label ?? libraryNavLabel(type);
    return Tooltip(
      message: tooltip ?? type.pluralLabel,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: selected && !enableWhenSelected ? null : onPressed,
          hoverColor: Color.alphaBlend(
            color.withValues(alpha: selected ? 0.14 : 0.1),
            palette.surface,
          ),
          highlightColor: Color.alphaBlend(
            color.withValues(alpha: selected ? 0.1 : 0.07),
            palette.surface,
          ),
          splashColor: Color.alphaBlend(
            color.withValues(alpha: selected ? 0.18 : 0.12),
            palette.surface,
          ),
          child: AnimatedContainer(
            duration: animationDuration,
            curve: Curves.easeOutCubic,
            height: 28,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(1),
                      topRight: Radius.circular(1),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 5),
                      Icon(
                        icon,
                        size: 14,
                        color: selected ? color : palette.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        resolvedLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: selected
                                  ? selectedTextColor
                                  : unselectedTextColor,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w600,
                              height: 1,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        count.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: selected
                                  ? selectedCountColor
                                  : unselectedCountColor,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                      ),
                      if (showsDisclosure) ...[
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: selected
                              ? selectedCountColor
                              : unselectedCountColor,
                        ),
                      ],
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
