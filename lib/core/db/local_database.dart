import 'package:drift/drift.dart';
import 'package:collectarr_app/core/db/open_connection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_database_tables.g.dart';
import 'universal_local_tables.dart';

part 'local_database.g.dart';

@DriftDatabase(tables: [
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
  ProviderAccountsCache,
  ProviderItemLinksCache,
  ...collectarrKindTableTypes,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor])
      : super(executor ?? openConnection());

  /// Version 2 consolidates Music owned medium details into one JSON column.
  /// Version 3 moves pre-release-group Music references to their canonical
  /// release-group root.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, _) async {
          if (from < 3) {
            await _migrateMusicReleaseGroupRoots(m);
          }
        },
      );
}

Future<void> _migrateMusicReleaseGroupRoots(Migrator migrator) async {
  final db = migrator.database;

  // Older Music collection rows used the selected release id as the
  // collection root. Resolve it from the typed release table before the
  // workspace starts building Shelf sources.
  await db.customStatement('''
    UPDATE music_owned_items_rows
    SET item_id = COALESCE(
      (
        SELECT release_group_id
        FROM music_release_rows
        WHERE music_release_rows.id = music_owned_items_rows.item_id
      ),
      (
        SELECT release_group_id
        FROM music_release_rows
        WHERE music_release_rows.id =
          json_extract(music_owned_items_rows.target_ref_json, '\$.id')
      ),
      item_id
    )
    WHERE EXISTS (
      SELECT 1
      FROM music_release_rows
      WHERE music_release_rows.id = music_owned_items_rows.item_id
         OR music_release_rows.id =
            json_extract(music_owned_items_rows.target_ref_json, '\$.id')
    )
  ''');

  await db.customStatement('''
    UPDATE music_owned_items_rows
    SET target_ref_json = json_set(
      target_ref_json,
      '\$.root_id',
      (
        SELECT release_group_id
        FROM music_release_rows
        WHERE music_release_rows.id =
          json_extract(music_owned_items_rows.target_ref_json, '\$.id')
      )
    )
    WHERE json_valid(target_ref_json)
      AND EXISTS (
        SELECT 1
        FROM music_release_rows
        WHERE music_release_rows.id =
          json_extract(music_owned_items_rows.target_ref_json, '\$.id')
      )
  ''');

  await _rewriteMusicRootInJsonColumn(
    db,
    table: 'music_tracking_rows',
    column: 'catalog_ref_json',
    idPath: r'$.id',
  );
  await _rewriteMusicRootInJsonColumn(
    db,
    table: 'wishlist_items_cache',
    column: 'catalog_ref_json',
    idPath: r'$.id',
  );
  await _rewriteMusicRootInJsonColumn(
    db,
    table: 'user_external_links_cache',
    column: 'catalog_ref_json',
    idPath: r'$.id',
  );
  await _rewriteMusicRootInJsonColumn(
    db,
    table: 'custom_field_values_cache',
    column: 'catalog_ref_json',
    idPath: r'$.id',
  );
  await _rewriteMusicRootInJsonColumn(
    db,
    table: 'user_metadata_overrides_cache',
    column: 'target_ref_json',
    idPath: r'$.id',
  );
  await _rewriteMusicRootInJsonColumn(
    db,
    table: 'provider_item_links_cache',
    column: 'local_entity_ref_json',
    idPath: r'$.id',
  );

  await db.customStatement('''
    UPDATE music_listen_events_rows
    SET release_group_id = COALESCE(
      (
        SELECT release_group_id
        FROM music_release_rows
        WHERE music_release_rows.id = music_listen_events_rows.release_id
      ),
      release_group_id
    ),
    target_ref_json = CASE
      WHEN json_valid(target_ref_json)
       AND EXISTS (
         SELECT 1
         FROM music_release_rows
         WHERE music_release_rows.id = music_listen_events_rows.release_id
       )
      THEN json_set(
        target_ref_json,
        '\$.root_id',
        (
          SELECT release_group_id
          FROM music_release_rows
          WHERE music_release_rows.id = music_listen_events_rows.release_id
        )
      )
      ELSE target_ref_json
    END
    WHERE EXISTS (
      SELECT 1
      FROM music_release_rows
      WHERE music_release_rows.id = music_listen_events_rows.release_id
    )
  ''');
}

Future<void> _rewriteMusicRootInJsonColumn(
  GeneratedDatabase db, {
  required String table,
  required String column,
  required String idPath,
}) {
  return db.customStatement('''
    UPDATE $table
    SET $column = json_set(
      $column,
      '\$.root_id',
      (
        SELECT release_group_id
        FROM music_release_rows
        WHERE music_release_rows.id = json_extract($column, '$idPath')
      )
    )
    WHERE json_valid($column)
      AND json_extract($column, '\$.kind') = 'music'
      AND EXISTS (
        SELECT 1
        FROM music_release_rows
        WHERE music_release_rows.id = json_extract($column, '$idPath')
      )
  ''');
}
