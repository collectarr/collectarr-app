import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'catalog_workspace_data_dispatch.dart';

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
    final transportItems =
        await CatalogSnapshotRepository(_db).findTransportsByRefs(refs);
    return transportItems.map(
      (ref, item) => MapEntry(ref, workspaceCatalogDataFromTransport(item)),
    );
  }
}
