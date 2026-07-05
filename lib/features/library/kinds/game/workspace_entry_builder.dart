import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/catalog_item_types.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/kinds/game/game_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class GamePersonalOverlay {
  const GamePersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.updatedAt,
    this.itemImages = const <ItemImage>[],
    this.isOwnedOverride = false,
    this.isTrackedOverride = false,
    this.isWishlistedOverride = false,
  });

  factory GamePersonalOverlay.fromShelfEntry(ShelfEntry source) {
    return GamePersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      updatedAt: source.updatedAt,
      itemImages: source.itemImages,
    );
  }

  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final DateTime? updatedAt;
  final List<ItemImage> itemImages;
  final bool isOwnedOverride;
  final bool isTrackedOverride;
  final bool isWishlistedOverride;

  bool get isOwned => ownedItem != null || isOwnedOverride;
  bool get isTracked => trackingEntry != null || isTrackedOverride;
  bool get isWishlisted => wishlistItem != null || isWishlistedOverride;
}

LibraryWorkspaceEntry buildGameReleaseWorkspaceEntry({
  required GameWorkspaceEntry titleEntry,
  required GameRelease release,
  required GamePersonalOverlay overlay,
}) {
  final releasePlatform = release.platform?.trim().isNotEmpty == true
      ? release.platform!.trim()
      : titleEntry.game?.platforms.isNotEmpty == true
          ? titleEntry.game!.platforms.first
          : null;
  return GameWorkspaceEntry(
    common: LibraryWorkspaceEntryData(
      id: '${titleEntry.id}:release:${release.id}',
      browseScope: LibraryBrowserScope.release,
      titleItemId: titleEntry.id,
      releaseId: release.id,
      copyId: null,
      ownedItemId: overlay.ownedItem?.id,
      mediaType: 'game',
      title: titleEntry.title,
      displayTitle: titleEntry.displayTitle,
      localizedTitle: titleEntry.localizedTitle,
      originalTitle: titleEntry.originalTitle,
      searchAliases: _copyStringList(titleEntry.searchAliases),
      itemNumber: null,
      synopsis: titleEntry.synopsis,
      coverImageUrl: release.coverImageUrl ?? titleEntry.coverImageUrl,
      thumbnailImageUrl: release.coverImageUrl ??
          titleEntry.thumbnailImageUrl ??
          titleEntry.coverImageUrl,
      itemImages: overlay.itemImages,
      publisher: release.publisher ?? titleEntry.publisher,
      coverDate: titleEntry.coverDate,
      releaseDate: release.releaseDate,
      releaseYear: release.releaseDate?.year ?? titleEntry.releaseYear,
      barcode: release.barcode,
      variant: release.title,
      crossover: titleEntry.crossover,
      isOwned: overlay.isOwned,
      isTracked: overlay.isTracked,
      isWishlisted: overlay.isWishlisted,
      hasMissingCover: false,
      hasMissingMetadata: false,
      condition: overlay.ownedItem?.condition,
      grade: overlay.ownedItem?.grade,
      primaryReferenceLabel: libraryPrimaryReferenceLabel(
        ownedItem: overlay.ownedItem,
        wishlistItem: overlay.wishlistItem,
        mediaType: 'game',
      ),
      referenceScopeLabel: libraryReferenceScopeLabel(
        ownedItem: overlay.ownedItem,
        wishlistItem: overlay.wishlistItem,
        mediaType: 'game',
      ),
      referenceFormatLabel: releasePlatform,
      referenceEditionId: release.id,
      referenceVariantId:
          overlay.ownedItem?.variantId ?? overlay.wishlistItem?.variantId,
      referenceBundleReleaseId: overlay.ownedItem?.bundleReleaseId ??
          overlay.wishlistItem?.bundleReleaseId,
      notes: overlay.ownedItem?.personalNotes ?? overlay.wishlistItem?.notes,
      tags: overlay.ownedItem?.tags,
      collectionStatus: overlay.ownedItem?.collectionStatus,
      lastBagBoardDate: overlay.ownedItem?.lastBagBoardDate,
      pricePaidCents: overlay.ownedItem?.pricePaidCents,
      currency: overlay.ownedItem?.currency,
      locationPath: overlay.locationPath,
      addedAt: overlay.ownedItem?.createdAt ?? overlay.wishlistItem?.createdAt,
      editions: const <CatalogEdition>[],
      updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      trailerUrls: _copyTrailerList(titleEntry.trailerUrls),
      plotSummary: titleEntry.plotSummary,
      plotDescription: titleEntry.plotDescription,
      creators: _copyCreatorList(titleEntry.creators),
      characters: _copyStringList(titleEntry.characters),
      storyArcs: _copyStringList(titleEntry.storyArcs),
      genres: _copyStringList(titleEntry.genres),
      country: titleEntry.country,
      language: release.language ?? titleEntry.language,
      ageRating: titleEntry.ageRating,
      audienceRating: titleEntry.audienceRating,
    ),
    game: titleEntry.game,
    gameReleases: titleEntry.gameReleases,
  );
}

LibraryWorkspaceEntry buildGameWorkspaceEntry(
  GameWork work,
  GamePersonalOverlay overlay,
) {
  final releases = _copyGameReleaseList(work.releases);
  final referenceRelease = _resolvePrimaryGameRelease(releases);
  final referenceFormatLabel =
      referenceRelease?.format?.trim().isNotEmpty == true
          ? referenceRelease!.format!.trim()
          : referenceRelease?.title.trim().isNotEmpty == true
              ? referenceRelease!.title.trim()
              : work.physicalFormatLabel;
  return GameWorkspaceEntry(
    common: LibraryWorkspaceEntryData(
      id: work.id,
      browseScope: LibraryBrowserScope.title,
      titleItemId: work.id,
      releaseId: null,
      copyId: null,
      ownedItemId: overlay.ownedItem?.id,
      mediaType: 'game',
      title: work.title,
      displayTitle: work.displayTitle,
      localizedTitle: work.localizedTitle,
      originalTitle: work.originalTitle,
      searchAliases: _copyStringList(work.searchAliases),
      itemNumber: work.itemNumber,
      synopsis: work.synopsis,
      coverImageUrl: work.coverImageUrl ?? referenceRelease?.coverImageUrl,
      thumbnailImageUrl: work.thumbnailImageUrl ??
          referenceRelease?.coverImageUrl ??
          work.coverImageUrl,
      itemImages: overlay.itemImages,
      publisher: work.publisher ?? referenceRelease?.publisher,
      coverDate: work.coverDate,
      releaseDate: work.releaseDate ?? referenceRelease?.releaseDate,
      releaseYear: work.releaseYear ?? referenceRelease?.releaseDate?.year,
      barcode: work.barcode ?? referenceRelease?.barcode,
      variant: referenceFormatLabel,
      crossover: work.crossover,
      isOwned: overlay.isOwned,
      isTracked: overlay.isTracked,
      isWishlisted: overlay.isWishlisted,
      hasMissingCover:
          work.coverImageUrl == null && referenceRelease?.coverImageUrl == null,
      hasMissingMetadata: work.hasMissingCoreMetadata,
      condition: overlay.ownedItem?.condition,
      grade: overlay.ownedItem?.grade,
      primaryReferenceLabel: libraryPrimaryReferenceLabel(
        ownedItem: overlay.ownedItem,
        wishlistItem: overlay.wishlistItem,
        mediaType: 'game',
      ),
      referenceScopeLabel: libraryReferenceScopeLabel(
        ownedItem: overlay.ownedItem,
        wishlistItem: overlay.wishlistItem,
        mediaType: 'game',
      ),
      referenceFormatLabel: referenceFormatLabel,
      referenceEditionId: overlay.ownedItem?.editionId ??
          overlay.wishlistItem?.editionId ??
          referenceRelease?.id,
      referenceVariantId:
          overlay.ownedItem?.variantId ?? overlay.wishlistItem?.variantId,
      referenceBundleReleaseId: overlay.ownedItem?.bundleReleaseId ??
          overlay.wishlistItem?.bundleReleaseId,
      notes: overlay.ownedItem?.personalNotes ?? overlay.wishlistItem?.notes,
      tags: overlay.ownedItem?.tags,
      collectionStatus: overlay.ownedItem?.collectionStatus,
      lastBagBoardDate: overlay.ownedItem?.lastBagBoardDate,
      pricePaidCents: overlay.ownedItem?.pricePaidCents,
      currency: overlay.ownedItem?.currency,
      locationPath: overlay.locationPath,
      addedAt: overlay.ownedItem?.createdAt ?? overlay.wishlistItem?.createdAt,
      editions: const <CatalogEdition>[],
      updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      trailerUrls: _copyTrailerList(work.trailerUrls),
      plotSummary: work.plotSummary,
      plotDescription: work.plotDescription,
      creators: _copyCreatorList(work.creators),
      characters: _copyStringList(work.characters),
      storyArcs: _copyStringList(work.storyArcs),
      genres: _copyStringList(work.genres),
      country: work.country,
      language: work.language ?? referenceRelease?.language,
      ageRating: work.ageRating,
      audienceRating: work.audienceRating,
    ),
    game: GameCatalogDetails(platforms: work.platforms),
    gameReleases: releases,
  );
}

GameRelease? _resolvePrimaryGameRelease(List<GameRelease> releases) {
  for (final release in releases) {
    if (release.isPrimary) {
      return release;
    }
  }
  return releases.isEmpty ? null : releases.first;
}

List<GameRelease> _copyGameReleaseList(List<GameRelease> values) {
  return List<GameRelease>.unmodifiable(values);
}

List<String>? _copyStringList(List<String>? values) {
  if (values == null) return null;
  return List<String>.unmodifiable(values);
}

List<Map<String, dynamic>>? _copyCreatorList(
  List<Map<String, dynamic>>? values,
) {
  if (values == null) return null;
  return List<Map<String, dynamic>>.unmodifiable(
    values.map((value) => Map<String, dynamic>.unmodifiable(value)),
  );
}

List<TrailerLink> _copyTrailerList(List<TrailerLink> values) {
  return List<TrailerLink>.unmodifiable(values);
}
