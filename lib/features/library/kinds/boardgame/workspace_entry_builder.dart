import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class BoardGamePersonalOverlay {
  const BoardGamePersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.updatedAt,
  });

  factory BoardGamePersonalOverlay.fromShelfEntry(ShelfEntry source) {
    return BoardGamePersonalOverlay(
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

LibraryWorkspaceEntry buildBoardGamesLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  return buildBoardGameWorkspaceEntry(
    _boardGameWorkFromCatalogItem(source.catalogItem!),
    source.catalogItem!,
    BoardGamePersonalOverlay.fromShelfEntry(source),
  );
}

LibraryWorkspaceEntry buildBoardGamesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final work = _boardGameWorkFromWorkspaceEntry(request.titleEntry);
  return BoardGameWorkspaceEntry(
    common: _buildReleaseEntryData(request, work),
    series: request.titleEntry.series,
    publishing: request.titleEntry.publishing,
    game: null,
  );
}

LibraryWorkspaceEntry buildBoardGameWorkspaceEntry(
  BoardGameWork work,
  CatalogItem metadata,
  BoardGamePersonalOverlay overlay,
) {
  final selectedEdition = work.editions.isEmpty ? null : work.editions.first;
  final referenceFormatLabel = selectedEdition == null
      ? metadata.physicalFormatLabel
      : selectedEdition.format?.trim().isNotEmpty == true
          ? selectedEdition.format!.trim()
          : selectedEdition.editionTitle?.trim().isNotEmpty == true
              ? selectedEdition.editionTitle!.trim()
              : metadata.physicalFormatLabel;
  final genres = <String>[
    ...?metadata.genres,
    ...work.categories,
    ...work.mechanics,
  ];
  return BoardGameWorkspaceEntry(
    common: LibraryWorkspaceEntryData(
      id: work.id,
      browseScope: LibraryBrowserScope.title,
      titleItemId: work.id,
      releaseId: null,
      copyId: null,
      ownedItemId: overlay.ownedItem?.id,
      mediaType: 'boardgame',
      title: work.title,
      displayTitle: metadata.displayTitle,
      localizedTitle: metadata.localizedTitle,
      originalTitle: metadata.originalTitle,
      searchAliases: _copyStringList(metadata.searchAliases),
      itemNumber: metadata.itemNumber,
      synopsis: metadata.synopsis,
      coverImageUrl: metadata.coverImageUrl ?? selectedEdition?.coverImageUrl,
      thumbnailImageUrl: metadata.thumbnailImageUrl ??
          selectedEdition?.coverImageUrl ??
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
          selectedEdition?.coverImageUrl == null,
      hasMissingMetadata: _hasMissingCoreMetadata(metadata),
      condition: overlay.ownedItem?.condition,
      grade: overlay.ownedItem?.grade,
      primaryReferenceLabel: libraryPrimaryReferenceLabel(
        ownedItem: overlay.ownedItem,
        wishlistItem: overlay.wishlistItem,
        mediaType: 'boardgame',
      ),
      referenceScopeLabel: libraryReferenceScopeLabel(
        ownedItem: overlay.ownedItem,
        wishlistItem: overlay.wishlistItem,
        mediaType: 'boardgame',
      ),
      referenceFormatLabel: referenceFormatLabel,
      referenceEditionId: overlay.ownedItem?.editionId ??
          overlay.wishlistItem?.editionId ??
          selectedEdition?.id,
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
      trailerUrls: const <TrailerLink>[],
      plotSummary: metadata.plotSummary,
      plotDescription: metadata.plotDescription,
      creators: _copyCreatorList(metadata.creators),
      characters: _copyStringList(metadata.characters),
      storyArcs: _copyStringList(metadata.storyArcs),
      genres: _copyStringList(genres),
      country: metadata.country,
      language: metadata.language,
      ageRating: metadata.ageRating,
      audienceRating: metadata.audienceRating,
    ),
    series: metadata.series,
    publishing: metadata.publishing,
    game: null,
  );
}

LibraryWorkspaceEntryData _buildReleaseEntryData(
  LibraryReleaseEntryRequest request,
  BoardGameWork work,
) {
  final selectedEdition = work.editions.isEmpty
      ? null
      : _boardGameEditionById(work.editions,
              request.referenceEditionId ?? request.edition.id) ??
          work.editions.first;
  final referenceFormatLabel = selectedEdition == null
      ? request.edition.physicalFormatLabel
      : selectedEdition.format?.trim().isNotEmpty == true
          ? selectedEdition.format!.trim()
          : selectedEdition.editionTitle?.trim().isNotEmpty == true
              ? selectedEdition.editionTitle!.trim()
              : request.edition.physicalFormatLabel;
  return LibraryWorkspaceEntryData(
    id: '${request.titleEntry.id}:release:${request.edition.id}',
    browseScope: LibraryBrowserScope.release,
    titleItemId: request.titleEntry.id,
    releaseId: request.edition.id,
    copyId: null,
    ownedItemId: null,
    mediaType: 'boardgame',
    title: request.titleEntry.title,
    displayTitle: request.titleEntry.displayTitle,
    localizedTitle: request.titleEntry.localizedTitle,
    originalTitle: request.titleEntry.originalTitle,
    searchAliases: _copyStringList(request.titleEntry.searchAliases),
    itemNumber: null,
    synopsis: request.titleEntry.synopsis,
    coverImageUrl:
        request.titleEntry.coverImageUrl ?? selectedEdition?.coverImageUrl,
    thumbnailImageUrl: request.titleEntry.thumbnailImageUrl ??
        selectedEdition?.coverImageUrl ??
        request.titleEntry.coverImageUrl,
    publisher: selectedEdition?.publisher ?? request.titleEntry.publisher,
    coverDate: request.titleEntry.coverDate,
    releaseDate: selectedEdition?.releaseDate ?? request.edition.releaseDate,
    releaseYear:
        (selectedEdition?.releaseDate ?? request.edition.releaseDate)?.year ??
            request.titleEntry.releaseYear,
    barcode: selectedEdition?.barcode ?? request.edition.upc,
    variant: referenceFormatLabel,
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
    referenceFormatLabel: referenceFormatLabel,
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
    creators: null,
    characters: null,
    storyArcs: null,
    genres: null,
    country: null,
    language: selectedEdition?.language ?? request.edition.language,
    ageRating: null,
    audienceRating: null,
  );
}

BoardGameWork _boardGameWorkFromWorkspaceEntry(LibraryWorkspaceEntry entry) {
  return BoardGameWork(
    id: entry.id,
    title: entry.title,
    platforms:
        List<String>.unmodifiable(entry.game?.platforms ?? const <String>[]),
    identifiers: const <String>[],
    contributors: const <String>[],
    mechanics: const <String>[],
    categories: List<String>.unmodifiable(entry.genres ?? const <String>[]),
    families: const <String>[],
    expansions: const <String>[],
    rankings: const <String>[],
    editions: [
      for (final edition in entry.editions)
        BoardGameEdition(
          id: edition.id,
          title: edition.title,
          editionTitle: edition.title,
          format: edition.physicalFormatLabel ?? edition.physicalFormat,
          publisher: edition.publisher,
          catalogNumber: edition.upc,
          barcode: edition.upc,
          releaseStatus: null,
          releaseDate: edition.releaseDate,
          language: edition.language,
          country: edition.region,
          ageRating: null,
          audienceRating: null,
          minPlayers: null,
          maxPlayers: null,
          playingTimeMinutes: null,
          minAge: null,
          coverImageUrl: null,
        ),
    ],
  );
}

BoardGameEdition? _boardGameEditionById(
    List<BoardGameEdition> editions, String? editionId) {
  final normalized = editionId?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  for (final edition in editions) {
    if (edition.id == normalized) {
      return edition;
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

bool _hasMissingCoreMetadata(CatalogItem item) {
  return item.publisher == null &&
      item.releaseDate == null &&
      item.releaseYear == null &&
      item.coverImageUrl == null &&
      item.physicalFormatLabel == null;
}

BoardGameWork _boardGameWorkFromCatalogItem(CatalogItem item) {
  final editions = [
    for (final edition in item.editions)
      BoardGameEdition(
        id: edition.id,
        title: edition.title,
        editionTitle: edition.title,
        format: edition.format,
        publisher: edition.publisher,
        catalogNumber: edition.upc,
        barcode: edition.upc,
        releaseStatus: null,
        releaseDate: edition.releaseDate,
        language: edition.language,
        country: edition.region,
        ageRating: item.ageRating,
        audienceRating: item.audienceRating,
        minPlayers: null,
        maxPlayers: null,
        playingTimeMinutes: null,
        minAge: null,
        coverImageUrl: edition.variants.isNotEmpty
            ? edition.variants.first.coverImageUrl
            : null,
      ),
  ];
  return BoardGameWork(
    id: item.id,
    title: item.title,
    platforms: List<String>.unmodifiable(item.game?.platforms ?? const <String>[]),
    identifiers: const <String>[],
    contributors: item.creators == null
        ? const <String>[]
        : List<String>.unmodifiable(
            item.creators!
                .map((creator) => creator['name']?.toString() ?? '')
                .where((name) => name.isNotEmpty),
          ),
    mechanics: const <String>[],
    categories: item.genres == null
        ? const <String>[]
        : List<String>.unmodifiable(item.genres!),
    families: const <String>[],
    expansions: const <String>[],
    rankings: const <String>[],
    editions: editions,
  );
}
