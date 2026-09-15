import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final musicListeningRepositoryProvider = Provider<MusicListeningRepository>(
  (ref) => MusicListeningRepository(ref.watch(localDatabaseProvider)),
);

final musicListeningEventsProvider =
    FutureProvider.family<List<MusicListenEvent>, CatalogEntityRef>(
  (ref, target) =>
      ref.watch(musicListeningRepositoryProvider).listForTarget(target),
);

final musicReleaseGroupTrackingSummaryProvider = FutureProvider.family<
    MusicReleaseGroupTrackingSummary, MusicReleaseGroupId>(
  (ref, groupId) =>
      ref.watch(musicListeningRepositoryProvider).getTrackingSummary(groupId),
);
