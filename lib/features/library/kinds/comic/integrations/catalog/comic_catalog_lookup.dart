import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

final class ComicCatalogLookup implements CatalogKindLookup {
  ComicCatalogLookup(this._db);

  final LocalDatabase _db;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  Future<CatalogSearchHit?> findByBarcode(String barcode) async {
    final normalized = normalizeCatalogLookupValue(barcode);
    if (normalized.isEmpty) return null;
    for (final media in await ComicRepository(_db).search()) {
      if (_matchesBarcode(media, normalized)) {
        return catalogLookupHit(
          kind: kind,
          id: media.id?.value ?? '',
          title: media.title,
          subtitle: media.issueNumber,
        );
      }
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
    for (final media in await ComicRepository(_db).search()) {
      if (normalizeCatalogLookupTitle(media.title) != normalizedTitle) {
        continue;
      }
      if (normalizedItemNumber != null &&
          normalizedItemNumber.isNotEmpty &&
          media.issueNumber?.trim() != normalizedItemNumber) {
        continue;
      }
      return catalogLookupHit(
        kind: kind,
        id: media.id?.value ?? '',
        title: media.title,
        subtitle: media.issueNumber,
      );
    }
    return null;
  }

  bool _matchesBarcode(ComicMedia media, String normalized) {
    if (_same(media.barcode, normalized)) return true;
    for (final release in media.releases) {
      if (_same(release.upc, normalized) || _same(release.isbn, normalized)) {
        return true;
      }
      for (final variant in release.variants) {
        if (_same(variant.barcode, normalized) ||
            _same(variant.isbn, normalized)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _same(String? value, String normalized) {
    return value != null && normalizeCatalogLookupValue(value) == normalized;
  }
}
