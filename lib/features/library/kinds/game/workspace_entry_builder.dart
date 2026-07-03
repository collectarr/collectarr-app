import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/game/game_domain.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
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
  final metadataItem = LibraryMetadataItem.fromCatalogItem(source.catalogItem!);
  return buildGameWorkspaceEntry(
    GameWork.fromMetadataItem(metadataItem),
    metadataItem,
    GamePersonalOverlay.fromShelfEntry(source),
  );
}

LibraryWorkspaceEntry buildGamesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final work = _gameWorkFromWorkspaceEntry(request.titleEntry);
  return GameWorkspaceEntry(
    common: _buildReleaseEntryData(request, work),
    game: GameCatalogDetails(platforms: work.platforms),
  );
}

LibraryWorkspaceEntry buildGameWorkspaceEntry(
  GameWork work,
  LibraryMetadataItem metadata,
  GamePersonalOverlay overlay,
) {
  final editions = [
    for (final release in work.releases) _gameReleaseToCatalogEdition(release),
  ];
  final referenceRelease = _resolvePrimaryGameRelease(work.releases);
  final referenceFormatLabel =
      referenceRelease?.format?.trim().isNotEmpty == true
          ? referenceRelease!.format!.trim()
          : referenceRelease?.title.trim().isNotEmpty == true
              ? referenceRelease!.title.trim()
              : metadata.physicalFormatLabel;
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
      displayTitle: metadata.displayTitle,
      localizedTitle: metadata.localizedTitle,
      originalTitle: metadata.originalTitle,
      searchAliases: _copyStringList(metadata.searchAliases),
      itemNumber: metadata.itemNumber,
      synopsis: metadata.synopsis,
      coverImageUrl: metadata.coverImageUrl ?? referenceRelease?.coverImageUrl,
      thumbnailImageUrl: metadata.thumbnailImageUrl ??
          referenceRelease?.coverImageUrl ??
          metadata.coverImageUrl,
      publisher: metadata.publisher,
      coverDate: metadata.coverDate,
      releaseDate: metadata.releaseDate,
      releaseYear: metadata.releaseYear,
      barcode: metadata.barcode,
      variant: referenceFormatLabel,
      crossover: metadata.crossover,
      isOwned: overlay.isOwned,
      isTracked: overlay.isTracked,
      isWishlisted: overlay.isWishlisted,
      hasMissingCover: metadata.coverImageUrl == null &&
          referenceRelease?.coverImageUrl == null,
      hasMissingMetadata: _hasMissingCoreMetadata(metadata),
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
      editions: _copyEditionList(editions),
      updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      trailerUrls: const <TrailerLink>[],
      plotSummary: metadata.plotSummary,
      plotDescription: metadata.plotDescription,
      creators: _copyCreatorList(metadata.creators),
      characters: _copyStringList(metadata.characters),
      storyArcs: _copyStringList(metadata.storyArcs),
      genres: _copyStringList(metadata.genres),
      country: metadata.country,
      language: metadata.language,
      ageRating: metadata.ageRating,
      audienceRating: metadata.audienceRating,
    ),
    game: GameCatalogDetails(platforms: work.platforms),
  );
}

LibraryWorkspaceEntryData _buildReleaseEntryData(
  LibraryReleaseEntryRequest request,
  GameWork work,
) {
  final referenceRelease = _resolvePrimaryGameRelease(work.releases);
  final selectedRelease = _gameReleaseById(
        work.releases,
        request.referenceEditionId ?? request.edition.id,
      ) ??
      referenceRelease;
  final releasePlatform = selectedRelease?.platform?.trim().isNotEmpty == true
      ? selectedRelease!.platform!.trim()
      : work.platforms.isNotEmpty
          ? work.platforms.first
          : null;
  return LibraryWorkspaceEntryData(
    id: '${request.titleEntry.id}:release:${request.edition.id}',
    browseScope: LibraryBrowserScope.release,
    titleItemId: request.titleEntry.id,
    releaseId: request.edition.id,
    copyId: null,
    ownedItemId: null,
    mediaType: 'game',
    title: request.titleEntry.title,
    displayTitle: request.titleEntry.displayTitle,
    localizedTitle: request.titleEntry.localizedTitle,
    originalTitle: request.titleEntry.originalTitle,
    searchAliases: _copyStringList(request.titleEntry.searchAliases),
    itemNumber: null,
    synopsis: request.titleEntry.synopsis,
    coverImageUrl:
        selectedRelease?.coverImageUrl ?? request.titleEntry.coverImageUrl,
    thumbnailImageUrl: selectedRelease?.coverImageUrl ??
        request.titleEntry.thumbnailImageUrl ??
        request.titleEntry.coverImageUrl,
    publisher: selectedRelease?.publisher ?? request.titleEntry.publisher,
    coverDate: request.titleEntry.coverDate,
    releaseDate: selectedRelease?.releaseDate ?? request.edition.releaseDate,
    releaseYear:
        (selectedRelease?.releaseDate ?? request.edition.releaseDate)?.year ??
            request.titleEntry.releaseYear,
    barcode: selectedRelease?.barcode ?? request.edition.upc,
    variant: selectedRelease?.title ?? request.edition.title,
    crossover: request.titleEntry.crossover,
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
    editions: _copyEditionList(
      request.editions.isEmpty ? [request.edition] : request.editions,
    ),
    updatedAt: request.updatedAt,
    trailerUrls: const <TrailerLink>[],
    creators: null,
    characters: null,
    storyArcs: null,
    genres: null,
    country: null,
    language: selectedRelease?.language ?? request.edition.language,
    ageRating: null,
    audienceRating: null,
  );
}

GameWork _gameWorkFromWorkspaceEntry(LibraryWorkspaceEntry entry) {
  return GameWork(
    id: entry.id,
    title: entry.title,
    platforms:
        List<String>.unmodifiable(entry.game?.platforms ?? const <String>[]),
    identifiers: const <String>[],
    companyRoles: const <String>[],
    ageRatings: const <String>[],
    releases: [
      for (final edition in entry.editions)
        GameRelease(
          id: edition.id,
          title: edition.title,
          platform: edition.variants.isNotEmpty
              ? edition.variants.first.platform
              : null,
          releaseDate: edition.releaseDate,
          format: edition.physicalFormatLabel ?? edition.physicalFormat,
          publisher: edition.publisher,
          catalogNumber: edition.upc,
          releaseStatus: null,
          language: edition.language,
          barcode: edition.upc,
        ),
    ],
  );
}

GameRelease? _resolvePrimaryGameRelease(List<GameRelease> releases) {
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

List<CatalogEdition> _copyEditionList(List<CatalogEdition> values) {
  return List<CatalogEdition>.unmodifiable(values);
}

CatalogEdition _gameReleaseToCatalogEdition(GameRelease release) {
  return CatalogEdition(
    id: release.id,
    title: release.title,
    format: release.format,
    publisher: release.publisher,
    isbn: null,
    upc: release.catalogNumber,
    language: release.language,
    region: release.regionCode,
    releaseDate: release.releaseDate,
    physicalFormat: release.platform,
    physicalFormatLabel: release.format ?? release.platform,
    variants: const <CatalogVariant>[],
  );
}

bool _hasMissingCoreMetadata(LibraryMetadataItem item) {
  return item.publisher == null &&
      item.releaseDate == null &&
      item.releaseYear == null &&
      item.coverImageUrl == null &&
      item.physicalFormatLabel == null;
}
