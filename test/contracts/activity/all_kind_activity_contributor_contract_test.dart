import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/config/library_activity_contributor.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_watch_session.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';

import 'activity_contract.dart';

void main() {
  for (final contributor in libraryActivityContributors) {
    defineActivityContributorContract<LibraryActivityContributor,
        LibraryActivityContext, ActivityEvent>(
      name: contributor.kind.apiValue,
      create: () => contributor,
      project: (subject, context) => subject.contribute(context),
      projection: ActivityEventProjection<ActivityEvent>(
        timestamp: (event) => event.timestamp,
        kind: (event) => event.kind,
        sourceId: (event) => event.sourceId,
      ),
      createContext: () => _contextFor(contributor.kind),
    );
  }
}

LibraryActivityContext _contextFor(CatalogMediaKind kind) {
  final itemId = '${kind.apiValue}-activity-contract-item';
  final targetRef = CatalogEntityRef(
    kind: kind,
    entityType: const CatalogEntityTypeId('episode'),
    id: itemId,
  );
  final session = switch (kind) {
    CatalogMediaKind.tv => TvWatchSession(
        id: '${kind.apiValue}-activity-contract-session',
        seriesId: TvSeriesId(itemId),
        targetRef: targetRef,
        seasonNumber: 1,
        episodeNumber: 1,
        watchedAt: DateTime.utc(2026, 9, 6),
        updatedAt: DateTime.utc(2026, 9, 6),
      ),
    CatalogMediaKind.anime => AnimeWatchSession(
        id: '${kind.apiValue}-activity-contract-session',
        targetRef: targetRef,
        seasonNumber: 1,
        episodeNumber: 1,
        watchedAt: DateTime.utc(2026, 9, 6),
        updatedAt: DateTime.utc(2026, 9, 6),
      ),
    _ => WatchSession(
        id: '${kind.apiValue}-activity-contract-session',
        targetRef: targetRef,
        watchedAt: DateTime.utc(2026, 9, 6),
        updatedAt: DateTime.utc(2026, 9, 6),
      ),
  };
  return LibraryActivityContext(
    watchSessions: [session],
  );
}
