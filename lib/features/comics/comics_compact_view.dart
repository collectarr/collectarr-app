import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_duplicate_items.dart';
import 'package:collectarr_app/features/comics/comics_inspector.dart';
import 'package:collectarr_app/features/comics/comics_shelf_views.dart';
import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicsCompactView extends ConsumerWidget {
  const ComicsCompactView({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.selectedGroup,
    required this.queryController,
    required this.onSearch,
    required this.onAddComic,
    required this.onEditFilters,
    required this.hasActiveFilters,
    required this.activeFilterCount,
    required this.duplicateGroups,
    required this.onClearFilters,
    required this.coverSize,
    required this.onCoverSizeChanged,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onSelectItem,
    required this.onClearGroup,
  });

  final List<CatalogItem> items;
  final CatalogItem? selectedItem;
  final String? selectedGroup;
  final TextEditingController queryController;
  final ValueChanged<String> onSearch;
  final VoidCallback onAddComic;
  final VoidCallback onEditFilters;
  final bool hasActiveFilters;
  final int activeFilterCount;
  final List<ComicsDuplicateGroup> duplicateGroups;
  final VoidCallback onClearFilters;
  final double coverSize;
  final ValueChanged<double> onCoverSizeChanged;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<CatalogItem> onSelectItem;
  final VoidCallback onClearGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = watchComicWishlistIds(ref);
    return _CompactComicsView(
      items: items,
      ownedByItemId: ownedByItemId,
      wishlistIds: wishlistIds,
      selectedItem: selectedItem,
      selectedGroup: selectedGroup,
      queryController: queryController,
      onSearch: onSearch,
      onAddComic: onAddComic,
      onEditFilters: onEditFilters,
      hasActiveFilters: hasActiveFilters,
      activeFilterCount: activeFilterCount,
      duplicateGroups: duplicateGroups,
      onClearFilters: onClearFilters,
      coverSize: coverSize,
      onCoverSizeChanged: onCoverSizeChanged,
      onScanBarcode: onScanBarcode,
      onRefreshMetadata: onRefreshMetadata,
      onSelectItem: onSelectItem,
      onClearGroup: onClearGroup,
    );
  }
}

class _CompactComicsView extends StatelessWidget {
  const _CompactComicsView({
    required this.items,
    required this.ownedByItemId,
    required this.wishlistIds,
    required this.selectedItem,
    required this.selectedGroup,
    required this.queryController,
    required this.onSearch,
    required this.onAddComic,
    required this.onEditFilters,
    required this.hasActiveFilters,
    required this.activeFilterCount,
    required this.duplicateGroups,
    required this.onClearFilters,
    required this.coverSize,
    required this.onCoverSizeChanged,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onSelectItem,
    required this.onClearGroup,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Set<String> wishlistIds;
  final CatalogItem? selectedItem;
  final String? selectedGroup;
  final TextEditingController queryController;
  final ValueChanged<String> onSearch;
  final VoidCallback onAddComic;
  final VoidCallback onEditFilters;
  final bool hasActiveFilters;
  final int activeFilterCount;
  final List<ComicsDuplicateGroup> duplicateGroups;
  final VoidCallback onClearFilters;
  final double coverSize;
  final ValueChanged<double> onCoverSizeChanged;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<CatalogItem> onSelectItem;
  final VoidCallback onClearGroup;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Tooltip(
                  message: 'Add comics',
                  child: IconButton.filled(
                    onPressed: onAddComic,
                    icon: const Icon(Icons.add),
                  ),
                ),
                const SizedBox(width: 8),
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
                  message: 'Filters',
                  child: Badge(
                    isLabelVisible: hasActiveFilters,
                    label: Text(activeFilterCount.toString()),
                    child: IconButton.filledTonal(
                      onPressed: onEditFilters,
                      icon: const Icon(Icons.filter_list),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                if (hasActiveFilters) ...[
                  Tooltip(
                    message: 'Clear filters',
                    child: IconButton.filledTonal(
                      onPressed: onClearFilters,
                      icon: const Icon(Icons.filter_alt_off_outlined),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                if (duplicateGroups.isNotEmpty) ...[
                  Tooltip(
                    message: 'Duplicate candidates',
                    child: Badge(
                      label: Text(duplicateGroups.length.toString()),
                      child: IconButton.filledTonal(
                        onPressed: () => showComicsDuplicateItemsDialog(
                          context,
                          duplicateGroups: duplicateGroups,
                        ),
                        icon: const Icon(Icons.content_copy),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Tooltip(
                  message: 'Cover size',
                  child: IconButton.filledTonal(
                    onPressed: () => _showCompactCoverSizeSheet(
                      context,
                      coverSize,
                      onCoverSizeChanged,
                    ),
                    icon: const Icon(Icons.photo_size_select_large_outlined),
                  ),
                ),
                const SizedBox(width: 4),
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
        if (selectedGroup != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: InputChip(
                label: Text(selectedGroup!),
                onDeleted: onClearGroup,
              ),
            ),
          ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: ComicsEmptyState(onAddComic: onAddComic),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: coverSize,
                mainAxisExtent: coverSize * 1.53,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final ownedItem = ownedByItemId[item.id];
                return LibraryCoverTile(
                  entry: comicWorkspaceEntry(
                    item,
                    ownedItem,
                    null,
                    isWishlisted: wishlistIds.contains(item.id),
                  ),
                  selected: item.id == selectedItem?.id,
                  onTap: () {
                    onSelectItem(item);
                    _showCompactInspector(context, item);
                  },
                  selectedColor: kClzSelection,
                  accentColor: kClzAccent,
                  selectionColor: kClzYellow,
                  mutedTextColor: kClzTextMuted,
                );
              },
            ),
          ),
      ],
    );
  }
}

void _showCompactCoverSizeSheet(
  BuildContext context,
  double coverSize,
  ValueChanged<double> onCoverSizeChanged,
) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      var draftSize = coverSize;
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cover size',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  min: kComicsMinCoverSize,
                  max: kComicsMaxCoverSize,
                  divisions: 7,
                  value: draftSize,
                  onChanged: (value) {
                    setSheetState(() => draftSize = value);
                    onCoverSizeChanged(value);
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showCompactInspector(BuildContext context, CatalogItem item) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.9,
        child: LibraryAwareComicInspector(item: item),
      );
    },
  );
}
