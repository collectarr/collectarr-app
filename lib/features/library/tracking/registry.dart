import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';
import 'package:collectarr_app/features/library/tracking/storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/unit_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
import 'package:collectarr_app/features/sync/kind_sync_entity_codec.dart';

const List<TrackingStorageCodec> libraryTrackingStorageCodecs = [
  MusicTrackingStateCodec(),
  BookTrackingStateCodec(),
  ComicTrackingStateCodec(),
  GameTrackingStateCodec(),
];

const List<TrackingUnitStorageCodec> libraryTrackingUnitCodecs = [
  BookTrackingUnitCodec(),
  ComicTrackingUnitCodec(),
];

const List<WatchSessionCodec> libraryWatchSessionCodecs = [];

const List<CustomEpisodeSyncCodec> libraryCustomEpisodeCodecs = [];

const List<KindSyncEntityCodec> libraryKindSyncEntityCodecs = [
  MusicListeningSyncCodec(),
];
