import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

final class TvCatalogLookup implements CatalogKindLookup {
  TvCatalogLookup(this._db);

  final LocalDatabase _db;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  Future<CatalogSearchHit?> resolve(CatalogLookupQuery query) {
    if (query.title?.trim().isNotEmpty == true) {
      return _findByTitleAndItemNumber(
        title: query.title!,
        itemNumber: query.value,
      );
    }
    return _findByBarcode(query.value ?? '');
  }

  Future<CatalogSearchHit?> _findByBarcode(String barcode) async {
    final normalized = normalizeCatalogLookupValue(barcode);
    if (normalized.isEmpty) return null;
    for (final item in await _items()) {
      final metadata = _metadata(item);
      if (_same(metadata.barcode, normalized) ||
          metadata.identifiers.any(
            (identifier) => _same(identifier.value, normalized),
          )) {
        return _hit(item);
      }
    }
    return null;
  }

  Future<CatalogSearchHit?> _findByTitleAndItemNumber({
    required String title,
    String? itemNumber,
  }) async {
    final normalizedTitle = normalizeCatalogLookupTitle(title);
    if (normalizedTitle.isEmpty) return null;
    final normalizedItemNumber = itemNumber?.trim();
    for (final item in await _items()) {
      final metadata = _metadata(item);
      if (normalizeCatalogLookupTitle(metadata.title) != normalizedTitle) {
        continue;
      }
      if (normalizedItemNumber != null &&
          normalizedItemNumber.isNotEmpty &&
          metadata.itemNumber?.trim() != normalizedItemNumber) {
        continue;
      }
      return _hit(item);
    }
    return null;
  }

  CatalogSearchHit _hit(CatalogItemDto item) {
    final metadata = _metadata(item);
    return catalogLookupHit(
      kind: kind,
      id: item.id,
      title: metadata.displayTitle ??
          metadata.localizedTitle ??
          metadata.originalTitle ??
          metadata.title,
      subtitle: metadata.itemNumber,
    );
  }

  Future<List<CatalogItemDto>> _items() =>
      CatalogItemCacheRepository(_db).findAll(kind: kind);

  TvSeriesMetadata _metadata(CatalogItemDto item) =>
      TvSeriesMetadata.fromJson(item.kindData);

  bool _same(String? value, String normalized) =>
      value != null && normalizeCatalogLookupValue(value) == normalized;
}
