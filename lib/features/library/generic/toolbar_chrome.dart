import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/config/library_media_presentation_models.dart'
    show LibrarySortFavorite;

const double kLibraryToolbarCompactBreakpoint = 760;

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

enum LibrarySeriesCompletionScope {
  all,
  completed,
  notCompleted,
}

extension LibrarySeriesCompletionScopeUi on LibrarySeriesCompletionScope {
  String get label {
    return switch (this) {
      LibrarySeriesCompletionScope.all => 'Show all series',
      LibrarySeriesCompletionScope.completed => 'Show completed',
      LibrarySeriesCompletionScope.notCompleted => 'Show not completed',
    };
  }

  IconData get icon {
    return switch (this) {
      LibrarySeriesCompletionScope.all => Icons.select_all,
      LibrarySeriesCompletionScope.completed => Icons.check_circle_outline,
      LibrarySeriesCompletionScope.notCompleted => Icons.radio_button_unchecked,
    };
  }
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
    this.missingSequenceSummary,
  });

  final String title;
  final int totalCount;
  final int ownedCount;
  final int wishlistCount;
  final int forSaleCount;
  final int onOrderCount;
  final int soldCount;
  final int catalogOnlyCount;
  final String? missingSequenceSummary;
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
  return type.presentation.sortFavorites;
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
  return type.presentation.columnFavorites;
}

Set<String> libraryDefaultPinnedColumnFavoriteKeysForType(
  LibraryTypeConfig type,
) {
  final presets = libraryColumnFavoritesForType(type);
  return {
    for (final preset in presets.take(2)) libraryColumnFavoriteKey(preset),
  };
}
