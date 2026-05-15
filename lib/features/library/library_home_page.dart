import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_page.dart';
import 'package:collectarr_app/features/library/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/generic_library_page.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_type_registry.dart';
import 'package:collectarr_app/features/library/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryHomePage extends ConsumerStatefulWidget {
  const LibraryHomePage({super.key});

  @override
  ConsumerState<LibraryHomePage> createState() => _LibraryHomePageState();
}

class _LibraryHomePageState extends ConsumerState<LibraryHomePage> {
  String _selectedKind = 'comic';

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final navPreferences = ref.watch(libraryNavPreferencesProvider);
    final allTypes = _orderedTopLevelTypes(catalog, navPreferences);
    final visibleTypes = _visibleTypes(allTypes, navPreferences);
    final selected = _selectedType(visibleTypes, _selectedKind);
    final shelf = ref.watch(shelfProvider);
    final counts = shelf.maybeWhen(
      data: _countsByKind,
      orElse: () => const <String, _LibraryKindCount>{},
    );
    final registry = ref.watch(resolvedLibraryTypesProvider);
    final topBar = _MediaLibraryNav(
      types: visibleTypes,
      counts: counts,
      registry: registry,
      selectedKind: selected.kind,
      onSelected: (type) => setState(() => _selectedKind = type.kind),
    );
    final titleBar = _MediaLibraryTitleBar(
      type: selected,
      registry: registry,
    );
    final selectedConfig = _libraryConfigForCatalogType(selected, registry);
    final content = selected.kind == 'comic'
        ? ComicsPage(
            topBar: navPreferences.placement == LibraryNavPlacement.top
                ? topBar
                : titleBar,
          )
        : GenericLibraryPage(
            type: selectedConfig,
            topBar: navPreferences.placement == LibraryNavPlacement.top
                ? topBar
                : titleBar,
            accent: libraryAccentForKind(selected.kind),
          );

    if (navPreferences.placement == LibraryNavPlacement.left) {
      return Theme(
        data: kClzComicsTheme,
        child: Row(
          children: [
            _MediaLibraryRail(
              types: visibleTypes,
              counts: counts,
              registry: registry,
              selectedKind: selected.kind,
              onSelected: (type) => setState(() => _selectedKind = type.kind),
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    return content;
  }
}

class _MediaLibraryNav extends StatelessWidget {
  const _MediaLibraryNav({
    required this.types,
    required this.counts,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
  });

  final List<CatalogMediaType> types;
  final Map<String, _LibraryKindCount> counts;
  final LibraryTypeRegistry registry;
  final String selectedKind;
  final ValueChanged<CatalogMediaType> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedType(types, selectedKind);
    final accent = libraryAccentForKind(selected.kind);
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: accent,
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
            child: _MediaLibraryNavStrip(
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

class _MediaLibraryTitleBar extends StatelessWidget {
  const _MediaLibraryTitleBar({
    required this.type,
    required this.registry,
  });

  final CatalogMediaType type;
  final LibraryTypeRegistry registry;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(type.kind);
    final icon = registry.byKind(type.kind)?.workspace.icon ??
        libraryIconForKind(type.kind);
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: accent,
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

class _MediaLibraryNavStrip extends StatelessWidget {
  const _MediaLibraryNavStrip({
    required this.types,
    required this.counts,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
  });

  final List<CatalogMediaType> types;
  final Map<String, _LibraryKindCount> counts;
  final LibraryTypeRegistry registry;
  final String selectedKind;
  final ValueChanged<CatalogMediaType> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxButtons =
            ((constraints.maxWidth - 42) / 116).floor().clamp(1, types.length);
        final split = _splitNavTypes(types, selectedKind, maxButtons);
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
                        child: _MediaLibraryNavButton(
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
              _MediaLibraryOverflowMenu(
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

class _MediaLibraryOverflowMenu extends StatelessWidget {
  const _MediaLibraryOverflowMenu({
    required this.types,
    required this.counts,
    required this.registry,
    required this.onSelected,
  });

  final List<CatalogMediaType> types;
  final Map<String, _LibraryKindCount> counts;
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

class _NavTypeSplit {
  const _NavTypeSplit({
    required this.visible,
    required this.overflow,
  });

  final List<CatalogMediaType> visible;
  final List<CatalogMediaType> overflow;
}

class _MediaLibraryRail extends StatelessWidget {
  const _MediaLibraryRail({
    required this.types,
    required this.counts,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
  });

  final List<CatalogMediaType> types;
  final Map<String, _LibraryKindCount> counts;
  final LibraryTypeRegistry registry;
  final String selectedKind;
  final ValueChanged<CatalogMediaType> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedType(types, selectedKind);
    final accent = libraryAccentForKind(selected.kind);
    return Container(
      width: 78,
      decoration: BoxDecoration(
        color: kClzToolbar,
        border: Border(right: BorderSide(color: accent)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 42,
              child: Icon(Icons.cloud_queue, color: accent, size: 22),
            ),
            const Divider(height: 1, color: kClzDivider),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: types.length,
                itemBuilder: (context, index) {
                  final type = types[index];
                  final typeAccent = libraryAccentForKind(type.kind);
                  final selected = type.kind == selectedKind;
                  return Tooltip(
                    message: type.pluralLabel,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: selected ? null : () => onSelected(type),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: selected
                                ? typeAccent.withValues(alpha: 0.34)
                                : Colors.black.withValues(alpha: 0.20),
                            border: Border.all(
                              color: selected ? Colors.white70 : typeAccent,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SizedBox(
                            height: 48,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  registry.byKind(type.kind)?.workspace.icon ??
                                      libraryIconForKind(type.kind),
                                  size: 19,
                                  color: selected ? Colors.white : typeAccent,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (counts[type.kind]?.total ?? 0).toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaLibraryNavButton extends StatelessWidget {
  const _MediaLibraryNavButton({
    required this.type,
    required this.color,
    required this.icon,
    required this.selected,
    required this.count,
    required this.onPressed,
  });

  final CatalogMediaType type;
  final Color color;
  final IconData icon;
  final bool selected;
  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? Colors.white.withValues(alpha: 0.24)
        : Colors.black.withValues(alpha: 0.28);
    final borderColor = selected ? Colors.white.withValues(alpha: 0.72) : color;
    return Tooltip(
      message: type.pluralLabel,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(3),
          onTap: selected ? null : onPressed,
          child: SizedBox(
            height: 30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 4, height: double.infinity, color: color),
                const SizedBox(width: 8),
                Icon(icon, size: 17, color: selected ? Colors.white : color),
                const SizedBox(width: 7),
                Text(
                  _navLabel(type),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
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

class _LibraryKindCount {
  const _LibraryKindCount({
    this.owned = 0,
    this.wishlist = 0,
  });

  final int owned;
  final int wishlist;

  int get total => owned + wishlist;

  _LibraryKindCount add({required bool owned, required bool wishlist}) {
    return _LibraryKindCount(
      owned: this.owned + (owned ? 1 : 0),
      wishlist: this.wishlist + (wishlist ? 1 : 0),
    );
  }
}

List<CatalogMediaType> _orderedTopLevelTypes(
  List<CatalogMediaType> catalog,
  LibraryNavPreferences preferences,
) {
  final topLevelByKind = {
    for (final type in catalog)
      if (type.isTopLevel) type.kind: type,
  };
  final defaultKinds = [
    for (final config in collectarrLibraryTypes.types) config.workspace.kind,
  ];
  final orderedKinds = preferences.orderedKinds([
    ...defaultKinds,
    ...topLevelByKind.keys,
  ]);
  final ordered = <CatalogMediaType>[];
  for (final kind in orderedKinds) {
    final type = topLevelByKind.remove(kind);
    if (type != null) {
      ordered.add(type);
    }
  }
  ordered.addAll(topLevelByKind.values.toList()
    ..sort((a, b) => a.pluralLabel.compareTo(b.pluralLabel)));
  return ordered.isEmpty
      ? fallbackMediaCatalog.where((t) => t.isTopLevel).toList()
      : ordered;
}

List<CatalogMediaType> _visibleTypes(
  List<CatalogMediaType> types,
  LibraryNavPreferences preferences,
) {
  final visible = [
    for (final type in types)
      if (preferences.isVisible(type.kind)) type,
  ];
  return visible.isEmpty ? types.take(1).toList(growable: false) : visible;
}

_NavTypeSplit _splitNavTypes(
  List<CatalogMediaType> types,
  String selectedKind,
  int maxVisible,
) {
  if (types.length <= maxVisible) {
    return _NavTypeSplit(visible: types, overflow: const []);
  }
  final visible = types.take(maxVisible).toList();
  final selected =
      _firstWhereOrNull(types, (type) => type.kind == selectedKind);
  if (selected != null && !visible.any((type) => type.kind == selectedKind)) {
    visible[visible.length - 1] = selected;
  }
  final visibleKinds = {for (final type in visible) type.kind};
  return _NavTypeSplit(
    visible: visible,
    overflow: [
      for (final type in types)
        if (!visibleKinds.contains(type.kind)) type,
    ],
  );
}

CatalogMediaType _selectedType(List<CatalogMediaType> types, String kind) {
  for (final type in types) {
    if (type.kind == kind) {
      return type;
    }
  }
  return types.first;
}

T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T value) test) {
  for (final value in values) {
    if (test(value)) {
      return value;
    }
  }
  return null;
}

LibraryTypeConfig _libraryConfigForCatalogType(
  CatalogMediaType type,
  LibraryTypeRegistry registry,
) {
  final known = registry.byKind(type.kind);
  if (known != null) {
    return known;
  }
  final providers = _providerOptionsForCatalogType(type);
  return LibraryTypeConfig(
    workspace: LibraryWorkspaceConfig(
      kind: type.kind,
      title: _displayLabel(type.pluralLabel, type.kind, plural: true),
      icon: libraryIconForKind(type.kind),
      preferencePrefix: 'catalog_${type.kind}',
      defaultSortColumn: LibrarySortColumn.title,
      defaultVisibleColumns: _fallbackVisibleColumnsForKind(type.kind),
    ),
    singularLabel: _displayLabel(type.singularLabel, type.kind),
    pluralLabel: _displayLabel(type.pluralLabel, type.kind, plural: true),
    defaultMetadataProvider: type.defaultProvider ??
        (type.providers.isEmpty ? '' : type.providers.first),
    metadataProviders: providers,
    trackingProfile: _trackingProfileForKind(type.kind),
  );
}

List<LibraryMetadataProviderOption> _providerOptionsForCatalogType(
  CatalogMediaType type,
) {
  final kind = type.kind.trim().toLowerCase();
  return [
    for (final providerId in type.providers)
      _providerOptionForCatalogKind(providerId, kind),
  ];
}

LibraryMetadataProviderOption _providerOptionForCatalogKind(
  String providerId,
  String kind,
) {
  final option = collectarrMetadataProviderRegistry.byId(providerId);
  if (option == null) {
    return LibraryMetadataProviderOption(
      id: providerId,
      label: _titleFromToken(providerId),
      supportedKinds: {kind},
    );
  }
  if (option.supportsKind(kind)) {
    return option;
  }
  return LibraryMetadataProviderOption(
    id: option.id,
    label: option.label,
    description: option.description,
    supportedKinds: {...option.supportedKinds, kind},
    requiresApiKey: option.requiresApiKey,
    usagePolicy: option.usagePolicy,
  );
}

Set<LibraryTableColumn> _fallbackVisibleColumnsForKind(String kind) {
  return {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    if (kind == 'comic' || kind == 'manga') LibraryTableColumn.issue,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.storageBox,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  };
}

MediaTrackingProfile _trackingProfileForKind(String kind) {
  return switch (kind) {
    'anime' || 'movie' || 'tv' => videoTrackingProfile,
    'boardgame' || 'game' => gameTrackingProfile,
    'comic' => comicTrackingProfile,
    _ => readingTrackingProfile,
  };
}

String _displayLabel(String value, String fallback, {bool plural = false}) {
  final trimmed = value.trim();
  if (trimmed.isNotEmpty) {
    return trimmed;
  }
  final label = _titleFromToken(fallback);
  return plural ? '${label}s' : label;
}

String _titleFromToken(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'[_-]+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'Library';
  }
  return [
    for (final part in parts)
      if (part.length == 1)
        part.toUpperCase()
      else
        '${part[0].toUpperCase()}${part.substring(1)}',
  ].join(' ');
}

Map<String, _LibraryKindCount> _countsByKind(ShelfState state) {
  final counts = <String, _LibraryKindCount>{};
  for (final entry in state.entries) {
    final kind = entry.catalogItem?.kind;
    if (kind == null || kind.isEmpty) {
      continue;
    }
    counts[kind] = (counts[kind] ?? const _LibraryKindCount()).add(
      owned: entry.isOwned,
      wishlist: entry.isWishlisted,
    );
  }
  return counts;
}

String _navLabel(CatalogMediaType type) {
  return switch (type.kind) {
    'boardgame' => 'Board Games',
    'music' => 'Music',
    'tv' => 'TV Shows',
    _ => type.pluralLabel,
  };
}
