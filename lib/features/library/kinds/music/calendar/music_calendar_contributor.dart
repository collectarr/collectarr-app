import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';

/// Music owns the mapping from a selected release's date to calendar time.
final class MusicCalendarContributor implements LibraryCalendarContributor {
  const MusicCalendarContributor({this.loadAlbum});

  final Future<MusicAlbum?> Function(String id)? loadAlbum;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final ref in context.catalogRefs) {
      final id = ref.id;
      final album = loadAlbum != null
          ? await loadAlbum!(id)
          : await _loadAlbum(context, id);
      if (album == null) continue;
      final date = album.releaseDate;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: DateTime.utc(date.year, date.month, date.day),
        title: album.title,
        eventId: 'music-album:${album.id.value}',
        catalogRef: ref,
      ));
    }
    return events;
  }

  Future<MusicAlbum?> _loadAlbum(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('Music calendar contribution requires a database');
    }
    return CatalogItemCacheRepository(database)
        .find(CatalogItemRef(kind: kind, id: id))
        .then((item) => item == null
            ? null
            : MusicCatalogMapper.mapMetadataItemToMusic(item));
  }
}
