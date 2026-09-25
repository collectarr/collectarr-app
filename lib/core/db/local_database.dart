import 'dart:convert';

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
  int get schemaVersion => 5;

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
          if (from < 3) {
            await m.createTable(musicReleaseImagesRows);
          }
          if (from < 4) {
            await m.alterTable(TableMigration(musicReleaseGroupRows));
          }
          if (from < 5) {
            await _migrateMusicFieldOwnership(m);
          }
        },
      );

  Future<void> _migrateMusicFieldOwnership(Migrator migrator) async {
    final releaseRows = await customSelect(
      'SELECT id, physical_format, physical_format_label, box_set_name '
      'FROM music_release_rows',
    ).get();
    final mediumRows = await customSelect(
      'SELECT id, release_id, medium_number, medium_type, media_condition '
      'FROM music_medium_rows ORDER BY release_id, medium_number',
    ).get();

    await migrator.createTable(musicReleaseLocalDetailsRows);
    await migrator.createTable(musicLegacyMediumConditionArchiveRows);
    for (final row in releaseRows) {
      final releaseId = row.read<String>('id');
      final boxSetName = row.read<String?>('box_set_name')?.trim();
      if (boxSetName != null && boxSetName.isNotEmpty) {
        await into(musicReleaseLocalDetailsRows).insertOnConflictUpdate(
          MusicReleaseLocalDetailsRowsCompanion.insert(
            releaseId: releaseId,
            boxSetName: Value(boxSetName),
          ),
        );
      }
    }

    for (final row in mediumRows) {
      final condition = row.read<String?>('media_condition')?.trim();
      if (condition == null || condition.isEmpty) continue;
      await into(musicLegacyMediumConditionArchiveRows).insertOnConflictUpdate(
        MusicLegacyMediumConditionArchiveRowsCompanion.insert(
          id: row.read<String>('id'),
          releaseId: row.read<String>('release_id'),
          mediumNumber: row.read<int>('medium_number'),
          condition: condition,
          archivedAt: DateTime.now().toUtc(),
        ),
      );
    }

    await _moveLegacyMediumConditions(mediumRows);
    await migrator.alterTable(TableMigration(musicReleaseRows));
    await migrator.alterTable(TableMigration(musicMediumRows));

    final mediumTypesByRelease = <String, List<String>>{};
    for (final row in mediumRows) {
      final releaseId = row.read<String>('release_id');
      final mediumType = row.read<String?>('medium_type')?.trim();
      if (mediumType == null || mediumType.isEmpty) continue;
      mediumTypesByRelease.putIfAbsent(releaseId, () => []).add(mediumType);
    }
    for (final row in releaseRows) {
      final releaseId = row.read<String>('id');
      final legacyType = (row.read<String?>('physical_format_label') ??
              row.read<String?>('physical_format'))
          ?.trim();
      final values = mediumTypesByRelease[releaseId] ??
          (legacyType == null || legacyType.isEmpty
              ? <String>[]
              : [legacyType]);
      await (update(musicReleaseRows)
            ..where((release) => release.id.equals(releaseId)))
          .write(
        MusicReleaseRowsCompanion(
          mediumTypesJson: Value(jsonEncode(values)),
        ),
      );
    }
  }

  Future<void> _moveLegacyMediumConditions(
    List<QueryRow> mediumRows,
  ) async {
    final conditionsByRelease = <String, List<(int, String)>>{};
    for (final row in mediumRows) {
      final condition = row.read<String?>('media_condition')?.trim();
      if (condition == null || condition.isEmpty) continue;
      conditionsByRelease
          .putIfAbsent(row.read<String>('release_id'), () => [])
          .add((row.read<int>('medium_number'), condition));
    }
    if (conditionsByRelease.isEmpty) return;

    final ownedRows = await customSelect(
      'SELECT id, target_ref_json, medium_details_json '
      'FROM music_owned_items_rows',
    ).get();
    for (final row in ownedRows) {
      final targetRefRaw = row.read<String?>('target_ref_json');
      if (targetRefRaw == null || targetRefRaw.isEmpty) continue;
      final decodedRef = jsonDecode(targetRefRaw);
      if (decodedRef is! Map ||
          decodedRef['kind'] != 'music' ||
          decodedRef['entity_type'] != 'release') {
        continue;
      }
      final releaseId = decodedRef['id']?.toString();
      final conditions =
          releaseId == null ? null : conditionsByRelease[releaseId];
      if (conditions == null || conditions.isEmpty) continue;

      final rawDetails = row.read<String?>('medium_details_json') ?? '[]';
      final decodedDetails = jsonDecode(rawDetails);
      final details = decodedDetails is List
          ? [
              for (final value in decodedDetails)
                if (value is Map) Map<String, dynamic>.from(value),
            ]
          : <Map<String, dynamic>>[];
      var changed = false;
      for (final (mediumIndex, condition) in conditions) {
        final existing = details.cast<Map<String, dynamic>?>().firstWhere(
              (value) => value?['medium_index'] == mediumIndex,
              orElse: () => null,
            );
        if (existing == null) {
          details.add({
            'medium_index': mediumIndex,
            'media_condition': condition,
          });
          changed = true;
        } else if ((existing['media_condition'] as String?)
                ?.trim()
                .isNotEmpty !=
            true) {
          existing['media_condition'] = condition;
          changed = true;
        }
      }
      if (!changed) continue;
      await (update(musicOwnedItemsRows)
            ..where((item) => item.id.equals(row.read<String>('id'))))
          .write(
        MusicOwnedItemsRowsCompanion(
          mediumDetailsJson: Value(jsonEncode(details)),
        ),
      );
    }
  }
}
