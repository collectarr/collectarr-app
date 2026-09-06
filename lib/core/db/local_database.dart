import 'package:drift/drift.dart';
import 'package:collectarr_app/core/db/open_connection.dart';
import 'package:collectarr_app/features/library/kinds/book/data/local/book_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/local/boardgame_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/local/comic_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/game/data/local/game_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/local/manga_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/local/movie_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/local/anime_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_tables.dart';
import 'universal_local_tables.dart';

part 'local_database.g.dart';

@DriftDatabase(tables: [
  OwnedItemsCache,
  WishlistItemsCache,
  TrackingEntriesCache,
  TrackingUnitsCache,
  SyncQueue,
  UserMetadataOverridesCache,
  UserExternalLinksCache,
  CustomFieldDefinitionsCache,
  CustomFieldValuesCache,
  ItemImagesCache,
  LoansCache,
  LocationsCache,
  SmartListsCache,
  UserFoldersCache,
  UserFolderItemsCache,
  ReadingQueueCache,
  PickListValuesCache,
  SerialAuthorityCache,
  ProviderAccountsCache,
  ProviderItemLinksCache,
  ComicMediaRows,
  ComicReleaseRows,
  ComicOwnedItemsRows,
  ComicReadingRows,
  ComicOwnedDetailsRows,
  MangaMediaRows,
  MangaOwnedDetailsRows,
  MangaOwnedItemsRows,
  BookMediaRows,
  BookReleaseRows,
  BookOwnedDetailsRows,
  BookOwnedItemsRows,
  GameMediaRows,
  GameReleaseRows,
  GameOwnedDetailsRows,
  GameOwnedItemsRows,
  BoardGameMediaRows,
  BoardGameEditionRows,
  BoardGameOwnedDetailsRows,
  BoardGameOwnedItemsRows,
  BoardGamePlaySessionsRows,
  MovieMediaRows,
  MovieReleaseRows,
  MovieOwnedDetailsRows,
  MovieOwnedItemsRows,
  TvSeriesRows,
  TvSeasonRows,
  TvEpisodeRows,
  TvReleaseRows,
  TvReleaseMediaRows,
  TvReleaseEpisodeMapRows,
  TvOwnedDetailsRows,
  TvOwnedItemsRows,
  TvWatchSessionRows,
  TvEpisodeProgressRows,
  TvCustomEpisodeRows,
  TvTrackingUnitRows,
  AnimeMediaRows,
  AnimeEpisodeRows,
  AnimeReleaseRows,
  AnimeOwnedDetailsRows,
  AnimeOwnedItemsRows,
  AnimeTrackingRows,
  AnimeTrackingUnitRows,
  AnimeWatchSessionRows,
  AnimeCustomEpisodeRows,
  ComicTrackingUnitRows,
  MangaTrackingUnitRows,
  BookTrackingUnitRows,
  MusicReleaseRows,
  MusicMediaRows,
  MusicTrackRows,
  MusicOwnedDetailsRows,
  MusicOwnedItemsRows,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor])
      : super(executor ?? openConnection());

  /// Version 1 is the complete pre-release schema. New installations create
  /// the full table set directly.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}
