import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit_mutations.dart';

/// TV-owned provider for episode progress mutations.
///
/// The shared collection provider owns only the repositories and mutation
/// runner. The semantic TV mutation is composed at the TV boundary.
final tvTrackingUnitMutationsProvider =
    Provider<TvTrackingUnitMutations>((ref) {
  return TvTrackingUnitMutations(
    trackingUnits: ref.watch(trackingUnitsCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});
