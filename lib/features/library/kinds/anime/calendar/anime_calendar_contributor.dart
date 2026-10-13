import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_watch_session.dart';

/// Anime contributes locally owned watch activity with contained episode
/// coordinates rather than a separate episode identity.
final class AnimeCalendarContributor implements LibraryCalendarContributor {
  const AnimeCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    return [
      for (final session
          in context.watchSessions.whereType<AnimeWatchSession>())
        if (!session.isDeleted)
          CalendarEvent(
            kind: CalendarEventKind.watched,
            date: session.watchedAt,
            title: '${context.titleForRef(session.libraryEntryRef)}'
                '${_episodeLabel(session.seasonNumber, session.episodeNumber)}',
            eventId: 'watch:${session.id}',
            libraryEntryRef: session.libraryEntryRef,
          ),
    ];
  }
}

String _episodeLabel(int? seasonNumber, int? episodeNumber) {
  if (seasonNumber == null || episodeNumber == null) return '';
  return ' S${seasonNumber}E$episodeNumber';
}
