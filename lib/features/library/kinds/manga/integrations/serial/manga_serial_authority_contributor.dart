import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
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
      final title = (value.seriesTitle ?? '').trim();
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
      );
    }
  }

  @override
  Future<List<SerialAuthorityCatalogRecord>> catalogRecords(
    LocalDatabase db,
  ) async {
    final items = await CatalogItemCacheRepository(db).findAll(kind: kind);
    return [
      for (final item in items) _recordFromItem(item),
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

    final cache = CatalogItemCacheRepository(db);
    final items = await cache.findAll(kind: kind);
    final catalog = CatalogTransportRepository(db);
    for (final item in items) {
      if (!wanted.contains(item.id)) continue;

      final kindData = MangaMetadata.fromJson(item.kindData)
          .copyWith(seriesTitle: seriesTitle)
          .toJson();
      await catalog.upsertTransportItems([
        CatalogItemDto.raw(
          id: item.id,
          mediaKind: kind,
          kindData: kindData,
        ),
      ]);
    }
  }

  static SerialAuthorityCatalogRecord _recordFromItem(CatalogItemDto item) {
    final metadata = MangaMetadata.fromJson(item.kindData);
    final seriesTitle = metadata.seriesTitle?.trim();
    return SerialAuthorityCatalogRecord(
      itemId: item.id,
      title: metadata.title,
      seriesTitle:
          seriesTitle == null || seriesTitle.isEmpty ? null : seriesTitle,
    );
  }
}
