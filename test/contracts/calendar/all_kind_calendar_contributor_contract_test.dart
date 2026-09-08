import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'calendar_contract.dart';

void main() {
  for (final contributor in libraryCalendarContributors) {
    defineCalendarContributorContract<LibraryCalendarContributor,
        LibraryCalendarContext, CalendarEvent>(
      name: contributor.kind.apiValue,
      create: () => contributor,
      project: (subject, context) => subject.contribute(context),
      id: (event) => event.eventId ?? '',
      title: (event) => event.title,
      kindReference: (event) => event.itemId ?? event.ownedItemId ?? '',
      startsAt: (event) => event.date,
      endsAt: (event) => event.date,
      createContext: () => _contextFor(contributor.kind),
    );
  }
}

const _calendarWatchKinds = {
  CatalogMediaKind.tv,
  CatalogMediaKind.anime,
};

LibraryCalendarContext _contextFor(CatalogMediaKind kind) {
  return LibraryCalendarContext(
    catalogItemIds: const <String>{},
    watchSessions: _calendarWatchKinds.contains(kind)
        ? [
            WatchSession(
              id: '${kind.apiValue}-calendar-session',
              targetRef: CatalogEntityRef(
                kind: kind.apiValue,
                entityType: CatalogEntityType.episode,
                id: '${kind.apiValue}-calendar-contract-item',
              ),
              watchedAt: DateTime.utc(2026, 9, 2),
              updatedAt: DateTime.utc(2026, 9, 2),
            ),
          ]
        : const [],
    titleForItem: (itemId) => itemId,
  );
}
