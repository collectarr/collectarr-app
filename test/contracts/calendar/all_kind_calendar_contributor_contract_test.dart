import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
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

LibraryCalendarContext _contextFor(CatalogMediaKind kind) {
  final item = testCatalogItem(
    id: '${kind.apiValue}-calendar-contract-item',
    kind: kind.apiValue,
    title: '${kind.apiValue} calendar item',
    releaseDate: DateTime.utc(2026, 9, 1),
    payload: kind == CatalogMediaKind.tv
        ? {
            'releases': [
              {
                'id': 'tv-calendar-release',
                'series_id': 'tv-calendar-contract-item',
                'title': 'TV release',
                'release_date': '2026-09-01T00:00:00.000Z',
              },
            ],
          }
        : kind == CatalogMediaKind.anime
            ? {
                'releases': [
                  {
                    'id': 'anime-calendar-release',
                    'series_id': 'anime-calendar-contract-item',
                    'release_title': 'Anime release',
                    'release_date': '2026-09-01T00:00:00.000Z',
                  },
                ],
              }
            : null,
  );

  return LibraryCalendarContext(
    catalogItems: [item],
    watchSessions: kind == CatalogMediaKind.tv || kind == CatalogMediaKind.anime
        ? [
            WatchSession(
              id: '${kind.apiValue}-calendar-session',
              targetRef: CatalogEntityRef(
                kind: kind.apiValue,
                entityType: CatalogEntityType.episode,
                id: item.id,
              ),
              watchedAt: DateTime.utc(2026, 9, 2),
              updatedAt: DateTime.utc(2026, 9, 2),
            ),
          ]
        : const [],
    titleForItem: (itemId) => itemId,
  );
}
