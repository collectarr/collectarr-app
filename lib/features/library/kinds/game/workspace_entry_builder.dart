import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
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
  });

  factory GamePersonalOverlay.fromShelfEntry(ShelfEntry source) {
    return GamePersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      updatedAt: source.updatedAt,
    );
  }

  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final DateTime? updatedAt;

  bool get isOwned => ownedItem != null;
  bool get isTracked => trackingEntry != null;
  bool get isWishlisted => wishlistItem != null;
}

LibraryWorkspaceEntry buildGamesLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  return buildGameWorkspaceEntry(
    GameWork.fromCatalogItem(source.catalogItem!),
    GamePersonalOverlay.fromShelfEntry(source),
  );
}

LibraryWorkspaceEntry buildGamesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry as GameWorkspaceEntry;
  final selectedRelease = _gameReleaseById(
        entry.gameReleases,
        request.referenceEditionId ?? request.edition.id,
      ) ??
      _resolvePrimaryGameRelease(entry.gameReleases);
  final releasePlatform = selectedRelease?.platform?.trim().isNotEmpty == true
      ? selectedRelease!.platform!.trim()
      : entry.game?.platforms.isNotEmpty == true
          ? entry.game!.platforms.first
          : null;
  return GameWorkspaceEntry(
    common: LibraryWorkspaceEntryData(
      id: '${entry.id}:release:${request.edition.id}',
      browseScope: LibraryBrowserScope.release,
      titleItemId: entry.id,
      releaseId: request.edition.id,
      copyId: null,
      ownedItemId: null,
      mediaType: 'game',
      title: entry.title,
      displayTitle: entry.displayTitle,
      localizedTitle: entry.localizedTitle,
      originalTitle: entry.originalTitle,
      searchAliases: _copyStringList(entry.searchAliases),
      itemNumber: null,
      synopsis: entry.synopsis,
      coverImageUrl: selectedRelease?.coverImageUrl ?? entry.coverImageUrl,
      thumbnailImageUrl: selectedRelease?.coverImageUrl ??
          entry.thumbnailImageUrl ??
          entry.coverImageUrl,
      publisher: selectedRelease?.publisher ?? entry.publisher,
      coverDate: entry.coverDate,
      releaseDate: selectedRelease?.releaseDate ?? request.edition.releaseDate,
      releaseYear:
          (selectedRelease?.releaseDate ?? request.edition.releaseDate)?.year ??
              entry.releaseYear,
      barcode: selectedRelease?.barcode ?? request.edition.upc,
      variant: selectedRelease?.title ?? request.edition.title,
      crossover: entry.crossover,
      isOwned: request.isOwned,
      isTracked: request.isTracked,
      isWishlisted: request.isWishlisted,
      hasMissingCover: false,
      hasMissingMetadata: false,
      condition: null,
      grade: null,
      primaryReferenceLabel: null,
      referenceScopeLabel: null,
      referenceFormatLabel:
          releasePlatform ?? request.edition.physicalFormatLabel,
      referenceEditionId: request.referenceEditionId ?? request.edition.id,
      referenceVariantId: request.referenceVariantId,
      referenceBundleReleaseId: request.referenceBundleReleaseId,
      notes: null,
      tags: null,
      collectionStatus: null,
      lastBagBoardDate: null,
      pricePaidCents: null,
      currency: null,
      locationPath: null,
      addedAt: null,
      editions: const <CatalogEdition>[],
      updatedAt: request.updatedAt,
      trailerUrls: const <TrailerLink>[],
      plotSummary: null,
      plotDescription: null,
      creators: null,
      characters: null,
      storyArcs: null,
      genres: null,
      country: null,
      language: selectedRelease?.language ?? request.edition.language,
      ageRating: null,
      audienceRating: null,
    ),
    game: entry.game,
    gameReleases: entry.gameReleases,
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

GameRelease? _gameReleaseById(List<GameRelease> releases, String? releaseId) {
  final normalized = releaseId?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  for (final release in releases) {
    if (release.id == normalized) {
      return release;
    }
  }
  return null;
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
