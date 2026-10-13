import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_workspace_data_dispatch.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

/// Loads kind-owned workspace data without converting a local entry identity
/// into a Core Catalog Item reference.
final class CatalogWorkspaceDataRepository {
  CatalogWorkspaceDataRepository(this._db);

  final LocalDatabase _db;

  Future<Map<LibraryEntryRef, LibraryWorkspaceKindData>> findEntries(
    Iterable<LibraryEntryRef> refs,
  ) async {
    final records = await LibraryEntryStore(_db).findByRefs(refs);
    if (records.isEmpty) return const {};
    return enrichedWorkspaceKindDataByEntry(
      _db,
      {
        for (final entry in records.entries) entry.key: entry.value.catalogData,
      },
    );
  }

  Future<Map<CatalogItemRef, LibraryWorkspaceKindData>> findCatalogItems(
    Iterable<CatalogItemRef> refs,
  ) async {
    final requested = refs.toSet();
    if (requested.isEmpty) return const {};
    final result = <CatalogItemRef, LibraryWorkspaceKindData>{};
    final transportItems =
        await CatalogSnapshotRepository(_db).findTransportsByRefs(requested);
    for (final entry in transportItems.entries) {
      result[entry.key] = await enrichedWorkspaceCatalogDataFromTransport(
        _db,
        entry.value,
      );
    }
    return result;
  }
}
