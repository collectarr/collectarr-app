import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

final class TvCatalogLookup implements CatalogKindLookup {
  TvCatalogLookup(this._db);

  final LocalDatabase _db;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  Future<CatalogSearchHit?> findByBarcode(String barcode) async {
    final normalized = normalizeCatalogLookupValue(barcode);
    if (normalized.isEmpty) return null;
    for (final series in await TvRepository(_db).search()) {
      if (_matchesBarcode(series, normalized)) return _hit(series);
    }
    return null;
  }

  @override
  Future<CatalogSearchHit?> findByTitleAndItemNumber({
    required String title,
    String? itemNumber,
  }) async {
    final normalizedTitle = normalizeCatalogLookupTitle(title);
    if (normalizedTitle.isEmpty) return null;
    final normalizedItemNumber = itemNumber?.trim();
    for (final series in await TvRepository(_db).search()) {
      if (normalizeCatalogLookupTitle(series.title) != normalizedTitle) {
        continue;
      }
      if (normalizedItemNumber != null &&
          normalizedItemNumber.isNotEmpty &&
          _itemNumber(series)?.trim() != normalizedItemNumber) {
        continue;
      }
      return _hit(series);
    }
    return null;
  }

  CatalogSearchHit _hit(TvSeries series) {
    return catalogLookupHit(
      kind: kind,
      id: series.id,
      title: series.title,
      subtitle: _itemNumber(series),
    );
  }

  bool _matchesBarcode(TvSeries series, String normalized) {
    if (_same(_text(series.rawPayload['barcode']), normalized)) return true;
    for (final release in series.releases) {
      if (_same(release.sku, normalized)) return true;
      if (_same(_text(release.rawPayload['barcode']), normalized)) return true;
    }
    return false;
  }

  String? _itemNumber(TvSeries series) {
    return _text(series.rawPayload['item_number']);
  }

  String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  bool _same(String? value, String normalized) {
    return value != null && normalizeCatalogLookupValue(value) == normalized;
  }
}
