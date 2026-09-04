import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:collectarr_app/core/db/open_connection.dart';
import 'package:collectarr_app/features/library/kinds/book/data/local/book_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/local/boardgame_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/local/comic_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/game/data/local/game_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/local/manga_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/local/movie_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_tables.dart';

part 'local_database.g.dart';

class CatalogCache extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class OwnedItemsCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get kind => text().withDefault(const Constant('unknown'))();
  TextColumn get detailsJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isDigital => boolean().nullable()();
  TextColumn get anchorType => text().nullable()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get bundleReleaseId => text().nullable()();
  TextColumn get condition => text().nullable()();
  TextColumn get grade => text().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  IntColumn get pricePaidCents => integer().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get personalNotes => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get indexNumber => integer().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get readStatus => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get tags => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get soldAt => dateTime().nullable()();
  IntColumn get sellPriceCents => integer().nullable()();
  TextColumn get soldTo => text().nullable()();
  TextColumn get ownerUserId => text().nullable()();
  TextColumn get ownerLabel => text().nullable()();
  TextColumn get locationId => text().nullable()();
  TextColumn get purchaseStore => text().nullable()();
  TextColumn get collectionStatus => text().nullable()();
  IntColumn get marketValueCents => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomFieldDefinitionsCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get fieldType => text()(); // text, number, date, bool, select
  TextColumn get mediaKind => text().nullable()(); // null = all media types
  TextColumn get editScope => text().nullable()(); // null = all edit scopes
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get options => text().nullable()(); // JSON array for select type
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomFieldValuesCache extends Table {
  TextColumn get id => text()();
  TextColumn get targetId => text()();
  TextColumn get targetScope => text()();
  TextColumn get catalogRefJson => text().nullable()();
  TextColumn get fieldDefinitionId => text()();
  TextColumn get value => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ItemImagesCache extends Table {
  TextColumn get id => text()();
  TextColumn get ownedItemId => text()();
  TextColumn get imageType => text().withDefault(
      const Constant('front_cover'))(); // front_cover, back_cover, auxiliary
  BlobColumn get imageData => blob()(); // raw image bytes
  TextColumn get caption => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserExternalLinksCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get label => text()();
  TextColumn get url => text()();
  TextColumn get kind => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WishlistItemsCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get anchorType => text().nullable()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get bundleReleaseId => text().nullable()();
  IntColumn get targetPriceCents => integer().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TrackingEntriesCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get ownedItemId => text().nullable()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get bundleReleaseId => text().nullable()();
  TextColumn get sourceType => text().nullable()();
  TextColumn get status => text().nullable()();
  IntColumn get rating => integer().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get progressCurrent => integer().nullable()();
  IntColumn get progressTotal => integer().nullable()();
  IntColumn get timesCompleted => integer().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  TextColumn get episodeRatings => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TrackingUnitsCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get trackingEntryId => text().nullable()();
  TextColumn get ownedItemId => text().nullable()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get bundleReleaseId => text().nullable()();
  TextColumn get unitType => text()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  IntColumn get volumeNumber => integer().nullable()();
  IntColumn get chapterNumber => integer().nullable()();
  TextColumn get issueNumber => text().nullable()();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class WatchSessionsCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get targetRefJson => text().nullable()();
  TextColumn get trackingEntryId => text().nullable()();
  IntColumn get seasonNumber => integer().nullable()();
  IntColumn get episodeNumber => integer().nullable()();
  TextColumn get sourceType => text().nullable()();
  TextColumn get seenWhere => text().nullable()();
  DateTimeColumn get watchedAt => dateTime()();
  IntColumn get rating => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get clientChangedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entityType, entityId};
}

class UserMetadataOverridesCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get editionId => text().nullable()();
  TextColumn get variantId => text().nullable()();
  TextColumn get fieldPath => text()();
  TextColumn get originalValue => text().nullable()();
  TextColumn get overrideValue => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomEpisodesCache extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  IntColumn get seasonNumber => integer()();
  IntColumn get episodeNumber => integer()();
  TextColumn get title => text()();
  TextColumn get overview => text().nullable()();
  TextColumn get airDate => text().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  TextColumn get stillImageUrl => text().nullable()();
  TextColumn get localImagePath => text().nullable()();
  TextColumn get thumbnailImageUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LoansCache extends Table {
  TextColumn get id => text()();
  TextColumn get ownedItemId => text()();
  TextColumn get borrowerName => text()();
  DateTimeColumn get lentDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get returnedDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocationsCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class SmartListsCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get mediaKind => text().nullable()();
  TextColumn get criteriaJson => text()(); // serialized filter/sort/query
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserFoldersCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get parentId => text().nullable()();
  TextColumn get iconName => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserFolderItemsCache extends Table {
  TextColumn get folderId => text()();
  TextColumn get ownedItemId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {folderId, ownedItemId};
}

class ReadingQueueCache extends Table {
  TextColumn get ownedItemId => text()();
  IntColumn get position => integer()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {ownedItemId};
}

class PickListValuesCache extends Table {
  TextColumn get id => text()();
  TextColumn get listName => text()(); // e.g. 'condition', 'grade', 'tags'
  TextColumn get mediaKind => text().nullable()();
  TextColumn get value => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class SerialAuthorityCache extends Table {
  TextColumn get id => text()();
  TextColumn get mediaKind => text()();
  TextColumn get title => text()();
  TextColumn get normalizedTitle => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get normalizedSortTitle => text().nullable()();
  TextColumn get coreSeriesId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProviderAccountsCache extends Table {
  TextColumn get id => text()();
  TextColumn get provider => text()();
  TextColumn get displayName => text()();
  TextColumn get authType => text()();
  TextColumn get remoteAccountId => text().nullable()();
  TextColumn get remoteHandle => text().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get connectedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get enabledCapabilitiesJson => text()();
  TextColumn get syncPolicyJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProviderItemLinksCache extends Table {
  TextColumn get accountId => text()();
  TextColumn get provider => text()();
  TextColumn get remoteItemId => text()();
  TextColumn get remoteEntryId => text().nullable()();
  TextColumn get localEntityRefJson => text()();
  TextColumn get baseSnapshotJson => text().nullable()();
  DateTimeColumn get lastPulledAt => dateTime().nullable()();
  DateTimeColumn get lastPushedAt => dateTime().nullable()();
  TextColumn get remoteRevision => text().nullable()();
  TextColumn get metadataJson => text()();

  @override
  Set<Column> get primaryKey => {accountId, remoteItemId};
}

@DriftDatabase(tables: [
  CatalogCache,
  OwnedItemsCache,
  WishlistItemsCache,
  TrackingEntriesCache,
  TrackingUnitsCache,
  WatchSessionsCache,
  SyncQueue,
  UserMetadataOverridesCache,
  CustomEpisodesCache,
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
  ComicMediaRows,
  ComicReleaseRows,
  ComicOwnedDetailsRows,
  MangaMediaRows,
  MangaOwnedDetailsRows,
  BookMediaRows,
  BookReleaseRows,
  BookOwnedDetailsRows,
  GameMediaRows,
  GameReleaseRows,
  GameOwnedDetailsRows,
  BoardGameMediaRows,
  BoardGameEditionRows,
  BoardGameOwnedDetailsRows,
  BoardGamePlaySessionsRows,
  MovieMediaRows,
  MovieReleaseRows,
  MovieOwnedDetailsRows,
  TvSeriesRows,
  TvSeasonRows,
  TvEpisodeRows,
  TvReleaseRows,
  TvReleaseMediaRows,
  TvReleaseEpisodeMapRows,
  TvOwnedDetailsRows,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor])
      : super(executor ?? openConnection());

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 8) {
          await m.createTable(providerAccountsCache);
          await m.createTable(providerItemLinksCache);
        }
        if (from < 9) {
          final columns = await customSelect(
            'PRAGMA table_info(${providerAccountsCache.actualTableName})',
          ).get();
          final hasUsername = columns.any(
            (column) => column.data['name']?.toString() == 'username',
          );
          if (!hasUsername) {
            await m.addColumn(
              providerAccountsCache,
              providerAccountsCache.username,
            );
          }
        }
        if (from < 10) {
          await _migrateOwnedItemsCache(m);
        }
        if (from < 11) {
          await m.createTable(comicOwnedDetailsRows);
        }
        if (from < 12) {
          await m.createTable(mangaMediaRows);
          await m.createTable(mangaOwnedDetailsRows);
        }
        if (from < 13) {
          await m.createTable(bookMediaRows);
          await m.createTable(bookReleaseRows);
          await m.createTable(bookOwnedDetailsRows);
        }
        if (from < 14) {
          await m.createTable(gameMediaRows);
          await m.createTable(gameReleaseRows);
          await m.createTable(gameOwnedDetailsRows);
        }
        if (from < 15) {
          await m.createTable(boardGameMediaRows);
          await m.createTable(boardGameEditionRows);
          await m.createTable(boardGameOwnedDetailsRows);
        }
        if (from < 16) {
          await m.createTable(boardGamePlaySessionsRows);
        }
        if (from < 17) {
          await m.createTable(movieMediaRows);
          await m.createTable(movieReleaseRows);
          await m.createTable(movieOwnedDetailsRows);
        }
        if (from < 18) {
          await m.createTable(tvSeriesRows);
          await m.createTable(tvSeasonRows);
          await m.createTable(tvEpisodeRows);
          await m.createTable(tvReleaseRows);
          await m.createTable(tvReleaseMediaRows);
          await m.createTable(tvReleaseEpisodeMapRows);
          await m.createTable(tvOwnedDetailsRows);
        } else {
          await _destructiveRebuild(m);
        }
      },
      beforeOpen: (details) async {
        // A newer on-disk version cannot be migrated safely by this client.
        if (!details.wasCreated &&
            details.versionBefore != null &&
            details.versionBefore! > details.versionNow) {
          await _destructiveRebuild(createMigrator());
        }
      },
    );
  }

  Future<void> _migrateOwnedItemsCache(Migrator m) async {
    final tableName = ownedItemsCache.actualTableName;
    final columns = await customSelect('PRAGMA table_info($tableName)').get();
    final columnNames = columns
        .map((column) => column.data['name']?.toString())
        .whereType<String>()
        .toSet();
    if (columnNames.contains('kind') && columnNames.contains('details_json')) {
      return;
    }

    final legacyRows = await customSelect('SELECT * FROM $tableName').get();
    final catalogKinds = <String, String>{};
    final catalogRows = await customSelect(
      'SELECT id, kind FROM ${catalogCache.actualTableName}',
    ).get();
    for (final row in catalogRows) {
      final id = row.data['id']?.toString();
      final kind = row.data['kind']?.toString();
      if (id != null && kind != null && kind.isNotEmpty) {
        catalogKinds[id] = kind;
      }
    }
    final migratedRows = <String, ({String kind, String detailsJson})>{};
    for (final row in legacyRows) {
      final id = row.data['id']?.toString();
      if (id == null) {
        continue;
      }
      final data = row.data;
      final catalogKind = catalogKinds[data['item_id']?.toString()];
      migratedRows[id] = (
        kind: _legacyOwnedKind(data, catalogKind: catalogKind),
        detailsJson: jsonEncode(_legacyOwnedDetails(data)),
      );
    }

    await m.alterTable(
      TableMigration(
        ownedItemsCache,
        newColumns: [ownedItemsCache.kind, ownedItemsCache.detailsJson],
      ),
    );

    for (final entry in migratedRows.entries) {
      await customStatement(
        'UPDATE $tableName SET kind = ?, details_json = ? WHERE id = ?',
        [entry.value.kind, entry.value.detailsJson, entry.key],
      );
    }
  }

  String _legacyOwnedKind(
    Map<String, Object?> row, {
    String? catalogKind,
  }) {
    if (catalogKind != null && catalogKind.isNotEmpty) {
      return catalogKind;
    }
    if (_hasLegacyValue(row, [
          'raw_or_slabbed',
          'grading_company',
          'grader_notes',
          'signed_by',
          'label_type',
          'custom_label',
          'page_quality',
          'certification_number',
          'key_reason',
          'key_category',
          'key_severity',
          'cover_price_cents',
          'last_bag_board_date',
        ]) ||
        _legacyBool(row['key_comic']) == true) {
      return 'comic';
    }
    if (_hasLegacyValue(row, [
      'features',
      'hdr_formats_json',
      'box_set_id',
      'box_set_name',
      'region',
      'packaging',
      'distributor',
    ])) {
      return 'movie';
    }
    if (_hasLegacyValue(row, [
      'game_completeness',
      'game_has_box',
      'game_has_manual',
      'game_price_charting_id',
      'game_core_region',
      'game_value_is_locked',
    ])) {
      return 'game';
    }
    if (_hasLegacyValue(row, ['storage_device', 'storage_slot'])) {
      return 'music';
    }
    return 'unknown';
  }

  Map<String, Object?> _legacyOwnedDetails(Map<String, Object?> row) {
    final details = <String, Object?>{};

    void copy(String oldName, String newName) {
      final value = row[oldName];
      if (value != null) {
        details[newName] = value;
      }
    }

    for (final field in const [
      'raw_or_slabbed',
      'grading_company',
      'grader_notes',
      'signed_by',
      'label_type',
      'custom_label',
      'page_quality',
      'certification_number',
      'key_reason',
      'key_category',
      'key_severity',
      'cover_price_cents',
      'features',
      'box_set_id',
      'box_set_name',
      'storage_device',
      'storage_slot',
      'region',
      'packaging',
      'distributor',
    ]) {
      copy(field, field);
    }

    final keyComic = _legacyBool(row['key_comic']);
    if (keyComic != null) {
      details['key_comic'] = keyComic;
    }
    for (final field in const [
      'game_completeness',
      'game_price_charting_id',
      'game_core_region',
    ]) {
      copy(
        field,
        field == 'game_price_charting_id' ? 'game_pricecharting_id' : field,
      );
    }
    for (final field in const [
      'game_has_box',
      'game_has_manual',
      'game_value_is_locked',
    ]) {
      final value = _legacyBool(row[field]);
      if (value != null) {
        details[field] = value;
      }
    }

    final hdrFormats = row['hdr_formats_json'];
    if (hdrFormats is String && hdrFormats.isNotEmpty) {
      try {
        final decoded = jsonDecode(hdrFormats);
        if (decoded is List) {
          details['hdr_formats'] = decoded;
        }
      } on Object {
        // Ignore malformed legacy JSON and preserve the remaining fields.
      }
    }

    final lastBagBoardDate = row['last_bag_board_date'];
    final lastBagBoardDateValue = switch (lastBagBoardDate) {
      DateTime value => value.toUtc().toIso8601String(),
      int value => DateTime.fromMillisecondsSinceEpoch(value, isUtc: true)
          .toIso8601String(),
      num value =>
        DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true)
            .toIso8601String(),
      String value => DateTime.tryParse(value)?.toUtc().toIso8601String(),
      _ => null,
    };
    if (lastBagBoardDateValue != null) {
      details['last_bag_board_date'] = lastBagBoardDateValue;
    }
    return details;
  }

  bool? _legacyBool(Object? value) {
    return switch (value) {
      bool value => value,
      num value => value != 0,
      _ => null,
    };
  }

  bool _hasLegacyValue(Map<String, Object?> row, List<String> names) {
    return names.any((name) => row[name] != null);
  }

  Future<void> _destructiveRebuild(Migrator m) async {
    for (final table in allTables) {
      await customStatement(
        'DROP TABLE IF EXISTS ${table.actualTableName}',
      );
    }
    await m.createAll();
  }
}
