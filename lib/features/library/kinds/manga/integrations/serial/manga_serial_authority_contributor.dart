import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

/// Projects Manga's typed series identity into serial authority storage.
final class MangaSerialAuthorityContributor
    implements SerialAuthorityContributor {
  const MangaSerialAuthorityContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  Iterable<SerialAuthorityCandidate> candidates(
    Iterable<Object?> metadata,
  ) sync* {
    for (final value in metadata) {
      if (value is! MangaMetadata) continue;
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
