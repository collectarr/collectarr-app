import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';

final class ComicRepository
    implements ReadRepository<ComicCatalogItemId, ComicCatalogItem> {
  ComicRepository(this._db);

  final LocalDatabase _db;

  CatalogItemCacheRepository get _catalog => CatalogItemCacheRepository(_db);

  @override
  Future<ComicCatalogItem?> findById(ComicCatalogItemId id) =>
      getCatalogItem(id);

  Future<ComicCatalogItem?> getCatalogItem(ComicCatalogItemId id) async {
    final item = await _catalog.find(
      CatalogItemRef(kind: CatalogMediaKind.comic, id: id.value),
    );
    return item == null
        ? null
        : ComicCatalogItem.fromJson(catalogTransportPayloadFor(item));
  }

  Future<List<ComicCatalogItem>> search([String query = '']) async {
    final normalizedQuery = query.trim().toLowerCase();
    final media = [
      for (final item in await _catalog.findAll(kind: CatalogMediaKind.comic))
        ComicCatalogItem.fromJson(catalogTransportPayloadFor(item)),
    ];
    final results = normalizedQuery.isEmpty
        ? media
        : media.where((item) {
            return item.title.toLowerCase().contains(normalizedQuery) ||
                (item.sortTitle?.toLowerCase().contains(normalizedQuery) ??
                    false) ||
                (item.seriesTitle?.toLowerCase().contains(normalizedQuery) ??
                    false) ||
                (item.issueNumber?.toLowerCase().contains(normalizedQuery) ??
                    false);
          }).toList(growable: false);
    results.sort((left, right) {
      final sortTitle = (left.sortTitle ?? '').compareTo(right.sortTitle ?? '');
      if (sortTitle != 0) return sortTitle;
      final title = left.title.compareTo(right.title);
      if (title != 0) return title;
      return (left.id?.value ?? '').compareTo(right.id?.value ?? '');
    });
    return results;
  }

  Future<void> updateCatalogItem(ComicCatalogItem media) async {
    final id = media.id?.value.trim();
    if (id == null || id.isEmpty) {
      throw StateError('Cannot update Comic Catalog Item without an id');
    }
    final item = CatalogItemDto.fromJson({
      ...media.toJson(),
      'id': id,
      'kind': CatalogMediaKind.comic.apiValue,
    }).withKindData(media);
    await _catalog.upsert(item);
  }
}
