import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';

final class BookCatalogLookup implements CatalogKindLookup {
  BookCatalogLookup(this._db);

  final LocalDatabase _db;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  Future<CatalogSearchHit?> findByBarcode(String barcode) async {
    final normalized = normalizeCatalogLookupValue(barcode);
    if (normalized.isEmpty) return null;
    for (final media in await BookRepository(_db).search()) {
      if (_matchesBarcode(media, normalized)) return _hit(media);
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
    for (final media in await BookRepository(_db).search()) {
      if (normalizeCatalogLookupTitle(media.title) != normalizedTitle) {
        continue;
      }
      if (normalizedItemNumber != null &&
          normalizedItemNumber.isNotEmpty &&
          _itemNumber(media)?.trim() != normalizedItemNumber) {
        continue;
      }
      return _hit(media);
    }
    return null;
  }

  CatalogSearchHit _hit(BookMedia media) {
    return catalogLookupHit(
      kind: kind,
      id: media.id.value,
      title: media.title,
      subtitle: _itemNumber(media),
    );
  }

  bool _matchesBarcode(BookMedia media, String normalized) {
    if (_same(media.barcode, normalized)) return true;
    for (final edition in media.editions) {
      if (_same(edition.isbn, normalized) || _same(edition.upc, normalized)) {
        return true;
      }
      for (final variant in edition.variants) {
        if (_same(variant.barcode, normalized) ||
            _same(variant.isbn, normalized)) {
          return true;
        }
      }
    }
    return false;
  }

  String? _itemNumber(BookMedia media) {
    final value = media.rawPayload['item_number'];
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  bool _same(String? value, String normalized) {
    return value != null && normalizeCatalogLookupValue(value) == normalized;
  }
}
