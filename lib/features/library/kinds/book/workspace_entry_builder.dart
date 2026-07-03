import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
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

  factory BookPersonalOverlay.fromShelfEntry(ShelfEntry source) {
    return BookPersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      watchSessions: source.watchSessions,
      itemImages: source.itemImages,
      updatedAt: source.updatedAt,
      fallbackOwnerLabel: source.fallbackOwnerLabel,
    );
  }

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
  final editions = [
    for (final edition in work.editions) _bookEditionToCatalogEdition(edition),
  ];
  final primaryRelease = _resolvePrimaryBookRelease(work.editions);
  final primaryReleaseCoverUrl =
      _primaryBookReleaseCover(primaryRelease.edition) ??
          primaryRelease.variant?.thumbnailImageUrl ??
          primaryRelease.variant?.coverImageUrl;
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
        editions: editions,
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
      lastBagBoardDate: overlay.ownedItem?.lastBagBoardDate,
      pricePaidCents: overlay.ownedItem?.pricePaidCents,
      currency: overlay.ownedItem?.currency,
      locationPath: overlay.locationPath,
      addedAt: overlay.ownedItem?.createdAt ?? overlay.wishlistItem?.createdAt,
      editions: _copyEditionList(editions),
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
  );
}

LibraryWorkspaceEntry buildBookWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final metadataItem = LibraryMetadataItem.fromCatalogItem(source.catalogItem!);
  return buildBookWorkspaceEntry(
    BookWork.fromMetadataItem(metadataItem),
    BookPersonalOverlay.fromShelfEntry(source),
  );
}

LibraryWorkspaceEntry buildBookReleaseWorkspaceEntry(
  LibraryReleaseEntryRequest request,
) {
  final book = _bookWorkFromWorkspaceEntry(request.titleEntry);
  return BookWorkspaceEntry(
    common: _buildReleaseEntryData(request, book),
    series: book.series,
    publishing: book.publishing,
  );
}

LibraryWorkspaceEntryData _buildReleaseEntryData(
  LibraryReleaseEntryRequest request,
  BookWork book,
) {
  CatalogVariant? primaryVariant;
  for (final variant in request.edition.variants) {
    if (variant.isPrimary) {
      primaryVariant = variant;
      break;
    }
  }
  primaryVariant ??=
      request.edition.variants.isEmpty ? null : request.edition.variants.first;
  final editions =
      request.editions.isEmpty ? request.titleEntry.editions : request.editions;
  return LibraryWorkspaceEntryData(
    id: '${book.id}:release:${request.edition.id}',
    browseScope: LibraryBrowserScope.release,
    titleItemId: book.id,
    releaseId: request.edition.id,
    copyId: null,
    ownedItemId: null,
    mediaType: 'book',
    title: book.title,
    displayTitle: book.displayTitle,
    localizedTitle: book.localizedTitle,
    originalTitle: book.originalTitle,
    searchAliases: _copyStringList(book.searchAliases),
    itemNumber: null,
    synopsis: book.synopsis,
    coverImageUrl: primaryVariant?.coverImageUrl ?? book.coverImageUrl,
    thumbnailImageUrl: primaryVariant?.thumbnailImageUrl ??
        primaryVariant?.coverImageUrl ??
        book.thumbnailImageUrl ??
        book.coverImageUrl,
    publisher: request.edition.publisher ?? book.publisher,
    coverDate: book.coverDate,
    releaseDate: request.edition.releaseDate,
    releaseYear: request.edition.releaseDate?.year ?? book.releaseYear,
    barcode: primaryVariant?.barcode ?? request.edition.upc,
    variant: primaryVariant?.name ?? request.edition.title,
    crossover: book.crossover,
    isOwned: request.isOwned,
    isTracked: request.isTracked,
    isWishlisted: request.isWishlisted,
    hasMissingCover: false,
    hasMissingMetadata: false,
    condition: null,
    grade: null,
    primaryReferenceLabel: null,
    referenceScopeLabel: null,
    referenceFormatLabel: primaryVariant?.physicalFormatLabel ??
        request.edition.physicalFormatLabel,
    referenceEditionId: request.referenceEditionId ?? request.edition.id,
    referenceVariantId: request.referenceVariantId ?? primaryVariant?.id,
    referenceBundleReleaseId: request.referenceBundleReleaseId,
    notes: null,
    tags: null,
    collectionStatus: null,
    lastBagBoardDate: null,
    pricePaidCents: null,
    currency: null,
    locationPath: null,
    addedAt: null,
    editions: _copyEditionList(editions),
    updatedAt: request.updatedAt,
    trailerUrls: _copyTrailerList(book.trailerUrls),
    creators: _copyCreatorList(book.creators),
    characters: _copyStringList(book.characters),
    storyArcs: _copyStringList(book.storyArcs),
    genres: _copyStringList(book.genres),
    country: book.country,
    language: request.edition.language ?? book.language,
    ageRating: book.ageRating,
    audienceRating: book.audienceRating,
  );
}

BookWork _bookWorkFromWorkspaceEntry(LibraryWorkspaceEntry entry) {
  return BookWork(
    id: entry.id,
    title: entry.title,
    displayTitle: entry.displayTitle,
    localizedTitle: entry.localizedTitle,
    originalTitle: entry.originalTitle,
    searchAliases:
        List<String>.unmodifiable(entry.searchAliases ?? const <String>[]),
    itemNumber: entry.itemNumber,
    synopsis: entry.synopsis,
    coverImageUrl: entry.coverImageUrl,
    thumbnailImageUrl: entry.thumbnailImageUrl,
    publisher: entry.publisher,
    coverDate: entry.coverDate,
    releaseDate: entry.releaseDate,
    releaseYear: entry.releaseYear,
    barcode: entry.barcode,
    variant: entry.variant,
    crossover: entry.crossover,
    series: entry.series,
    publishing: entry.publishing,
    editions: [
      for (final edition in entry.editions)
        BookEdition.fromCatalogEdition(edition),
    ],
    trailerUrls: List<TrailerLink>.unmodifiable(entry.trailerUrls),
    plotSummary: entry.plotSummary,
    plotDescription: entry.plotDescription,
    creators: entry.creators == null
        ? null
        : List<Map<String, dynamic>>.unmodifiable(
            entry.creators!
                .map((value) => Map<String, dynamic>.unmodifiable(value)),
          ),
    characters: List<String>.unmodifiable(entry.characters ?? const <String>[]),
    storyArcs: List<String>.unmodifiable(entry.storyArcs ?? const <String>[]),
    genres: List<String>.unmodifiable(entry.genres ?? const <String>[]),
    country: entry.country,
    language: entry.language,
    ageRating: entry.ageRating,
    audienceRating: entry.audienceRating,
    physicalFormatLabel: entry.referenceFormatLabel,
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

List<TrailerLink> _copyTrailerList(List<TrailerLink> values) {
  return List<TrailerLink>.unmodifiable(values);
}

CatalogEdition _bookEditionToCatalogEdition(BookEdition edition) {
  return CatalogEdition(
    id: edition.id,
    title: edition.title,
    format: edition.format,
    publisher: edition.publisher,
    isbn: edition.isbn,
    upc: edition.upc,
    language: edition.language,
    region: edition.region,
    releaseDate: edition.releaseDate,
    physicalFormat: edition.physicalFormat,
    physicalFormatLabel: edition.physicalFormatLabel,
    variants: [
      for (final variant in edition.variants)
        _bookVariantToCatalogVariant(variant),
    ],
  );
}

CatalogVariant _bookVariantToCatalogVariant(BookVariant variant) {
  return CatalogVariant(
    id: variant.id,
    name: variant.name,
    variantType: variant.variantType,
    sku: variant.sku,
    barcode: variant.barcode,
    isbn: variant.isbn,
    region: variant.region,
    coverImageUrl: variant.coverImageUrl,
    thumbnailImageUrl: variant.thumbnailImageUrl,
    description: variant.description,
    physicalFormat: variant.physicalFormat,
    physicalFormatLabel: variant.physicalFormatLabel,
    isPrimary: variant.isPrimary,
  );
}
