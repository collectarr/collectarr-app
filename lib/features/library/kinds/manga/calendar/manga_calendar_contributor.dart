import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';

/// Manga owns the mapping from catalog publication metadata to calendar time.
final class MangaCalendarContributor implements LibraryCalendarContributor {
  const MangaCalendarContributor({this.loadMedia});

  final Future<MangaMedia?> Function(String id)? loadMedia;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final id in context.catalogItemIds) {
      final manga = loadMedia != null
          ? await loadMedia!(id)
          : await _loadMedia(context, id);
      if (manga == null) continue;
      final date = manga.firstPublicationDate;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: manga.title,
        eventId: 'manga-release:${manga.id}',
        itemId: id,
      ));
    }
    return events;
  }

  Future<MangaMedia?> _loadMedia(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('Manga calendar contribution requires a database');
    }
    return MangaRepository(database).getMedia(id);
  }
}
