import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_mapper.dart';

/// Movie owns the mapping from movie media release dates to calendar events.
final class MovieCalendarContributor implements LibraryCalendarContributor {
  const MovieCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  Iterable<CalendarEvent> contribute(LibraryCalendarContext context) sync* {
    for (final item in context.catalogItems) {
      if (item.mediaKind != kind) continue;

      final movie = MovieWorkspaceMapper.fromCatalogItem(item);
      final date = movie.releaseDate;
      if (date == null) continue;
      yield CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: movie.title,
        eventId: 'movie-release:${movie.primaryRelease?.id.value ?? item.id}',
        itemId: item.id,
      );
    }
  }
}
