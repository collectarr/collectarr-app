import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/utils/text_utils.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/video_release_source.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/workspace/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';

LibraryWorkspaceEntry buildGenericLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final input = _buildShelfWorkspaceEntryInput(source);
  return GenericWorkspaceEntry(
    common: input.common,
    metadata: input.metadata,
    series: input.item.series,
    publishing: input.item.publishing,
    video: input.item.video,
    music: input.item.music,
    game: input.item.game,
  );
}

LibraryWorkspaceEntry buildBooksLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final input = _buildShelfWorkspaceEntryInput(source, mediaType: 'book');
  return BookWorkspaceEntry(
    common: input.common,
    metadata: input.metadata,
    series: input.item.series,
    publishing: input.item.publishing,
  );
}

LibraryWorkspaceEntry buildBoardGamesLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final input = _buildShelfWorkspaceEntryInput(source, mediaType: 'boardgame');
  return BoardGameWorkspaceEntry(
    common: input.common,
    metadata: input.metadata,
    series: input.item.series,
    publishing: input.item.publishing,
    game: input.item.game,
  );
}

LibraryWorkspaceEntry buildGamesLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final input = _buildShelfWorkspaceEntryInput(source, mediaType: 'game');
  return GameWorkspaceEntry(
    common: input.common,
    metadata: input.metadata,
    series: input.item.series,
    publishing: input.item.publishing,
    game: input.item.game,
  );
}

LibraryWorkspaceEntry buildMusicLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final input = _buildShelfWorkspaceEntryInput(source, mediaType: 'music');
  return MusicWorkspaceEntry(
    common: input.common,
    metadata: input.metadata,
    series: input.item.series,
    publishing: input.item.publishing,
    music: input.item.music,
  );
}

LibraryWorkspaceEntry buildMoviesLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final input = _buildShelfWorkspaceEntryInput(source);
  return _buildVideoWorkspaceEntry(
    common: input.common,
    metadata: input.metadata,
    series: input.item.series,
    publishing: input.item.publishing,
    video: input.item.video,
  );
}

LibraryWorkspaceEntry buildComicsLibraryWorkspaceEntryFromShelf(
  ShelfEntry source,
) {
  final input = _buildShelfWorkspaceEntryInput(source, mediaType: 'comic');
  return ComicWorkspaceEntry(
    common: input.common,
    metadata: input.metadata,
    comic: input.comic,
    series: input.item.series,
    publishing: input.item.publishing,
  );
}

LibraryWorkspaceEntry buildGenericLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return GenericWorkspaceEntry(
    common: _buildReleaseEntryData(request),
    metadata: _buildReleaseEntryMetadata(request),
    series: entry.series,
    publishing: entry.publishing,
    video: entry.video,
    music: entry.music,
    game: entry.game,
  );
}

LibraryWorkspaceEntry buildBooksLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return BookWorkspaceEntry(
    common: _buildReleaseEntryData(request, mediaType: 'book'),
    metadata: _buildReleaseEntryMetadata(request),
    series: entry.series,
    publishing: entry.publishing,
  );
}

LibraryWorkspaceEntry buildBoardGamesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return BoardGameWorkspaceEntry(
    common: _buildReleaseEntryData(request, mediaType: 'boardgame'),
    metadata: _buildReleaseEntryMetadata(request),
    series: entry.series,
    publishing: entry.publishing,
    game: entry.game,
  );
}

LibraryWorkspaceEntry buildGamesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return GameWorkspaceEntry(
    common: _buildReleaseEntryData(request, mediaType: 'game'),
    metadata: _buildReleaseEntryMetadata(request),
    series: entry.series,
    publishing: entry.publishing,
    game: entry.game,
  );
}

LibraryWorkspaceEntry buildMusicLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return MusicWorkspaceEntry(
    common: _buildReleaseEntryData(request, mediaType: 'music'),
    metadata: _buildReleaseEntryMetadata(request),
    series: entry.series,
    publishing: entry.publishing,
    music: entry.music,
  );
}

LibraryWorkspaceEntry buildMoviesLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return _buildVideoWorkspaceEntry(
    common: _buildReleaseEntryData(request),
    metadata: _buildReleaseEntryMetadata(request),
    series: entry.series,
    publishing: entry.publishing,
    video: entry.video,
  );
}

LibraryWorkspaceEntry buildComicsLibraryReleaseEntry(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  return ComicWorkspaceEntry(
    common: _buildReleaseEntryData(request, mediaType: 'comic'),
    metadata: _buildReleaseEntryMetadata(request),
    comic: entry.comic,
    series: entry.series,
    publishing: entry.publishing,
  );
}

class _ShelfWorkspaceEntryInput {
  const _ShelfWorkspaceEntryInput({
    required this.item,
    required this.common,
    required this.metadata,
    required this.comic,
  });

  final CatalogItem item;
  final LibraryWorkspaceEntryData common;
  final LibraryWorkspaceMetadata metadata;
  final ComicWorkspaceDetails? comic;
}

_ShelfWorkspaceEntryInput _buildShelfWorkspaceEntryInput(
  ShelfEntry source, {
  String? mediaType,
}) {
  final item = source.catalogItem!;
  final normalizedMediaType = (mediaType ?? item.kind).trim().toLowerCase();
  final resolvedEditions = resolveVideoCatalogEditionsForCatalogItem(
    item,
    ownedItems: source.ownedItem == null
        ? const <OwnedItem>[]
        : [source.ownedItem!],
    wishlistItems: source.wishlistItem == null
        ? const <WishlistItem>[]
        : [source.wishlistItem!],
  );
  return _ShelfWorkspaceEntryInput(
    item: item,
    common: LibraryWorkspaceEntryData(
      id: item.id,
      browseScope: LibraryBrowserScope.title,
      titleItemId: item.id,
      releaseId: null,
      copyId: null,
      ownedItemId: source.ownedItem?.id,
      mediaType: normalizedMediaType,
      title: item.title,
      displayTitle: item.displayTitle,
      localizedTitle: item.localizedTitle,
      originalTitle: item.originalTitle,
      searchAliases: _copyStringList(item.searchAliases),
      itemNumber: item.itemNumber,
      synopsis: item.synopsis,
      coverImageUrl: item.coverImageUrl,
      thumbnailImageUrl: item.thumbnailImageUrl,
      publisher: item.publisher,
      releaseDate: item.releaseDate,
      releaseYear: item.releaseYear,
      barcode: item.barcode,
      variant: item.displayEditionLabel,
      isOwned: source.isOwned,
      isTracked: source.isTracked,
      isWishlisted: source.isWishlisted,
      hasMissingCover: item.displayCoverUrl == null,
      hasMissingMetadata: genericHasMissingCoreMetadata(item),
      condition: source.ownedItem?.condition,
      grade: source.ownedItem?.grade,
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
        editions: resolvedEditions,
        fallbackFormatLabel: item.physicalFormatLabel,
      ),
      referenceEditionId:
          source.ownedItem?.editionId ?? source.wishlistItem?.editionId,
      referenceVariantId:
          source.ownedItem?.variantId ?? source.wishlistItem?.variantId,
      referenceBundleReleaseId:
          source.ownedItem?.bundleReleaseId ?? source.wishlistItem?.bundleReleaseId,
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
    ),
    metadata: LibraryWorkspaceMetadata(
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
    ),
    comic: normalizedMediaType == 'comic'
        ? ComicWorkspaceDetails(
            rawOrSlabbed: source.ownedItem?.rawOrSlabbed,
            gradingCompany: source.ownedItem?.gradingCompany,
            labelType: source.ownedItem?.labelType,
            certificationNumber: source.ownedItem?.certificationNumber,
            keyComic: source.ownedItem?.keyComic ?? false,
            keyReason: source.ownedItem?.keyReason,
          )
        : null,
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
    publisher: request.edition.publisher ?? entry.publisher,
    releaseDate: request.edition.releaseDate,
    releaseYear: request.edition.releaseDate?.year ?? entry.releaseYear,
    barcode: primaryVariant?.barcode ?? request.edition.upc,
    variant: primaryVariant?.name ?? request.edition.title,
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
  );
}

LibraryWorkspaceMetadata _buildReleaseEntryMetadata(
  LibraryReleaseEntryRequest request,
) {
  final entry = request.titleEntry;
  final metadata = entry.metadata;
  return LibraryWorkspaceMetadata(
    creators: _copyCreatorList(metadata.creators),
    characters: _copyStringList(metadata.characters),
    storyArcs: _copyStringList(metadata.storyArcs),
    genres: _copyStringList(metadata.genres),
    country: metadata.country,
    language: request.edition.language ?? metadata.language,
    ageRating: metadata.ageRating,
    audienceRating: metadata.audienceRating,
    rawPlatforms: _copyStringList(entry.game?.platforms),
  );
}

LibraryWorkspaceEntry _buildVideoWorkspaceEntry({
  required LibraryWorkspaceEntryData common,
  required LibraryWorkspaceMetadata metadata,
  CatalogSeriesDetails? series,
  CatalogPublishingDetails? publishing,
  VideoCatalogDetails? video,
}) {
  return switch (common.mediaType) {
    'tv' => TvWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
        video: video,
      ),
    'anime' => AnimeWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
        video: video,
      ),
    _ => MovieWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
        video: video,
      ),
  };
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

String defaultLibraryBucketLabel(
  LibraryBucketingContext context,
  LibraryMediaGroupLabels labels,
) {
  final entry = context.entry;
  final metadata = entry.metadata;
  final source = context.source;
  final publisher = entry.publisher?.trim();
  return switch (context.groupMode) {
    LibraryGroupMode.series => _seriesBucket(entry, labels.unknownSeries),
    LibraryGroupMode.storyArc => 'Story arc',
    LibraryGroupMode.character => 'Character',
    LibraryGroupMode.year => entry.releaseYear?.toString() ??
        (entry.releaseDate?.year.toString() ?? 'Unknown year'),
    LibraryGroupMode.audienceRating => metadata.audienceRating?.trim().isNotEmpty == true
      ? metadata.audienceRating!
        : 'No audience rating',
    LibraryGroupMode.color => _stringBucket(entry.video?.color, 'No color'),
    LibraryGroupMode.publisher =>
      publisher == null || publisher.isEmpty ? labels.unknownPublisher : publisher,
    LibraryGroupMode.genre => _firstOrDefault(metadata.genres, 'No genre'),
    LibraryGroupMode.country =>
      metadata.country?.trim().isNotEmpty == true ? metadata.country! : 'Unknown country',
    LibraryGroupMode.language =>
      metadata.language?.trim().isNotEmpty == true ? metadata.language! : 'Unknown language',
    LibraryGroupMode.ageRating =>
      metadata.ageRating?.trim().isNotEmpty == true ? metadata.ageRating! : 'Unrated',
    LibraryGroupMode.movieOrTvSeries => _movieOrTvSeriesBucket(entry),
    LibraryGroupMode.releaseDate => _dateBucket(entry.releaseDate, 'Unknown release date'),
    LibraryGroupMode.releaseMonth =>
      _monthBucket(entry.releaseDate, fallback: 'Unknown release month'),
    LibraryGroupMode.releaseYear => _yearBucket(
      entry.releaseDate ?? (entry.releaseYear == null ? null : DateTime(entry.releaseYear!)),
      'Unknown release year',
    ),
    LibraryGroupMode.audioTracks => _stringBucket(entry.video?.audioTracks, 'No audio tracks'),
    LibraryGroupMode.boxSet => _stringBucket(source.ownedItem?.boxSetName, 'No box set'),
    LibraryGroupMode.distributor => _stringBucket(source.ownedItem?.distributor, 'No distributor'),
    LibraryGroupMode.editionReleaseDate => _dateBucket(
      _referenceEditionForEntry(entry)?.releaseDate,
      'Unknown edition release date',
    ),
    LibraryGroupMode.editionReleaseMonth => _monthBucket(
      _referenceEditionForEntry(entry)?.releaseDate,
      fallback: 'Unknown edition release month',
    ),
    LibraryGroupMode.editionReleaseYear => _yearBucket(
      _referenceEditionForEntry(entry)?.releaseDate,
      'Unknown edition release year',
    ),
    LibraryGroupMode.extras => _stringBucket(source.ownedItem?.features, 'No extras'),
    LibraryGroupMode.format => _editionFormatBucket(entry),
    LibraryGroupMode.hdr => _firstOrDefault(source.ownedItem?.hdrFormats, 'No HDR'),
    LibraryGroupMode.layers => _stringBucket(entry.video?.layers, 'No layers'),
    LibraryGroupMode.packaging => _stringBucket(source.ownedItem?.packaging, 'No packaging'),
    LibraryGroupMode.regions => _stringBucket(_referenceRegionFor(source, entry), 'No region'),
    LibraryGroupMode.screenRatios => _stringBucket(entry.video?.screenRatio, 'No screen ratio'),
    LibraryGroupMode.subtitles => _stringBucket(entry.video?.subtitles, 'No subtitles'),
    LibraryGroupMode.actor => _creatorBucketByRole(entry, 'actor'),
    LibraryGroupMode.director => _creatorBucketByRole(entry, 'director'),
    LibraryGroupMode.musician => _creatorBucketByRole(entry, 'musician'),
    LibraryGroupMode.photography => _creatorBucketByRole(entry, 'photography'),
    LibraryGroupMode.producer => _creatorBucketByRole(entry, 'producer'),
    LibraryGroupMode.creator => _creatorBucketByRole(entry, null),
    LibraryGroupMode.writer => _creatorBucketByRole(entry, 'writer'),
    LibraryGroupMode.artist => _creatorBucketByRole(entry, 'artist'),
    LibraryGroupMode.penciller => _creatorBucketByRole(entry, 'penciller'),
    LibraryGroupMode.colorist => _creatorBucketByRole(entry, 'colorist'),
    LibraryGroupMode.letterer => _creatorBucketByRole(entry, 'letterer'),
    LibraryGroupMode.coverArtist => _creatorBucketByRole(entry, 'cover'),
    LibraryGroupMode.editor => _creatorBucketByRole(entry, 'editor'),
    LibraryGroupMode.location => _locationBucket(entry.locationPath),
    LibraryGroupMode.ownership => entry.isOwned
        ? 'Owned'
        : entry.isWishlisted
            ? 'Wishlist'
            : 'Catalog only',
    LibraryGroupMode.addedDate => _dateBucket(
      source.ownedItem?.createdAt ?? source.wishlistItem?.createdAt,
      'Unknown added date',
    ),
    LibraryGroupMode.addedMonth => _monthBucket(
      source.ownedItem?.createdAt ?? source.wishlistItem?.createdAt,
      fallback: 'Unknown added month',
    ),
    LibraryGroupMode.addedYear => _yearBucket(
      source.ownedItem?.createdAt ?? source.wishlistItem?.createdAt,
      'Unknown added year',
    ),
    LibraryGroupMode.collectionStatus => _stringBucket(
      source.ownedItem?.collectionStatus,
      'No collection status',
    ),
    LibraryGroupMode.title => _titleBucket(entry.resolvedTitle),
    LibraryGroupMode.grade => entry.grade?.trim().isNotEmpty == true ? entry.grade! : 'Ungraded',
    LibraryGroupMode.condition => entry.condition?.trim().isNotEmpty == true
        ? entry.condition!
        : 'No condition',
    LibraryGroupMode.rawOrSlabbed => entry.comic?.rawOrSlabbed?.trim().isNotEmpty == true
      ? entry.comic!.rawOrSlabbed!
        : 'Raw',
    LibraryGroupMode.isKeyComic => entry.comic?.keyComic == true ? 'Key' : 'Not special',
    LibraryGroupMode.imageType => _imageTypeBucket(source),
    LibraryGroupMode.modifiedDate => formatCompactDate(entry.updatedAt),
    LibraryGroupMode.modifiedMonth => _monthBucket(entry.updatedAt),
    LibraryGroupMode.myRating => _ratingBucket(source.tracking.rating),
    LibraryGroupMode.owner => _ownerBucket(source),
    LibraryGroupMode.purchaseDate => _dateBucket(
      source.ownedItem?.purchaseDate,
      'Unknown purchase date',
    ),
    LibraryGroupMode.purchaseMonth => _monthBucket(
      source.ownedItem?.purchaseDate,
      fallback: 'Unknown purchase month',
    ),
    LibraryGroupMode.purchaseYear => _yearBucket(
      source.ownedItem?.purchaseDate,
      'Unknown purchase year',
    ),
    LibraryGroupMode.purchaseStore => _stringBucket(source.ownedItem?.purchaseStore, 'No purchase store'),
    LibraryGroupMode.storageDevice => _stringBucket(source.ownedItem?.storageDevice, 'No storage device'),
    LibraryGroupMode.tags => _firstOrDefault(
      entry.tags
          ?.split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
      'No tags',
    ),
    LibraryGroupMode.watchDate => _dateBucket(_latestWatchSession(source)?.watchedAt, 'Unknown watch date'),
    LibraryGroupMode.watchMonth => _monthBucket(
      _latestWatchSession(source)?.watchedAt,
      fallback: 'Unknown watch month',
    ),
    LibraryGroupMode.watchYear => _yearBucket(
      _latestWatchSession(source)?.watchedAt,
      'Unknown watch year',
    ),
    LibraryGroupMode.watched => _watchedBucket(source),
    LibraryGroupMode.watchedWhere => _watchedWhereBucket(source),
  };
}

bool genericHasMissingCoreMetadata(CatalogItem item) {
  return item.publisher == null &&
      item.releaseDate == null &&
      item.releaseYear == null &&
      item.displayCoverUrl == null &&
      item.displayEditionLabel == null;
}

const _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _imageTypeLabels = <String, String>{
  'front_cover': 'Front Cover',
  'back_cover': 'Back Cover',
  'auxiliary': 'Photos',
};

String _dateBucket(DateTime? value, String fallback) {
  return value == null ? fallback : formatCompactDate(value);
}

String _monthBucket(DateTime? value, {String fallback = 'Unknown month'}) {
  if (value == null) {
    return fallback;
  }
  final local = value.toLocal();
  return '${_monthNames[local.month - 1]} ${local.year}';
}

String _yearBucket(DateTime? value, String fallback) {
  return value == null ? fallback : value.toLocal().year.toString();
}

String _stringBucket(String? value, String fallback) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return fallback;
  }
  return normalized;
}

String _ratingBucket(int? rating) {
  if (rating == null || rating <= 0) {
    return 'No rating';
  }
  return rating.toString();
}

String _imageTypeBucket(ShelfEntry source) {
  final imageType = source.itemImages.firstOrNull?.imageType;
  if (imageType == null || imageType.trim().isEmpty) {
    return 'No image type';
  }
  return _imageTypeLabels[imageType] ?? imageType;
}

WatchSession? _latestWatchSession(ShelfEntry source) {
  return source.watchSessions.firstOrNull;
}

String _watchedBucket(ShelfEntry source) {
  final latestSession = _latestWatchSession(source);
  final tracking = source.tracking;
  final watched = latestSession != null ||
      tracking.completedAt != null ||
      tracking.status == MediaTrackingStatus.completed ||
      tracking.status == MediaTrackingStatus.repeating;
  return watched ? 'Watched' : 'Not watched';
}

String _watchedWhereBucket(ShelfEntry source) {
  final label = _latestWatchSession(source)?.sourceType?.label;
  if (label == null || label.trim().isEmpty) {
    return 'Unknown watch source';
  }
  return label;
}

String _ownerBucket(ShelfEntry source) {
  final explicit = source.ownedItem?.ownerLabel?.trim();
  if (explicit != null && explicit.isNotEmpty) {
    return explicit;
  }
  final fallback = source.fallbackOwnerLabel?.trim();
  if (fallback != null && fallback.isNotEmpty) {
    return fallback;
  }
  return 'Unknown owner';
}

String _locationBucket(String? location) {
  final normalized = location?.trim();
  if (normalized == null || normalized.isEmpty) {
    return 'No location';
  }
  return normalized;
}

String _firstOrDefault(List<String>? values, String fallback) {
  if (values == null || values.isEmpty) return fallback;
  final first = values.first.trim();
  return first.isEmpty ? fallback : first;
}

String _editionFormatBucket(LibraryWorkspaceEntry entry) {
  for (final edition in entry.editions) {
    final label = edition.physicalFormatLabel ?? edition.physicalFormat;
    if (label != null && label.trim().isNotEmpty) {
      return label.trim();
    }
  }
  return 'Unknown format';
}

String _movieOrTvSeriesBucket(LibraryWorkspaceEntry entry) {
  final normalizedMediaType = entry.mediaType.trim().toLowerCase();
  if (normalizedMediaType == 'tv') {
    return 'TV Series';
  }
  final series = entry.series;
  if (series?.seasonNumber != null || series?.episodeNumber != null) {
    return 'TV Series';
  }
  return 'Movie';
}

CatalogEdition? _referenceEditionForEntry(LibraryWorkspaceEntry entry) {
  final resolved = resolveLibraryEntryReferenceRelease(entry);
  return resolved.edition ?? (entry.editions.isEmpty ? null : entry.editions.first);
}

String? _referenceRegionFor(ShelfEntry source, LibraryWorkspaceEntry entry) {
  final resolved = resolveLibraryEntryReferenceRelease(entry);
  final variantRegion = resolved.variant?.region?.trim();
  if (variantRegion != null && variantRegion.isNotEmpty) {
    return variantRegion;
  }
  final editionRegion = _referenceEditionForEntry(entry)?.region?.trim();
  if (editionRegion != null && editionRegion.isNotEmpty) {
    return editionRegion;
  }
  final ownedRegion = source.ownedItem?.region?.trim();
  if (ownedRegion != null && ownedRegion.isNotEmpty) {
    return ownedRegion;
  }
  return null;
}

String _creatorBucketByRole(LibraryWorkspaceEntry entry, String? role) {
  for (final credit in entry.metadata.creators ?? const <Map<String, dynamic>>[]) {
    final name = credit['name']?.toString().trim();
    if (name == null || name.isEmpty) continue;
    if (role == null) return name;
    final creditRole = credit['role']?.toString().toLowerCase().trim();
    if (creditRole != null && _matchesCreatorRole(creditRole, role)) {
      return name;
    }
  }
  return role != null ? 'Unknown $role' : 'Unknown creator';
}

bool _matchesCreatorRole(String creditRole, String role) {
  return switch (role) {
    'actor' => creditRole.contains('actor') || creditRole.contains('cast'),
    'musician' =>
      creditRole.contains('musician') ||
      creditRole.contains('music') ||
      creditRole.contains('composer'),
    'photography' =>
      creditRole.contains('photography') ||
      creditRole.contains('director of photography') ||
      creditRole.contains('cinemat'),
    _ => creditRole.contains(role),
  };
}

String _seriesBucket(LibraryWorkspaceEntry entry, String unknownLabel) {
  final seriesTitle = entry.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  final title = entry.resolvedTitle.trim();
  return title.isEmpty ? unknownLabel : title;
}

String _titleBucket(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? 'Unknown' : trimmed.substring(0, 1).toUpperCase();
}