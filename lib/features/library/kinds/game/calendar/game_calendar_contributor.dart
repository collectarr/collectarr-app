import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_mapper.dart';

/// Game owns the mapping from game releases to calendar dates.
final class GameCalendarContributor implements LibraryCalendarContributor {
  const GameCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  Iterable<CalendarEvent> contribute(LibraryCalendarContext context) sync* {
    for (final item in context.catalogItems) {
      if (item.mediaKind != kind) continue;

      final game = GameCatalogMapper.mapMetadataItemToGame(item);
      final date = game.releaseDate;
      if (date == null) continue;
      yield CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: game.title,
        itemId: item.id,
      );
    }
  }
}
