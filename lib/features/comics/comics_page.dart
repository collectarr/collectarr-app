import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _kDesktopBreakpoint = 980;

enum _ComicsViewMode { grid, list }

class ComicsPage extends ConsumerStatefulWidget {
  const ComicsPage({super.key});

  @override
  ConsumerState<ComicsPage> createState() => _ComicsPageState();
}

class _ComicsPageState extends ConsumerState<ComicsPage> {
  String query = 'spider-man';
  String? selectedItemId;
  String? selectedSeries;
  _ComicsViewMode viewMode = _ComicsViewMode.grid;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(comicsSearchProvider(query));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F6),
      body: SafeArea(
        bottom: false,
        child: results.when(
          data: (items) => _ComicsWorkspace(
            items: items,
            queryController: _controller,
            selectedItemId: selectedItemId,
            selectedSeries: selectedSeries,
            viewMode: viewMode,
            onSearch: (value) => setState(() {
              query = value.trim();
              selectedItemId = null;
              selectedSeries = null;
            }),
            onSelectItem: (item) => setState(() => selectedItemId = item.id),
            onSelectSeries: (series) => setState(() {
              selectedSeries = series;
              selectedItemId = null;
            }),
            onClearSeries: () => setState(() => selectedSeries = null),
            onScanBarcode: () => _handleBarcodeScan(context),
            onViewModeChanged: (value) => setState(() => viewMode = value),
          ),
          error: (error, stackTrace) => _ErrorState(message: error.toString()),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Future<void> _handleBarcodeScan(BuildContext context) async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const BarcodeScanSheet(),
    );
    if (code == null || !context.mounted) {
      return;
    }

    try {
      final result =
          await ref.read(apiClientProvider).lookupBarcode(code, kind: 'comic');
      final item = CatalogItem.fromJson(result);
      await CatalogCacheRepository(ref.read(localDatabaseProvider))
          .upsertAll([item]);
      setState(() {
        query = item.title;
        selectedSeries = null;
        selectedItemId = item.id;
        _controller.text = item.title;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Found ${item.title}')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No metadata found for barcode $code')),
        );
      }
    }
  }
}

class _ComicsWorkspace extends StatelessWidget {
  const _ComicsWorkspace({
    required this.items,
    required this.queryController,
    required this.selectedItemId,
    required this.selectedSeries,
    required this.viewMode,
    required this.onSearch,
    required this.onSelectItem,
    required this.onSelectSeries,
    required this.onClearSeries,
    required this.onScanBarcode,
    required this.onViewModeChanged,
  });

  final List<CatalogItem> items;
  final TextEditingController queryController;
  final String? selectedItemId;
  final String? selectedSeries;
  final _ComicsViewMode viewMode;
  final ValueChanged<String> onSearch;
  final ValueChanged<CatalogItem> onSelectItem;
  final ValueChanged<String> onSelectSeries;
  final VoidCallback onClearSeries;
  final VoidCallback onScanBarcode;
  final ValueChanged<_ComicsViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= _kDesktopBreakpoint;
    final series = _seriesBuckets(items);
    final visibleItems = selectedSeries == null
        ? items
        : items
            .where((item) => item.title == selectedSeries)
            .toList(growable: false);
    final selectedItem = _selectedItem(visibleItems, selectedItemId);

    if (!isWide) {
      return _LibraryAwareCompactComicsView(
        items: visibleItems,
        selectedItem: selectedItem,
        selectedSeries: selectedSeries,
        queryController: queryController,
        onSearch: onSearch,
        onScanBarcode: onScanBarcode,
        onRefreshMetadata: () => _showMetadataRefreshPlaceholder(context),
        onSelectItem: onSelectItem,
        onClearSeries: onClearSeries,
      );
    }

    return Column(
      children: [
        _ComicsToolbar(
          controller: queryController,
          itemCount: visibleItems.length,
          totalCount: items.length,
          selectedSeries: selectedSeries,
          viewMode: viewMode,
          onSearch: onSearch,
          onScanBarcode: onScanBarcode,
          onRefreshMetadata: () => _showMetadataRefreshPlaceholder(context),
          onClearSeries: onClearSeries,
          onViewModeChanged: onViewModeChanged,
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 250,
                child: _SeriesSidebar(
                  series: series,
                  selectedSeries: selectedSeries,
                  onSelectSeries: onSelectSeries,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: viewMode == _ComicsViewMode.grid
                    ? _LibraryAwareCoverGrid(
                        items: visibleItems,
                        selectedItemId: selectedItem?.id,
                        onSelectItem: onSelectItem,
                      )
                    : _LibraryAwareComicList(
                        items: visibleItems,
                        selectedItemId: selectedItem?.id,
                        onSelectItem: onSelectItem,
                      ),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 340,
                child: _LibraryAwareComicInspector(item: selectedItem),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_SeriesBucket> _seriesBuckets(List<CatalogItem> source) {
    final counts = <String, int>{};
    for (final item in source) {
      counts[item.title] = (counts[item.title] ?? 0) + 1;
    }
    final buckets = counts.entries
        .map((entry) => _SeriesBucket(title: entry.key, count: entry.value))
        .toList(growable: false)
      ..sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    return buckets;
  }

  void _showMetadataRefreshPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Metadata refresh is not wired yet')),
    );
  }

  CatalogItem? _selectedItem(
      List<CatalogItem> visibleItems, String? selectedId) {
    if (visibleItems.isEmpty) {
      return null;
    }
    if (selectedId == null) {
      return visibleItems.first;
    }
    for (final item in visibleItems) {
      if (item.id == selectedId) {
        return item;
      }
    }
    return visibleItems.first;
  }
}

class _ComicsToolbar extends StatelessWidget {
  const _ComicsToolbar({
    required this.controller,
    required this.itemCount,
    required this.totalCount,
    required this.selectedSeries,
    required this.viewMode,
    required this.onSearch,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onClearSeries,
    required this.onViewModeChanged,
  });

  final TextEditingController controller;
  final int itemCount;
  final int totalCount;
  final String? selectedSeries;
  final _ComicsViewMode viewMode;
  final ValueChanged<String> onSearch;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final VoidCallback onClearSeries;
  final ValueChanged<_ComicsViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add Comics'),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Scan barcode',
              child: IconButton.filledTonal(
                onPressed: onScanBarcode,
                icon: const Icon(Icons.qr_code_scanner),
              ),
            ),
            Tooltip(
              message: 'Refresh metadata',
              child: IconButton.filledTonal(
                onPressed: onRefreshMetadata,
                icon: const Icon(Icons.sync),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 360,
              child: SearchBar(
                controller: controller,
                hintText: 'Search comics...',
                leading: const Icon(Icons.search),
                trailing: [
                  Tooltip(
                    message: 'Search',
                    child: IconButton(
                      onPressed: () => onSearch(controller.text),
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
                onSubmitted: onSearch,
              ),
            ),
            if (selectedSeries != null) ...[
              const SizedBox(width: 8),
              InputChip(
                label: Text(selectedSeries!),
                onDeleted: onClearSeries,
              ),
            ],
            const Spacer(),
            _ToolbarStat(label: 'Shown', value: itemCount),
            const SizedBox(width: 8),
            _ToolbarStat(label: 'Total', value: totalCount),
            const SizedBox(width: 8),
            SegmentedButton<_ComicsViewMode>(
              segments: const [
                ButtonSegment(
                  value: _ComicsViewMode.grid,
                  icon: Tooltip(
                    message: 'Grid view',
                    child: Icon(Icons.grid_view),
                  ),
                ),
                ButtonSegment(
                  value: _ComicsViewMode.list,
                  icon: Tooltip(
                    message: 'List view',
                    child: Icon(Icons.view_list),
                  ),
                ),
              ],
              selected: {viewMode},
              onSelectionChanged: (selection) =>
                  onViewModeChanged(selection.first),
              showSelectedIcon: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarStat extends StatelessWidget {
  const _ToolbarStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textTheme.labelSmall),
        Text(value.toString(), style: textTheme.titleMedium),
      ],
    );
  }
}

class _SeriesSidebar extends StatelessWidget {
  const _SeriesSidebar({
    required this.series,
    required this.selectedSeries,
    required this.onSelectSeries,
  });

  final List<_SeriesBucket> series;
  final String? selectedSeries;
  final ValueChanged<String> onSelectSeries;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLowest),
      child: Column(
        children: [
          Container(
            height: 42,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder, size: 18),
                const SizedBox(width: 8),
                Text('Series', style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: series.length,
              itemBuilder: (context, index) {
                final bucket = series[index];
                final selected = bucket.title == selectedSeries;
                return _SeriesRow(
                  bucket: bucket,
                  selected: selected,
                  onTap: () => onSelectSeries(bucket.title),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesRow extends StatelessWidget {
  const _SeriesRow({
    required this.bucket,
    required this.selected,
    required this.onTap,
  });

  final _SeriesBucket bucket;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: selected ? colorScheme.primaryContainer : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                bucket.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(width: 8),
            Badge(
              label: Text(bucket.count.toString()),
              backgroundColor: selected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              textColor: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryAwareCoverGrid extends ConsumerWidget {
  const _LibraryAwareCoverGrid({
    required this.items,
    required this.selectedItemId,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final String? selectedItemId;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = _watchWishlistIds(ref);
    return _CoverGrid(
      items: items,
      ownedByItemId: ownedByItemId,
      wishlistIds: wishlistIds,
      selectedItemId: selectedItemId,
      onSelectItem: onSelectItem,
    );
  }
}

class _CoverGrid extends StatelessWidget {
  const _CoverGrid({
    required this.items,
    required this.ownedByItemId,
    required this.wishlistIds,
    required this.selectedItemId,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Set<String> wishlistIds;
  final String? selectedItemId;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState();
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 128,
        mainAxisExtent: 196,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _CoverTile(
          item: item,
          libraryState: _LibraryState(
            ownedItem: ownedByItemId[item.id],
            isWishlisted: wishlistIds.contains(item.id),
          ),
          selected: item.id == selectedItemId,
          onTap: () => onSelectItem(item),
        );
      },
    );
  }
}

class _LibraryAwareComicList extends ConsumerWidget {
  const _LibraryAwareComicList({
    required this.items,
    required this.selectedItemId,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final String? selectedItemId;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = _watchWishlistIds(ref);
    return _ComicList(
      items: items,
      ownedByItemId: ownedByItemId,
      wishlistIds: wishlistIds,
      selectedItemId: selectedItemId,
      onSelectItem: onSelectItem,
    );
  }
}

class _ComicList extends StatelessWidget {
  const _ComicList({
    required this.items,
    required this.ownedByItemId,
    required this.wishlistIds,
    required this.selectedItemId,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Set<String> wishlistIds;
  final String? selectedItemId;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final libraryState = _LibraryState(
          ownedItem: ownedByItemId[item.id],
          isWishlisted: wishlistIds.contains(item.id),
        );
        return _ComicListRow(
          item: item,
          libraryState: libraryState,
          selected: item.id == selectedItemId,
          onTap: () => onSelectItem(item),
        );
      },
    );
  }
}

class _ComicListRow extends StatelessWidget {
  const _ComicListRow({
    required this.item,
    required this.libraryState,
    required this.selected,
    required this.onTap,
  });

  final CatalogItem item;
  final _LibraryState libraryState;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ownedItem = libraryState.ownedItem;
    return Material(
      color: selected ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 96,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color:
                  selected ? colorScheme.primary : colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: _CoverImage(item: item),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.itemNumber == null
                          ? item.title
                          : '${item.title} #${item.itemNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                    if (item.synopsis != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.synopsis!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (libraryState.isOwned)
                          _StatusPill(
                            icon: Icons.inventory_2,
                            label: ownedItem?.grade == null
                                ? 'Owned'
                                : 'Owned ${ownedItem!.grade}',
                          ),
                        if (libraryState.isWishlisted)
                          const _StatusPill(
                            icon: Icons.star,
                            label: 'Wishlist',
                          ),
                        if (!libraryState.isOwned && !libraryState.isWishlisted)
                          const _StatusPill(
                            icon: Icons.library_add,
                            label: 'Catalog',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _CoverTile extends StatelessWidget {
  const _CoverTile({
    required this.item,
    required this.libraryState,
    required this.selected,
    required this.onTap,
  });

  final CatalogItem item;
  final _LibraryState libraryState;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CoverImage(item: item),
                  Positioned(
                    left: 4,
                    top: 4,
                    child: _CoverBadges(libraryState: libraryState),
                  ),
                  if (selected)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.check_circle,
                            color: colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.itemNumber == null
                  ? item.title
                  : '${item.title} #${item.itemNumber}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverBadges extends StatelessWidget {
  const _CoverBadges({required this.libraryState});

  final _LibraryState libraryState;

  @override
  Widget build(BuildContext context) {
    if (!libraryState.isOwned && !libraryState.isWishlisted) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 4,
      children: [
        if (libraryState.isOwned)
          const _CoverBadge(icon: Icons.inventory_2, label: 'Owned'),
        if (libraryState.isWishlisted)
          const _CoverBadge(icon: Icons.star, label: 'Wishlist'),
      ],
    );
  }
}

class _CoverBadge extends StatelessWidget {
  const _CoverBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 13, color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final placeholder = _GeneratedCover(item: item);
    final url = item.displayCoverUrl;
    if (url == null || url.isEmpty) {
      return placeholder;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}

class _GeneratedCover extends StatelessWidget {
  const _GeneratedCover({required this.item});

  final CatalogItem item;

  static const _palettes = [
    (Color(0xFF145DA0), Color(0xFFB1D4E0), Color(0xFFFFFFFF)),
    (Color(0xFFB22222), Color(0xFFFFD166), Color(0xFFFFFFFF)),
    (Color(0xFF2D6A4F), Color(0xFF95D5B2), Color(0xFFFFFFFF)),
    (Color(0xFF3D348B), Color(0xFFF7B801), Color(0xFFFFFFFF)),
    (Color(0xFF22223B), Color(0xFFC9ADA7), Color(0xFFFFFFFF)),
    (Color(0xFF7F5539), Color(0xFFE6CCB2), Color(0xFF201A16)),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[item.title.hashCode.abs() % _palettes.length];
    final title = item.title.replaceAll(', Vol.', '\nVol.');
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: DecoratedBox(
        decoration: BoxDecoration(color: palette.$1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(height: 18, color: palette.$2),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(height: 28, color: const Color(0x33000000)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 34),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 86,
                  child: Text(
                    title,
                    maxLines: 4,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.$3,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 0.95,
                    ),
                  ),
                ),
              ),
            ),
            if (item.itemNumber != null)
              Positioned(
                right: 6,
                bottom: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.$2,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Text(
                      '#${item.itemNumber}',
                      style: TextStyle(
                        color: palette.$3 == const Color(0xFFFFFFFF)
                            ? const Color(0xFF1D1D1D)
                            : palette.$3,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LibraryAwareComicInspector extends ConsumerWidget {
  const _LibraryAwareComicInspector({required this.item});

  final CatalogItem? item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = _watchWishlistIds(ref);
    return _ComicInspector(
      item: item,
      libraryState: _libraryStateFor(item, ownedByItemId, wishlistIds),
    );
  }
}

class _ComicInspector extends ConsumerWidget {
  const _ComicInspector({
    required this.item,
    required this.libraryState,
  });

  final CatalogItem? item;
  final _LibraryState libraryState;

  static const _conditions = [
    'Near Mint',
    'Very Fine',
    'Fine',
    'Good',
    'Poor',
  ];

  static const _grades = [
    'Ungraded',
    '10.0',
    '9.8',
    '9.6',
    '9.4',
    '9.0',
    '8.0',
    '7.0',
    '6.0',
    '5.0',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final ownedItem = libraryState.ownedItem;
    final isOwned = ownedItem != null;
    if (item == null) {
      return const _EmptyInspector();
    }
    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.surface),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item!.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Tooltip(
                message:
                    isOwned ? 'Remove from collection' : 'Add to collection',
                child: IconButton.filled(
                  onPressed: isOwned
                      ? () => _removeFromCollection(context, ref, ownedItem)
                      : () => _addToCollection(context, ref, item!),
                  icon: Icon(isOwned ? Icons.remove : Icons.add),
                ),
              ),
            ],
          ),
          Text(
            item!.itemNumber == null ? item!.kind : '#${item!.itemNumber}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 2 / 3,
            child: _CoverImage(item: item!),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.inventory_2,
                label: isOwned ? 'Owned' : 'Not owned',
              ),
              _MetaChip(
                icon:
                    libraryState.isWishlisted ? Icons.star : Icons.star_border,
                label: libraryState.isWishlisted ? 'Wishlisted' : 'Wishlist',
              ),
              _MetaChip(
                icon: Icons.verified_outlined,
                label: ownedItem?.grade ?? 'Ungraded',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CollectionFields(
            enabled: isOwned,
            condition: ownedItem?.condition,
            grade: ownedItem?.grade,
            conditions: _conditions,
            grades: _grades,
            onConditionChanged: ownedItem == null
                ? null
                : (value) => _updateCollection(
                      context,
                      ref,
                      ownedItem,
                      condition: value,
                      grade: ownedItem.grade,
                    ),
            onGradeChanged: ownedItem == null
                ? null
                : (value) => _updateCollection(
                      context,
                      ref,
                      ownedItem,
                      condition: ownedItem.condition,
                      grade: value,
                    ),
          ),
          if (ownedItem != null) ...[
            const SizedBox(height: 12),
            _PersonalDetailsEditor(ownedItem: ownedItem),
          ],
          const SizedBox(height: 16),
          if (item!.synopsis != null)
            Text(item!.synopsis!,
                style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          if (isOwned)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _moveToWishlist(
                    context,
                    ref,
                    item!,
                    ownedItem,
                  ),
                  icon: const Icon(Icons.star_border),
                  label: const Text('Move to wishlist'),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      _removeFromCollection(context, ref, ownedItem),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Remove'),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: () => _addToCollection(context, ref, item!),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add to collection'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _toggleWishlist(context, ref, item!),
                  icon: Icon(
                    libraryState.isWishlisted ? Icons.star : Icons.star_border,
                  ),
                  label: Text(
                    libraryState.isWishlisted
                        ? 'Remove from wishlist'
                        : 'Move to wishlist',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _addToCollection(
      BuildContext context, WidgetRef ref, CatalogItem item) async {
    await ref.read(collectionMutationsProvider).addItem(
          item.id,
          condition: 'Near Mint',
          grade: 'Ungraded',
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to local collection')),
      );
    }
  }

  Future<void> _updateCollection(
    BuildContext context,
    WidgetRef ref,
    OwnedItem ownedItem, {
    required String? condition,
    required String? grade,
  }) async {
    await ref.read(collectionMutationsProvider).updateItem(
          ownedItem,
          condition: condition,
          grade: grade,
          purchaseDate: ownedItem.purchaseDate,
          pricePaidCents: ownedItem.pricePaidCents,
          currency: ownedItem.currency,
          personalNotes: ownedItem.personalNotes,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection details updated')),
      );
    }
  }

  Future<void> _removeFromCollection(
      BuildContext context, WidgetRef ref, OwnedItem ownedItem) async {
    await ref.read(collectionMutationsProvider).removeItem(ownedItem);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from local collection')),
      );
    }
  }

  Future<void> _moveToWishlist(
    BuildContext context,
    WidgetRef ref,
    CatalogItem item,
    OwnedItem ownedItem,
  ) async {
    await ref.read(collectionMutationsProvider).addToWishlist(item.id);
    await ref.read(collectionMutationsProvider).removeItem(ownedItem);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Moved to local wishlist')),
      );
    }
  }

  Future<void> _toggleWishlist(
      BuildContext context, WidgetRef ref, CatalogItem item) async {
    await ref.read(collectionMutationsProvider).toggleWishlist(item.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            libraryState.isWishlisted
                ? 'Removed from local wishlist'
                : 'Saved to local wishlist',
          ),
        ),
      );
    }
  }
}

class _CollectionFields extends StatelessWidget {
  const _CollectionFields({
    required this.enabled,
    required this.condition,
    required this.grade,
    required this.conditions,
    required this.grades,
    required this.onConditionChanged,
    required this.onGradeChanged,
  });

  final bool enabled;
  final String? condition;
  final String? grade;
  final List<String> conditions;
  final List<String> grades;
  final ValueChanged<String?>? onConditionChanged;
  final ValueChanged<String?>? onGradeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: conditions.contains(condition) ? condition : null,
            decoration: const InputDecoration(
              labelText: 'Condition',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final option in conditions)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: enabled ? onConditionChanged : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: grades.contains(grade) ? grade : null,
            decoration: const InputDecoration(
              labelText: 'Grade',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final option in grades)
                DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: enabled ? onGradeChanged : null,
          ),
        ),
      ],
    );
  }
}

class _PersonalDetailsEditor extends ConsumerStatefulWidget {
  const _PersonalDetailsEditor({required this.ownedItem});

  final OwnedItem ownedItem;

  @override
  ConsumerState<_PersonalDetailsEditor> createState() =>
      _PersonalDetailsEditorState();
}

class _PersonalDetailsEditorState
    extends ConsumerState<_PersonalDetailsEditor> {
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _notesController;
  DateTime? _purchaseDate;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _currencyController = TextEditingController();
    _notesController = TextEditingController();
    _syncFromItem(widget.ownedItem);
  }

  @override
  void didUpdateWidget(covariant _PersonalDetailsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownedItem.id != widget.ownedItem.id ||
        oldWidget.ownedItem.updatedAt != widget.ownedItem.updatedAt) {
      _syncFromItem(widget.ownedItem);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _currencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Personal details',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickPurchaseDate,
              icon: const Icon(Icons.event),
              label: Text(
                _purchaseDate == null
                    ? 'Set purchase date'
                    : 'Purchased ${_formatDate(_purchaseDate!)}',
              ),
            ),
            if (_purchaseDate != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _purchaseDate = null),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear purchase date'),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price paid',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _currencyController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Personal notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save personal details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncFromItem(OwnedItem item) {
    _purchaseDate = item.purchaseDate;
    _priceController.text = item.pricePaidCents == null
        ? ''
        : (item.pricePaidCents! / 100).toStringAsFixed(2);
    _currencyController.text = item.currency ?? 'USD';
    _notesController.text = item.personalNotes ?? '';
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && mounted) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _save() async {
    final price = _parsePriceCents(_priceController.text);
    final currency = _currencyController.text.trim().toUpperCase();
    await ref.read(collectionMutationsProvider).updateItem(
          widget.ownedItem,
          condition: widget.ownedItem.condition,
          grade: widget.ownedItem.grade,
          purchaseDate: _purchaseDate,
          pricePaidCents: price,
          currency: currency.isEmpty ? null : currency,
          personalNotes: _emptyToNull(_notesController.text),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal details saved')),
      );
    }
  }

  int? _parsePriceCents(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      return widget.ownedItem.pricePaidCents;
    }
    return (parsed * 100).round();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _LibraryAwareCompactComicsView extends ConsumerWidget {
  const _LibraryAwareCompactComicsView({
    required this.items,
    required this.selectedItem,
    required this.selectedSeries,
    required this.queryController,
    required this.onSearch,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onSelectItem,
    required this.onClearSeries,
  });

  final List<CatalogItem> items;
  final CatalogItem? selectedItem;
  final String? selectedSeries;
  final TextEditingController queryController;
  final ValueChanged<String> onSearch;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<CatalogItem> onSelectItem;
  final VoidCallback onClearSeries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = _watchWishlistIds(ref);
    return _CompactComicsView(
      items: items,
      ownedByItemId: ownedByItemId,
      wishlistIds: wishlistIds,
      selectedItem: selectedItem,
      selectedSeries: selectedSeries,
      queryController: queryController,
      onSearch: onSearch,
      onScanBarcode: onScanBarcode,
      onRefreshMetadata: onRefreshMetadata,
      onSelectItem: onSelectItem,
      onClearSeries: onClearSeries,
    );
  }
}

class _CompactComicsView extends StatelessWidget {
  const _CompactComicsView({
    required this.items,
    required this.ownedByItemId,
    required this.wishlistIds,
    required this.selectedItem,
    required this.selectedSeries,
    required this.queryController,
    required this.onSearch,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onSelectItem,
    required this.onClearSeries,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Set<String> wishlistIds;
  final CatalogItem? selectedItem;
  final String? selectedSeries;
  final TextEditingController queryController;
  final ValueChanged<String> onSearch;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<CatalogItem> onSelectItem;
  final VoidCallback onClearSeries;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    controller: queryController,
                    hintText: 'Search comics...',
                    leading: const Icon(Icons.search),
                    onSubmitted: onSearch,
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Scan barcode',
                  child: IconButton.filledTonal(
                    onPressed: onScanBarcode,
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'Refresh metadata',
                  child: IconButton.filledTonal(
                    onPressed: onRefreshMetadata,
                    icon: const Icon(Icons.sync),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedSeries != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: InputChip(
                  label: Text(selectedSeries!), onDeleted: onClearSeries),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 130,
              mainAxisExtent: 196,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _CoverTile(
                item: item,
                libraryState: _LibraryState(
                  ownedItem: ownedByItemId[item.id],
                  isWishlisted: wishlistIds.contains(item.id),
                ),
                selected: item.id == selectedItem?.id,
                onTap: () {
                  onSelectItem(item);
                  _showCompactInspector(context, item);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

void _showCompactInspector(BuildContext context, CatalogItem item) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.9,
        child: _LibraryAwareComicInspector(item: item),
      );
    },
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No comics found'));
  }
}

class _EmptyInspector extends StatelessWidget {
  const _EmptyInspector();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No comic selected'));
  }
}

class _SeriesBucket {
  const _SeriesBucket({required this.title, required this.count});

  final String title;
  final int count;
}

class _LibraryState {
  const _LibraryState({this.ownedItem, this.isWishlisted = false});

  final OwnedItem? ownedItem;
  final bool isWishlisted;

  bool get isOwned => ownedItem != null;
}

Set<String> _watchWishlistIds(WidgetRef ref) {
  return ref.watch(wishlistIdsProvider).maybeWhen(
        data: (ids) => ids,
        orElse: () => const <String>{},
      );
}

_LibraryState _libraryStateFor(
  CatalogItem? item,
  Map<String, OwnedItem> ownedByItemId,
  Set<String> wishlistIds,
) {
  if (item == null) {
    return const _LibraryState();
  }
  return _LibraryState(
    ownedItem: ownedByItemId[item.id],
    isWishlisted: wishlistIds.contains(item.id),
  );
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
