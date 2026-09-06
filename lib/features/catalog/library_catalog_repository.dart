import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_serial_authority_contributors.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_catalog_repository_codecs.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';

/// Reads and writes the kind-owned catalog graphs.
///
/// Generic catalog orchestration over the typed kind repositories. No catalog
/// payload is stored by this class; typed kind repositories own the durable
/// representation.
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
    Iterable<CatalogItem> items, {
    bool captureDerivedData = true,
  }) async {
    final catalogItems = items.toList(growable: false);
    if (catalogItems.isEmpty) return;

    for (final item in catalogItems) {
      await _upsertItem(item);
    }
    if (captureDerivedData) {
      await _captureDerivedData([
        for (final item in catalogItems) typedCatalogItemFromCatalogItem(item),
      ]);
    }
  }

  /// Captures only derived infrastructure values from already typed catalog
  /// projections. The owning kind contributors interpret metadata; this
  /// repository only coordinates the persistence transaction.
  Future<void> _captureDerivedData(Iterable<CatalogItem> items) async {
    final list = items.toList(growable: false);
    if (list.isEmpty) return;

    final byKind = <CatalogMediaKind, List<Object?>>{};
    for (final item in list) {
      byKind.putIfAbsent(item.mediaKind, () => <Object?>[]).add(
            item.kindMetadata,
          );
    }

    final pickLists = PickListRepository(_db);
    final serialAuthority = SerialAuthorityRepository(_db);
    final serialCandidates = <SerialAuthorityCandidate>[];
    await _db.transaction(() async {
      for (final entry in byKind.entries) {
        for (final contributor in defaultPickListDefinitionContributors) {
          if (contributor.kind != entry.key) continue;
          for (final projected in contributor.catalogValues(entry.value)) {
            await pickLists.captureValuesWithoutTransaction(
              projected.listName,
              projected.values,
              mediaKind: entry.key.apiValue,
            );
          }
        }
        for (final contributor in collectarrSerialAuthorityContributors) {
          if (contributor.kind != entry.key) continue;
          serialCandidates.addAll(contributor.candidates(entry.value));
        }
      }
      await serialAuthority
          .captureCandidatesWithoutTransaction(serialCandidates);
    });
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
}
