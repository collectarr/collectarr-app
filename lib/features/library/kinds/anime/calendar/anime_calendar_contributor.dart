import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_mapper.dart';

/// Anime owns the meaning of episode coordinates in watch-session calendar
/// text independently from TV.
final class AnimeCalendarContributor implements LibraryCalendarContributor {
  const AnimeCalendarContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  Iterable<CalendarEvent> contribute(LibraryCalendarContext context) sync* {
    for (final item in context.catalogItems) {
      if (item.mediaKind != kind) continue;

      final anime = AnimeWorkspaceMapper.fromCatalogItem(item);
      for (final release in anime.releases) {
        final date = release.releaseDate;
        if (date == null) continue;
        yield CalendarEvent(
          kind: CalendarEventKind.releaseDate,
          date: date,
          title: '${anime.title} — ${release.title}',
          itemId: item.id,
        );
      }
    }

    for (final session in context.watchSessions) {
      if (session.isDeleted || session.targetRef.mediaKind != kind) continue;

      final episodeLabel =
          session.seasonNumber != null && session.episodeNumber != null
              ? ' S${session.seasonNumber}E${session.episodeNumber}'
              : '';
      yield CalendarEvent(
        kind: CalendarEventKind.watched,
        date: session.watchedAt,
        title: '${context.titleForItem(session.itemId)}$episodeLabel',
        itemId: session.itemId,
      );
    }
  }
}
