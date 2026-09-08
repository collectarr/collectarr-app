import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

/// Music owns the mapping from a selected release's date to calendar time.
final class MusicCalendarContributor implements LibraryCalendarContributor {
  const MusicCalendarContributor({this.loadRelease});

  final Future<MusicRelease?> Function(String id)? loadRelease;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final id in context.catalogItemIds) {
      final release = loadRelease != null
          ? await loadRelease!(id)
          : await _loadRelease(context, id);
      if (release == null) continue;
      final date = release.releaseDate;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: release.title,
        eventId: 'music-release:${release.id.value}',
        itemId: id,
      ));
    }
    return events;
  }

  Future<MusicRelease?> _loadRelease(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('Music calendar contribution requires a database');
    }
    return MusicRepository(database).getRelease(MusicReleaseId(id));
  }
}
