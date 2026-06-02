// ignore_for_file: use_super_parameters

import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/library_browser_scope.dart';

sealed class LibraryWorkspaceEntry {
  LibraryWorkspaceEntry._({
    required this.id,
    required this.mediaType,
    required this.title,
    this.browseScope = LibraryBrowserScope.title,
    this.titleItemId,
    this.releaseId,
    this.copyId,
    this.displayTitle,
    this.localizedTitle,
    this.originalTitle,
    this.searchAliases,
    this.ownedItemId,
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.publisher,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.isOwned = false,
    this.isTracked = false,
    this.isWishlisted = false,
    this.hasMissingCover = false,
    this.hasMissingMetadata = false,
    this.condition,
    this.grade,
    this.primaryReferenceLabel,
    this.referenceScopeLabel,
    this.referenceFormatLabel,
    this.referenceEditionId,
    this.referenceVariantId,
    this.referenceBundleReleaseId,
    this.notes,
    this.tags,
    this.collectionStatus,
    this.lastBagBoardDate,
    this.pricePaidCents,
    this.currency,
    this.locationPath,
    this.addedAt,
    this.editions = const <CatalogEdition>[],
    required this.updatedAt,
    this.trailerUrls = const <TrailerLink>[],
  });

  factory LibraryWorkspaceEntry({
    required String id,
    required String mediaType,
    required String title,
    LibraryBrowserScope browseScope = LibraryBrowserScope.title,
    String? titleItemId,
    String? releaseId,
    String? copyId,
    String? displayTitle,
    String? localizedTitle,
    String? originalTitle,
    List<String>? searchAliases,
    String? ownedItemId,
    String? itemNumber,
    String? synopsis,
    String? plotSummary,
    String? plotDescription,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    String? publisher,
    DateTime? releaseDate,
    int? releaseYear,
    String? barcode,
    String? variant,
    bool isOwned = false,
    bool isTracked = false,
    bool isWishlisted = false,
    bool hasMissingCover = false,
    bool hasMissingMetadata = false,
    String? condition,
    String? grade,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? labelType,
    String? certificationNumber,
    String? primaryReferenceLabel,
    String? referenceScopeLabel,
    String? referenceFormatLabel,
    String? referenceEditionId,
    String? referenceVariantId,
    String? referenceBundleReleaseId,
    bool keyComic = false,
    String? keyReason,
    String? notes,
    String? tags,
    String? collectionStatus,
    DateTime? lastBagBoardDate,
    int? pricePaidCents,
    String? currency,
    String? locationPath,
    DateTime? addedAt,
    CatalogSeriesDetails? series,
    VideoCatalogDetails? video,
    MusicCatalogDetails? music,
    GameCatalogDetails? game,
    CatalogPublishingDetails? publishing,
    List<Map<String, dynamic>>? creators,
    List<String>? characters,
    List<String>? storyArcs,
    List<String>? genres,
    String? country,
    String? language,
    String? ageRating,
    String? audienceRating,
    List<CatalogEdition> editions = const <CatalogEdition>[],
    required DateTime updatedAt,
    List<TrailerLink>? trailerUrls,
  }) {
    final normalizedMediaType = mediaType.trim().toLowerCase();
    final common = LibraryWorkspaceEntryData(
      id: id,
      browseScope: browseScope,
      titleItemId: titleItemId,
      releaseId: releaseId,
      copyId: copyId,
      ownedItemId: ownedItemId,
      mediaType: normalizedMediaType,
      title: title,
      displayTitle: displayTitle,
      localizedTitle: localizedTitle,
      originalTitle: originalTitle,
      searchAliases: _copyStringList(searchAliases),
      itemNumber: itemNumber,
      synopsis: synopsis,
      coverImageUrl: coverImageUrl,
      thumbnailImageUrl: thumbnailImageUrl,
      publisher: publisher,
      releaseDate: releaseDate,
      releaseYear: releaseYear,
      barcode: barcode,
      variant: variant,
      isOwned: isOwned,
      isTracked: isTracked,
      isWishlisted: isWishlisted,
      hasMissingCover: hasMissingCover,
      hasMissingMetadata: hasMissingMetadata,
      condition: condition,
      grade: grade,
      primaryReferenceLabel: primaryReferenceLabel,
      referenceScopeLabel: referenceScopeLabel,
      referenceFormatLabel: referenceFormatLabel,
      referenceEditionId: referenceEditionId,
      referenceVariantId: referenceVariantId,
      referenceBundleReleaseId: referenceBundleReleaseId,
      notes: notes,
      tags: tags,
      collectionStatus: collectionStatus,
      lastBagBoardDate: lastBagBoardDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      locationPath: locationPath,
      addedAt: addedAt,
      editions: _copyEditionList(editions),
      updatedAt: updatedAt,
      trailerUrls: trailerUrls ?? const <TrailerLink>[],
    );
    final metadata = LibraryWorkspaceMetadata(
      plotSummary: plotSummary,
      plotDescription: plotDescription,
      creators: _copyMapList(creators),
      characters: _copyStringList(characters),
      storyArcs: _copyStringList(storyArcs),
      genres: _copyStringList(genres),
      country: country,
      language: language,
      ageRating: ageRating,
      audienceRating: audienceRating,
      rawPlatforms: _copyStringList(game?.platforms),
    );
    return _buildTypedWorkspaceEntry(
      mediaType: normalizedMediaType,
      common: common,
      metadata: metadata,
      comic: _comicOrNull(
        rawOrSlabbed: rawOrSlabbed,
        gradingCompany: gradingCompany,
        labelType: labelType,
        certificationNumber: certificationNumber,
        keyComic: keyComic,
        keyReason: keyReason,
      ),
      series: series,
      publishing: publishing,
      video: video,
      music: music,
      game: game,
    );
  }

  factory LibraryWorkspaceEntry.releaseNode({
    required String titleItemId,
    required String mediaType,
    required String title,
    required CatalogEdition edition,
    String? displayTitle,
    String? localizedTitle,
    String? originalTitle,
    List<String>? searchAliases,
    String? fallbackSynopsis,
    String? fallbackCoverImageUrl,
    String? fallbackThumbnailImageUrl,
    String? fallbackPublisher,
    int? fallbackReleaseYear,
    CatalogSeriesDetails? fallbackSeries,
    CatalogPublishingDetails? fallbackPublishing,
    VideoCatalogDetails? fallbackVideo,
    MusicCatalogDetails? fallbackMusic,
    GameCatalogDetails? fallbackGame,
    List<Map<String, dynamic>>? fallbackCreators,
    List<String>? fallbackCharacters,
    List<String>? fallbackStoryArcs,
    List<String>? fallbackGenres,
    String? fallbackCountry,
    String? fallbackLanguage,
    String? fallbackAgeRating,
    String? fallbackAudienceRating,
    bool isOwned = false,
    bool isWishlisted = false,
    bool isTracked = false,
    String? referenceEditionId,
    String? referenceVariantId,
    String? referenceBundleReleaseId,
    List<CatalogEdition> editions = const <CatalogEdition>[],
    required DateTime updatedAt,
  }) {
    final normalizedMediaType = mediaType.trim().toLowerCase();
    CatalogVariant? primaryVariant;
    for (final variant in edition.variants) {
      if (variant.isPrimary) {
        primaryVariant = variant;
        break;
      }
    }
    primaryVariant ??= edition.variants.isEmpty ? null : edition.variants.first;
    final common = LibraryWorkspaceEntryData(
      id: '$titleItemId:release:${edition.id}',
      browseScope: LibraryBrowserScope.release,
      titleItemId: titleItemId,
      releaseId: edition.id,
      copyId: null,
      ownedItemId: null,
      mediaType: normalizedMediaType,
      title: title,
      displayTitle: displayTitle,
      localizedTitle: localizedTitle,
      originalTitle: originalTitle,
      searchAliases: _copyStringList(searchAliases),
      itemNumber: null,
      synopsis: fallbackSynopsis,
      coverImageUrl: primaryVariant?.coverImageUrl ?? fallbackCoverImageUrl,
      thumbnailImageUrl: primaryVariant?.thumbnailImageUrl ??
          primaryVariant?.coverImageUrl ??
          fallbackThumbnailImageUrl ??
          fallbackCoverImageUrl,
      publisher: edition.publisher ?? fallbackPublisher,
      releaseDate: edition.releaseDate,
      releaseYear: edition.releaseDate?.year ?? fallbackReleaseYear,
      barcode: primaryVariant?.barcode ?? edition.upc,
      variant: primaryVariant?.name ?? edition.title,
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
          primaryVariant?.physicalFormatLabel ?? edition.physicalFormatLabel,
      referenceEditionId: referenceEditionId ?? edition.id,
      referenceVariantId: referenceVariantId ?? primaryVariant?.id,
      referenceBundleReleaseId: referenceBundleReleaseId,
      notes: null,
      tags: null,
      collectionStatus: null,
      lastBagBoardDate: null,
      pricePaidCents: null,
      currency: null,
      locationPath: null,
      addedAt: null,
      editions: _copyEditionList(editions.isEmpty ? [edition] : editions),
      updatedAt: updatedAt,
      trailerUrls: const <TrailerLink>[],
    );
    final metadata = LibraryWorkspaceMetadata(
      creators: _copyMapList(fallbackCreators),
      characters: _copyStringList(fallbackCharacters),
      storyArcs: _copyStringList(fallbackStoryArcs),
      genres: _copyStringList(fallbackGenres),
      country: fallbackCountry,
      language: edition.language ?? fallbackLanguage,
      ageRating: fallbackAgeRating,
      audienceRating: fallbackAudienceRating,
      rawPlatforms: _copyStringList(fallbackGame?.platforms),
    );
    return _buildTypedWorkspaceEntry(
      mediaType: normalizedMediaType,
      common: common,
      metadata: metadata,
      comic: null,
      series: fallbackSeries,
      publishing: fallbackPublishing,
      video: fallbackVideo,
      music: fallbackMusic,
      game: fallbackGame,
    );
  }

  final String id;
  final LibraryBrowserScope browseScope;
  final String? titleItemId;
  final String? releaseId;
  final String? copyId;
  final String? ownedItemId;
  final String mediaType;
  final String title;
  final String? displayTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final List<String>? searchAliases;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final bool isOwned;
  final bool isTracked;
  final bool isWishlisted;
  final bool hasMissingCover;
  final bool hasMissingMetadata;
  final String? condition;
  final String? grade;
  final String? primaryReferenceLabel;
  final String? referenceScopeLabel;
  final String? referenceFormatLabel;
  final String? referenceEditionId;
  final String? referenceVariantId;
  final String? referenceBundleReleaseId;
  final String? notes;
  final String? tags;
  final String? collectionStatus;
  final DateTime? lastBagBoardDate;
  final int? pricePaidCents;
  final String? currency;
  final String? locationPath;
  final DateTime? addedAt;
  final List<CatalogEdition> editions;
  final DateTime updatedAt;
  final List<TrailerLink> trailerUrls;

  String get resolvedTitle {
    final display = displayTitle?.trim();
    if (display != null && display.isNotEmpty) {
      return display;
    }
    final localized = localizedTitle?.trim();
    if (localized != null && localized.isNotEmpty) {
      return localized;
    }
    final raw = title.trim();
    if (raw.isNotEmpty) {
      return raw;
    }
    final original = originalTitle?.trim();
    if (original != null && original.isNotEmpty) {
      return original;
    }
    return title;
  }

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  LibraryWorkspaceMetadata get metadata;
  ComicWorkspaceDetails? get comic;
  CatalogSeriesDetails? get series;
  CatalogPublishingDetails? get publishing;
  VideoCatalogDetails? get video;
  MusicCatalogDetails? get music;
  GameCatalogDetails? get game;

}

LibraryWorkspaceEntry _buildTypedWorkspaceEntry({
  required String mediaType,
  required LibraryWorkspaceEntryData common,
  required LibraryWorkspaceMetadata metadata,
  ComicWorkspaceDetails? comic,
  CatalogSeriesDetails? series,
  CatalogPublishingDetails? publishing,
  VideoCatalogDetails? video,
  MusicCatalogDetails? music,
  GameCatalogDetails? game,
}) {
  switch (mediaType.trim().toLowerCase()) {
    case 'comic':
      return ComicWorkspaceEntry(
        common: common,
        metadata: metadata,
        comic: comic,
        series: series,
        publishing: publishing,
      );
    case 'manga':
      return MangaWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
      );
    case 'book':
      return BookWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
      );
    case 'movie':
      return MovieWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
        video: video,
      );
    case 'tv':
      return TvWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
        video: video,
      );
    case 'anime':
      return AnimeWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
        video: video,
      );
    case 'music':
      return MusicWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
        music: music,
      );
    case 'game':
      return GameWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
        game: game,
      );
    case 'boardgame':
      return BoardGameWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
        game: game,
      );
    default:
      return GenericWorkspaceEntry(
        common: common,
        metadata: metadata,
        series: series,
        publishing: publishing,
        video: video,
        music: music,
        game: game,
      );
  }
}

abstract base class _TypedLibraryWorkspaceEntry extends LibraryWorkspaceEntry {
  _TypedLibraryWorkspaceEntry._({
    required LibraryWorkspaceEntryData common,
    required this.metadataDetails,
    this.comicDetails,
    this.seriesDetails,
    this.publishingDetails,
    this.videoDetails,
    this.musicDetails,
    this.gameDetails,
  }) : super._(
          id: common.id,
      browseScope: common.browseScope,
      titleItemId: common.titleItemId,
      releaseId: common.releaseId,
      copyId: common.copyId,
      displayTitle: common.displayTitle,
      localizedTitle: common.localizedTitle,
      originalTitle: common.originalTitle,
      searchAliases: common.searchAliases,
          ownedItemId: common.ownedItemId,
          mediaType: common.mediaType,
          title: common.title,
          itemNumber: common.itemNumber,
          synopsis: common.synopsis,
          coverImageUrl: common.coverImageUrl,
          thumbnailImageUrl: common.thumbnailImageUrl,
          publisher: common.publisher,
          releaseDate: common.releaseDate,
          releaseYear: common.releaseYear,
          barcode: common.barcode,
          variant: common.variant,
          isOwned: common.isOwned,
          isTracked: common.isTracked,
          isWishlisted: common.isWishlisted,
          hasMissingCover: common.hasMissingCover,
          hasMissingMetadata: common.hasMissingMetadata,
          condition: common.condition,
          grade: common.grade,
          primaryReferenceLabel: common.primaryReferenceLabel,
          referenceScopeLabel: common.referenceScopeLabel,
          referenceFormatLabel: common.referenceFormatLabel,
          referenceEditionId: common.referenceEditionId,
          referenceVariantId: common.referenceVariantId,
          referenceBundleReleaseId: common.referenceBundleReleaseId,
          notes: common.notes,
          tags: common.tags,
          collectionStatus: common.collectionStatus,
          lastBagBoardDate: common.lastBagBoardDate,
          pricePaidCents: common.pricePaidCents,
          currency: common.currency,
          locationPath: common.locationPath,
          addedAt: common.addedAt,
          editions: common.editions,
          updatedAt: common.updatedAt,
          trailerUrls: common.trailerUrls,
        );

  final LibraryWorkspaceMetadata metadataDetails;
  final ComicWorkspaceDetails? comicDetails;
  final CatalogSeriesDetails? seriesDetails;
  final CatalogPublishingDetails? publishingDetails;
  final VideoCatalogDetails? videoDetails;
  final MusicCatalogDetails? musicDetails;
  final GameCatalogDetails? gameDetails;

  @override
  LibraryWorkspaceMetadata get metadata => metadataDetails;

  @override
  ComicWorkspaceDetails? get comic => comicDetails;

  @override
  CatalogSeriesDetails? get series => seriesDetails;

  @override
  CatalogPublishingDetails? get publishing => publishingDetails;

  @override
  VideoCatalogDetails? get video => videoDetails;

  @override
  MusicCatalogDetails? get music => musicDetails;

  @override
  GameCatalogDetails? get game => gameDetails;
}

final class ComicWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  ComicWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    required LibraryWorkspaceMetadata metadata,
    ComicWorkspaceDetails? comic,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          metadataDetails: metadata,
          comicDetails: comic,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
        );
}

final class MangaWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MangaWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    required LibraryWorkspaceMetadata metadata,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          metadataDetails: metadata,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
        );
}

final class BookWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  BookWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    required LibraryWorkspaceMetadata metadata,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          metadataDetails: metadata,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
        );
}

final class MovieWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MovieWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    required LibraryWorkspaceMetadata metadata,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          metadataDetails: metadata,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          videoDetails: _videoOrNull(video),
        );
}

final class TvWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  TvWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    required LibraryWorkspaceMetadata metadata,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          metadataDetails: metadata,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          videoDetails: _videoOrNull(video),
        );
}

final class AnimeWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  AnimeWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    required LibraryWorkspaceMetadata metadata,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          metadataDetails: metadata,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          videoDetails: _videoOrNull(video),
        );
}

final class MusicWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MusicWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    required LibraryWorkspaceMetadata metadata,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    MusicCatalogDetails? music,
  }) : super._(
          common: common,
          metadataDetails: metadata,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          musicDetails: _musicOrNull(music),
        );
}

final class GameWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  GameWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    required LibraryWorkspaceMetadata metadata,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          metadataDetails: metadata,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          gameDetails: _gameOrNull(game),
        );
}

final class BoardGameWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  BoardGameWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    required LibraryWorkspaceMetadata metadata,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          metadataDetails: metadata,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          gameDetails: _gameOrNull(game),
        );
}

final class GenericWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  GenericWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    required LibraryWorkspaceMetadata metadata,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
    MusicCatalogDetails? music,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          metadataDetails: metadata,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          videoDetails: _videoOrNull(video),
          musicDetails: _musicOrNull(music),
          gameDetails: _gameOrNull(game),
        );
}

class LibraryWorkspaceMetadata {
  const LibraryWorkspaceMetadata({
    this.plotSummary,
    this.plotDescription,
    this.creators,
    this.characters,
    this.storyArcs,
    this.genres,
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.rawPlatforms,
  });

  final String? plotSummary;
  final String? plotDescription;
  final List<Map<String, dynamic>>? creators;
  final List<String>? characters;
  final List<String>? storyArcs;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final List<String>? rawPlatforms;
}

class ComicWorkspaceDetails {
  const ComicWorkspaceDetails({
    this.rawOrSlabbed,
    this.gradingCompany,
    this.labelType,
    this.certificationNumber,
    this.keyComic = false,
    this.keyReason,
  });

  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? labelType;
  final String? certificationNumber;
  final bool keyComic;
  final String? keyReason;

  bool get hasData =>
      rawOrSlabbed != null ||
      gradingCompany != null ||
      labelType != null ||
      certificationNumber != null ||
      keyComic ||
      keyReason != null;
}

class LibraryWorkspaceEntryData {
  const LibraryWorkspaceEntryData({
    required this.id,
    required this.browseScope,
    required this.titleItemId,
    required this.releaseId,
    required this.copyId,
    required this.ownedItemId,
    required this.mediaType,
    required this.title,
    required this.displayTitle,
    required this.localizedTitle,
    required this.originalTitle,
    required this.searchAliases,
    required this.itemNumber,
    required this.synopsis,
    required this.coverImageUrl,
    required this.thumbnailImageUrl,
    required this.publisher,
    required this.releaseDate,
    required this.releaseYear,
    required this.barcode,
    required this.variant,
    required this.isOwned,
    required this.isTracked,
    required this.isWishlisted,
    required this.hasMissingCover,
    required this.hasMissingMetadata,
    required this.condition,
    required this.grade,
    required this.primaryReferenceLabel,
    required this.referenceScopeLabel,
    required this.referenceFormatLabel,
    required this.referenceEditionId,
    required this.referenceVariantId,
    required this.referenceBundleReleaseId,
    required this.notes,
    required this.tags,
    required this.collectionStatus,
    required this.lastBagBoardDate,
    required this.pricePaidCents,
    required this.currency,
    required this.locationPath,
    required this.addedAt,
    required this.editions,
    required this.updatedAt,
    required this.trailerUrls,
  });

  final String id;
  final LibraryBrowserScope browseScope;
  final String? titleItemId;
  final String? releaseId;
  final String? copyId;
  final String? ownedItemId;
  final String mediaType;
  final String title;
  final String? displayTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final List<String>? searchAliases;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? publisher;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final bool isOwned;
  final bool isTracked;
  final bool isWishlisted;
  final bool hasMissingCover;
  final bool hasMissingMetadata;
  final String? condition;
  final String? grade;
  final String? primaryReferenceLabel;
  final String? referenceScopeLabel;
  final String? referenceFormatLabel;
  final String? referenceEditionId;
  final String? referenceVariantId;
  final String? referenceBundleReleaseId;
  final String? notes;
  final String? tags;
  final String? collectionStatus;
  final DateTime? lastBagBoardDate;
  final int? pricePaidCents;
  final String? currency;
  final String? locationPath;
  final DateTime? addedAt;
  final List<CatalogEdition> editions;
  final DateTime updatedAt;
  final List<TrailerLink> trailerUrls;
}

CatalogSeriesDetails? _seriesOrNull(CatalogSeriesDetails? details) {
  if (details == null) {
    return null;
  }
  return details.hasData ? details : null;
}

CatalogPublishingDetails? _publishingOrNull(CatalogPublishingDetails? details) {
  if (details == null) {
    return null;
  }
  return details.hasData ? details : null;
}

VideoCatalogDetails? _videoOrNull(VideoCatalogDetails? details) {
  if (details == null) {
    return null;
  }
  return details.hasData ? details : null;
}

MusicCatalogDetails? _musicOrNull(MusicCatalogDetails? details) {
  if (details == null) {
    return null;
  }
  return details.hasData ? details : null;
}

GameCatalogDetails? _gameOrNull(GameCatalogDetails? details) {
  if (details == null) {
    return null;
  }
  return details.hasData ? details : null;
}

ComicWorkspaceDetails? _comicOrNull({
  String? rawOrSlabbed,
  String? gradingCompany,
  String? labelType,
  String? certificationNumber,
  bool keyComic = false,
  String? keyReason,
}) {
  final details = ComicWorkspaceDetails(
    rawOrSlabbed: rawOrSlabbed,
    gradingCompany: gradingCompany,
    labelType: labelType,
    certificationNumber: certificationNumber,
    keyComic: keyComic,
    keyReason: keyReason,
  );
  return details.hasData ? details : null;
}

List<String>? _copyStringList(List<String>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}

List<Map<String, dynamic>>? _copyMapList(List<Map<String, dynamic>>? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  return values.toList(growable: false);
}

List<CatalogEdition> _copyEditionList(List<CatalogEdition> values) {
  if (values.isEmpty) {
    return const <CatalogEdition>[];
  }
  return values.toList(growable: false);
}

