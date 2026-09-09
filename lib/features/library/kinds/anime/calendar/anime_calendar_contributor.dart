import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';

/// Anime owns the meaning of episode coordinates in watch-session calendar
/// text independently from TV.
final class AnimeCalendarContributor implements LibraryCalendarContributor {
  const AnimeCalendarContributor({this.loadMedia});

  final Future<AnimeMedia?> Function(String id)? loadMedia;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  Future<Iterable<CalendarEvent>> contribute(
    LibraryCalendarContext context,
  ) async {
    final events = <CalendarEvent>[];
    for (final ref in context.catalogRefs) {
      final id = ref.id;
      final anime = loadMedia != null
          ? await loadMedia!(id)
          : await _loadMedia(context, id);
      if (anime == null) continue;
      for (final release in anime.releases) {
        final date = release.releaseDate;
        if (date == null) continue;
        events.add(CalendarEvent(
          kind: CalendarEventKind.releaseDate,
          date: date,
          title: '${anime.title} — ${release.title}',
          eventId: 'anime-release:${release.id.value}',
          itemId: id,
        ));
      }
    }

    for (final session in context.watchSessions) {
      if (session.isDeleted || session.targetRef.mediaKind != kind) continue;

      final episodeLabel =
          session.seasonNumber != null && session.episodeNumber != null
              ? ' S${session.seasonNumber}E${session.episodeNumber}'
              : '';
      events.add(CalendarEvent(
        kind: CalendarEventKind.watched,
        date: session.watchedAt,
        title: '${context.titleForRef(session.targetRef)}$episodeLabel',
        eventId: 'watch:${session.id}',
        itemId: session.itemId,
      ));
    }
    return events;
  }

  Future<AnimeMedia?> _loadMedia(
    LibraryCalendarContext context,
    String id,
  ) {
    final database = context.database;
    if (database == null) {
      throw StateError('Anime calendar contribution requires a database');
    }
    return AnimeRepository(database).getMedia(AnimeMediaId(id));
  }
}
