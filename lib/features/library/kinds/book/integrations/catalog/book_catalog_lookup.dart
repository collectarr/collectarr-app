import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';

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
      if (normalizeCatalogLookupTitle(item.title) != normalizedTitle) {
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
    return catalogLookupHit(
      kind: kind,
      id: item.id,
      title: item.resolvedDisplayTitle,
      subtitle: item.itemNumber ?? _firstIdentifier(item),
    );
  }

  Future<List<CatalogItemDto>> _items() =>
      CatalogItemCacheRepository(_db).findAll(kind: kind);

  Iterable<String> _identifierValues(CatalogItemDto item) sync* {
    final payload = item.payload;
    for (final key in const [
      'barcode',
      'isbn',
      'isbn10',
      'isbn13',
      'item_number',
      'catalog_number',
    ]) {
      final value = payload[key];
      if (value is String && value.trim().isNotEmpty) yield value;
    }
    final identifiers = payload['identifiers'];
    if (identifiers is Iterable) {
      for (final identifier in identifiers) {
        if (identifier is String) {
          yield identifier;
        } else if (identifier is Map) {
          final value = identifier['normalized_value'] ?? identifier['value'];
          if (value is String && value.trim().isNotEmpty) yield value;
        }
      }
    }
    final printings = payload['printings'];
    if (printings is Iterable) {
      for (final printing in printings) {
        if (printing is Map && printing['isbn'] is String) {
          yield printing['isbn'] as String;
        }
      }
    }
  }

  String? _firstIdentifier(CatalogItemDto item) =>
      item.itemNumber ?? _identifierValues(item).firstOrNull;

  bool _same(String value, String normalized) =>
      normalizeCatalogLookupValue(value) == normalized;
}
