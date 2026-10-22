import 'dart:convert';

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
  int get schemaVersion => 4;

  // Dormant kind models remain available to their isolated source modules.
  // The release database exposes and creates only shared and released-kind
  // tables.
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
        gameTrackingRows,
      ];

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        // Explicit, ordered upgrade steps; each runs once, from the released
        // schema it follows.
        onUpgrade: (migrator, from, to) async {
          if (from < 1 || to > 4) {
            throw StateError(
                'No released migration exists from schema $from to $to.');
          }
          if (from < 2) {
            // 2: borrower contact details on pick-list values.
            await migrator.addColumn(
                pickListValuesCache, pickListValuesCache.email);
            await migrator.addColumn(
                pickListValuesCache, pickListValuesCache.address);
          }
          if (from < 3) {
            // 3: Game release.
            await migrator.createTable(gameTrackingRows);
          }
          if (from < 4) {
            // 4: personal tags are a list instead of one comma-separated
            // string, in entries and in their pending Sync changes.
            await _storeTagsAsLists('library_entries', '');
            await _storeTagsAsLists(
                'sync_queue', " WHERE entity_type = 'library_entry'");
          }
        },
      );

  Future<void> _storeTagsAsLists(String table, String filter) async {
    final rows = await customSelect(
      'SELECT rowid AS row_id, payload_json FROM $table$filter',
    ).get();
    for (final row in rows) {
      final payload = jsonDecode(row.read<String>('payload_json'));
      if (payload is! Map<String, dynamic>) continue;
      final personal = payload['personal_data'];
      if (personal is! Map<String, dynamic>) continue;
      final tags = personal['tags'];
      if (tags is! String) continue;
      final seen = <String>{};
      personal['tags'] = [
        for (final raw in tags.split(','))
          if (raw.trim() case final tag when tag.isNotEmpty)
            if (seen.add(tag.toLowerCase())) tag,
      ];
      await customUpdate(
        'UPDATE $table SET payload_json = ? WHERE rowid = ?',
        variables: [
          Variable.withString(jsonEncode(payload)),
          Variable.withInt(row.read<int>('row_id')),
        ],
      );
    }
  }
}
