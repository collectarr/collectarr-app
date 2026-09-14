import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'anime_tracking_lifecycle.dart';
import 'anime_tracking_lifecycle_codec.dart';

/// Loads the complete Anime tracking aggregate inside the Anime boundary.
///
/// The mixed Library host receives only [TrackingSummary]. Anime-specific
/// episode coordinates are resolved here for the Anime tracking editor.
final animeTrackingLifecycleBySeriesIdProvider =
    FutureProvider.autoDispose.family<AnimeTrackingLifecycle?, String>(
  (ref, seriesId) async {
    final catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.anime,
      entityType: const CatalogEntityTypeId('work'),
      id: seriesId,
    );
    final entries = await AnimeTrackingLifecycleCodec().listFromStorage(
      ref.watch(localDatabaseProvider),
    );
    for (final entry in entries) {
      if (entry.catalogRef.rootScope != catalogRef) continue;
      if (entry case final AnimeTrackingLifecycle typedEntry) {
        return typedEntry;
      }
      throw StateError(
        'Anime tracking codec returned a non-Anime tracking record: '
        '${entry.runtimeType}',
      );
    }
    return null;
  },
);
