import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

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
    for (final ref in context.libraryEntryRefs) {
      if (ref.kind != kind) continue;
      final id = ref.id.value;
      final item =
          loadItem != null ? await loadItem!(id) : await _loadItem(context, id);
      if (item == null) continue;
      final metadata = MangaMetadata.fromJson(item.kindData);
      final date = metadata.releaseDate?.asDateTime ??
          metadata.originalPublicationDate ??
          metadata.localizedReleaseDate;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: DateTime.utc(date.year, date.month, date.day),
        title: metadata.title,
        eventId: 'manga-item:${item.id}',
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
      throw StateError('Manga calendar contribution requires a database');
    }
    return CatalogItemCacheRepository(database).find(
      CatalogItemRef(kind: kind, id: id),
    );
  }

}
