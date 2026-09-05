import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_mapper.dart';

/// BoardGame owns the mapping from publication/edition dates to the calendar.
final class BoardGameCalendarContributor implements LibraryCalendarContributor {
  const BoardGameCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  Iterable<CalendarEvent> contribute(LibraryCalendarContext context) sync* {
    for (final item in context.catalogItems) {
      if (item.mediaKind != kind) continue;

      final boardGame = BoardGameCatalogMapper.mapDtoToBoardGame(item);
      final date = boardGame.releaseDate;
      if (date == null) continue;
      yield CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: date,
        title: boardGame.title,
        itemId: item.id,
      );
    }
  }
}
