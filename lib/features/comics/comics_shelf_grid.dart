import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_shelf_empty_state.dart';
import 'package:collectarr_app/features/comics/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicsShelfCoverGrid extends ConsumerWidget {
  const ComicsShelfCoverGrid({
    super.key,
    required this.items,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.coverSize,
    required this.onAddComic,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = watchComicWishlistIds(ref);
    return _CoverGrid(
      items: items,
      ownedByItemId: ownedByItemId,
      wishlistIds: wishlistIds,
      selectedItemId: selectedItemId,
      selectedItemIds: selectedItemIds,
      coverSize: coverSize,
      onAddComic: onAddComic,
      onSelectItem: onSelectItem,
    );
  }
}

class ComicsShelfCardGrid extends ConsumerWidget {
  const ComicsShelfCardGrid({
    super.key,
    required this.items,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.coverSize,
    required this.onAddComic,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedByItemId = ref.watch(collectionByCatalogItemProvider);
    final wishlistIds = watchComicWishlistIds(ref);
    return _CardGrid(
      items: items,
      ownedByItemId: ownedByItemId,
      wishlistIds: wishlistIds,
      selectedItemId: selectedItemId,
      selectedItemIds: selectedItemIds,
      coverSize: coverSize,
      onAddComic: onAddComic,
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
    required this.selectedItemIds,
    required this.coverSize,
    required this.onAddComic,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Set<String> wishlistIds;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return LibraryWorkspaceGrid<CatalogItem>(
      items: items,
      emptyBuilder: (_) => ComicsEmptyState(onAddComic: onAddComic),
      maxCrossAxisExtent: coverSize,
      mainAxisExtent: coverSize * 1.53,
      backgroundColor: kClzGridCanvas,
      itemBuilder: (context, item) {
        final ownedItem = ownedByItemId[item.id];
        return LibraryCoverTile(
          entry: comicWorkspaceEntry(
            item,
            ownedItem,
            null,
            isWishlisted: wishlistIds.contains(item.id),
          ),
          selected:
              selectedItemIds.contains(item.id) || item.id == selectedItemId,
          onTap: () => onSelectItem(item),
          selectedColor: kClzSelection,
          accentColor: kClzAccent,
          selectionColor: kClzYellow,
          mutedTextColor: kClzTextMuted,
        );
      },
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({
    required this.items,
    required this.ownedByItemId,
    required this.wishlistIds,
    required this.selectedItemId,
    required this.selectedItemIds,
    required this.coverSize,
    required this.onAddComic,
    required this.onSelectItem,
  });

  final List<CatalogItem> items;
  final Map<String, OwnedItem> ownedByItemId;
  final Set<String> wishlistIds;
  final String? selectedItemId;
  final Set<String> selectedItemIds;
  final double coverSize;
  final VoidCallback onAddComic;
  final ValueChanged<CatalogItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    final cardHeight = (coverSize * 1.12).clamp(138.0, 174.0).toDouble();
    return LibraryWorkspaceGrid<CatalogItem>(
      items: items,
      emptyBuilder: (_) => ComicsEmptyState(onAddComic: onAddComic),
      maxCrossAxisExtent: 430,
      mainAxisExtent: cardHeight,
      backgroundColor: kClzGridCanvas,
      itemBuilder: (context, item) {
        final ownedItem = ownedByItemId[item.id];
        return _ComicCard(
          entry: comicWorkspaceEntry(
            item,
            ownedItem,
            null,
            isWishlisted: wishlistIds.contains(item.id),
          ),
          selected:
              selectedItemIds.contains(item.id) || item.id == selectedItemId,
          onTap: () => onSelectItem(item),
        );
      },
    );
  }
}

class _ComicCard extends StatelessWidget {
  const _ComicCard({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final LibraryWorkspaceEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LibraryWorkspaceCard(
      entry: entry,
      selected: selected,
      onTap: onTap,
      dateFormatter: formatComicDate,
      moneyFormatter: formatComicMoney,
      selectedColor: kClzSelection,
      accentColor: kClzAccent,
      mutedTextColor: kClzTextMuted,
    );
  }
}
