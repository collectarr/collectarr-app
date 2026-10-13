import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';

/// Game owns the mapping from game releases to calendar dates.
final class GameCalendarContributor implements LibraryCalendarContributor {
  const GameCalendarContributor({this.loadItem});

  final Future<CatalogItemDto?> Function(String id)? loadItem;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final ref in context.libraryEntryRefs) {
      if (ref.kind != kind) continue;
      final id = ref.id.value;
      final Map<String, dynamic>? catalogData;
      if (loadItem case final loader?) {
        final item = await loader(id);
        if (item == null) continue;
        catalogData = item.kindData;
      } else {
        catalogData = await _loadCatalogData(context, id);
      }
      if (catalogData == null) continue;
      final metadata = GameCatalogMetadata.fromJson(catalogData);
      final date = metadata.releaseDate;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: DateTime.utc(date.year, date.month, date.day),
        title: metadata.title,
        eventId: 'game-item:$id',
        libraryEntryRef: ref,
      ));
    }
    return events;
  }

  Future<Map<String, dynamic>?> _loadCatalogData(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('Game calendar contribution requires a database');
    }
    return LibraryEntryStore(database)
        .find(kind, id)
        .then((entry) => entry?.catalogData);
  }
}
