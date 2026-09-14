import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

/// Comic owns the meaning of a catalog release date for calendar projection.
final class ComicCalendarContributor implements LibraryCalendarContributor {
  const ComicCalendarContributor({this.loadMedia});

  final Future<ComicMedia?> Function(String id)? loadMedia;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final ref in context.catalogRefs) {
      final id = ref.id;
      final comic = loadMedia != null
          ? await loadMedia!(id)
          : await _loadMedia(context, id);
      if (comic == null) continue;
      final date = comic.releaseDate ?? comic.coverDate;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: comic.title,
        eventId: 'comic-release:$id',
        catalogRef: ref,
      ));
    }
    return events;
  }

  Future<ComicMedia?> _loadMedia(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('Comic calendar contribution requires a database');
    }
    return ComicRepository(database).getMedia(ComicMediaId(id));
  }
}
