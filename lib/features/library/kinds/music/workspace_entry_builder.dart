import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/music/music_domain.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

/// Personal (app-owned) overlay for a music shelf entry, kept separate from the
/// catalog metadata so the workspace-entry builder mirrors the kind-first
/// pattern (catalog data + personal overlay) used by the book reference kind.
final class MusicPersonalOverlay {
  const MusicPersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.itemImages = const <ItemImage>[],
    this.updatedAt,
    this.fallbackOwnerLabel,
  });

  factory MusicPersonalOverlay.fromShelf(ShelfEntry source) {
    return MusicPersonalOverlay(
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
  final DateTime? updatedAt;
  final String? fallbackOwnerLabel;

  bool get isOwned => ownedItem != null;
  bool get isTracked => trackingEntry != null;
  bool get isWishlisted => wishlistItem != null;
}

LibraryWorkspaceEntry buildMusicLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final catalogItem = source.catalogItem;
  if (catalogItem == null) {
    throw StateError('Expected catalog item for music workspace entry');
  }
  return buildMusicWorkspaceEntry(
    MusicWork.fromMetadataItem(catalogItem),
    MusicPersonalOverlay.fromShelf(source),
  );
}

LibraryWorkspaceEntry buildMusicWorkspaceEntry(
  MusicWork work,
  MusicPersonalOverlay overlay,
) {
  return MusicWorkspaceEntry(
    common: _buildShelfWorkspaceEntryData(work, overlay, mediaType: 'music'),
    series: work.series,
    publishing: work.publishing,
    music: work.music,
  );
}

LibraryWorkspaceEntry buildMusicLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return MusicWorkspaceEntry(
    common: _buildReleaseEntryData(request, mediaType: 'music'),
    series: entry.series,
    publishing: entry.publishing,
    music: entry.music,
  );
}

LibraryWorkspaceEntryData _buildShelfWorkspaceEntryData(
  MusicWork work,
  MusicPersonalOverlay overlay, {
  String? mediaType,
}) {
  final normalizedMediaType = (mediaType ?? 'music').trim().toLowerCase();
  final resolvedEditions = work.editions;
  return LibraryWorkspaceEntryData(
    id: work.id,
    browseScope: LibraryBrowserScope.title,
    titleItemId: work.id,
    releaseId: null,
    copyId: null,
    ownedItemId: overlay.ownedItem?.id,
    mediaType: normalizedMediaType,
    title: work.title,
    displayTitle: work.displayTitle,
    localizedTitle: work.localizedTitle,
    originalTitle: work.originalTitle,
    searchAliases: _copyStringList(work.searchAliases),
    itemNumber: work.itemNumber,
    synopsis: work.synopsis,
    coverImageUrl: work.coverImageUrl,
    thumbnailImageUrl: work.thumbnailImageUrl,
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
    hasMissingMetadata: work.hasMissingCoreMetadata,
    condition: overlay.ownedItem?.condition,
    grade: overlay.ownedItem?.grade,
    primaryReferenceLabel: libraryPrimaryReferenceLabel(
      ownedItem: overlay.ownedItem,
      wishlistItem: overlay.wishlistItem,
      mediaType: normalizedMediaType,
    ),
    referenceScopeLabel: libraryReferenceScopeLabel(
      ownedItem: overlay.ownedItem,
      wishlistItem: overlay.wishlistItem,
      mediaType: normalizedMediaType,
    ),
    referenceFormatLabel: libraryReferenceFormatLabel(
      ownedItem: overlay.ownedItem,
      wishlistItem: overlay.wishlistItem,
      editions: resolvedEditions,
      fallbackFormatLabel: work.displayEditionLabel,
    ),
    referenceEditionId:
        overlay.ownedItem?.editionId ?? overlay.wishlistItem?.editionId,
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
    editions: _copyEditionList(resolvedEditions),
    updatedAt: overlay.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    trailerUrls: _copyTrailerList(work.trailerUrls),
    plotSummary: work.synopsis,
    plotDescription: null,
    creators: _copyCreatorList(work.creators),
    characters: _copyStringList(work.characters),
    storyArcs: _copyStringList(work.storyArcs),
    genres: _copyStringList(work.genres),
    country: work.country,
    language: work.language,
    ageRating: work.ageRating,
    audienceRating: work.audienceRating,
    rawPlatforms: null,
  );
}

LibraryWorkspaceEntryData _buildReleaseEntryData(
  LibraryReleaseEntryRequest request, {
  String? mediaType,
}) {
  final entry = request.titleEntry;
  final normalizedMediaType =
      (mediaType ?? entry.mediaType).trim().toLowerCase();
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
