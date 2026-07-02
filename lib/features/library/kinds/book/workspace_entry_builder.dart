import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildBooksLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final item = source.catalogItem!;
  return BookWorkspaceEntry(
    common: _buildShelfWorkspaceEntryData(source),
    series: item.series,
    publishing: item.publishing,
  );
}

LibraryWorkspaceEntry buildBooksLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return BookWorkspaceEntry(
    common: _buildReleaseEntryData(request),
    series: entry.series,
    publishing: entry.publishing,
  );
}

LibraryWorkspaceEntryData _buildShelfWorkspaceEntryData(ShelfEntry source) {
  final item = source.catalogItem!;
  final resolvedEditions = item.editions;
  final primaryRelease = _resolvePrimaryBookRelease(resolvedEditions);
  final primaryReleaseCoverUrl =
      _primaryBookReleaseCover(primaryRelease.edition) ??
          primaryRelease.variant?.thumbnailImageUrl ??
          primaryRelease.variant?.coverImageUrl;
  return LibraryWorkspaceEntryData(
    id: item.id,
    browseScope: LibraryBrowserScope.title,
    titleItemId: item.id,
    releaseId: null,
    copyId: null,
    ownedItemId: source.ownedItem?.id,
    mediaType: 'book',
    title: item.title,
    displayTitle: item.displayTitle,
    localizedTitle: item.localizedTitle,
    originalTitle: item.originalTitle,
    searchAliases: _copyStringList(item.searchAliases),
    itemNumber: item.itemNumber,
    synopsis: item.synopsis,
    coverImageUrl: item.coverImageUrl ?? primaryReleaseCoverUrl,
    thumbnailImageUrl:
        item.thumbnailImageUrl ?? primaryReleaseCoverUrl ?? item.coverImageUrl,
    publisher: item.publisher,
    coverDate: item.coverDate,
    releaseDate: item.releaseDate,
    releaseYear: item.releaseYear,
    barcode: item.barcode,
    variant: item.displayEditionLabel,
    crossover: item.crossover,
    isOwned: source.isOwned,
    isTracked: source.isTracked,
    isWishlisted: source.isWishlisted,
    hasMissingCover: item.displayCoverUrl == null,
    hasMissingMetadata: _hasMissingCoreMetadata(item),
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
      fallbackFormatLabel: item.physicalFormatLabel,
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
    trailerUrls: _copyTrailerList(item.trailerUrls),
    plotSummary: item.plotSummary,
    plotDescription: item.plotDescription,
    creators: _copyCreatorList(item.creators),
    characters: _copyStringList(item.characters),
    storyArcs: _copyStringList(item.storyArcs),
    genres: _copyStringList(item.genres),
    country: item.country,
    language: item.language,
    ageRating: item.ageRating,
    audienceRating: item.audienceRating,
    rawPlatforms: _copyStringList(item.game?.platforms),
  );
}

({CatalogEdition? edition, CatalogVariant? variant}) _resolvePrimaryBookRelease(
    List<CatalogEdition> editions) {
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

String? _primaryBookReleaseCover(CatalogEdition? edition) {
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
  final entry = request.titleEntry;
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
    id: '${entry.id}:release:${request.edition.id}',
    browseScope: LibraryBrowserScope.release,
    titleItemId: entry.id,
    releaseId: request.edition.id,
    copyId: null,
    ownedItemId: null,
    mediaType: 'book',
    title: entry.title,
    displayTitle: entry.displayTitle,
    localizedTitle: entry.localizedTitle,
    originalTitle: entry.originalTitle,
    searchAliases: _copyStringList(entry.searchAliases),
    itemNumber: null,
    synopsis: entry.synopsis,
    coverImageUrl: primaryVariant?.coverImageUrl ?? entry.coverImageUrl,
    thumbnailImageUrl: primaryVariant?.thumbnailImageUrl ??
        primaryVariant?.coverImageUrl ??
        entry.thumbnailImageUrl ??
        entry.coverImageUrl,
    publisher: request.edition.publisher ?? entry.publisher,
    coverDate: entry.coverDate,
    releaseDate: request.edition.releaseDate,
    releaseYear: request.edition.releaseDate?.year ?? entry.releaseYear,
    barcode: primaryVariant?.barcode ?? request.edition.upc,
    variant: primaryVariant?.name ?? request.edition.title,
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
    trailerUrls: _copyTrailerList(entry.trailerUrls),
    creators: _copyCreatorList(entry.creators),
    characters: _copyStringList(entry.characters),
    storyArcs: _copyStringList(entry.storyArcs),
    genres: _copyStringList(entry.genres),
    country: entry.country,
    language: request.edition.language ?? entry.language,
    ageRating: entry.ageRating,
    audienceRating: entry.audienceRating,
    rawPlatforms: _copyStringList(entry.game?.platforms ?? entry.rawPlatforms),
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

bool _hasMissingCoreMetadata(CatalogItem item) {
  return item.publisher == null &&
      item.releaseDate == null &&
      item.releaseYear == null &&
      item.displayCoverUrl == null &&
      item.displayEditionLabel == null;
}
