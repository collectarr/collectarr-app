import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

/// TV owns the meaning of episode coordinates in watch-session calendar text.
final class TvCalendarContributor implements LibraryCalendarContributor {
  const TvCalendarContributor({this.loadSeries});

  final Future<TvSeries?> Function(String id)? loadSeries;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final ref in context.catalogRefs) {
      final id = ref.id;
      final series = loadSeries != null
          ? await loadSeries!(id)
          : await _loadSeries(context, id);
      if (series == null) continue;
      for (final release in series.releases) {
        final date = release.releaseDate;
        if (date == null) continue;
        events.add(CalendarEvent(
          kind: CalendarEventKind.releaseDate,
          date: date,
          title: '${series.title} — ${release.title}',
          eventId: 'tv-release:${release.id}',
          catalogRef: ref,
        ));
      }
    }

    for (final session in context.watchSessions) {
      if (session.isDeleted || session.targetRef.mediaKind != kind) continue;

      final episodeLabel =
          session.seasonNumber != null && session.episodeNumber != null
              ? ' S${session.seasonNumber}E${session.episodeNumber}'
              : '';
      events.add(CalendarEvent(
        kind: CalendarEventKind.watched,
        date: session.watchedAt,
        title: '${context.titleForRef(session.targetRef)}$episodeLabel',
        eventId: 'watch:${session.id}',
        catalogRef: session.targetRef,
      ));
    }
    return events;
  }

  Future<TvSeries?> _loadSeries(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('TV calendar contribution requires a database');
    }
    return TvRepository(database).getSeries(TvSeriesId(id));
  }
}
