import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/config/library_activity_contributor.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

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
  return LibraryActivityContext(
    watchSessions: [
      WatchSession(
        id: '${kind.apiValue}-activity-contract-session',
        targetRef: CatalogEntityRef(
          kind: kind.apiValue,
          entityType: CatalogEntityType.episode,
          id: itemId,
        ),
        watchedAt: DateTime.utc(2026, 9, 6),
        updatedAt: DateTime.utc(2026, 9, 6),
      ),
    ],
  );
}
