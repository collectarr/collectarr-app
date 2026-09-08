import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';

/// Movie owns the mapping from movie media release dates to calendar events.
final class MovieCalendarContributor implements LibraryCalendarContributor {
  const MovieCalendarContributor({this.loadMedia});

  final Future<MovieMedia?> Function(String id)? loadMedia;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final id in context.catalogItemIds) {
      final movie = loadMedia != null
          ? await loadMedia!(id)
          : await _loadMedia(context, id);
      if (movie == null) continue;
      final date = movie.releaseDate;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: movie.title,
        eventId: 'movie-release:${movie.releases.firstOrNull?.id.value ?? id}',
        itemId: id,
      ));
    }
    return events;
  }

  Future<MovieMedia?> _loadMedia(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('Movie calendar contribution requires a database');
    }
    return MovieRepository(database).getMedia(MovieMediaId(id));
  }
}
