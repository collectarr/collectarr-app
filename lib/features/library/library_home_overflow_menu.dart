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
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final type in types)
          PopupMenuItem(
            value: type,
            child: ListTile(
              dense: true,
              leading: Icon(
                registry.byKind(type.kind)?.workspace.icon ??
                    libraryIconForKind(type.kind),
                color: libraryAccentForKind(type.kind),
              ),
              title: Text(type.pluralLabel),
              trailing: Text((counts[type.kind]?.total ?? 0).toString()),
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
