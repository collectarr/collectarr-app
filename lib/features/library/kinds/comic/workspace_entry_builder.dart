import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

LibraryWorkspaceEntry buildComicsLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final work = ComicWork.fromMetadataItem(source.catalogItem!);
  final overlay = ComicPersonalOverlay.fromShelf(source);
  return ComicWorkspaceEntry(
    common: _buildShelfWorkspaceEntryData(
      source,
      work: work,
      overlay: overlay,
    ),
    comic: overlay.toWorkspaceDetails(),
    series: work.series,
    publishing: work.publishing,
  );
}

LibraryWorkspaceEntry buildComicsLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  final work = ComicWork.fromWorkspaceEntry(entry);
  return ComicWorkspaceEntry(
    common: _buildReleaseEntryData(request, mediaType: 'comic'),
    comic: entry.comic,
    series: work.series ?? entry.series,
    publishing: work.publishing ?? entry.publishing,
  );
}

LibraryWorkspaceEntryData _buildShelfWorkspaceEntryData(
  ShelfEntry source, {
  required ComicWork work,
  required ComicPersonalOverlay overlay,
  String? mediaType,
}) {
  final item = source.catalogItem!;
  final normalizedMediaType = (mediaType ?? item.kind).trim().toLowerCase();
  return LibraryWorkspaceEntryData(
    id: item.id,
    browseScope: LibraryBrowserScope.title,
    titleItemId: item.id,
    releaseId: null,
    copyId: null,
    ownedItemId: source.ownedItem?.id,
    mediaType: normalizedMediaType,
    title: work.title,
    displayTitle: work.displayTitle,
    localizedTitle: work.localizedTitle,
    originalTitle: work.originalTitle,
    searchAliases: _copyStringList(item.searchAliases),
    itemNumber: work.itemNumber,
    synopsis: work.synopsis,
    coverImageUrl: work.coverImageUrl,
    thumbnailImageUrl: work.thumbnailImageUrl,
    itemImages: source.itemImages,
    publisher: work.publisher,
    coverDate: work.coverDate,
    releaseDate: work.releaseDate,
    releaseYear: work.releaseYear,
    barcode: work.barcode,
    variant: work.variant ?? item.displayEditionLabel,
    crossover: work.crossover,
    isOwned: source.isOwned,
    isTracked: source.isTracked,
    isWishlisted: source.isWishlisted,
    hasMissingCover: work.displayCoverUrl == null,
    hasMissingMetadata: work.hasMissingCoreMetadata,
    condition: overlay.ownedItem?.condition,
    grade: overlay.ownedItem?.grade,
    signedBy: overlay.signedBy ?? overlay.ownedItem?.signedBy,
    marketValueCents: overlay.ownedItem?.marketValueCents,
    marketValueCurrency: overlay.ownedItem?.currency,
    primaryReferenceLabel: libraryPrimaryReferenceLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      mediaType: normalizedMediaType,
    ),
    referenceScopeLabel: libraryReferenceScopeLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      mediaType: normalizedMediaType,
    ),
    referenceFormatLabel: libraryReferenceFormatLabel(
      ownedItem: source.ownedItem,
      wishlistItem: source.wishlistItem,
      editions: item.editions,
      fallbackFormatLabel: item.physicalFormatLabel,
    ),
    referenceEditionId:
        source.ownedItem?.editionId ?? source.wishlistItem?.editionId,
    referenceVariantId:
        source.ownedItem?.variantId ?? source.wishlistItem?.variantId,
    referenceBundleReleaseId:
        source.ownedItem?.bundleReleaseId ?? source.wishlistItem?.bundleReleaseId,
    notes: overlay.ownedItem?.personalNotes ?? overlay.wishlistItem?.notes,
    tags: overlay.ownedItem?.tags,
    collectionStatus: overlay.ownedItem?.collectionStatus,
    lastBagBoardDate: overlay.lastBagBoardDate,
    pricePaidCents: overlay.ownedItem?.pricePaidCents,
    currency: overlay.ownedItem?.currency,
    locationPath: overlay.locationPath,
    addedAt: overlay.ownedItem?.createdAt ?? overlay.wishlistItem?.createdAt,
    editions: _copyEditionList(item.editions),
    updatedAt: source.updatedAt,
    trailerUrls: _copyTrailerList(work.trailerUrls),
    plotSummary: work.plotSummary ?? item.plotSummary,
    plotDescription: work.plotDescription ?? item.plotDescription,
    creators: _copyCreatorList(work.creators ?? item.creators),
    characters: _copyStringList(work.characters.isEmpty ? item.characters : work.characters),
    storyArcs: _copyStringList(work.storyArcs.isEmpty ? item.storyArcs : work.storyArcs),
    genres: _copyStringList(work.genres.isEmpty ? item.genres : work.genres),
    country: work.country ?? item.country,
    language: work.language ?? item.language,
    ageRating: work.ageRating ?? item.ageRating,
    audienceRating: work.audienceRating ?? item.audienceRating,
    rawPlatforms: _copyStringList(item.game?.platforms),
  );
}

LibraryWorkspaceEntryData _buildReleaseEntryData(
  LibraryReleaseEntryRequest request, {
  String? mediaType,
}) {
  final entry = request.titleEntry;
  final normalizedMediaType = (mediaType ?? entry.mediaType).trim().toLowerCase();
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
    mediaType: normalizedMediaType,
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
    itemImages: entry.itemImages,
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
    signedBy: null,
    marketValueCents: null,
    marketValueCurrency: null,
    primaryReferenceLabel: null,
    referenceScopeLabel: null,
    referenceFormatLabel:
        primaryVariant?.physicalFormatLabel ?? request.edition.physicalFormatLabel,
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