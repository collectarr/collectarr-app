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
    this.rawOrSlabbed,
    this.gradingCompany,
    this.labelType,
    this.certificationNumber,
    this.primaryReferenceLabel,
    this.referenceScopeLabel,
    this.referenceFormatLabel,
    this.referenceEditionId,
    this.referenceVariantId,
    this.referenceBundleReleaseId,
    this.keyComic = false,
    this.keyReason,
    this.notes,
    this.tags,
    this.collectionStatus,
    this.lastBagBoardDate,
    this.pricePaidCents,
    this.currency,
    this.locationPath,
    this.addedAt,
    this.creators,
    this.characters,
    this.storyArcs,
    this.genres,
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.editions = const <CatalogEdition>[],
    required this.updatedAt,
    this.rawPlatforms,
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
    final common = _LibraryWorkspaceCommon(
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
      rawOrSlabbed: rawOrSlabbed,
      gradingCompany: gradingCompany,
      labelType: labelType,
      certificationNumber: certificationNumber,
      primaryReferenceLabel: primaryReferenceLabel,
      referenceScopeLabel: referenceScopeLabel,
      referenceFormatLabel: referenceFormatLabel,
      referenceEditionId: referenceEditionId,
      referenceVariantId: referenceVariantId,
      referenceBundleReleaseId: referenceBundleReleaseId,
      keyComic: keyComic,
      keyReason: keyReason,
      notes: notes,
      tags: tags,
      collectionStatus: collectionStatus,
      lastBagBoardDate: lastBagBoardDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      locationPath: locationPath,
      addedAt: addedAt,
      creators: _copyMapList(creators),
      characters: _copyStringList(characters),
      storyArcs: _copyStringList(storyArcs),
      genres: _copyStringList(genres),
      country: country,
      language: language,
      ageRating: ageRating,
      audienceRating: audienceRating,
      editions: _copyEditionList(editions),
      updatedAt: updatedAt,
      rawPlatforms: _copyStringList(game?.platforms),
      trailerUrls: trailerUrls ?? const <TrailerLink>[],
    );
    series = series == null ? null : _seriesOrNull(series);
    publishing = publishing == null ? null : _publishingOrNull(publishing);
    video = video == null ? null : _videoOrNull(video);
    music = music == null ? null : _musicOrNull(music);
    game = game == null ? null : _gameOrNull(game);

    switch (normalizedMediaType) {
      case 'comic':
        return ComicWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case 'manga':
        return MangaWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case 'book':
        return BookWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
        );
      case 'movie':
        return MovieWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
        );
      case 'tv':
        return TvWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
        );
      case 'anime':
        return AnimeWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
        );
      case 'music':
        return MusicWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          music: music,
        );
      case 'game':
        return GameWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          game: game,
        );
      case 'boardgame':
        return BoardGameWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          game: game,
        );
      default:
        return GenericWorkspaceEntry._(
          common: common,
          series: series,
          publishing: publishing,
          video: video,
          music: music,
          game: game,
        );
    }
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
    CatalogVariant? primaryVariant;
    for (final variant in edition.variants) {
      if (variant.isPrimary) {
        primaryVariant = variant;
        break;
      }
    }
    primaryVariant ??= edition.variants.isEmpty ? null : edition.variants.first;
    return LibraryWorkspaceEntry(
      id: '$titleItemId:release:${edition.id}',
      browseScope: LibraryBrowserScope.release,
      titleItemId: titleItemId,
      releaseId: edition.id,
      mediaType: mediaType,
      title: title,
      displayTitle: displayTitle,
      localizedTitle: localizedTitle,
      originalTitle: originalTitle,
      searchAliases: searchAliases,
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
      referenceFormatLabel:
          primaryVariant?.physicalFormatLabel ?? edition.physicalFormatLabel,
      referenceEditionId: referenceEditionId ?? edition.id,
      referenceVariantId: referenceVariantId ?? primaryVariant?.id,
      referenceBundleReleaseId: referenceBundleReleaseId,
      creators: fallbackCreators,
      characters: fallbackCharacters,
      storyArcs: fallbackStoryArcs,
      genres: fallbackGenres,
      country: fallbackCountry,
      language: edition.language ?? fallbackLanguage,
      ageRating: fallbackAgeRating,
      audienceRating: fallbackAudienceRating,
      series: fallbackSeries,
      publishing: fallbackPublishing,
      video: fallbackVideo,
      music: fallbackMusic,
      game: fallbackGame,
      editions: editions.isEmpty ? [edition] : editions,
      updatedAt: updatedAt,
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
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? labelType;
  final String? certificationNumber;
  final String? primaryReferenceLabel;
  final String? referenceScopeLabel;
  final String? referenceFormatLabel;
  final String? referenceEditionId;
  final String? referenceVariantId;
  final String? referenceBundleReleaseId;
  final bool keyComic;
  final String? keyReason;
  final String? notes;
  final String? tags;
  final String? collectionStatus;
  final DateTime? lastBagBoardDate;
  final int? pricePaidCents;
  final String? currency;
  final String? locationPath;
  final DateTime? addedAt;
  final List<Map<String, dynamic>>? creators;
  final List<String>? characters;
  final List<String>? storyArcs;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final List<CatalogEdition> editions;
  final DateTime updatedAt;
  final List<String>? rawPlatforms;
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

  CatalogSeriesDetails? get series;
  CatalogPublishingDetails? get publishing;
  VideoCatalogDetails? get video;
  MusicCatalogDetails? get music;
  GameCatalogDetails? get game;

}

abstract base class _TypedLibraryWorkspaceEntry extends LibraryWorkspaceEntry {
  _TypedLibraryWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
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
          rawOrSlabbed: common.rawOrSlabbed,
          gradingCompany: common.gradingCompany,
          labelType: common.labelType,
          certificationNumber: common.certificationNumber,
          primaryReferenceLabel: common.primaryReferenceLabel,
          referenceScopeLabel: common.referenceScopeLabel,
          referenceFormatLabel: common.referenceFormatLabel,
          referenceEditionId: common.referenceEditionId,
          referenceVariantId: common.referenceVariantId,
          referenceBundleReleaseId: common.referenceBundleReleaseId,
          keyComic: common.keyComic,
          keyReason: common.keyReason,
          notes: common.notes,
          tags: common.tags,
          collectionStatus: common.collectionStatus,
          lastBagBoardDate: common.lastBagBoardDate,
          pricePaidCents: common.pricePaidCents,
          currency: common.currency,
          locationPath: common.locationPath,
          addedAt: common.addedAt,
          creators: common.creators,
          characters: common.characters,
          storyArcs: common.storyArcs,
          genres: common.genres,
          country: common.country,
          language: common.language,
          ageRating: common.ageRating,
          audienceRating: common.audienceRating,
          editions: common.editions,
          updatedAt: common.updatedAt,
          rawPlatforms: common.rawPlatforms,
          trailerUrls: common.trailerUrls,
        );

  final CatalogSeriesDetails? seriesDetails;
  final CatalogPublishingDetails? publishingDetails;
  final VideoCatalogDetails? videoDetails;
  final MusicCatalogDetails? musicDetails;
  final GameCatalogDetails? gameDetails;

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
  ComicWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class MangaWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MangaWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class BookWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  BookWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
        );
}

final class MovieWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MovieWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class TvWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  TvWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class AnimeWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  AnimeWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
        );
}

final class MusicWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MusicWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    MusicCatalogDetails? music,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          musicDetails: music,
        );
}

final class GameWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  GameWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          gameDetails: game,
        );
}

final class BoardGameWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  BoardGameWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          gameDetails: game,
        );
}

final class GenericWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  GenericWorkspaceEntry._({
    required _LibraryWorkspaceCommon common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
    MusicCatalogDetails? music,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          seriesDetails: series,
          publishingDetails: publishing,
          videoDetails: video,
          musicDetails: music,
          gameDetails: game,
        );
}

class _LibraryWorkspaceCommon {
  const _LibraryWorkspaceCommon({
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
    required this.rawOrSlabbed,
    required this.gradingCompany,
    required this.labelType,
    required this.certificationNumber,
    required this.primaryReferenceLabel,
    required this.referenceScopeLabel,
    required this.referenceFormatLabel,
    required this.referenceEditionId,
    required this.referenceVariantId,
    required this.referenceBundleReleaseId,
    required this.keyComic,
    required this.keyReason,
    required this.notes,
    required this.tags,
    required this.collectionStatus,
    required this.lastBagBoardDate,
    required this.pricePaidCents,
    required this.currency,
    required this.locationPath,
    required this.addedAt,
    required this.creators,
    required this.characters,
    required this.storyArcs,
    required this.genres,
    required this.country,
    required this.language,
    required this.ageRating,
    required this.audienceRating,
    required this.editions,
    required this.updatedAt,
    required this.rawPlatforms,
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
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? labelType;
  final String? certificationNumber;
  final String? primaryReferenceLabel;
  final String? referenceScopeLabel;
  final String? referenceFormatLabel;
  final String? referenceEditionId;
  final String? referenceVariantId;
  final String? referenceBundleReleaseId;
  final bool keyComic;
  final String? keyReason;
  final String? notes;
  final String? tags;
  final String? collectionStatus;
  final DateTime? lastBagBoardDate;
  final int? pricePaidCents;
  final String? currency;
  final String? locationPath;
  final DateTime? addedAt;
  final List<Map<String, dynamic>>? creators;
  final List<String>? characters;
  final List<String>? storyArcs;
  final List<String>? genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final List<CatalogEdition> editions;
  final DateTime updatedAt;
  final List<String>? rawPlatforms;
  final List<TrailerLink> trailerUrls;
}

CatalogSeriesDetails? _seriesOrNull(CatalogSeriesDetails details) {
  return details.hasData ? details : null;
}

CatalogPublishingDetails? _publishingOrNull(CatalogPublishingDetails details) {
  return details.hasData ? details : null;
}

VideoCatalogDetails? _videoOrNull(VideoCatalogDetails details) {
  return details.hasData ? details : null;
}

MusicCatalogDetails? _musicOrNull(MusicCatalogDetails details) {
  return details.hasData ? details : null;
}

GameCatalogDetails? _gameOrNull(GameCatalogDetails details) {
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

