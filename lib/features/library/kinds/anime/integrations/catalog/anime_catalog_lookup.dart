import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';

final class AnimeCatalogLookup implements CatalogKindLookup {
  AnimeCatalogLookup(this._db);

  final LocalDatabase _db;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

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
    final items = await CatalogItemCacheRepository(_db).findAll(kind: kind);
    for (final item in items) {
      final metadata = AnimeMetadata.fromJson(item.kindData);
      if (_matchesBarcode(metadata, normalized)) {
        return _hit(item.id, metadata);
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
    final items = await CatalogItemCacheRepository(_db).findAll(kind: kind);
    for (final item in items) {
      final metadata = AnimeMetadata.fromJson(item.kindData);
      if (normalizeCatalogLookupTitle(metadata.title) != normalizedTitle) {
        continue;
      }
      if (normalizedItemNumber != null &&
          normalizedItemNumber.isNotEmpty &&
          metadata.itemNumber?.trim() != normalizedItemNumber) {
        continue;
      }
      return _hit(item.id, metadata);
    }
    return null;
  }

  CatalogSearchHit _hit(String id, AnimeMetadata metadata) {
    return catalogLookupHit(
      kind: kind,
      id: id,
      title: metadata.title,
      subtitle: metadata.itemNumber,
    );
  }

  bool _matchesBarcode(AnimeMetadata metadata, String normalized) {
    if (_same(metadata.barcode, normalized)) return true;
    for (final identifier in metadata.identifiers) {
      if (_same(identifier.value, normalized)) return true;
    }
    return false;
  }

  bool _same(String? value, String normalized) {
    return value != null && normalizeCatalogLookupValue(value) == normalized;
  }
}
