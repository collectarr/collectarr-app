import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final List<void Function(Ref)> kindSyncProjectionInvalidators = [
  (ref) => ref.invalidate(musicListeningRepositoryProvider),
];

final List<void Function(WidgetRef)>
    kindDatabaseMaintenanceProjectionInvalidators = [
  (ref) => ref.invalidate(animeTrackingStateBySeriesIdProvider),
  (ref) => ref.invalidate(boardGamePlaySessionsProvider),
  (ref) => ref.invalidate(boardGameAllPlaySessionsProvider),
  (ref) => ref.invalidate(boardGamePlayStatsProvider),
  (ref) => ref.invalidate(musicListeningEventsProvider),
  (ref) => ref.invalidate(musicAlbumImagesProvider),
  (ref) => ref.invalidate(tvTrackingStateByCatalogItemIdProvider),
  (ref) => ref.invalidate(tvCustomEpisodesByLibraryEntryRefProvider),
];
