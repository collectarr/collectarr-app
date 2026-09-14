import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';

/// Book owns the mapping from catalog snapshots to edition release dates.
final class BookCalendarContributor implements LibraryCalendarContributor {
  const BookCalendarContributor({this.loadMedia});

  final Future<BookMedia?> Function(String id)? loadMedia;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final ref in context.catalogRefs) {
      final id = ref.id;
      final book = loadMedia != null
          ? await loadMedia!(id)
          : await _loadMedia(context, id);
      if (book == null) continue;
      final date =
          book.editions.firstOrNull?.releaseDate ?? book.firstPublicationDate;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: book.title,
        eventId: 'book-release:${book.editions.firstOrNull?.id ?? id}',
        catalogRef: ref,
      ));
    }
    return events;
  }

  Future<BookMedia?> _loadMedia(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('Book calendar contribution requires a database');
    }
    return BookRepository(database).getMedia(BookMediaId(id));
  }
}
