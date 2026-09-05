import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_activity_contributor.dart';

/// TV owns the meaning of episode coordinates in activity details.
final class TvActivityContributor implements LibraryActivityContributor {
  const TvActivityContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

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
