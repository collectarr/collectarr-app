import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class UserFolderRepository {
  UserFolderRepository(this._db);

  final LocalDatabase _db;

  Future<List<UserFolder>> getAll() async {
    final rows = await (_db.select(_db.userFoldersCache)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows
        .map((r) => UserFolder(
              id: r.id,
              name: r.name,
              description: r.description,
              parentId: r.parentId,
              iconName: r.iconName,
              sortOrder: r.sortOrder,
            ))
        .toList();
  }

  Future<UserFolder> create({required String name, String? parentId}) async {
    final id = const Uuid().v4();
    final maxSort = await _db
        .customSelect(
          'SELECT COALESCE(MAX(sort_order), 0) AS m FROM user_folders_cache',
        )
        .getSingle();
    final sortOrder = (maxSort.data['m'] as int) + 1;

    await _db.into(_db.userFoldersCache).insert(
          UserFoldersCacheCompanion.insert(
            id: id,
            name: name,
            parentId: Value(parentId),
            sortOrder: Value(sortOrder),
          ),
        );
    final folder = UserFolder(
        id: id, name: name, parentId: parentId, sortOrder: sortOrder);
    await _enqueue(folder, 'upsert');
    return folder;
  }

  Future<void> rename(String id, String newName) async {
    await (_db.update(_db.userFoldersCache)..where((t) => t.id.equals(id)))
        .write(UserFoldersCacheCompanion(name: Value(newName)));
    final folder = await _getById(id);
    if (folder != null) await _enqueue(folder, 'upsert');
  }

  Future<void> delete(String id) async {
    final folder = await _getById(id);
    if (folder != null) await _enqueue(folder, 'delete');
    final children = await (_db.select(_db.userFoldersCache)
          ..where((t) => t.parentId.equals(id)))
        .get();
    await deleteLocally(id);
    for (final child in children) {
      await _enqueue(
        UserFolder(
          id: child.id,
          name: child.name,
          description: child.description,
          parentId: null,
          iconName: child.iconName,
          sortOrder: child.sortOrder,
        ),
        'upsert',
      );
    }
  }

  Future<void> deleteLocally(String id) async {
    // Unparent children
    await (_db.update(_db.userFoldersCache)
          ..where((t) => t.parentId.equals(id)))
        .write(const UserFoldersCacheCompanion(parentId: Value(null)));
    // Remove folder items
    await (_db.delete(_db.userFolderItemsCache)
          ..where((t) => t.folderId.equals(id)))
        .go();
    // Delete folder
    await (_db.delete(_db.userFoldersCache)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<LibraryEntryRef>> getLibraryEntryRefsInFolder(
      String folderId) async {
    final rows = await (_db.select(_db.userFolderItemsCache)
          ..where((t) => t.folderId.equals(folderId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows.map((r) {
      final ref = LibraryEntryRef.fromKey(r.libraryEntryRefKey);
      requireKnownLibraryEntryRef(ref);
      return ref;
    }).toList();
  }

  Future<List<({String folderId, int sortOrder})>> getMembershipSnapshotForItem(
      LibraryEntryRef ref) async {
    requireKnownLibraryEntryRef(ref);
    final rows = await (_db.select(_db.userFolderItemsCache)
          ..where((t) => t.libraryEntryRefKey.equals(ref.key))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return [
      for (final row in rows)
        (folderId: row.folderId, sortOrder: row.sortOrder),
    ];
  }

  Future<void> replaceMembershipsForItem(
    LibraryEntryRef ref,
    List<({String folderId, int sortOrder})> memberships,
  ) async {
    requireKnownLibraryEntryRef(ref);
    await (_db.delete(_db.userFolderItemsCache)
          ..where((t) => t.libraryEntryRefKey.equals(ref.key)))
        .go();
    if (memberships.isEmpty) return;
    await _db.batch((batch) {
      for (final membership in memberships) {
        batch.insert(
          _db.userFolderItemsCache,
          UserFolderItemsCacheCompanion.insert(
            folderId: membership.folderId,
            libraryEntryRefKey: ref.key,
            sortOrder: Value(membership.sortOrder),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> applySyncedUpsert(UserFolder folder) async {
    await _db.into(_db.userFoldersCache).insertOnConflictUpdate(
          UserFoldersCacheCompanion.insert(
            id: folder.id,
            name: folder.name,
            description: Value(folder.description),
            parentId: Value(folder.parentId),
            iconName: Value(folder.iconName),
            sortOrder: Value(folder.sortOrder),
          ),
        );
  }

  Future<void> applySyncedDelete(String id) => deleteLocally(id);

  Future<void> addItemToFolder(
      String folderId, LibraryEntryRef libraryEntryRef) async {
    requireKnownLibraryEntryRef(libraryEntryRef);
    final maxSort = await _db.customSelect(
      'SELECT COALESCE(MAX(sort_order), 0) AS m FROM user_folder_items_cache WHERE folder_id = ?',
      variables: [Variable.withString(folderId)],
    ).getSingle();
    final sortOrder = (maxSort.data['m'] as int) + 1;

    await _db.into(_db.userFolderItemsCache).insertOnConflictUpdate(
          UserFolderItemsCacheCompanion.insert(
            folderId: folderId,
            libraryEntryRefKey: libraryEntryRef.key,
            sortOrder: Value(sortOrder),
          ),
        );
  }

  Future<void> removeItemFromFolder(
    String folderId,
    LibraryEntryRef libraryEntryRef,
  ) async {
    requireKnownLibraryEntryRef(libraryEntryRef);
    await (_db.delete(_db.userFolderItemsCache)
          ..where((t) =>
              t.folderId.equals(folderId) &
              t.libraryEntryRefKey.equals(libraryEntryRef.key)))
        .go();
  }

  Future<List<UserFolder>> getFoldersForItem(
      LibraryEntryRef libraryEntryRef) async {
    requireKnownLibraryEntryRef(libraryEntryRef);
    final rows = await (_db.select(_db.userFolderItemsCache)
          ..where((t) => t.libraryEntryRefKey.equals(libraryEntryRef.key)))
        .get();
    if (rows.isEmpty) return [];
    final folderIds = rows.map((r) => r.folderId).toSet();
    final folders = await (_db.select(_db.userFoldersCache)
          ..where((t) => t.id.isIn(folderIds)))
        .get();
    return folders
        .map((r) => UserFolder(
              id: r.id,
              name: r.name,
              description: r.description,
              parentId: r.parentId,
              iconName: r.iconName,
              sortOrder: r.sortOrder,
            ))
        .toList();
  }

  Future<UserFolder?> findById(String id) async {
    final row = await (_db.select(_db.userFoldersCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return UserFolder(
      id: row.id,
      name: row.name,
      description: row.description,
      parentId: row.parentId,
      iconName: row.iconName,
      sortOrder: row.sortOrder,
    );
  }

  Future<UserFolder?> _getById(String id) => findById(id);

  Future<void> _enqueue(UserFolder folder, String action) async {
    final now = DateTime.now().toUtc();
    await SyncQueueRepository(_db).enqueue(SyncChange(
      id: 'user_folder:${folder.id}:$action:${now.microsecondsSinceEpoch}',
      entityType: 'user_folder',
      entityId: folder.id,
      action: action,
      payload: action == 'delete' ? const {} : folder.toSyncPayload(),
      clientChangedAt: now,
    ));
  }
}
