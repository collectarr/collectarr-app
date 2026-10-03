import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
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
      final item = await _loadItem(context, ref.id.value);
      if (item == null) continue;
      final metadata = BookCatalogMetadata.fromJson(item.kindData);
      final date = metadata.releaseDate ?? metadata.releaseDateParts?.asDateTime;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: DateTime.utc(date.year, date.month, date.day),
        title:
            metadata.localizedTitle ?? metadata.originalTitle ?? metadata.title,
        eventId: 'book-catalog-item:${item.id}',
        libraryEntryRef: ref,
      ));
    }
    return events;
  }

  Future<CatalogItemDto?> _loadItem(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('Book calendar contribution requires a database');
    }
    return CatalogItemCacheRepository(database).find(
      CatalogItemRef(kind: CatalogMediaKind.book, id: id),
    );
  }
}
