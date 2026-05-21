import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool itemHasMissingCover(CatalogItem item) {
  return item.displayCoverUrl == null ||
      item.displayCoverUrl!.trim().isEmpty;
}

bool itemHasMissingDetails(CatalogItem item) {
  return (item.publisher == null || item.publisher!.trim().isEmpty) ||
      item.releaseDate == null ||
      (item.synopsis == null || item.synopsis!.trim().isEmpty);
}

LibraryWorkspaceEntry libraryWorkspaceEntryFromItem(
  CatalogItem item,
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem, {
  bool? isWishlisted,
}) {
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
    isWishlisted: isWishlisted ?? wishlistItem != null,
    hasMissingCover: itemHasMissingCover(item),
    hasMissingMetadata: itemHasMissingDetails(item),
    condition: ownedItem?.condition,
    grade: ownedItem?.grade,
    pricePaidCents: ownedItem?.pricePaidCents,
    currency: ownedItem?.currency,
    storageBox: ownedItem?.storageBox,
    seriesTitle: item.seriesTitle,
    volumeName: item.volumeName,
    volumeNumber: item.volumeNumber,
    seasonNumber: item.seasonNumber,
    episodeNumber: item.episodeNumber,
    trackCount: item.trackCount,
    tracks: item.tracks,
    creators: item.creators,
    characters: item.characters,
    storyArcs: item.storyArcs,
    genres: item.genres,
    pageCount: item.pageCount,
    coverPriceCents: item.coverPriceCents,
    catalogCurrency: item.currency,
    country: item.country,
    language: item.language,
    ageRating: item.ageRating,
    imprint: item.imprint,
    subtitle: item.subtitle,
    seriesGroup: item.seriesGroup,
    updatedAt: _latestLibraryUpdate(ownedItem, wishlistItem),
  );
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
