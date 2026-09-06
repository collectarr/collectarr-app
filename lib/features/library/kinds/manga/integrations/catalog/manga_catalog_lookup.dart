import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';

final class MangaCatalogLookup implements CatalogKindLookup {
  MangaCatalogLookup(this._db);

  final LocalDatabase _db;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  Future<CatalogSearchHit?> findByBarcode(String barcode) async {
    final normalized = normalizeCatalogLookupValue(barcode);
    if (normalized.isEmpty) return null;
    for (final media in await MangaRepository(_db).search()) {
      if (_matchesBarcode(media, normalized)) {
        return _hit(media);
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
    for (final media in await MangaRepository(_db).search()) {
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

  CatalogSearchHit _hit(MangaMedia media) {
    return catalogLookupHit(
      kind: kind,
      id: media.id,
      title: media.title,
      subtitle: _itemNumber(media),
    );
  }

  bool _matchesBarcode(MangaMedia media, String normalized) {
    if (_same(_text(media.rawPayload['barcode']), normalized)) return true;
    if (_same(_text(media.rawPayload['isbn']), normalized)) return true;
    final identifiers = media.identifiers;
    for (final identifier in identifiers) {
      final value = identifier is Map
          ? identifier['value'] ?? identifier['barcode'] ?? identifier['isbn']
          : null;
      if (_same(_text(value), normalized)) return true;
    }
    return false;
  }

  String? _itemNumber(MangaMedia media) {
    return _text(media.rawPayload['item_number']) ??
        _text(media.rawPayload['volume_number']);
  }

  String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  bool _same(String? value, String normalized) {
    return value != null && normalizeCatalogLookupValue(value) == normalized;
  }
}
