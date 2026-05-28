import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
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
            height: 38,
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
            color: palette.isDark
                ? Colors.black.withValues(alpha: 0.26)
                : Color.alphaBlend(
                    appPalette(context).accent.withValues(alpha: 0.08),
                    palette.surfaceSubtle,
                  ),
            border: Border.all(
              color: palette.isDark
                  ? Colors.white38
                  : Color.alphaBlend(
                      appPalette(context).accent.withValues(alpha: 0.16),
                      palette.divider,
                    ),
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.more_horiz,
                  color: palette.isDark ? Colors.white : palette.textPrimary,
                  size: 17,
                ),
                const SizedBox(width: 5),
                Text(
                  'More',
                  style: TextStyle(
                    color: palette.isDark ? Colors.white : palette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  types.length.toString(),
                  style: TextStyle(
                    color: palette.isDark
                        ? Colors.white.withValues(alpha: 0.82)
                        : palette.textMuted,
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
      height: 38,
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
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: palette.isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : palette.surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: palette.isDark ? Colors.white24 : palette.divider,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: palette.isDark
                      ? Colors.white.withValues(alpha: 0.86)
                      : palette.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
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
