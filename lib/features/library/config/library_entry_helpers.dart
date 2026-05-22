import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
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
    isWishlisted: isWishlisted ?? wishlistItem != null,
    hasMissingCover: itemHasMissingCover(item),
    hasMissingMetadata: itemHasMissingDetails(item),
    condition: ownedItem?.condition,
    grade: ownedItem?.grade,
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
