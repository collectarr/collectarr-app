import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
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
    final maxSort = await _db.customSelect(
      'SELECT COALESCE(MAX(sort_order), 0) AS m FROM user_folders_cache',
    ).getSingle();
    final sortOrder = (maxSort.data['m'] as int) + 1;

    await _db.into(_db.userFoldersCache).insert(
          UserFoldersCacheCompanion.insert(
            id: id,
            name: name,
            parentId: Value(parentId),
            sortOrder: Value(sortOrder),
          ),
        );
    return UserFolder(id: id, name: name, parentId: parentId, sortOrder: sortOrder);
  }

  Future<void> rename(String id, String newName) async {
    await (_db.update(_db.userFoldersCache)..where((t) => t.id.equals(id)))
        .write(UserFoldersCacheCompanion(name: Value(newName)));
  }

  Future<void> delete(String id) async {
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

  Future<List<String>> getItemIdsInFolder(String folderId) async {
    final rows = await (_db.select(_db.userFolderItemsCache)
          ..where((t) => t.folderId.equals(folderId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows.map((r) => r.ownedItemId).toList();
  }

  Future<void> addItemToFolder(String folderId, String ownedItemId) async {
    final maxSort = await _db.customSelect(
      'SELECT COALESCE(MAX(sort_order), 0) AS m FROM user_folder_items_cache WHERE folder_id = ?',
      variables: [Variable.withString(folderId)],
    ).getSingle();
    final sortOrder = (maxSort.data['m'] as int) + 1;

    await _db.into(_db.userFolderItemsCache).insertOnConflictUpdate(
          UserFolderItemsCacheCompanion.insert(
            folderId: folderId,
            ownedItemId: ownedItemId,
            sortOrder: Value(sortOrder),
          ),
        );
  }

  Future<void> removeItemFromFolder(String folderId, String ownedItemId) async {
    await (_db.delete(_db.userFolderItemsCache)
          ..where(
              (t) => t.folderId.equals(folderId) & t.ownedItemId.equals(ownedItemId)))
        .go();
  }

  Future<List<UserFolder>> getFoldersForItem(String ownedItemId) async {
    final rows = await (_db.select(_db.userFolderItemsCache)
          ..where((t) => t.ownedItemId.equals(ownedItemId)))
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
}
