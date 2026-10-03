import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tv_tracking_state.dart';
import 'tv_tracking_state_codec.dart';

/// Loads the complete TV tracking aggregate for a series at the TV boundary.
///
/// Generic Collection exposes only [TrackingSummary]. Episode ratings are TV
/// semantics, so the TV inspector resolves its concrete lifecycle locally.
final tvTrackingStateBySeriesIdProvider =
    FutureProvider.autoDispose.family<TvTrackingState?, String>(
  (ref, seriesId) async {
    final libraryEntryRef = LibraryEntryRef(
      kind: CatalogMediaKind.tv,
      id: LibraryEntryId(seriesId),
    );
    final entries = await TvTrackingStateCodec().listFromStorage(
      ref.watch(localDatabaseProvider),
    );
    for (final entry in entries) {
      if (entry.libraryEntryRef != libraryEntryRef) continue;
      if (entry case final TvTrackingState typedEntry) {
        return typedEntry;
      }
      throw StateError(
        'TV tracking codec returned a non-TV tracking record: ${entry.runtimeType}',
      );
    }
    return null;
  },
);
