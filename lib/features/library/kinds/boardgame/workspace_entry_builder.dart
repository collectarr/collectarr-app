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

LibraryWorkspaceEntry buildBoardGamesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final titleEntry = request.titleEntry;
  if (titleEntry is! BoardGameWorkspaceEntry || titleEntry.boardGameWork == null) {
    throw StateError('BoardGame release entry requires a typed boardGameWork');
  }
  final work = titleEntry.boardGameWork!;
  return BoardGameWorkspaceEntry(
    common: _buildReleaseEntryData(request, work),
    series: request.titleEntry.series,
    publishing: request.titleEntry.publishing,
    game: null,
    boardGameWork: work,
  );
}

LibraryWorkspaceEntry buildBoardGameWorkspaceEntry(
  BoardGameWork work,
  BoardGamePersonalOverlay overlay,
) {
  final selectedEdition = _primaryBoardGameEdition(work);
  final referenceFormatLabel = _boardGameReleaseLabel(selectedEdition);
  final genres = <String>[
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
      displayTitle: work.title,
      localizedTitle: null,
      originalTitle: null,
      searchAliases: const <String>[],
      itemNumber: null,
      synopsis: null,
      coverImageUrl: selectedEdition?.coverImageUrl,
      thumbnailImageUrl: selectedEdition?.coverImageUrl,
      publisher: selectedEdition?.publisher,
      coverDate: null,
      releaseDate: selectedEdition?.releaseDate,
      releaseYear: selectedEdition?.releaseDate?.year,
      barcode: selectedEdition?.barcode,
      variant: referenceFormatLabel,
      crossover: null,
      isOwned: overlay.isOwned,
      isTracked: overlay.isTracked,
      isWishlisted: overlay.isWishlisted,
      hasMissingCover: selectedEdition?.coverImageUrl == null,
      hasMissingMetadata: _hasMissingCoreMetadata(work, selectedEdition),
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
      editions: const [],
      updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      trailerUrls: const [],
      plotSummary: null,
      plotDescription: null,
      creators: _copyCreatorListFromStrings(work.contributors),
      characters: const <String>[],
      storyArcs: const <String>[],
      genres: _copyStringList(genres),
      country: selectedEdition?.country,
      language: selectedEdition?.language,
      ageRating: null,
      audienceRating: null,
    ),
    series: null,
    publishing: null,
    game: null,
    boardGameWork: work,
  );
}

LibraryWorkspaceEntryData _buildReleaseEntryData(
  LibraryReleaseEntryRequest request,
  BoardGameWork work,
) {
  final selectedEdition = _boardGameEditionById(
        work.editions,
        request.referenceEditionId ?? request.edition.id,
      ) ??
      _primaryBoardGameEdition(work);
  final referenceFormatLabel = _boardGameReleaseLabel(selectedEdition) ??
      request.edition.physicalFormatLabel ??
      request.edition.physicalFormat;
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
        selectedEdition?.coverImageUrl ?? request.titleEntry.coverImageUrl,
    thumbnailImageUrl:
        selectedEdition?.coverImageUrl ?? request.titleEntry.thumbnailImageUrl,
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
    editions: const [],
    updatedAt: request.updatedAt,
    trailerUrls: const [],
    plotSummary: null,
    plotDescription: null,
    creators: _copyCreatorListFromStrings(work.contributors),
    characters: null,
    storyArcs: null,
    genres: _copyStringList([
      ...work.categories,
      ...work.mechanics,
    ]),
    country: null,
    language: selectedEdition?.language ?? request.edition.language,
    ageRating: null,
    audienceRating: null,
  );
}

BoardGameEdition? _primaryBoardGameEdition(BoardGameWork work) {
  return work.editions.isEmpty ? null : work.editions.first;
}

BoardGameEdition? _boardGameEditionById(
  List<BoardGameEdition> editions,
  String? editionId,
) {
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

String? _boardGameReleaseLabel(BoardGameEdition? edition) {
  if (edition == null) return null;
  final format = edition.format?.trim();
  if (format != null && format.isNotEmpty) {
    return format;
  }
  final editionTitle = edition.editionTitle?.trim();
  if (editionTitle != null && editionTitle.isNotEmpty) {
    return editionTitle;
  }
  return null;
}

List<String>? _copyStringList(List<String>? values) {
  if (values == null) return null;
  return List<String>.unmodifiable(values);
}

List<Map<String, dynamic>>? _copyCreatorListFromStrings(List<String> values) {
  if (values.isEmpty) return null;
  return List<Map<String, dynamic>>.unmodifiable(
    values.map((value) => <String, dynamic>{'name': value}),
  );
}

bool _hasMissingCoreMetadata(
  BoardGameWork work,
  BoardGameEdition? edition,
) {
  return work.contributors.isEmpty &&
      work.categories.isEmpty &&
      work.mechanics.isEmpty &&
      work.editions.isEmpty &&
      edition?.publisher == null &&
      edition?.releaseDate == null &&
      edition?.coverImageUrl == null;
}
