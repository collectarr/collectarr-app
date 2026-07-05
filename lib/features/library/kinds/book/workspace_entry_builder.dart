import 'package:collectarr_app/core/models/catalog_item_types.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class BookPersonalOverlay {
  const BookPersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.itemImages = const <ItemImage>[],
    this.customFieldValues = const <CustomFieldValue>[],
    this.updatedAt,
    this.fallbackOwnerLabel,
  });

  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final List<WatchSession> watchSessions;
  final List<ItemImage> itemImages;
  final List<CustomFieldValue> customFieldValues;
  final DateTime? updatedAt;
  final String? fallbackOwnerLabel;

  bool get isOwned => ownedItem != null;
  bool get isTracked => trackingEntry != null;
  bool get isWishlisted => wishlistItem != null;
}

LibraryWorkspaceEntry buildBookWorkspaceEntry(
  BookWork work,
  BookPersonalOverlay overlay,
) {
  final bookEditions = _copyBookEditionList(work.editions);
  final primaryRelease = _resolvePrimaryBookRelease(work.editions);
  final primaryReleaseCoverUrl =
      _primaryBookReleaseCover(primaryRelease.edition) ??
          primaryRelease.variant?.thumbnailImageUrl ??
          primaryRelease.variant?.coverImageUrl;
  final originalDetails = work.originalDetails;
  final physicalDetails = bookEditions.isNotEmpty
      ? BookPhysicalDetails(
          dimensions: bookEditions.first.dimensions,
          dustJacket: bookEditions.first.dustJacket,
          printing: bookEditions.first.printing,
          firstEdition: bookEditions.first.firstEdition,
          numberLine: bookEditions.first.numberLine,
          coverImagePath: bookEditions.first.coverImagePath,
          thumbnailImagePath: bookEditions.first.thumbnailImagePath,
          backImagePath: bookEditions.first.backImagePath,
        )
      : null;
  return BookWorkspaceEntry(
    common: LibraryWorkspaceEntryData(
      id: work.id,
      browseScope: LibraryBrowserScope.title,
      titleItemId: work.id,
      releaseId: null,
      copyId: null,
      ownedItemId: overlay.ownedItem?.id,
      mediaType: 'book',
      title: work.title,
      displayTitle: work.displayTitle,
      localizedTitle: work.localizedTitle,
      originalTitle: work.originalTitle,
      searchAliases: _copyStringList(work.searchAliases),
      itemNumber: work.itemNumber,
      synopsis: work.synopsis,
      coverImageUrl: work.coverImageUrl ?? primaryReleaseCoverUrl,
      thumbnailImageUrl: work.thumbnailImageUrl ??
          primaryReleaseCoverUrl ??
          work.coverImageUrl,
      itemImages: overlay.itemImages,
      publisher: work.publisher,
      coverDate: work.coverDate,
      releaseDate: work.releaseDate,
      releaseYear: work.releaseYear,
      barcode: work.barcode,
      variant: work.displayEditionLabel,
      crossover: work.crossover,
      isOwned: overlay.isOwned,
      isTracked: overlay.isTracked,
      isWishlisted: overlay.isWishlisted,
      hasMissingCover: work.displayCoverUrl == null,
      hasMissingMetadata: _hasMissingCoreMetadata(work),
      condition: overlay.ownedItem?.condition,
      grade: overlay.ownedItem?.grade,
      primaryReferenceLabel: libraryPrimaryReferenceLabel(
        ownedItem: overlay.ownedItem,
        wishlistItem: overlay.wishlistItem,
        mediaType: 'book',
      ),
      referenceScopeLabel: libraryReferenceScopeLabel(
        ownedItem: overlay.ownedItem,
        wishlistItem: overlay.wishlistItem,
        mediaType: 'book',
      ),
      referenceFormatLabel: libraryReferenceFormatLabel(
        ownedItem: overlay.ownedItem,
        wishlistItem: overlay.wishlistItem,
        editions: const <CatalogEdition>[],
        fallbackFormatLabel: work.physicalFormatLabel,
      ),
      referenceEditionId: overlay.ownedItem?.editionId ??
          overlay.wishlistItem?.editionId ??
          primaryRelease.edition?.id,
      referenceVariantId: overlay.ownedItem?.variantId ??
          overlay.wishlistItem?.variantId ??
          primaryRelease.variant?.id,
      referenceBundleReleaseId: overlay.ownedItem?.bundleReleaseId ??
          overlay.wishlistItem?.bundleReleaseId,
      notes: overlay.ownedItem?.personalNotes ?? overlay.wishlistItem?.notes,
      tags: overlay.ownedItem?.tags,
      collectionStatus: overlay.ownedItem?.collectionStatus,
      readStatus: overlay.trackingEntry?.statusStorageValue ??
          overlay.ownedItem?.readStatus,
      rating: overlay.trackingEntry?.rating ?? overlay.ownedItem?.rating,
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
      language: work.language,
      ageRating: work.ageRating,
      audienceRating: work.audienceRating,
    ),
    series: work.series,
    publishing: work.publishing,
    bookEditions: bookEditions,
    originalDetails: originalDetails,
    physicalDetails: physicalDetails,
  );
}

LibraryWorkspaceEntry buildBookEditionWorkspaceEntry({
  required BookWorkspaceEntry titleEntry,
  required BookEdition edition,
  required BookVariant? variant,
  required BookPersonalOverlay overlay,
  required bool isOwned,
  required bool isTracked,
  required bool isWishlisted,
  required String? referenceEditionId,
  required String? referenceVariantId,
  required String? referenceBundleReleaseId,
  required DateTime updatedAt,
}) {
  final bookEditions = titleEntry.bookEditions;
  return BookWorkspaceEntry(
    common: _buildEditionEntryData(
      titleEntry: titleEntry,
      edition: edition,
      variant: variant,
      overlay: overlay,
      isOwned: isOwned,
      isTracked: isTracked,
      isWishlisted: isWishlisted,
      referenceEditionId: referenceEditionId,
      referenceVariantId: referenceVariantId,
      referenceBundleReleaseId: referenceBundleReleaseId,
      updatedAt: updatedAt,
    ),
    series: titleEntry.series,
    publishing: titleEntry.publishing,
    bookEditions: bookEditions,
    originalDetails: titleEntry.originalDetails,
    physicalDetails: titleEntry.physicalDetails ??
        BookPhysicalDetails(
          dimensions: edition.dimensions,
          dustJacket: edition.dustJacket,
          printing: edition.printing,
          firstEdition: edition.firstEdition,
          numberLine: edition.numberLine,
          coverImagePath: edition.coverImagePath,
          thumbnailImagePath: edition.thumbnailImagePath,
          backImagePath: edition.backImagePath,
        ),
  );
}

LibraryWorkspaceEntryData _buildEditionEntryData({
  required BookWorkspaceEntry titleEntry,
  required BookEdition edition,
  required BookVariant? variant,
  required BookPersonalOverlay overlay,
  required bool isOwned,
  required bool isTracked,
  required bool isWishlisted,
  required String? referenceEditionId,
  required String? referenceVariantId,
  required String? referenceBundleReleaseId,
  required DateTime updatedAt,
}) {
  final resolvedVariant =
      variant ?? (edition.variants.isEmpty ? null : edition.variants.first);
  return LibraryWorkspaceEntryData(
    id: '${titleEntry.id}:release:${edition.id}',
    browseScope: LibraryBrowserScope.release,
    titleItemId: titleEntry.id,
    releaseId: edition.id,
    copyId: null,
    ownedItemId: null,
    mediaType: 'book',
    title: titleEntry.title,
    displayTitle: titleEntry.displayTitle,
    localizedTitle: titleEntry.localizedTitle,
    originalTitle: titleEntry.originalTitle,
    searchAliases: _copyStringList(titleEntry.searchAliases),
    itemNumber: null,
    synopsis: titleEntry.synopsis,
    coverImageUrl: resolvedVariant?.coverImageUrl ?? titleEntry.coverImageUrl,
    thumbnailImageUrl: resolvedVariant?.thumbnailImageUrl ??
        resolvedVariant?.coverImageUrl ??
        titleEntry.thumbnailImageUrl ??
        titleEntry.coverImageUrl,
    itemImages: titleEntry.itemImages,
    publisher: edition.publisher ?? titleEntry.publisher,
    coverDate: titleEntry.coverDate,
    releaseDate: edition.releaseDate,
    releaseYear: edition.releaseDate?.year ?? titleEntry.releaseYear,
    barcode: resolvedVariant?.barcode ?? edition.upc,
    variant: resolvedVariant?.name ?? edition.title,
    crossover: titleEntry.crossover,
    isOwned: isOwned,
    isTracked: isTracked,
    isWishlisted: isWishlisted,
    hasMissingCover: false,
    hasMissingMetadata: false,
    condition: null,
    grade: null,
    primaryReferenceLabel: null,
    referenceScopeLabel: null,
    referenceFormatLabel:
        resolvedVariant?.physicalFormatLabel ?? edition.physicalFormatLabel,
    referenceEditionId: referenceEditionId ?? edition.id,
    referenceVariantId: referenceVariantId ?? resolvedVariant?.id,
    referenceBundleReleaseId: referenceBundleReleaseId,
    notes: null,
    tags: null,
    collectionStatus: null,
    readStatus: null,
    rating: null,
    lastBagBoardDate: null,
    pricePaidCents: null,
    currency: null,
    locationPath: null,
    addedAt: null,
    editions: const <CatalogEdition>[],
    updatedAt: overlay.updatedAt ?? updatedAt,
    trailerUrls: _copyTrailerList(titleEntry.trailerUrls),
    creators: _copyCreatorList(titleEntry.creators),
    characters: _copyStringList(titleEntry.characters),
    storyArcs: _copyStringList(titleEntry.storyArcs),
    genres: _copyStringList(titleEntry.genres),
    country: titleEntry.country,
    language: edition.language ?? titleEntry.language,
    ageRating: titleEntry.ageRating,
    audienceRating: titleEntry.audienceRating,
  );
}

({BookEdition? edition, BookVariant? variant}) _resolvePrimaryBookRelease(
  List<BookEdition> editions,
) {
  for (final edition in editions) {
    for (final variant in edition.variants) {
      if (variant.isPrimary) {
        return (edition: edition, variant: variant);
      }
    }
  }
  for (final edition in editions) {
    if (edition.variants.isNotEmpty) {
      return (edition: edition, variant: edition.variants.first);
    }
  }
  return (
    edition: editions.isEmpty ? null : editions.first,
    variant: null,
  );
}

String? _primaryBookReleaseCover(BookEdition? edition) {
  if (edition == null) {
    return null;
  }
  for (final variant in edition.variants) {
    if (!variant.isPrimary) {
      continue;
    }
    final thumbnail = variant.thumbnailImageUrl?.trim();
    if (thumbnail != null && thumbnail.isNotEmpty) {
      return thumbnail;
    }
    final cover = variant.coverImageUrl?.trim();
    if (cover != null && cover.isNotEmpty) {
      return cover;
    }
  }
  for (final variant in edition.variants) {
    final thumbnail = variant.thumbnailImageUrl?.trim();
    if (thumbnail != null && thumbnail.isNotEmpty) {
      return thumbnail;
    }
    final cover = variant.coverImageUrl?.trim();
    if (cover != null && cover.isNotEmpty) {
      return cover;
    }
  }
  return null;
}

bool _hasMissingCoreMetadata(BookWork book) {
  return book.publisher == null &&
      book.releaseDate == null &&
      book.releaseYear == null &&
      book.displayCoverUrl == null &&
      book.displayEditionLabel == null;
}

List<BookEdition> _copyBookEditionList(List<BookEdition> values) {
  return List<BookEdition>.unmodifiable(values);
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
