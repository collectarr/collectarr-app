import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';

/// Comic owns the meaning of a catalog release date for calendar projection.
final class ComicCalendarContributor implements LibraryCalendarContributor {
  const ComicCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  Iterable<CalendarEvent> contribute(LibraryCalendarContext context) sync* {
    for (final item in context.catalogItems) {
      if (item.mediaKind != kind) continue;

      final comic = ComicCoreMapper.fromCatalogItem(item);
      final date = comic.releaseDate ?? comic.coverDate;
      if (date == null) continue;
      yield CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: comic.title,
        itemId: item.id,
      );
    }
  }
}
