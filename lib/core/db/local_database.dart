import 'package:drift/drift.dart';
import 'package:collectarr_app/core/db/open_connection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_database_tables.g.dart';

import 'universal_local_tables.dart';

import 'package:collectarr_app/features/library/collections/library_collection_tables.dart';

part 'local_database.g.dart';

@DriftDatabase(
  tables: [
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
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor])
      : super(executor ?? openConnection());

  @override
  int get schemaVersion => 1;

  // Dormant kind models remain available to their isolated source modules.
  // The release database exposes and creates only shared and Music tables.
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        libraryEntries,
        libraryCollections,
        libraryCollectionMemberships,
        catalogItemsCache,
        wishlistItemsCache,
        syncQueue,
        userMetadataOverridesCache,
        userExternalLinksCache,
        customFieldDefinitionsCache,
        customFieldValuesCache,
        itemImagesCache,
        loansCache,
        locationsCache,
        smartListsCache,
        userFoldersCache,
        userFolderItemsCache,
        readingQueueCache,
        pickListValuesCache,
        serialAuthorityCache,
        musicTrackingRows,
        musicListenEventsRows,
      ];

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        // Add explicit, ordered upgrade steps when the released schema changes.
        onUpgrade: (migrator, from, to) => throw StateError(
          'No released migration exists from schema $from to $to.',
        ),
      );
}
