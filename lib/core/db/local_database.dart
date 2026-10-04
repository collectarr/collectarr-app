import 'package:drift/drift.dart';
import 'package:collectarr_app/core/db/open_connection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_database_tables.g.dart';
import 'universal_local_tables.dart';

part 'local_database.g.dart';

@DriftDatabase(tables: [
  LibraryEntries,
  CatalogItemsCache,
  WishlistItemsCache,
  SyncQueue,
  UserMetadataOverridesCache,
  UserExternalLinksCache,
  CustomFieldDefinitionsCache,
  CustomFieldValuesCache,
  ItemImagesCache,
  LoansCache,
  LocationsCache,
  SmartListsCache,
  UserFoldersCache,
  UserFolderItemsCache,
  ReadingQueueCache,
  PickListValuesCache,
  SerialAuthorityCache,
  ...collectarrKindTableTypes,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor])
      : super(executor ?? openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        onUpgrade: (migrator, from, to) async {
          if (from < 2 && to >= 2) {
            await _ensureExternalLinksEntryKey(migrator);
          }
        },
      );

  Future<void> _ensureExternalLinksEntryKey(Migrator migrator) async {
    final columns = await customSelect(
      'PRAGMA table_info("user_external_links_cache")',
    ).get();
    if (columns.isEmpty) {
      await migrator.createTable(userExternalLinksCache);
      return;
    }

    final columnNames = columns.map((row) => row.read<String>('name')).toSet();
    if (columnNames.contains('library_entry_ref_key')) return;

    // Keep existing link rows intact when upgrading a database created before
    // links were keyed by the local entry identity.
    await customStatement(
      "ALTER TABLE user_external_links_cache "
      "ADD COLUMN library_entry_ref_key TEXT NOT NULL DEFAULT ''",
    );
  }
}
