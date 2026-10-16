import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/config/library_media_presentation_models.dart'
    show LibrarySortFavorite;

const double kLibraryToolbarCompactBreakpoint = 760;

/// The status filter a library opens with: albums in the collection, as in
/// the reference. Clearing filters returns here rather than to All.
const kDefaultCollectionStatusScope = LibraryCollectionStatusScope.inCollection;

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
  Color get color => switch (this) {
        LibraryCollectionStatusScope.all => const Color(0xff777777),
        LibraryCollectionStatusScope.inCollection => const Color(0xff2aa4cc),
        LibraryCollectionStatusScope.forSale => const Color(0xff2d7427),
        LibraryCollectionStatusScope.wishList => const Color(0xffff9b00),
        LibraryCollectionStatusScope.onOrder => const Color(0xff13627f),
        LibraryCollectionStatusScope.sold => const Color(0xffa63131),
        LibraryCollectionStatusScope.notInCollection => const Color(0xff605c5c),
      };

  String get label {
    return switch (this) {
      LibraryCollectionStatusScope.all => 'All',
      LibraryCollectionStatusScope.inCollection => 'In Collection',
      LibraryCollectionStatusScope.forSale => 'For Sale',
      LibraryCollectionStatusScope.wishList => 'On Wish List',
      LibraryCollectionStatusScope.onOrder => 'On Order',
      LibraryCollectionStatusScope.sold => 'Sold',
      LibraryCollectionStatusScope.notInCollection => 'Not in Collection',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryCollectionStatusScope.all => AppIcons.collectionStatusAll,
      LibraryCollectionStatusScope.inCollection => AppIcons.check,
      LibraryCollectionStatusScope.forSale => AppIcons.collectionStatusForSale,
      LibraryCollectionStatusScope.wishList =>
        AppIcons.collectionStatusWishList,
      LibraryCollectionStatusScope.onOrder => AppIcons.collectionStatusOnOrder,
      LibraryCollectionStatusScope.sold => AppIcons.collectionStatusSold,
      LibraryCollectionStatusScope.notInCollection => AppIcons.close,
    };
  }
}

enum LibraryBucketCompletionScope {
  all,
  completed,
  notCompleted,
}

extension LibraryBucketCompletionScopeUi on LibraryBucketCompletionScope {
  String get label {
    return switch (this) {
      LibraryBucketCompletionScope.all => 'Show all groups',
      LibraryBucketCompletionScope.completed => 'Show completed',
      LibraryBucketCompletionScope.notCompleted => 'Show not completed',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryBucketCompletionScope.all => Icons.select_all,
      LibraryBucketCompletionScope.completed => Icons.check_circle_outline,
      LibraryBucketCompletionScope.notCompleted => Icons.radio_button_unchecked,
    };
  }
}

class LibraryBucketStatusSummary {
  const LibraryBucketStatusSummary({
    required this.title,
    required this.totalCount,
    required this.entryCount,
    required this.wishlistCount,
    required this.forSaleCount,
    required this.onOrderCount,
    required this.soldCount,
    required this.catalogOnlyCount,
    this.missingSequenceSummary,
  });

  final String title;
  final int totalCount;
  final int entryCount;
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
  LibraryKindRegistration type,
) {
  return const {
    LibraryWorkspacePreset.cover,
    LibraryWorkspacePreset.list,
  };
}

List<LibrarySortFavorite> librarySortFavoritesForType(
  LibraryKindRegistration type,
) {
  return libraryPresentationForKind(type.kind).sortFavorites;
}

Set<String> libraryDefaultPinnedSortFavoriteIdsForType(
  LibraryKindRegistration type,
) {
  final favorites = librarySortFavoritesForType(type);
  return {
    for (final favorite in favorites.take(2)) favorite.id,
  };
}

Set<String> sanitizeLibraryPinnedSortFavoriteIds(
    LibraryKindRegistration type, Iterable<String> ids,
    {List<LibrarySortFavorite> additionalFavorites = const []}) {
  final availableIds = {
    for (final favorite in librarySortFavoritesForType(type)) favorite.id,
    for (final favorite in additionalFavorites) favorite.id,
  };
  return ids.where(availableIds.contains).toSet();
}

List<LibraryTableColumnPreset> libraryColumnFavoritesForType(
  LibraryKindRegistration type,
) {
  return libraryPresentationForKind(type.kind).columnFavorites;
}

Set<String> libraryDefaultPinnedColumnFavoriteKeysForType(
  LibraryKindRegistration type,
) {
  final presets = libraryColumnFavoritesForType(type);
  return {
    for (final preset in presets.take(2)) libraryColumnFavoriteKey(preset),
  };
}

Set<String> sanitizeLibraryPinnedColumnFavoriteKeys(
  LibraryKindRegistration type,
  Iterable<String> keys,
) {
  final availableBuiltInKeys =
      libraryColumnFavoritesForType(type).map(libraryColumnFavoriteKey).toSet();
  return keys
      .where((key) =>
          !key.startsWith('builtin:') || availableBuiltInKeys.contains(key))
      .toSet();
}
