import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
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

LibraryWorkspaceEntry buildBoardGameEditionWorkspaceEntry({
  required BoardGameWorkspaceEntry titleEntry,
  required BoardGameEdition edition,
  required BoardGamePersonalOverlay overlay,
}) {
  final work = titleEntry.boardGameWork;
  if (work == null) {
    throw StateError('BoardGame edition entry requires a typed boardGameWork');
  }
  final referenceFormatLabel = _boardGameReleaseLabel(edition);
  return BoardGameWorkspaceEntry(
    common: LibraryWorkspaceEntryData(
      id: '${titleEntry.id}:release:${edition.id}',
      browseScope: LibraryBrowserScope.release,
      titleItemId: titleEntry.id,
      releaseId: edition.id,
      copyId: null,
      ownedItemId: null,
      mediaType: 'boardgame',
      title: titleEntry.title,
      displayTitle: titleEntry.displayTitle,
      localizedTitle: titleEntry.localizedTitle,
      originalTitle: titleEntry.originalTitle,
      searchAliases: _copyStringList(titleEntry.searchAliases),
      itemNumber: null,
      synopsis: titleEntry.synopsis,
      coverImageUrl: edition.coverImageUrl ?? titleEntry.coverImageUrl,
      thumbnailImageUrl: edition.coverImageUrl ??
          titleEntry.thumbnailImageUrl ??
          titleEntry.coverImageUrl,
      publisher: edition.publisher ?? titleEntry.publisher,
      coverDate: titleEntry.coverDate,
      releaseDate: edition.releaseDate,
      releaseYear: edition.releaseDate?.year ?? titleEntry.releaseYear,
      barcode: edition.barcode ?? edition.catalogNumber,
      variant: referenceFormatLabel,
      crossover: titleEntry.crossover,
      isOwned: titleEntry.isOwned,
      isTracked: titleEntry.isTracked,
      isWishlisted: titleEntry.isWishlisted,
      hasMissingCover: false,
      hasMissingMetadata: false,
      condition: null,
      grade: null,
      primaryReferenceLabel: null,
      referenceScopeLabel: null,
      referenceFormatLabel: referenceFormatLabel,
      referenceEditionId: edition.id,
      referenceVariantId: null,
      referenceBundleReleaseId: null,
      notes: null,
      tags: null,
      collectionStatus: null,
      lastBagBoardDate: null,
      pricePaidCents: null,
      currency: null,
      locationPath: null,
      addedAt: null,
      editions: const [],
      updatedAt: overlay.updatedAt ?? titleEntry.updatedAt,
      trailerUrls: const [],
      plotSummary: null,
      plotDescription: null,
      creators: _copyCreatorListFromStrings(work.contributors),
      characters: const <String>[],
      storyArcs: const <String>[],
      genres: _copyStringList([
        ...work.categories,
        ...work.mechanics,
      ]),
      country: edition.country,
      language: edition.language,
      ageRating: null,
      audienceRating: null,
    ),
    series: null,
    publishing: null,
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

BoardGameEdition? _primaryBoardGameEdition(BoardGameWork work) {
  return work.editions.isEmpty ? null : work.editions.first;
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
