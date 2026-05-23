import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryOwnedItemResolution {
  const LibraryOwnedItemResolution({
    required this.ownedItem,
    this.nextSelectedOwnedItemId,
    this.clearNewest = false,
  });

  final OwnedItem? ownedItem;
  final String? nextSelectedOwnedItemId;
  final bool clearNewest;

  bool shouldScheduleSelection(
    String? currentSelectedOwnedItemId,
    bool currentSelectNewest,
  ) {
    if (ownedItem == null || nextSelectedOwnedItemId == null) {
      return false;
    }
    return nextSelectedOwnedItemId != currentSelectedOwnedItemId ||
        (clearNewest && currentSelectNewest);
  }
}

bool itemHasMissingCover(CatalogItem item) {
  return item.displayCoverUrl == null ||
      item.displayCoverUrl!.trim().isEmpty;
}

bool itemHasMissingDetails(CatalogItem item) {
  return (item.publisher == null || item.publisher!.trim().isEmpty) ||
      item.releaseDate == null ||
      (item.synopsis == null || item.synopsis!.trim().isEmpty);
}

bool libraryShowsTrackData(String mediaType) {
  return collectarrLibraryTypes
          .byKind(mediaType)
          ?.capabilities
          .showsTrackData ??
      false;
}

bool libraryShowsSynopsis(String mediaType) {
  return collectarrLibraryTypes.byKind(mediaType)?.capabilities.showsSynopsis ??
      false;
}

bool libraryShowsReadingQueue(String mediaType) {
  final type = collectarrLibraryTypes.byKind(mediaType);
  if (type == null) {
    return false;
  }
  return type.trackingProfile.name == readingTrackingProfile.name;
}

LibraryWorkspaceEntry libraryWorkspaceEntryFromItem(
  CatalogItem item,
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem, {
  bool? isWishlisted,
}) {
  final series = item.series;
  final video = item.video;
  final music = item.music;
  final game = item.game;
  final publishing = item.publishing;
  return LibraryWorkspaceEntry(
    id: item.id,
    mediaType: item.kind,
    title: item.title,
    itemNumber: item.itemNumber,
    synopsis: item.synopsis,
    coverImageUrl: item.coverImageUrl,
    thumbnailImageUrl: item.thumbnailImageUrl,
    publisher: item.publisher,
    releaseDate: item.releaseDate,
    releaseYear: item.releaseYear,
    barcode: item.barcode,
    variant: item.variant,
    isOwned: ownedItem != null,
    isTracked: false,
    isWishlisted: isWishlisted ?? wishlistItem != null,
    hasMissingCover: itemHasMissingCover(item),
    hasMissingMetadata: itemHasMissingDetails(item),
    condition: ownedItem?.condition,
    grade: ownedItem?.grade,
    rawOrSlabbed: ownedItem?.rawOrSlabbed,
    gradingCompany: ownedItem?.gradingCompany,
    keyComic: ownedItem?.keyComic ?? false,
    keyReason: ownedItem?.keyReason,
    notes: ownedItem?.personalNotes ?? wishlistItem?.notes,
    primaryReferenceLabel: libraryPrimaryReferenceLabel(
      ownedItem: ownedItem,
      wishlistItem: wishlistItem,
    ),
    pricePaidCents: ownedItem?.pricePaidCents,
    currency: ownedItem?.currency,
    storageBox: ownedItem?.storageBox,
    series: series,
    video: video,
    music: music,
    game: game,
    publishing: publishing,
    creators: item.creators,
    characters: item.characters,
    storyArcs: item.storyArcs,
    genres: item.genres,
    country: item.country,
    language: item.language,
    ageRating: item.ageRating,
    editions: item.editions,
    updatedAt: _latestLibraryUpdate(ownedItem, wishlistItem),
  );
}

String? libraryOwnedReferenceLabel(OwnedItem? ownedItem) {
  return _libraryReferenceLabel(
    ownedItem?.personalAnchor,
    itemLabel: 'Owned as media',
    releaseLabel: 'Owned as release',
    bundleLabel: 'Owned as bundle',
  );
}

String? libraryWishlistReferenceLabel(WishlistItem? wishlistItem) {
  return _libraryReferenceLabel(
    wishlistItem?.personalAnchor,
    itemLabel: 'Wishlisted as media',
    releaseLabel: 'Wishlisted as release',
    bundleLabel: 'Wishlisted as bundle',
  );
}

String? libraryPrimaryReferenceLabel({
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem,
}) {
  return libraryOwnedReferenceLabel(ownedItem) ??
      libraryWishlistReferenceLabel(wishlistItem);
}

String? resolveLibraryOwnedItemId(
  LibraryWorkspaceEntry entry,
  OwnedItem? ownedItem,
) {
  return ownedItem?.id ?? entry.ownedItemId;
}

TrackingEntry? resolveActiveTrackingEntry(
  List<TrackingEntry> entries,
  OwnedItem? activeOwnedItem,
) {
  if (entries.isEmpty) {
    return null;
  }
  if (activeOwnedItem != null) {
    for (final entry in entries) {
      if (entry.ownedItemId == activeOwnedItem.id) {
        return entry;
      }
    }
  }
  for (final entry in entries) {
    if (entry.ownedItemId == null) {
      return entry;
    }
  }
  return entries.first;
}

LibraryOwnedItemResolution resolveActiveOwnedItem(
  List<OwnedItem> ownedCopies, {
  OwnedItem? fallback,
  String? selectedOwnedItemId,
  bool selectNewest = false,
}) {
  if (ownedCopies.isEmpty) {
    return LibraryOwnedItemResolution(ownedItem: fallback);
  }
  if (selectNewest) {
    final newest = ownedCopies.first;
    return LibraryOwnedItemResolution(
      ownedItem: newest,
      nextSelectedOwnedItemId: newest.id,
      clearNewest: true,
    );
  }
  if (selectedOwnedItemId != null) {
    for (final item in ownedCopies) {
      if (item.id == selectedOwnedItemId) {
        return LibraryOwnedItemResolution(ownedItem: item);
      }
    }
  }
  final resolved = fallback != null
      ? ownedCopies.firstWhere(
          (item) => item.id == fallback.id,
          orElse: () => ownedCopies.first,
        )
      : ownedCopies.first;
  return LibraryOwnedItemResolution(
    ownedItem: resolved,
    nextSelectedOwnedItemId: resolved.id,
  );
}

String? _libraryReferenceLabel(
  PersonalItemAnchorType? anchor,
  {
  required String itemLabel,
  required String releaseLabel,
  required String bundleLabel,
}) {
  return switch (anchor) {
    PersonalItemAnchorType.item => itemLabel,
    PersonalItemAnchorType.variant => releaseLabel,
    PersonalItemAnchorType.bundleRelease => bundleLabel,
    null => null,
  };
}

String buildOwnedCopyLabel(
  OwnedItem item,
  List<CatalogEdition> editions,
  int index,
) {
  final parts = <String>['Copy ${index + 1}'];
  final editionLabel = _ownedCopyEditionLabel(item, editions);
  if (editionLabel != null) {
    parts.add(editionLabel);
  }
  if (item.condition != null && item.condition!.trim().isNotEmpty) {
    parts.add(item.condition!.trim());
  }
  if (item.grade != null && item.grade!.trim().isNotEmpty) {
    parts.add(item.grade!.trim());
  }
  if (item.storageBox != null && item.storageBox!.trim().isNotEmpty) {
    parts.add(item.storageBox!.trim());
  }
  final purchaseLabel = formatNullableDate(item.purchaseDate);
  if (purchaseLabel != null) {
    parts.add(purchaseLabel);
  }
  return parts.join('  ·  ');
}

String? _ownedCopyEditionLabel(OwnedItem item, List<CatalogEdition> editions) {
  CatalogEdition? matchedEdition;
  CatalogVariant? matchedVariant;
  if (item.editionId != null) {
    for (final edition in editions) {
      if (edition.id == item.editionId) {
        matchedEdition = edition;
        break;
      }
    }
  }
  if (item.variantId != null) {
    final editionPool =
        matchedEdition != null ? <CatalogEdition>[matchedEdition] : editions;
    for (final edition in editionPool) {
      for (final variant in edition.variants) {
        if (variant.id == item.variantId) {
          matchedEdition ??= edition;
          matchedVariant = variant;
          break;
        }
      }
      if (matchedVariant != null) {
        break;
      }
    }
  }
  final parts = <String>[];
  final editionTitle = matchedEdition?.title.trim();
  if (editionTitle != null && editionTitle.isNotEmpty) {
    parts.add(editionTitle);
  }
  final variantName = matchedVariant?.name.trim();
  if (variantName != null &&
      variantName.isNotEmpty &&
      !parts.contains(variantName)) {
    parts.add(variantName);
  }
  if (parts.isEmpty) {
    return null;
  }
  return parts.join(' / ');
}

Set<String> watchWishlistIds(WidgetRef ref) {
  return ref.watch(wishlistIdsProvider).maybeWhen(
        data: (ids) => ids,
        orElse: () => const <String>{},
      );
}

String formatMoney(int? cents, String? currency) {
  if (cents == null) {
    return '';
  }
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  final prefix = currency == null || currency.isEmpty ? '' : '$currency ';
  return '$prefix$sign$whole.$fraction';
}

String formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

String? formatNullableDate(DateTime? value) {
  return value == null ? null : formatDate(value);
}

DateTime _latestLibraryUpdate(
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem,
) {
  final ownedUpdated = ownedItem?.updatedAt;
  final wishUpdated = wishlistItem?.updatedAt;
  if (ownedUpdated == null) {
    return wishUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  if (wishUpdated == null) {
    return ownedUpdated;
  }
  return ownedUpdated.isAfter(wishUpdated) ? ownedUpdated : wishUpdated;
}
