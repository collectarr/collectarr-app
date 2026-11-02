import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

/// Resolves Book identifiers against concrete Catalog Items cached from Core.
final class BookCatalogLookup implements CatalogKindLookup {
  BookCatalogLookup(this._db);

  final LocalDatabase _db;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  Future<CatalogSearchHit?> resolve(CatalogLookupQuery query) {
    if (query.title?.trim().isNotEmpty == true) {
      return _findByTitleAndIdentifier(
        title: query.title!,
        identifier: query.value,
      );
    }
    return _findByIdentifier(query.value ?? '');
  }

  Future<CatalogSearchHit?> _findByIdentifier(String identifier) async {
    final normalized = normalizeCatalogLookupValue(identifier);
    if (normalized.isEmpty) return null;
    for (final item in await _items()) {
      if (_identifierValues(item).any((value) => _same(value, normalized))) {
        return _hit(item);
      }
    }
    return null;
  }

  Future<CatalogSearchHit?> _findByTitleAndIdentifier({
    required String title,
    String? identifier,
  }) async {
    final normalizedTitle = normalizeCatalogLookupTitle(title);
    if (normalizedTitle.isEmpty) return null;
    final rawIdentifier = identifier?.trim();
    final normalizedIdentifier = rawIdentifier == null || rawIdentifier.isEmpty
        ? null
        : normalizeCatalogLookupValue(rawIdentifier);
    for (final item in await _items()) {
      if (normalizeCatalogLookupTitle(_metadata(item).title) !=
          normalizedTitle) {
        continue;
      }
      if (normalizedIdentifier != null &&
          !_identifierValues(item).any(
            (value) => _same(value, normalizedIdentifier),
          )) {
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
      title:
          metadata.localizedTitle ?? metadata.originalTitle ?? metadata.title,
      subtitle: metadata.itemNumber ?? _firstIdentifier(item),
    );
  }

  Future<List<CatalogItemDto>> _items() =>
      CatalogItemCacheRepository(_db).findAll(kind: kind);

  Iterable<String> _identifierValues(CatalogItemDto item) sync* {
    final metadata = _metadata(item);
    for (final value in [
      metadata.barcode,
      metadata.isbn,
      metadata.isbn10,
      metadata.isbn13,
      metadata.itemNumber,
      metadata.catalogNumber,
      for (final identifier in metadata.identifiers)
        identifier.normalizedValue ?? identifier.value,
      for (final printing in metadata.printings) printing.isbn,
    ]) {
      if (value?.trim().isNotEmpty == true) yield value!;
    }
  }

  String? _firstIdentifier(CatalogItemDto item) =>
      _metadata(item).itemNumber ?? _identifierValues(item).firstOrNull;

  BookCatalogMetadata _metadata(CatalogItemDto item) =>
      BookCatalogMetadata.fromJson(item.kindData);

  bool _same(String value, String normalized) =>
      normalizeCatalogLookupValue(value) == normalized;
}
