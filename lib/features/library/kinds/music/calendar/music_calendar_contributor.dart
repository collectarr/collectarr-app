import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_mapper.dart';

/// Music owns the mapping from a selected release's date to calendar time.
final class MusicCalendarContributor implements LibraryCalendarContributor {
  const MusicCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  Iterable<CalendarEvent> contribute(LibraryCalendarContext context) sync* {
    for (final item in context.catalogItems) {
      if (item.mediaKind != kind) continue;

      final release = MusicWorkspaceMapper.fromCatalogItem(item);
      final date = release.releaseDate;
      if (date == null) continue;
      yield CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: release.title,
        itemId: item.id,
      );
    }
  }
}
