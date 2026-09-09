import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';

/// BoardGame owns the mapping from publication/edition dates to the calendar.
final class BoardGameCalendarContributor implements LibraryCalendarContributor {
  const BoardGameCalendarContributor({this.loadMedia});

  final Future<BoardGameMedia?> Function(String id)? loadMedia;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final ref in context.catalogRefs) {
      final id = ref.id;
      final boardGame = loadMedia != null
          ? await loadMedia!(id)
          : await _loadMedia(context, id);
      if (boardGame == null) continue;
      final date = boardGame.releaseDate;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: boardGame.title,
        eventId:
            'boardgame-release:${boardGame.editions.firstOrNull?.id ?? id}',
        itemId: id,
      ));
    }
    return events;
  }

  Future<BoardGameMedia?> _loadMedia(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('BoardGame calendar contribution requires a database');
    }
    return BoardGameRepository(database).getMedia(BoardGameMediaId(id));
  }
}
