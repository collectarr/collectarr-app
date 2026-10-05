import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

/// Book maps each concrete Catalog Item's release date to a calendar event.
final class BookCalendarContributor implements LibraryCalendarContributor {
  const BookCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final ref in context.libraryEntryRefs) {
      if (ref.kind != kind) continue;
      final catalogData = await _loadCatalogData(context, ref.id.value);
      if (catalogData == null) continue;
      final metadata = BookCatalogMetadata.fromJson(catalogData);
      final date =
          metadata.releaseDate ?? metadata.releaseDateParts?.asDateTime;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: DateTime.utc(date.year, date.month, date.day),
        title:
            metadata.localizedTitle ?? metadata.originalTitle ?? metadata.title,
        eventId: 'book-entry:${ref.id.value}',
        libraryEntryRef: ref,
      ));
    }
    return events;
  }

  Future<Map<String, dynamic>?> _loadCatalogData(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('Book calendar contribution requires a database');
    }
    return LibraryEntryStore(database)
        .find(CatalogMediaKind.book, id)
        .then((entry) => entry?.catalogData);
  }
}
