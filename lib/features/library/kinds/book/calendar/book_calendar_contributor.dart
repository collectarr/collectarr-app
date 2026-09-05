import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';

/// Book owns the mapping from catalog snapshots to edition release dates.
final class BookCalendarContributor implements LibraryCalendarContributor {
  const BookCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  Iterable<CalendarEvent> contribute(LibraryCalendarContext context) sync* {
    for (final item in context.catalogItems) {
      if (item.mediaKind != kind) continue;

      final book = BookCatalogMapper.mapDtoToBook(item);
      final date = book.releaseDate;
      if (date == null) continue;
      yield CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: book.title,
        itemId: item.id,
      );
    }
  }
}
