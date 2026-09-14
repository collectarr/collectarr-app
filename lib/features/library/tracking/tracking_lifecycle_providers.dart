import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_lifecycle_codecs.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Complete tracking aggregates used by typed Library edit/detail flows.
///
/// Mixed Collection/Shelf code uses the summary providers from
/// `collection_controller.dart`. Full lifecycle values stay next to the
/// Library tracking integration because only a kind-dispatched Library flow
/// may interpret the concrete tracking subtype.
final trackingPersistenceEntriesProvider =
    FutureProvider<List<TrackingLifecycle>>((ref) async {
  final repository = TrackingLifecycleRepository(
    ref.watch(localDatabaseProvider),
    codecs: collectarrTrackingLifecycleCodecs,
  );
  return repository.listActive();
});

final trackingPersistenceEntriesByCatalogRefProvider =
    Provider<Map<CatalogEntityRef, List<TrackingLifecycle>>>((ref) {
  final tracking = ref.watch(trackingPersistenceEntriesProvider);
  return tracking.maybeWhen(
    data: (items) {
      final grouped = <CatalogEntityRef, List<TrackingLifecycle>>{};
      for (final item in items) {
        if (item.isDeleted) continue;
        grouped
            .putIfAbsent(item.catalogRef, () => <TrackingLifecycle>[])
            .add(item);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
      return grouped;
    },
    orElse: () => const <CatalogEntityRef, List<TrackingLifecycle>>{},
  );
});
