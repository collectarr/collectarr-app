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
    final selectedConfig = registry.byKind(selected.kind);
    final content = selected.kind == 'comic'
        ? ComicsPage(
            topBar: navPreferences.placement == LibraryNavPlacement.top
                ? topBar
                : titleBar,
          )
        : selectedConfig == null
            ? _PlannedLibraryPage(
                type: selected,
                config: selectedConfig,
                count: counts[selected.kind] ?? const _LibraryKindCount(),
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

class _PlannedLibraryPage extends StatelessWidget {
  const _PlannedLibraryPage({
    required this.type,
    required this.config,
    required this.count,
    required this.topBar,
  });

  final CatalogMediaType type;
  final LibraryTypeConfig? config;
  final _LibraryKindCount count;
  final Widget topBar;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kClzComicsTheme,
      child: Scaffold(
        backgroundColor: kClzCanvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              topBar,
              _PlannedLibraryToolbar(
                type: type,
                config: config,
                count: count,
              ),
              Expanded(
                child: _PlannedLibraryWorkspace(
                  type: type,
                  config: config,
                  count: count,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

class _PlannedLibraryToolbar extends StatelessWidget {
  const _PlannedLibraryToolbar({
    required this.type,
    required this.config,
    required this.count,
  });

  final CatalogMediaType type;
  final LibraryTypeConfig? config;
  final _LibraryKindCount count;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(type.kind);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kClzToolbar,
        border: Border(bottom: BorderSide(color: kClzDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              height: 30,
              child: FilledButton.icon(
                onPressed: null,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: accent.withValues(alpha: 0.44),
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                icon: const Icon(Icons.add, size: 17),
                label: Text('Add ${type.pluralLabel}'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox.square(
              dimension: 30,
              child: IconButton.filledTonal(
                tooltip: 'Scan barcode',
                onPressed: null,
                icon: const Icon(Icons.qr_code_scanner, size: 17),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 330,
              child: SearchBar(
                enabled: false,
                constraints: const BoxConstraints.tightFor(height: 32),
                hintText: 'Search ${type.pluralLabel.toLowerCase()}...',
                leading: Icon(
                    config?.workspace.icon ?? libraryIconForKind(type.kind)),
              ),
            ),
            const Spacer(),
            _ToolbarCount(label: 'Shown', value: count.total),
            const SizedBox(width: 8),
            _ToolbarCount(label: 'Owned', value: count.owned),
            const SizedBox(width: 8),
            _ToolbarCount(label: 'Wishlist', value: count.wishlist),
            const SizedBox(width: 8),
            const Icon(Icons.grid_view, color: Colors.white70, size: 18),
            const SizedBox(width: 12),
            const Icon(Icons.view_list, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}

class _PlannedLibraryWorkspace extends StatelessWidget {
  const _PlannedLibraryWorkspace({
    required this.type,
    required this.config,
    required this.count,
  });

  final CatalogMediaType type;
  final LibraryTypeConfig? config;
  final _LibraryKindCount count;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind(type.kind);
    final icon = config?.workspace.icon ?? libraryIconForKind(type.kind);
    return Row(
      children: [
        SizedBox(
          width: 250,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: kClzPanel),
            child: Column(
              children: [
                Container(
                  height: 42,
                  color: const Color(0xFF303030),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.folder, color: accent, size: 19),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          librarySidebarTitleForKind(type.kind),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Icon(Icons.tune, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        count.total == 0 ? '[All ${type.pluralLabel}]' : 'All',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.76)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ColoredBox(
            color: kClzCanvas,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 44, color: accent),
                    const SizedBox(height: 14),
                    Text(
                      'Your local ${type.pluralLabel.toLowerCase()} shelf is empty',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _providerSummary(type),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: kClzTextMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        SizedBox(
          width: 340,
          child: ColoredBox(
            color: kClzCanvas,
            child: Center(
              child: Text(
                'No ${type.singularLabel.toLowerCase()} selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolbarCount extends StatelessWidget {
  const _ToolbarCount({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF343434),
          border: Border.all(color: kClzDivider),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: kClzTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
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

String _providerSummary(CatalogMediaType type) {
  final providers = type.providers.isEmpty
      ? 'No providers registered'
      : 'Providers: ${type.providers.join(', ')}';
  if (type.physicalFormats.isEmpty) {
    return providers;
  }
  return '$providers. Formats: ${type.physicalFormats.map((f) => f.label).join(', ')}';
}
