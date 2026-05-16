import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/library_home_counts.dart';
import 'package:collectarr_app/features/library/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_type_registry.dart';
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
    return PopupMenuButton<CatalogMediaType>(
      tooltip: 'More libraries',
      color: const Color(0xFF202020),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.54),
      elevation: 10,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 5),
      constraints: const BoxConstraints(minWidth: 190, maxWidth: 250),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFF484848)),
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
            color: Colors.black.withValues(alpha: 0.26),
            border: Border.all(color: Colors.white38),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.more_horiz, color: Colors.white, size: 17),
                const SizedBox(width: 5),
                const Text(
                  'More',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  types.length.toString(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.86),
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
