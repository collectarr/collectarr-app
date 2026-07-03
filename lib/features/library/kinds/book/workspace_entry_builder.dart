import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/book_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildBooksLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final book = BookWork.fromCatalogItem(source.catalogItem!);
  return BookWorkspaceEntry(
    common: _buildShelfWorkspaceEntryData(source),
    series: book.series,
    publishing: book.publishing,
  );
}

LibraryWorkspaceEntry buildBooksLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final book = BookWork.fromWorkspaceEntry(request.titleEntry);
  return BookWorkspaceEntry(
    common: _buildReleaseEntryData(request),
    series: book.series,
    publishing: book.publishing,
  );
}

LibraryWorkspaceEntryData _buildShelfWorkspaceEntryData(ShelfEntry source) {
  final catalogItem = source.catalogItem!;
  final book = BookWork.fromCatalogItem(catalogItem);
  final resolvedEditions = catalogItem.editions;
  final primaryRelease = _resolvePrimaryBookRelease(book.editions);
  final primaryReleaseCoverUrl =
      _primaryBookReleaseCover(primaryRelease.edition) ??
      primaryRelease.variant?.thumbnailImageUrl ??
      primaryRelease.variant?.coverImageUrl;
  return LibraryWorkspaceEntryData(
    id: book.id,
    browseScope: LibraryBrowserScope.title,
    titleItemId: book.id,
    releaseId: null,
    copyId: null,
    ownedItemId: source.ownedItem?.id,
    mediaType: 'book',
    title: book.title,
    displayTitle: book.displayTitle,
    localizedTitle: book.localizedTitle,
    originalTitle: book.originalTitle,
    searchAliases: _copyStringList(book.searchAliases),
    itemNumber: book.itemNumber,
    synopsis: book.synopsis,
    coverImageUrl: book.coverImageUrl ?? primaryReleaseCoverUrl,
    thumbnailImageUrl:
        book.thumbnailImageUrl ?? primaryReleaseCoverUrl ?? book.coverImageUrl,
    publisher: book.publisher,
    coverDate: book.coverDate,
    releaseDate: book.releaseDate,
    releaseYear: book.releaseYear,
    barcode: book.barcode,
    variant: book.displayEditionLabel,
    crossover: book.crossover,
    isOwned: source.isOwned,
    isTracked: source.isTracked,
    isWishlisted: source.isWishlisted,
    hasMissingCover: book.displayCoverUrl == null,
    hasMissingMetadata: _hasMissingCoreMetadata(book),
    condition: source.ownedItem?.condition,
    grade: source.ownedItem?.grade,
    primaryReferenceLabel: libraryPrimaryReferenceLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      mediaType: 'book',
    ),
    referenceScopeLabel: libraryReferenceScopeLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      mediaType: 'book',
    ),
    referenceFormatLabel: libraryReferenceFormatLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      editions: resolvedEditions,
      fallbackFormatLabel: book.physicalFormatLabel,
    ),
    referenceEditionId: source.ownedItem?.editionId ??
        source.wishlistItem?.editionId ??
        primaryRelease.edition?.id,
    referenceVariantId: source.ownedItem?.variantId ??
        source.wishlistItem?.variantId ??
        primaryRelease.variant?.id,
    referenceBundleReleaseId: source.ownedItem?.bundleReleaseId ??
        source.wishlistItem?.bundleReleaseId,
    notes: source.ownedItem?.personalNotes ?? source.wishlistItem?.notes,
    tags: source.ownedItem?.tags,
    collectionStatus: source.ownedItem?.collectionStatus,
    lastBagBoardDate: source.ownedItem?.lastBagBoardDate,
    pricePaidCents: source.ownedItem?.pricePaidCents,
    currency: source.ownedItem?.currency,
    locationPath: source.locationPath,
    addedAt: source.ownedItem?.createdAt ?? source.wishlistItem?.createdAt,
    editions: _copyEditionList(resolvedEditions),
    updatedAt: source.updatedAt,
    trailerUrls: _copyTrailerList(book.trailerUrls),
    plotSummary: book.plotSummary,
    plotDescription: book.plotDescription,
    creators: _copyCreatorList(book.creators),
    characters: _copyStringList(book.characters),
    storyArcs: _copyStringList(book.storyArcs),
    genres: _copyStringList(book.genres),
    country: book.country,
    language: book.language,
    ageRating: book.ageRating,
    audienceRating: book.audienceRating,
  );
}

({BookEdition? edition, BookVariant? variant}) _resolvePrimaryBookRelease(
    List<BookEdition> editions) {
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

LibraryWorkspaceEntryData _buildReleaseEntryData(
  LibraryReleaseEntryRequest request,
) {
  final book = BookWork.fromWorkspaceEntry(request.titleEntry);
  CatalogVariant? primaryVariant;
  for (final variant in request.edition.variants) {
    if (variant.isPrimary) {
      primaryVariant = variant;
      break;
    }
  }
  primaryVariant ??=
      request.edition.variants.isEmpty ? null : request.edition.variants.first;
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
    editions: _copyEditionList(
      request.editions.isEmpty ? [request.edition] : request.editions,
    ),
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

List<TrailerLink> _copyTrailerList(List<TrailerLink>? values) {
  if (values == null) return const <TrailerLink>[];
  return List<TrailerLink>.unmodifiable(values);
}

bool _hasMissingCoreMetadata(BookWork book) {
  return book.hasMissingCoreMetadata;
}
