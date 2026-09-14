import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tv_tracking_lifecycle.dart';
import 'tv_tracking_lifecycle_codec.dart';

/// Loads the complete TV tracking aggregate for a series at the TV boundary.
///
/// Generic Collection exposes only [TrackingSummary]. Episode ratings are TV
/// semantics, so the TV inspector resolves its concrete lifecycle locally.
final tvTrackingLifecycleBySeriesIdProvider =
    FutureProvider.autoDispose.family<TvTrackingLifecycle?, String>(
  (ref, seriesId) async {
    final catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.tv,
      entityType: const CatalogEntityTypeId('work'),
      id: seriesId,
    );
    final entries = await TvTrackingLifecycleCodec().listFromStorage(
      ref.watch(localDatabaseProvider),
    );
    for (final entry in entries) {
      if (entry.catalogRef.rootScope != catalogRef) continue;
      if (entry case final TvTrackingLifecycle typedEntry) {
        return typedEntry;
      }
      throw StateError(
        'TV tracking codec returned a non-TV tracking record: ${entry.runtimeType}',
      );
    }
    return null;
  },
);
