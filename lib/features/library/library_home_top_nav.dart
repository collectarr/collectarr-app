import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/library_home_catalog.dart';
import 'package:collectarr_app/features/library/library_home_counts.dart';
import 'package:collectarr_app/features/library/library_home_nav_button.dart';
import 'package:collectarr_app/features/library/library_home_nav_models.dart';
import 'package:collectarr_app/features/library/library_home_overflow_menu.dart';
import 'package:collectarr_app/features/library/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_type_registry.dart';
import 'package:flutter/material.dart';

class MediaLibraryNav extends StatelessWidget {
  const MediaLibraryNav({
    super.key,
    required this.types,
    required this.counts,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
    this.animationDuration = const Duration(milliseconds: 320),
  });

  final List<CatalogMediaType> types;
  final Map<String, LibraryKindCount> counts;
  final LibraryTypeRegistry registry;
  final String selectedKind;
  final ValueChanged<CatalogMediaType> onSelected;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final selected = selectedLibraryHomeType(types, selectedKind);
    final accent = libraryAccentForKind(selected.kind);
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      height: 42,
      decoration: BoxDecoration(
        gradient: libraryChromeGradient(
          accent,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(
            color:
                Color.alphaBlend(Colors.black.withValues(alpha: 0.24), accent),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            child: Row(
              children: [
                const SizedBox(width: 10),
                const Icon(Icons.cloud_queue, size: 20, color: Colors.white),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    selected.pluralLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Container(width: 1, height: 24, color: Colors.white24),
          Expanded(
            child: MediaLibraryNavStrip(
              types: types,
              counts: counts,
              registry: registry,
              selectedKind: selected.kind,
              onSelected: onSelected,
            ),
          ),
          const SizedBox(
            width: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grid_view, size: 18, color: Colors.white),
                SizedBox(width: 12),
                Icon(Icons.person, size: 18, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MediaLibraryTitleBar extends StatelessWidget {
  const MediaLibraryTitleBar({
    super.key,
    required this.type,
    required this.registry,
    this.animationDuration = const Duration(milliseconds: 320),
  });

  final CatalogMediaType type;
  final LibraryTypeRegistry registry;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(type.kind);
    final icon = registry.byKind(type.kind)?.workspace.icon ??
        libraryIconForKind(type.kind);
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      height: 42,
      decoration: BoxDecoration(
        gradient: libraryChromeGradient(
          accent,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: Color.alphaBlend(
              Colors.black.withValues(alpha: 0.24),
              accent,
            ),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(Icons.cloud_queue, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              type.pluralLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Icon(Icons.grid_view, size: 18, color: Colors.white),
          const SizedBox(width: 12),
          const Icon(Icons.person, size: 18, color: Colors.white),
        ],
      ),
    );
  }
}

class MediaLibraryNavStrip extends StatelessWidget {
  const MediaLibraryNavStrip({
    super.key,
    required this.types,
    required this.counts,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
  });

  final List<CatalogMediaType> types;
  final Map<String, LibraryKindCount> counts;
  final LibraryTypeRegistry registry;
  final String selectedKind;
  final ValueChanged<CatalogMediaType> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxButtons =
            ((constraints.maxWidth - 42) / 116).floor().clamp(1, types.length);
        final split = splitLibraryNavTypes(types, selectedKind, maxButtons);
        return Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Row(
                  children: [
                    for (final type in split.visible)
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: MediaLibraryNavButton(
                          type: type,
                          color: libraryAccentForKind(type.kind),
                          icon: registry.byKind(type.kind)?.workspace.icon ??
                              libraryIconForKind(type.kind),
                          selected: type.kind == selectedKind,
                          count: counts[type.kind]?.total ?? 0,
                          onPressed: () => onSelected(type),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (split.overflow.isNotEmpty)
              MediaLibraryOverflowMenu(
                types: split.overflow,
                counts: counts,
                registry: registry,
                onSelected: onSelected,
              ),
          ],
        );
      },
    );
  }
}
