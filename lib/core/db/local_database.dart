import 'package:drift/drift.dart';
import 'package:collectarr_app/core/db/open_connection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_database_tables.g.dart';
import 'universal_local_tables.dart';
import 'package:collectarr_app/features/library/collections/library_collection_tables.dart';

part 'local_database.g.dart';

@DriftDatabase(tables: [
  LibraryEntries,
  LibraryCollections,
  LibraryCollectionMemberships,
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(
                pickListValuesCache, pickListValuesCache.sortName);
            await migrator.addColumn(
                pickListValuesCache, pickListValuesCache.isHidden);
          }
          if (from < 3) {
            await migrator.createTable(libraryCollections);
            await migrator.createTable(libraryCollectionMemberships);
          }
        },
      );
}
