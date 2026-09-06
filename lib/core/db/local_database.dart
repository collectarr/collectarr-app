import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/open_connection.dart';
import 'package:collectarr_app/features/library/kinds/book/data/local/book_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/local/boardgame_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/local/comic_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/local/comic_local_migration.dart';
import 'package:collectarr_app/features/library/kinds/game/data/local/game_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/local/manga_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/local/movie_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/local/movie_local_migration.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/local/tv_local_migration.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/local/anime_local_tables.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/local/anime_local_migration.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_tables.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'universal_local_tables.dart';

part 'local_database.g.dart';

@DriftDatabase(tables: [
  OwnedItemsCache,
  WishlistItemsCache,
  TrackingEntriesCache,
  TrackingUnitsCache,
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
  ComicMediaRows,
  ComicReleaseRows,
  ComicOwnedItemsRows,
  ComicReadingRows,
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
  MovieOwnedItemsRows,
  TvSeriesRows,
  TvSeasonRows,
  TvEpisodeRows,
  TvReleaseRows,
  TvReleaseMediaRows,
  TvReleaseEpisodeMapRows,
  TvOwnedDetailsRows,
  TvOwnedItemsRows,
  TvWatchSessionRows,
  TvEpisodeProgressRows,
  TvCustomEpisodeRows,
  TvTrackingUnitRows,
  AnimeMediaRows,
  AnimeEpisodeRows,
  AnimeReleaseRows,
  AnimeOwnedDetailsRows,
  AnimeOwnedItemsRows,
  AnimeTrackingRows,
  AnimeTrackingUnitRows,
  AnimeWatchSessionRows,
  AnimeCustomEpisodeRows,
  ComicTrackingUnitRows,
  MangaTrackingUnitRows,
  BookTrackingUnitRows,
  MusicReleaseRows,
  MusicMediaRows,
  MusicTrackRows,
  MusicOwnedDetailsRows,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor])
      : super(executor ?? openConnection());

  @override
  int get schemaVersion => 30;

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
        }
        if (from < 19) {
          await m.createTable(tvWatchSessionRows);
          await m.createTable(tvEpisodeProgressRows);
          await m.createTable(tvCustomEpisodeRows);
        }
        if (from < 20) {
          await m.createTable(animeMediaRows);
          await m.createTable(animeEpisodeRows);
          await m.createTable(animeReleaseRows);
          await m.createTable(animeOwnedDetailsRows);
          await m.createTable(animeTrackingRows);
        }
        if (from < 21) {
          await m.createTable(musicReleaseRows);
          await m.createTable(musicMediaRows);
          await m.createTable(musicTrackRows);
          await m.createTable(musicOwnedDetailsRows);
        }
        if (from < 22) {
          final columns = await customSelect(
            'PRAGMA table_info(${trackingEntriesCache.actualTableName})',
          ).get();
          final hasKind = columns.any(
            (column) => column.data['name']?.toString() == 'kind',
          );
          if (!hasKind) {
            await m.addColumn(trackingEntriesCache, trackingEntriesCache.kind);
          }
        }
        if (from < 23) {
          await _migrateCatalogCache();
        }
        if (from < 24) {
          await _migrateTrackingUnits(m);
        }
        if (from < 25) {
          await _migrateVideoPersonalRows(m);
        }
        if (from < 26) {
          if (await _hasTable(loansCache.actualTableName) &&
              !await _hasColumn(
                loansCache.actualTableName,
                loansCache.ownedKind.name,
              )) {
            await m.addColumn(loansCache, loansCache.ownedKind);
          }
          if (await _hasTable(ownedItemsCache.actualTableName)) {
            await customStatement('''
              UPDATE ${loansCache.actualTableName}
              SET owned_kind = (
                SELECT kind
                FROM ${ownedItemsCache.actualTableName}
                WHERE ${ownedItemsCache.actualTableName}.id =
                    ${loansCache.actualTableName}.owned_item_id
              )
              WHERE owned_kind IS NULL
            ''');
          }
        }
        if (from < 27) {
          if (!await _hasTable(comicOwnedItemsRows.actualTableName)) {
            await m.createTable(comicOwnedItemsRows);
          }
          if (!await _hasTable(comicReadingRows.actualTableName)) {
            await m.createTable(comicReadingRows);
          }
          await migrateComicOwnedItems(this);
        }
        if (from < 28) {
          if (!await _hasTable(movieOwnedItemsRows.actualTableName)) {
            await m.createTable(movieOwnedItemsRows);
          }
          await migrateMovieOwnedItems(this);
        }
        if (from < 29) {
          if (!await _hasTable(animeOwnedItemsRows.actualTableName)) {
            await m.createTable(animeOwnedItemsRows);
          }
          await migrateAnimeOwnedItems(this);
        }
        if (from < 30) {
          if (!await _hasTable(tvOwnedItemsRows.actualTableName)) {
            await m.createTable(tvOwnedItemsRows);
          }
          await migrateTvOwnedItems(this);
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
    if (await _hasTable('catalog_cache')) {
      final catalogRows = await customSelect(
        'SELECT id, kind FROM catalog_cache',
      ).get();
      for (final row in catalogRows) {
        final id = row.data['id']?.toString();
        final kind = row.data['kind']?.toString();
        if (id != null && kind != null && kind.isNotEmpty) {
          catalogKinds[id] = kind;
        }
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

  Future<void> _migrateCatalogCache() async {
    if (!await _hasTable('catalog_cache')) {
      return;
    }
    final rows = await customSelect(
      'SELECT id, kind, payload_json FROM catalog_cache',
    ).get();
    final items = <CatalogItem>[];
    for (final row in rows) {
      final decoded = jsonDecode(row.data['payload_json']?.toString() ?? '');
      if (decoded is! Map) continue;
      final payload = Map<String, dynamic>.from(decoded)
        ..['id'] ??= row.data['id']?.toString() ?? ''
        ..['kind'] ??= row.data['kind']?.toString() ?? 'unknown';
      try {
        items.add(CatalogItem.fromJson(payload));
      } on Object {
        // Ignore malformed legacy snapshots; the generic cache is retired.
      }
    }
    if (items.isNotEmpty) {
      await LibraryCatalogRepository(this).upsertAll(items);
    }
    await customStatement('DROP TABLE IF EXISTS catalog_cache');
  }

  Future<void> _migrateTrackingUnits(Migrator m) async {
    await m.createTable(tvTrackingUnitRows);
    await m.createTable(animeTrackingUnitRows);
    await m.createTable(bookTrackingUnitRows);
    await m.createTable(mangaTrackingUnitRows);
    await m.createTable(comicTrackingUnitRows);

    final tableName = trackingUnitsCache.actualTableName;
    final columns = await customSelect('PRAGMA table_info($tableName)').get();
    final columnNames = columns
        .map((column) => column.data['name']?.toString())
        .whereType<String>()
        .toSet();
    final kindExpression = columnNames.contains('kind')
        ? "COALESCE(NULLIF(u.kind, ''), NULLIF(e.kind, ''), 'unknown')"
        : "COALESCE(NULLIF(e.kind, ''), 'unknown')";
    String legacyColumn(String name) {
      return columnNames.contains(name) ? 'u.$name' : 'NULL';
    }

    final legacyRows = await customSelect('''
      SELECT
        u.id,
        ${legacyColumn('unit_type')} AS unit_type,
        ${legacyColumn('season_number')} AS season_number,
        ${legacyColumn('episode_number')} AS episode_number,
        ${legacyColumn('volume_number')} AS volume_number,
        ${legacyColumn('chapter_number')} AS chapter_number,
        ${legacyColumn('issue_number')} AS issue_number,
        $kindExpression AS kind
      FROM $tableName u
      LEFT JOIN ${trackingEntriesCache.actualTableName} e
        ON e.id = u.tracking_entry_id
    ''').get();
    final migratedKinds = <String, String>{};

    for (final row in legacyRows) {
      final data = row.data;
      final id = data['id']?.toString();
      final kind = data['kind']?.toString() ?? 'unknown';
      final unitType = data['unit_type']?.toString();
      if (id == null || id.isEmpty) {
        continue;
      }
      migratedKinds[id] = kind;
      final seasonNumber = _legacyInt(data['season_number']);
      final episodeNumber = _legacyInt(data['episode_number']);
      final volumeNumber = _legacyInt(data['volume_number']);
      final chapterNumber = _legacyInt(data['chapter_number']);
      final issueNumber = data['issue_number']?.toString();

      if ((kind == 'tv' || kind == 'anime') &&
          (unitType == 'season' || unitType == 'episode')) {
        await customStatement(
          'INSERT OR REPLACE INTO ${tvTrackingUnitRows.actualTableName} '
          '(id, season_number, episode_number) VALUES (?, ?, ?)',
          [id, seasonNumber, episodeNumber],
        );
        if (kind == 'anime') {
          await customStatement(
            'INSERT OR REPLACE INTO ${animeTrackingUnitRows.actualTableName} '
            '(id, season_number, episode_number) VALUES (?, ?, ?)',
            [id, seasonNumber, episodeNumber],
          );
          await customStatement(
            'DELETE FROM ${tvTrackingUnitRows.actualTableName} WHERE id = ?',
            [id],
          );
        }
      } else if (kind == 'book' || kind == 'manga') {
        final table = kind == 'book'
            ? bookTrackingUnitRows.actualTableName
            : mangaTrackingUnitRows.actualTableName;
        await customStatement(
          'INSERT OR REPLACE INTO $table '
          '(id, volume_number, chapter_number) VALUES (?, ?, ?)',
          [id, volumeNumber, chapterNumber],
        );
      } else if (kind == 'comic' && unitType == 'issue') {
        await customStatement(
          'INSERT OR REPLACE INTO ${comicTrackingUnitRows.actualTableName} '
          '(id, issue_number) VALUES (?, ?)',
          [id, issueNumber],
        );
      }
    }

    await m.alterTable(
      columnNames.contains('kind')
          ? TableMigration(trackingUnitsCache)
          : TableMigration(
              trackingUnitsCache,
              newColumns: [trackingUnitsCache.kind],
            ),
    );
    for (final entry in migratedKinds.entries) {
      await customStatement(
        'UPDATE $tableName SET kind = ? WHERE id = ?',
        [entry.value, entry.key],
      );
    }
  }

  int? _legacyInt(Object? value) {
    return switch (value) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };
  }

  Future<void> _migrateVideoPersonalRows(Migrator m) async {
    await m.createTable(animeWatchSessionRows);
    await m.createTable(animeCustomEpisodeRows);

    if (await _hasTable('watch_sessions_cache')) {
      final rows =
          await customSelect('SELECT * FROM watch_sessions_cache').get();
      for (final row in rows) {
        final data = row.data;
        final id = data['id']?.toString();
        final itemId = data['item_id']?.toString();
        if (id == null || itemId == null) {
          continue;
        }
        final targetRef = _legacyTargetRefJson(
          data['target_ref_json'],
          itemId: itemId,
        );
        final kind = _legacyTargetKind(
          data['target_ref_json'],
        );
        final table = kind == 'anime'
            ? animeWatchSessionRows.actualTableName
            : tvWatchSessionRows.actualTableName;
        await customStatement(
          'INSERT OR REPLACE INTO $table '
          '(id, series_id, episode_id, target_ref_json, tracking_entry_id, '
          'season_number, episode_number, source_type, seen_where, watched_at, '
          'rating, notes, updated_at, deleted_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            id,
            itemId,
            null,
            targetRef,
            data['tracking_entry_id'],
            _legacyInt(data['season_number']),
            _legacyInt(data['episode_number']),
            data['source_type'],
            data['seen_where'],
            _legacyDateTimeMillis(data['watched_at']),
            _legacyInt(data['rating']),
            data['notes'],
            _legacyDateTimeMillis(data['updated_at']),
            _legacyDateTimeMillis(data['deleted_at']),
          ],
        );
      }
      await customStatement('DROP TABLE watch_sessions_cache');
    }

    if (await _hasTable('custom_episodes_cache')) {
      final rows =
          await customSelect('SELECT * FROM custom_episodes_cache').get();
      for (final row in rows) {
        final data = row.data;
        final id = data['id']?.toString();
        final itemId = data['item_id']?.toString();
        if (id == null || itemId == null) {
          continue;
        }
        await customStatement(
          'INSERT OR REPLACE INTO ${tvCustomEpisodeRows.actualTableName} '
          '(id, series_id, season_number, episode_number, title, description, '
          'air_date, runtime_minutes, still_image_url, local_image_path, '
          'thumbnail_image_url, updated_at, deleted_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            id,
            itemId,
            _legacyInt(data['season_number']) ?? 0,
            _legacyInt(data['episode_number']) ?? 0,
            data['title']?.toString() ?? 'Untitled episode',
            data['overview'],
            _legacyDateTimeMillis(data['air_date']),
            _legacyInt(data['runtime_minutes']),
            data['still_image_url'],
            data['local_image_path'],
            data['thumbnail_image_url'],
            _legacyDateTimeMillis(data['updated_at']),
            _legacyDateTimeMillis(data['deleted_at']),
          ],
        );
      }
      await customStatement('DROP TABLE custom_episodes_cache');
    }
  }

  String _legacyTargetKind(Object? rawJson) {
    final raw = rawJson?.toString();
    if (raw == null || raw.isEmpty) {
      return 'tv';
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final kind = decoded['kind']?.toString().trim().toLowerCase();
        if (kind == 'anime') {
          return 'anime';
        }
      }
    } on Object {
      // Malformed legacy refs are retained as a TV fallback below.
    }
    return 'tv';
  }

  String _legacyTargetRefJson(
    Object? rawJson, {
    required String itemId,
  }) {
    final raw = rawJson?.toString();
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return jsonEncode(Map<String, dynamic>.from(decoded));
        }
      } on Object {
        // Fall through to a valid work reference.
      }
    }
    return jsonEncode({
      'kind': _legacyTargetKind(rawJson),
      'entity_type': 'work',
      'id': itemId,
    });
  }

  int? _legacyDateTimeMillis(Object? value) {
    return switch (value) {
      int value => value,
      num value => value.toInt(),
      DateTime value => value.millisecondsSinceEpoch,
      String value => DateTime.tryParse(value)?.millisecondsSinceEpoch,
      _ => null,
    };
  }

  Future<bool> _hasTable(String tableName) async {
    final rows = await customSelect(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
      variables: [Variable.withString('table'), Variable.withString(tableName)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _hasColumn(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName)').get();
    return rows.any(
      (row) => row.data['name']?.toString() == columnName,
    );
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
    await customStatement('DROP TABLE IF EXISTS catalog_cache');
    await m.createAll();
  }
}
