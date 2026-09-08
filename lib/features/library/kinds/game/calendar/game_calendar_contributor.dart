import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';

/// Game owns the mapping from game releases to calendar dates.
final class GameCalendarContributor implements LibraryCalendarContributor {
  const GameCalendarContributor({this.loadMedia});

  final Future<GameMedia?> Function(String id)? loadMedia;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final id in context.catalogItemIds) {
      final game = loadMedia != null
          ? await loadMedia!(id)
          : await _loadMedia(context, id);
      if (game == null) continue;
      final date = game.releaseDate;
      if (date == null) continue;
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: game.title,
        eventId: 'game-release:${game.releases.firstOrNull?.id ?? id}',
        itemId: id,
      ));
    }
    return events;
  }

  Future<GameMedia?> _loadMedia(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('Game calendar contribution requires a database');
    }
    return GameRepository(database).getMedia(GameMediaId(id));
  }
}
