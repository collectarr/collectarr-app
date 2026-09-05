import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';

/// Manga owns the mapping from catalog publication metadata to calendar time.
final class MangaCalendarContributor implements LibraryCalendarContributor {
  const MangaCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  Iterable<CalendarEvent> contribute(LibraryCalendarContext context) sync* {
    for (final item in context.catalogItems) {
      if (item.mediaKind != kind) continue;

      final payload = Map<String, dynamic>.from(item.toSyncPayload());
      if (item.releaseDate != null) {
        payload['first_publication_date'] = item.releaseDate!.toIso8601String();
      }
      final manga = MangaMedia.fromJson({
        ...payload,
        'id': item.id,
        'title': item.title,
      });
      final date = manga.firstPublicationDate;
      if (date == null) continue;
      yield CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: manga.title,
        eventId: 'manga-release:${manga.id}',
        itemId: item.id,
      );
    }
  }
}
