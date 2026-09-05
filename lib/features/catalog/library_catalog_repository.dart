import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/catalog/library_catalog_derived_data_service.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_catalog_repository_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';

/// Reads and writes the kind-owned catalog graphs.
///
/// This is the migration boundary for callers that still need a common
/// [CatalogItem] projection. No catalog payload is stored by this class; the
/// typed kind repositories own the durable representation.
final class LibraryCatalogRepository {
  LibraryCatalogRepository(
    this._db, {
    Iterable<CatalogKindRepositoryCodec> codecs =
        collectarrCatalogRepositoryCodecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<String, CatalogKindRepositoryCodec> _codecs;

  Future<void> upsertMetadataItems(List<CatalogItem> items) => upsertAll(items);

  Future<void> upsertAll(
    Iterable<dynamic> items, {
    bool captureDerivedData = true,
  }) async {
    final catalogItems = [
      for (final item in items)
        if (item is CatalogItem) typedCatalogItemFromCatalogItem(item),
    ];
    if (catalogItems.isEmpty) return;

    for (final item in catalogItems) {
      await _upsertItem(item);
    }
    if (captureDerivedData) {
      await LibraryCatalogDerivedDataService(
        _db,
        contributors: defaultPickListDefinitionContributors,
      ).capture(catalogItems);
    }
  }

  Future<Map<String, CatalogItem>> findByIds(Iterable<String> ids) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return const {};
    final result = <String, CatalogItem>{};
    for (final item in await _allItems()) {
      if (wanted.contains(item.id)) result[item.id] = item;
    }
    return result;
  }

  Future<List<CatalogItem>> findAll({String? kind}) async {
    final normalizedKind = kind?.trim().toLowerCase();
    return [
      for (final item in await _allItems())
        if (normalizedKind == null ||
            normalizedKind.isEmpty ||
            item.kind == normalizedKind)
          item,
    ];
  }

  Future<CatalogItem?> findById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;
    return (await findByIds([normalized]))[normalized];
  }

  Future<CatalogItem?> findByBarcode(String barcode, {String? kind}) async {
    final compact = _compactBarcode(barcode);
    if (compact.isEmpty) return null;
    final normalizedKind = kind?.trim().toLowerCase();
    for (final item in await _allItems()) {
      if (normalizedKind != null &&
          normalizedKind.isNotEmpty &&
          item.kind != normalizedKind) {
        continue;
      }
      if (_compactBarcode(item.barcode ?? '') == compact) return item;
    }
    return null;
  }

  Future<CatalogItem?> findByTitleAndIssue({
    required String title,
    required String? itemNumber,
    String? kind,
  }) async {
    final normalizedTitle = title.trim().toLowerCase();
    if (normalizedTitle.isEmpty) return null;
    final normalizedKind = kind?.trim().toLowerCase();
    final normalizedItemNumber = itemNumber?.trim();
    for (final item in await _allItems()) {
      if (normalizedKind != null &&
          normalizedKind.isNotEmpty &&
          item.kind != normalizedKind) {
        continue;
      }
      if (item.title.trim().toLowerCase() != normalizedTitle) continue;
      if (normalizedItemNumber != null &&
          normalizedItemNumber.isNotEmpty &&
          item.itemNumber?.trim() != normalizedItemNumber) {
        continue;
      }
      return item;
    }
    return null;
  }

  Future<void> _upsertItem(CatalogItem item) async {
    await _codecs[item.kind.trim().toLowerCase()]?.upsert(_db, item);
  }

  Future<List<CatalogItem>> _allItems() async {
    final result = <CatalogItem>[];
    for (final codec in _codecs.values) {
      result.addAll(await codec.list(_db));
    }
    return result;
  }

  static String _compactBarcode(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
