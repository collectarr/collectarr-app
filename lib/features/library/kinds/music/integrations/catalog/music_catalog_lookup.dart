import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

final class MusicCatalogLookup implements CatalogKindLookup {
  MusicCatalogLookup(this._db);

  final LocalDatabase _db;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  Future<CatalogSearchHit?> findByBarcode(String barcode) async {
    final normalized = normalizeCatalogLookupValue(barcode);
    if (normalized.isEmpty) return null;
    for (final release in await MusicRepository(_db).search()) {
      if (_same(release.barcode, normalized)) return _hit(release);
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
    for (final release in await MusicRepository(_db).search()) {
      if (normalizeCatalogLookupTitle(release.title) != normalizedTitle) {
        continue;
      }
      if (normalizedItemNumber != null &&
          normalizedItemNumber.isNotEmpty &&
          release.catalogNumber?.trim() != normalizedItemNumber) {
        continue;
      }
      return _hit(release);
    }
    return null;
  }

  CatalogSearchHit _hit(MusicRelease release) {
    return catalogLookupHit(
      kind: kind,
      id: release.id.value,
      title: release.title,
      subtitle: release.catalogNumber,
    );
  }

  bool _same(String? value, String normalized) {
    return value != null && normalizeCatalogLookupValue(value) == normalized;
  }
}
