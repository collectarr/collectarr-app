import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';

final class AnimeCatalogLookup implements CatalogKindLookup {
  AnimeCatalogLookup(this._db);

  final LocalDatabase _db;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  Future<CatalogSearchHit?> findByBarcode(String barcode) async {
    final normalized = normalizeCatalogLookupValue(barcode);
    if (normalized.isEmpty) return null;
    for (final media in await AnimeRepository(_db).search()) {
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
    for (final media in await AnimeRepository(_db).search()) {
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

  CatalogSearchHit _hit(AnimeMedia media) {
    return catalogLookupHit(
      kind: kind,
      id: media.id.value,
      title: media.title,
      subtitle: _itemNumber(media),
    );
  }

  bool _matchesBarcode(AnimeMedia media, String normalized) {
    if (_same(media.barcode, normalized)) return true;
    for (final identifier in media.identifiers) {
      if (_same(identifier.value, normalized)) return true;
    }
    for (final release in media.releases) {
      if (_same(release.barcode, normalized)) return true;
    }
    return false;
  }

  String? _itemNumber(AnimeMedia media) {
    return _text(media.rawPayload['item_number']);
  }

  String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  bool _same(String? value, String normalized) {
    return value != null && normalizeCatalogLookupValue(value) == normalized;
  }
}
