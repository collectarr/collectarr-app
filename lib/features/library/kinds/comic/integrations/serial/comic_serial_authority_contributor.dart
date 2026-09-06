import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

/// Projects Comic's typed series identity into serial authority storage.
final class ComicSerialAuthorityContributor
    implements SerialAuthorityContributor {
  const ComicSerialAuthorityContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  Iterable<SerialAuthorityCandidate> candidates(
    Iterable<Object?> metadata,
  ) sync* {
    for (final value in metadata) {
      if (value is! ComicCatalogMetadata) continue;
      final title =
          (value.seriesTitle ?? value.series?.seriesTitle ?? '').trim();
      if (title.isEmpty) {
        final itemTitle = value.title.trim();
        if (itemTitle.isEmpty) continue;
        yield SerialAuthorityCandidate(
          mediaKind: kind,
          title: itemTitle,
          sortTitle: itemTitle,
        );
        continue;
      }
      yield SerialAuthorityCandidate(
        mediaKind: kind,
        title: title,
        sortTitle: title,
        coreSeriesId: value.series?.seriesId,
      );
    }
  }
}
