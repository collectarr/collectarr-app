import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';

/// Manga owns the mapping from catalog publication metadata to calendar time.
final class MangaCalendarContributor implements LibraryCalendarContributor {
  const MangaCalendarContributor({this.loadItem});

  final Future<CatalogItemDto?> Function(String id)? loadItem;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final ref in context.catalogRefs) {
      final id = ref.id;
      final item =
          loadItem != null ? await loadItem!(id) : await _loadItem(context, id);
      if (item == null) continue;
      final date = item.releaseDate ?? _firstPublicationDate(item);
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: DateTime.utc(date.year, date.month, date.day),
        title: item.title,
        eventId: 'manga-item:${item.id}',
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
      throw StateError('Manga calendar contribution requires a database');
    }
    return CatalogItemCacheRepository(database).find(
      CatalogItemRef(kind: kind, id: id),
    );
  }

  DateTime? _firstPublicationDate(CatalogItemDto item) {
    final value = item.payload['first_publication_date']?.toString();
    return value == null ? null : DateTime.tryParse(value);
  }
}
