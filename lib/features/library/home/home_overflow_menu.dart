import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MediaLibraryOverflowMenu extends StatelessWidget {
  const MediaLibraryOverflowMenu({
    super.key,
    required this.types,
    required this.counts,
    required this.registry,
    required this.onSelected,
  });

  final List<CatalogMediaType> types;
  final Map<String, LibraryKindCount> counts;
  final LibraryTypeRegistry registry;
  final ValueChanged<CatalogMediaType> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final buttonBackground = Color.alphaBlend(
      palette.accent.withValues(alpha: palette.isDark ? 0.12 : 0.08),
      palette.surfaceSubtle.withValues(alpha: palette.isDark ? 0.9 : 1),
    );
    final buttonBorder = Color.alphaBlend(
      palette.accent.withValues(alpha: palette.isDark ? 0.18 : 0.16),
      palette.divider,
    );
    final buttonForeground =
        ThemeData.estimateBrightnessForColor(buttonBackground) ==
                Brightness.dark
            ? Colors.white
            : palette.textPrimary;
    return PopupMenuButton<CatalogMediaType>(
      tooltip: 'More libraries',
      color: palette.panelRaised,
      surfaceTintColor: Colors.transparent,
      shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.32),
      elevation: 10,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 5),
      constraints: const BoxConstraints(minWidth: 190, maxWidth: 250),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: palette.divider),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final type in types)
          PopupMenuItem(
            key: ValueKey('library-overflow-item-${type.kind}'),
            value: type,
            height: kLibraryToolbarPopupItemHeight,
            padding: EdgeInsets.zero,
            child: _OverflowMenuRow(
              type: type,
              icon: registry.byKind(type.kind)?.workspace.icon ??
                  libraryIconForKind(type.kind),
              count: counts[type.kind]?.total ?? 0,
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: buttonBackground,
            border: Border.all(color: buttonBorder),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.more_horiz,
                  color: buttonForeground,
                  size: 17,
                ),
                const SizedBox(width: 5),
                Text(
                  'More',
                  style: TextStyle(
                    color: buttonForeground,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  types.length.toString(),
                  style: TextStyle(
                    color: buttonForeground.withValues(alpha: 0.82),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
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

class _OverflowMenuRow extends StatelessWidget {
  const _OverflowMenuRow({
    required this.type,
    required this.icon,
    required this.count,
  });

  final CatalogMediaType type;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(type.kind);
    final palette = appPalette(context);
    return SizedBox(
      height: kLibraryToolbarPopupItemHeight,
      child: Row(
        children: [
          Container(width: 4, height: double.infinity, color: accent),
          const SizedBox(width: 10),
          Icon(icon, size: 17, color: accent),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              type.pluralLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
