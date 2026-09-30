import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';

/// Movie owns the mapping from Catalog Item release dates to calendar events.
final class MovieCalendarContributor implements LibraryCalendarContributor {
  const MovieCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final ref in context.catalogRefs) {
      final item = await _loadItem(context, ref.id);
      if (item == null) continue;
      final date = item.releaseDate;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: DateTime.utc(date.year, date.month, date.day),
        title: item.resolvedDisplayTitle,
        eventId: 'movie-catalog-item:${item.id}',
        catalogRef: ref,
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
      throw StateError('Movie calendar contribution requires a database');
    }
    return CatalogItemCacheRepository(database).find(
      CatalogItemRef(kind: CatalogMediaKind.movie, id: id),
    );
  }
}
