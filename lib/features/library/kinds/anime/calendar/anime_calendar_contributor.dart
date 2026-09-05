import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';

/// Anime owns the meaning of episode coordinates in watch-session calendar
/// text independently from TV.
final class AnimeCalendarContributor implements LibraryCalendarContributor {
  const AnimeCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  Iterable<CalendarEvent> contribute(LibraryCalendarContext context) sync* {
    for (final session in context.watchSessions) {
      if (session.isDeleted || session.targetRef.mediaKind != kind) continue;

      final episodeLabel =
          session.seasonNumber != null && session.episodeNumber != null
              ? ' S${session.seasonNumber}E${session.episodeNumber}'
              : '';
      yield CalendarEvent(
        kind: CalendarEventKind.watched,
        date: session.watchedAt,
        title: '${context.titleForItem(session.itemId)}$episodeLabel',
        itemId: session.itemId,
      );
    }
  }
}
