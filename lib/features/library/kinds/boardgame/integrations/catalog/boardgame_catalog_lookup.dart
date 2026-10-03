import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';

final class BoardGameCatalogLookup implements CatalogKindLookup {
  BoardGameCatalogLookup(this._db);

  final LocalDatabase _db;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

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
      if (_matchesBarcode(item, normalized)) return _hit(item);
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
      if (normalizeCatalogLookupTitle(item.title) != normalizedTitle) {
        continue;
      }
      if (normalizedItemNumber != null &&
          normalizedItemNumber.isNotEmpty &&
          _itemNumber(item)?.trim() != normalizedItemNumber) {
        continue;
      }
      return _hit(item);
    }
    return null;
  }

  Future<List<CatalogItemDto>> _items() async {
    final items = await CatalogItemCacheRepository(_db).findAll(kind: kind);
    return items..sort((left, right) => left.title.compareTo(right.title));
  }

  CatalogSearchHit _hit(CatalogItemDto item) {
    return catalogLookupHit(
      kind: kind,
      id: item.id,
      title: item.title,
      subtitle: _itemNumber(item),
    );
  }

  bool _matchesBarcode(CatalogItemDto item, String normalized) {
    if (_same(_text(item.barcode), normalized)) return true;
    if (_same(_text(item.payload['barcode']), normalized)) return true;
    final editions = item.payload['editions'];
    if (editions is! Iterable) return false;
    for (final edition in editions) {
      if (edition is! Map) continue;
      if (_same(_text(edition['barcode']), normalized)) return true;
    }
    return false;
  }

  String? _itemNumber(CatalogItemDto item) {
    final value = BoardGameMetadata.fromJson(item.kindData).itemNumber;
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  bool _same(String? value, String normalized) {
    return value != null && normalizeCatalogLookupValue(value) == normalized;
  }
}
