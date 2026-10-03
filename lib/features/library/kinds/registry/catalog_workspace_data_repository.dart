import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_workspace_data_dispatch.dart';

/// Reads catalog transport at the storage boundary and immediately dispatches
/// it into the owning kind's structural workspace data.
///
/// Collection/Shelf needs workspace data for rendering, but it must not carry
/// or rehydrate a generic catalog snapshot itself. Keeping this adapter next
/// to the generated kind dispatch makes the boundary explicit and leaves the
/// feature host with only structural workspace data.
final class CatalogWorkspaceDataRepository {
  CatalogWorkspaceDataRepository(this._db);

  final LocalDatabase _db;

  Future<Map<CatalogEntityRef, LibraryWorkspaceCatalogData>> findByRefs(
    Iterable<CatalogEntityRef> refs,
  ) async {
    final result = <CatalogEntityRef, LibraryWorkspaceCatalogData>{};
    final requested = {for (final ref in refs) ref.rootScope};

    // A local Library Entry owns a complete, editable snapshot. Render it
    // directly so the workspace remains available offline and never assumes
    // that the Core Catalog Item ID is the local entry ID.
    final localRecords = await LibraryEntryStore(_db).list();
    for (final record in localRecords) {
      final libraryEntryRef = LibraryEntryRef(
        kind: record.kind,
        id: LibraryEntryId(record.id),
      );
      final localRef = libraryEntryRef.localCatalogItemRef.rootScope;
      if (!requested.contains(localRef)) continue;
      result[localRef] = await enrichedWorkspaceCatalogDataFromItem(
        _db,
        record.catalogItem,
        libraryEntryRef: libraryEntryRef,
      );
    }

    final remaining = requested.difference(result.keys.toSet());
    final transportItems =
        await CatalogSnapshotRepository(_db).findTransportsByRefs(remaining);
    for (final entry in transportItems.entries) {
      result[entry.key] = await enrichedWorkspaceCatalogDataFromTransport(
        _db,
        entry.value,
      );
    }
    return result;
  }
}
