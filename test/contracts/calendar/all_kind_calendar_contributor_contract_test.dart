import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_watch_session.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
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
      kindReference: (event) =>
          event.catalogRef?.kind.apiValue ??
          event.ownedRef?.kind.apiValue ??
          '',
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
  final targetRef = CatalogEntityRef(
    kind: kind,
    entityType: const CatalogEntityTypeId('episode'),
    id: '${kind.apiValue}-calendar-contract-item',
  );
  final session = switch (kind) {
    CatalogMediaKind.tv => TvWatchSession(
        id: '${kind.apiValue}-calendar-session',
        seriesId: TvSeriesId('${kind.apiValue}-calendar-contract-item'),
        targetRef: targetRef,
        seasonNumber: 1,
        episodeNumber: 1,
        watchedAt: DateTime.utc(2026, 9, 2),
        updatedAt: DateTime.utc(2026, 9, 2),
      ),
    CatalogMediaKind.anime => AnimeWatchSession(
        id: '${kind.apiValue}-calendar-session',
        targetRef: targetRef,
        seasonNumber: 1,
        episodeNumber: 1,
        watchedAt: DateTime.utc(2026, 9, 2),
        updatedAt: DateTime.utc(2026, 9, 2),
      ),
    _ => WatchSession(
        id: '${kind.apiValue}-calendar-session',
        targetRef: targetRef,
        watchedAt: DateTime.utc(2026, 9, 2),
        updatedAt: DateTime.utc(2026, 9, 2),
      ),
  };
  return LibraryCalendarContext(
    catalogRefs: const <CatalogEntityRef>{},
    watchSessions: _calendarWatchKinds.contains(kind) ? [session] : const [],
    titleForRef: (ref) => ref.id,
  );
}
