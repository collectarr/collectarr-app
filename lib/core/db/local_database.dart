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

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(
              musicReleaseGroupRows,
              musicReleaseGroupRows.originalReleaseDatePartsJson,
            );
            await m.addColumn(
              musicReleaseGroupRows,
              musicReleaseGroupRows.recordingDatePartsJson,
            );
            await m.addColumn(
              musicReleaseRows,
              musicReleaseRows.releaseDatePartsJson,
            );
            await m.createTable(musicArtistCreditsRows);
            await m.createTable(musicReleaseLabelsRows);
          }
        },
      );
}
