import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';

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
    for (final ref in context.libraryEntryRefs) {
      if (ref.kind != kind) continue;
      final item = await _loadItem(context, ref.id.value);
      if (item == null) continue;
      final metadata = MovieCatalogMetadata.fromJson(item.kindData);
      final date =
          metadata.releaseDate ?? metadata.releaseDateParts?.asDateTime;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: DateTime.utc(date.year, date.month, date.day),
        title: metadata.displayTitle ??
            metadata.localizedTitle ??
            metadata.originalTitle ??
            metadata.title,
        eventId: 'movie-catalog-item:${item.id}',
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
      throw StateError('Movie calendar contribution requires a database');
    }
    return CatalogItemCacheRepository(database).find(
      CatalogItemRef(kind: CatalogMediaKind.movie, id: id),
    );
  }
}
