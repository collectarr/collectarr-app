import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_tracking_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit_mutations.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_custom_episode_mutations.dart';
import 'package:collectarr_app/state/local_database_provider.dart';

final tvTrackingRepositoryProvider = Provider<TvTrackingRepository>((ref) {
  return TvTrackingRepository(ref.watch(localDatabaseProvider));
});

/// TV-owned provider for episode progress mutations.
///
/// The shared collection provider owns only the repositories and mutation
/// runner. The semantic TV mutation is composed at the TV boundary.
final tvTrackingUnitMutationsProvider =
    Provider<TvTrackingUnitMutations>((ref) {
  return TvTrackingUnitMutations(
    trackingUnits: ref.watch(trackingUnitStorageRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});

final tvCustomEpisodesByCatalogRefProvider =
    FutureProvider.family<Map<int, List<TvCustomEpisode>>, CatalogEntityRef>(
        (ref, catalogRef) async {
  if (catalogRef.mediaKind != CatalogMediaKind.tv) {
    return const <int, List<TvCustomEpisode>>{};
  }
  final episodes = await ref
      .watch(tvTrackingRepositoryProvider)
      .listCustomEpisodes(TvSeriesId(catalogRef.id));
  final grouped = <int, List<TvCustomEpisode>>{};
  for (final episode in episodes) {
    grouped.putIfAbsent(episode.seasonNumber, () => <TvCustomEpisode>[]).add(
          episode,
        );
  }
  return grouped;
});

final tvCustomEpisodeMutationsProvider =
    Provider<TvCustomEpisodeMutations>((ref) {
  return TvCustomEpisodeMutations(
    tracking: ref.watch(tvTrackingRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});
