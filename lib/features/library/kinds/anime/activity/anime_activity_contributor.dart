import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_activity_contributor.dart';

/// Anime independently owns the meaning of episode coordinates in activity
/// details; it does not reuse TV domain code.
final class AnimeActivityContributor implements LibraryActivityContributor {
  const AnimeActivityContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  Iterable<ActivityEvent> contribute(LibraryActivityContext context) sync* {
    for (final session in context.watchSessions) {
      if (session.isDeleted || session.targetRef.mediaKind != kind) continue;

      final episodeLabel =
          session.seasonNumber != null && session.episodeNumber != null
              ? 'S${session.seasonNumber}E${session.episodeNumber}'
              : null;
      yield ActivityEvent(
        kind: ActivityEventKind.watched,
        timestamp: session.watchedAt,
        detail: episodeLabel,
        sourceId: session.id,
        rating: session.rating,
      );
    }
  }
}
