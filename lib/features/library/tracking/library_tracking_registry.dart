import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_custom_episode_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_watch_session_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_custom_episode_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_watch_session_codec.dart';
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
