import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

enum LibraryCollectionStatusScope {
  all,
  inCollection,
  forSale,
  wishList,
  onOrder,
  sold,
  notInCollection,
}

extension LibraryCollectionStatusScopeUi on LibraryCollectionStatusScope {
  String get label {
    return switch (this) {
      LibraryCollectionStatusScope.all => 'All',
      LibraryCollectionStatusScope.inCollection => 'In collection',
      LibraryCollectionStatusScope.forSale => 'For sale',
      LibraryCollectionStatusScope.wishList => 'Wish List',
      LibraryCollectionStatusScope.onOrder => 'On Order',
      LibraryCollectionStatusScope.sold => 'Sold',
      LibraryCollectionStatusScope.notInCollection => 'Not in Collection',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryCollectionStatusScope.all => Icons.select_all,
      LibraryCollectionStatusScope.inCollection => Icons.inventory_2_outlined,
      LibraryCollectionStatusScope.forSale => Icons.sell_outlined,
      LibraryCollectionStatusScope.wishList => Icons.star_border,
      LibraryCollectionStatusScope.onOrder => Icons.local_shipping_outlined,
      LibraryCollectionStatusScope.sold => Icons.paid_outlined,
      LibraryCollectionStatusScope.notInCollection =>
        Icons.hide_source_outlined,
    };
  }
}

class LibrarySortFavorite {
  const LibrarySortFavorite({
    required this.id,
    required this.label,
    required this.icon,
    required this.rules,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<LibrarySortRule> rules;
}

class LibrarySeriesStatusSummary {
  const LibrarySeriesStatusSummary({
    required this.title,
    required this.totalCount,
    required this.ownedCount,
    required this.wishlistCount,
    required this.forSaleCount,
    required this.onOrderCount,
    required this.soldCount,
    required this.catalogOnlyCount,
    this.missingIssueSummary,
  });

  final String title;
  final int totalCount;
  final int ownedCount;
  final int wishlistCount;
  final int forSaleCount;
  final int onOrderCount;
  final int soldCount;
  final int catalogOnlyCount;
  final String? missingIssueSummary;
}

String libraryColumnFavoriteKey(LibraryTableColumnPreset preset) {
  final rawKey = preset.id ?? preset.label;
  final normalized = rawKey.trim().toLowerCase().replaceAll(' ', '_');
  return preset.isSaved ? 'saved:$normalized' : 'builtin:$normalized';
}

Set<LibraryWorkspacePreset> libraryDefaultPinnedViewPresetsForType(
  LibraryTypeConfig type,
) {
  return const {
    LibraryWorkspacePreset.cover,
    LibraryWorkspacePreset.list,
  };
}

List<LibrarySortFavorite> librarySortFavoritesForType(
  LibraryTypeConfig type,
) {
  return switch (type.workspace.kind) {
    CatalogMediaKind.comic => const [
        LibrarySortFavorite(
          id: 'series_issue',
          label: 'Series + issue',
          icon: Icons.format_list_numbered,
          rules: [
            LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
            LibrarySortRule(column: LibrarySortColumn.issue, ascending: true),
            LibrarySortRule(column: LibrarySortColumn.variant, ascending: true),
          ],
        ),
        LibrarySortFavorite(
          id: 'recent',
          label: 'Recently added',
          icon: Icons.update,
          rules: [
            LibrarySortRule(
                column: LibrarySortColumn.updated, ascending: false),
            LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
          ],
        ),
        LibrarySortFavorite(
          id: 'publisher_date',
          label: 'Publisher + date',
          icon: Icons.business_outlined,
          rules: [
            LibrarySortRule(
                column: LibrarySortColumn.publisher, ascending: true),
            LibrarySortRule(
                column: LibrarySortColumn.releaseDate, ascending: true),
            LibrarySortRule(column: LibrarySortColumn.issue, ascending: true),
          ],
        ),
        LibrarySortFavorite(
          id: 'value_desc',
          label: 'Value high to low',
          icon: Icons.attach_money,
          rules: [
            LibrarySortRule(column: LibrarySortColumn.price, ascending: false),
            LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
          ],
        ),
      ],
    _ => const [
        LibrarySortFavorite(
          id: 'title_asc',
          label: 'Title A-Z',
          icon: Icons.sort_by_alpha,
          rules: [
            LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
          ],
        ),
        LibrarySortFavorite(
          id: 'release_latest',
          label: 'Latest release',
          icon: Icons.event,
          rules: [
            LibrarySortRule(
                column: LibrarySortColumn.releaseDate, ascending: false),
            LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
          ],
        ),
        LibrarySortFavorite(
          id: 'recent',
          label: 'Recently added',
          icon: Icons.update,
          rules: [
            LibrarySortRule(
                column: LibrarySortColumn.updated, ascending: false),
            LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
          ],
        ),
        LibrarySortFavorite(
          id: 'value_desc',
          label: 'Value high to low',
          icon: Icons.attach_money,
          rules: [
            LibrarySortRule(column: LibrarySortColumn.price, ascending: false),
            LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
          ],
        ),
      ],
  };
}

Set<String> libraryDefaultPinnedSortFavoriteIdsForType(
  LibraryTypeConfig type,
) {
  final favorites = librarySortFavoritesForType(type);
  return {
    for (final favorite in favorites.take(2)) favorite.id,
  };
}

List<LibraryTableColumnPreset> libraryColumnFavoritesForType(
  LibraryTypeConfig type,
) {
  return switch (type.workspace.kind) {
    CatalogMediaKind.comic => comicsTableColumnPresets,
    _ => const [
        LibraryTableColumnPreset(
          label: 'Essential',
          columns: {
            LibraryTableColumn.status,
            LibraryTableColumn.title,
            LibraryTableColumn.publisher,
            LibraryTableColumn.releaseDate,
            LibraryTableColumn.updated,
          },
        ),
        LibraryTableColumnPreset(
          label: 'Collection',
          columns: {
            LibraryTableColumn.status,
            LibraryTableColumn.title,
            LibraryTableColumn.condition,
            LibraryTableColumn.grade,
            LibraryTableColumn.price,
            LibraryTableColumn.wishlist,
            LibraryTableColumn.updated,
          },
        ),
        LibraryTableColumnPreset(
          label: 'Reference',
          columns: {
            LibraryTableColumn.status,
            LibraryTableColumn.title,
            LibraryTableColumn.variant,
            LibraryTableColumn.publisher,
            LibraryTableColumn.releaseDate,
            LibraryTableColumn.barcode,
            LibraryTableColumn.updated,
          },
        ),
      ],
  };
}

Set<String> libraryDefaultPinnedColumnFavoriteKeysForType(
  LibraryTypeConfig type,
) {
  final presets = libraryColumnFavoritesForType(type);
  return {
    for (final preset in presets.take(2)) libraryColumnFavoriteKey(preset),
  };
}
