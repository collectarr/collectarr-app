import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
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
      if (value is! ComicMedia) continue;
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
    final media = await ComicRepository(db).search();
    return [
      for (final item in media)
        if (item.id case final id?)
          SerialAuthorityCatalogRecord(
            itemId: id.value,
            title: item.title,
            seriesTitle: _seriesTitle(item),
            coreSeriesId: item.series?.seriesId,
          ),
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

    final repository = ComicRepository(db);
    for (final item in await repository.search()) {
      final id = item.id?.value;
      if (id == null || !wanted.contains(id)) continue;

      final payload = Map<String, dynamic>.from(item.toJson())
        ..['series_title'] = seriesTitle;
      final series = payload['series'] is Map
          ? Map<String, dynamic>.from(payload['series'] as Map)
          : <String, dynamic>{};
      if (coreSeriesId == null || coreSeriesId.trim().isEmpty) {
        series.remove('series_id');
        series.remove('seriesId');
      } else {
        series['series_id'] = coreSeriesId;
      }
      series['series_title'] = seriesTitle;
      payload['series'] = series;
      await repository.updateMedia(ComicMedia.fromJson(payload));
    }
  }

  static String? _seriesTitle(ComicMedia item) {
    final value = (item.seriesTitle ?? item.series?.seriesTitle)?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}
