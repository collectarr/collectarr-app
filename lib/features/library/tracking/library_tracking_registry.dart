import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';

const List<TrackingStorageCodec> libraryTrackingStorageCodecs = [
  AnimeTrackingStateCodec(),
  BoardGameTrackingStateCodec(),
  BookTrackingStateCodec(),
  ComicTrackingStateCodec(),
  GameTrackingStateCodec(),
  MangaTrackingStateCodec(),
  MovieTrackingStateCodec(),
  MusicTrackingStateCodec(),
  TvTrackingStateCodec(),
];

const List<TrackingUnitStorageCodec> libraryTrackingUnitCodecs = [
  AnimeTrackingUnitCodec(),
  BookTrackingUnitCodec(),
  ComicTrackingUnitCodec(),
  MangaTrackingUnitCodec(),
  TvTrackingUnitCodec(),
];

const List<WatchSessionCodec> libraryWatchSessionCodecs = [
  AnimeWatchSessionCodec(),
  TvWatchSessionCodec(),
];

const List<CustomEpisodeSyncCodec> libraryCustomEpisodeCodecs = [
  AnimeCustomEpisodeCodec(),
  TvCustomEpisodeCodec(),
];
