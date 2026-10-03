import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'anime_tracking_state.dart';
import 'anime_tracking_state_codec.dart';

/// Loads the complete Anime tracking aggregate inside the Anime boundary.
///
/// The mixed Library host receives only [TrackingSummary]. Anime-specific
/// episode coordinates are resolved here for the Anime tracking editor.
final animeTrackingStateBySeriesIdProvider =
    FutureProvider.autoDispose.family<AnimeTrackingState?, String>(
  (ref, seriesId) async {
    final libraryEntryRef = LibraryEntryRef(
      kind: CatalogMediaKind.anime,
      id: LibraryEntryId(seriesId),
    );
    final entries = await AnimeTrackingStateCodec().listFromStorage(
      ref.watch(localDatabaseProvider),
    );
    for (final entry in entries) {
      if (entry.libraryEntryRef != libraryEntryRef) continue;
      if (entry case final AnimeTrackingState typedEntry) {
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
