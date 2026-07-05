// ignore_for_file: use_super_parameters

part of 'library_workspace_entry.dart';

LibraryWorkspaceEntry _buildTypedWorkspaceEntry({
  required String mediaType,
  required LibraryWorkspaceEntryData common,
  ComicWorkspaceDetails? comic,
  CatalogSeriesDetails? series,
  CatalogPublishingDetails? publishing,
  VideoCatalogDetails? video,
  MusicCatalogDetails? music,
  GameCatalogDetails? game,
  List<GameRelease> gameReleases = const <GameRelease>[],
  BoardGameWork? boardGameWork,
}) {
  switch (mediaType.trim().toLowerCase()) {
    case 'comic':
      return ComicWorkspaceEntry(
        common: common,
        comic: comic,
        series: series,
        publishing: publishing,
      );
    case 'manga':
      return MangaWorkspaceEntry(
        common: common,
        series: series,
        publishing: publishing,
      );
    case 'book':
      return BookWorkspaceEntry(
        common: common,
        series: series,
        publishing: publishing,
      );
    case 'movie':
      return MovieWorkspaceEntry(
        common: common,
        series: series,
        publishing: publishing,
        video: video,
      );
    case 'tv':
      return TvWorkspaceEntry(
        common: common,
        series: series,
        publishing: publishing,
        video: video,
      );
    case 'anime':
      return AnimeWorkspaceEntry(
        common: common,
        series: series,
        publishing: publishing,
        video: video,
      );
    case 'music':
      return MusicWorkspaceEntry(
        common: common,
        series: series,
        publishing: publishing,
        music: music,
      );
    case 'game':
      return GameWorkspaceEntry(
        common: common,
        series: series,
        publishing: publishing,
        game: game,
        gameReleases: gameReleases,
      );
    case 'boardgame':
      return BoardGameWorkspaceEntry(
        common: common,
        series: series,
        publishing: publishing,
        game: game,
        boardGameWork: boardGameWork,
      );
    default:
      return GenericWorkspaceEntry(
        common: common,
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
    this.comicDetails,
    this.seriesDetails,
    this.publishingDetails,
    this.videoDetails,
    this.musicDetails,
    this.gameDetails,
    List<GameRelease> gameReleases = const <GameRelease>[],
    this.boardGameWork,
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
          frontCoverUrl: common.frontCoverUrl,
          backCoverUrl: common.backCoverUrl,
          itemImages: common.itemImages,
          publisher: common.publisher,
          coverDate: common.coverDate,
          releaseDate: common.releaseDate,
          releaseYear: common.releaseYear,
          barcode: common.barcode,
          variant: common.variant,
          crossover: common.crossover,
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
          plotSummary: common.plotSummary,
          plotDescription: common.plotDescription,
          creators: common.creators,
          characters: common.characters,
          storyArcs: common.storyArcs,
          genres: common.genres,
          country: common.country,
          language: common.language,
          ageRating: common.ageRating,
          audienceRating: common.audienceRating,
          rawPlatforms: common.rawPlatforms,
          gameReleases: gameReleases,
        );

  final ComicWorkspaceDetails? comicDetails;
  final CatalogSeriesDetails? seriesDetails;
  final CatalogPublishingDetails? publishingDetails;
  final VideoCatalogDetails? videoDetails;
  final MusicCatalogDetails? musicDetails;
  final GameCatalogDetails? gameDetails;
  final BoardGameWork? boardGameWork;

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
    ComicWorkspaceDetails? comic,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          comicDetails: comic,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
        );
}

final class MangaWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MangaWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
  }) : super._(
          common: common,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
        );
}

final class BookWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  BookWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    this.bookEditions = const <BookEdition>[],
  }) : super._(
          common: common,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
        );

  final List<BookEdition> bookEditions;
}

final class MovieWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MovieWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          videoDetails: _videoOrNull(video),
        );
}

final class TvWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  TvWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          videoDetails: _videoOrNull(video),
        );
}

final class AnimeWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  AnimeWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
  }) : super._(
          common: common,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          videoDetails: _videoOrNull(video),
        );
}

final class MusicWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  MusicWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    MusicCatalogDetails? music,
  }) : super._(
          common: common,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          musicDetails: _musicOrNull(music),
        );
}

final class GameWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  GameWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    GameCatalogDetails? game,
    List<GameRelease> gameReleases = const <GameRelease>[],
  }) : super._(
          common: common,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          gameDetails: _gameOrNull(game),
          gameReleases: gameReleases,
        );
}

final class BoardGameWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  BoardGameWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    GameCatalogDetails? game,
    BoardGameWork? boardGameWork,
  }) : super._(
          common: common,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          gameDetails: _gameOrNull(game),
          boardGameWork: boardGameWork,
        );
}

final class GenericWorkspaceEntry extends _TypedLibraryWorkspaceEntry {
  GenericWorkspaceEntry({
    required LibraryWorkspaceEntryData common,
    CatalogSeriesDetails? series,
    CatalogPublishingDetails? publishing,
    VideoCatalogDetails? video,
    MusicCatalogDetails? music,
    GameCatalogDetails? game,
  }) : super._(
          common: common,
          seriesDetails: _seriesOrNull(series),
          publishingDetails: _publishingOrNull(publishing),
          videoDetails: _videoOrNull(video),
          musicDetails: _musicOrNull(music),
          gameDetails: _gameOrNull(game),
        );
}
