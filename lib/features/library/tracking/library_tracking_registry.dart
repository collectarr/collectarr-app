import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
import 'package:collectarr_app/features/sync/kind_sync_entity_codec.dart';

const List<TrackingStorageCodec> libraryTrackingStorageCodecs = [
  MusicTrackingStateCodec(),
];

const List<TrackingUnitStorageCodec> libraryTrackingUnitCodecs = [];

const List<WatchSessionCodec> libraryWatchSessionCodecs = [];

const List<CustomEpisodeSyncCodec> libraryCustomEpisodeCodecs = [];

const List<KindSyncEntityCodec> libraryKindSyncEntityCodecs = [
  MusicListeningSyncCodec(),
];
