import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
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

  @override
  Future<List<SerialAuthorityCatalogRecord>> catalogRecords(
    LocalDatabase db,
  ) async {
    final media = await MangaRepository(db).search();
    return [
      for (final item in media) _recordFromMedia(item),
    ];
  }

  @override
  Future<void> assignSeries(
    LocalDatabase db, {
    required Iterable<String> itemIds,
    required String? coreSeriesId,
    required String seriesTitle,
  }) async {
    final wanted = itemIds.toSet();
    if (wanted.isEmpty) return;

    final repository = MangaRepository(db);
    for (final item in await repository.search()) {
      if (!wanted.contains(item.id)) continue;

      final payload = Map<String, dynamic>.from(item.rawPayload)
        ..['series_title'] = seriesTitle;
      final series = <String, dynamic>{'series_title': seriesTitle};
      if (coreSeriesId != null && coreSeriesId.trim().isNotEmpty) {
        series['series_id'] = coreSeriesId;
      }
      payload['series'] = series;
      await repository.updateMedia(item.copyWith(rawPayload: payload));
    }
  }

  static SerialAuthorityCatalogRecord _recordFromMedia(MangaMedia item) {
    final metadata = MangaMetadata.fromJson({
      ...item.rawPayload,
      'id': item.id,
      'title': item.title,
    });
    final seriesTitle =
        (metadata.seriesTitle ?? metadata.series?.seriesTitle)?.trim();
    return SerialAuthorityCatalogRecord(
      itemId: item.id,
      title: item.title,
      seriesTitle:
          seriesTitle == null || seriesTitle.isEmpty ? null : seriesTitle,
      coreSeriesId: metadata.series?.seriesId,
    );
  }
}
