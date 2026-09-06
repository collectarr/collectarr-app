import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/registry/owned_details_exports.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('stores catalog metadata needed for local filters', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final catalogRepo = LibraryCatalogRepository(db);
    await catalogRepo.upsertAll([
      typedCatalogItemFromMap({
        'id': 'comic-1',
        'kind': 'comic',
        'title': 'Superman, Vol. 4',
        'item_number': '8A',
        'thumbnail_image_url': 'https://cdn.example/superman-thumb.jpg',
        'edition_title': 'Direct market edition',
        'physical_format': 'single-issue',
        'physical_format_label': 'Single Issue',
        'publisher': 'DC',
        'release_date': '2016-10-05T00:00:00.000Z',
        'release_year': 2016,
        'barcode': '76194134192700811',
        'variant': 'Regular Cover',
      }),
    ]);

    final catalog = await catalogRepo.findById('comic-1');
    final catalogPayload = catalog!.payload;
    expect(catalogPayload['publisher'], 'DC');
    expect(catalogPayload['thumbnail_image_url'],
        'https://cdn.example/superman-thumb.jpg');
    expect(catalogPayload['edition_title'], 'Direct market edition');
    expect(catalogPayload['physical_format'], 'single-issue');
    expect(catalogPayload['physical_format_label'], 'Single Issue');
    expect(catalogPayload['release_date'], '2016-10-05T00:00:00.000Z');
    expect(catalogPayload['release_year'], 2016);
    expect(catalogPayload['barcode'], '76194134192700811');
    expect(catalogPayload['variant'], 'Regular Cover');
  });

  test('reports the current schema version', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 30);
  });

  test('migrates a v7 cache to v30 without losing existing cache rows',
      () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_migrate');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await _insertLegacyCatalogItem(
      old,
      id: 'comic-1',
      kind: 'comic',
      payload: {'id': 'comic-1', 'title': 'Preserved'},
    );
    await old.customStatement(
      'DROP TABLE ${old.providerAccountsCache.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.providerItemLinksCache.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.comicOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.mangaMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.mangaOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.bookMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.bookReleaseRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.bookOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameReleaseRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameEditionRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGamePlaySessionsRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 7');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final catalog = await LibraryCatalogRepository(db).findById('comic-1');
    expect(catalog?.id, 'comic-1');
    expect(catalog?.title, 'Preserved');
    expect(await db.select(db.providerAccountsCache).get(), isEmpty);
    expect(await db.select(db.providerItemLinksCache).get(), isEmpty);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 30);
  });

  test('migrates a v8 provider account table by adding username', () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_username');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    final accountsTable = old.providerAccountsCache.actualTableName;
    await old.customStatement('''
      INSERT INTO $accountsTable (
        id, provider, display_name, auth_type, remote_account_id,
        remote_handle, username, avatar_url, connected_at, last_sync_at,
        enabled_capabilities_json, sync_policy_json
      ) VALUES (
        'account-1', 'tmdb', 'TMDB', 'oauth', NULL,
        NULL, 'old-user', NULL, NULL, NULL, '[]', '{}'
      )
    ''');
    await old.customStatement(
        'ALTER TABLE $accountsTable RENAME TO ${accountsTable}_current');
    await old.customStatement('''
      CREATE TABLE $accountsTable (
        id TEXT NOT NULL,
        provider TEXT NOT NULL,
        display_name TEXT NOT NULL,
        auth_type TEXT NOT NULL,
        remote_account_id TEXT,
        remote_handle TEXT,
        avatar_url TEXT,
        connected_at INTEGER,
        last_sync_at INTEGER,
        enabled_capabilities_json TEXT NOT NULL,
        sync_policy_json TEXT NOT NULL,
        PRIMARY KEY (id)
      )
    ''');
    await old.customStatement('''
      INSERT INTO $accountsTable (
        id, provider, display_name, auth_type, remote_account_id,
        remote_handle, avatar_url, connected_at, last_sync_at,
        enabled_capabilities_json, sync_policy_json
      )
      SELECT id, provider, display_name, auth_type, remote_account_id,
        remote_handle, avatar_url, connected_at, last_sync_at,
        enabled_capabilities_json, sync_policy_json
      FROM ${accountsTable}_current
    ''');
    await old.customStatement('DROP TABLE ${accountsTable}_current');
    await old.customStatement(
      'DROP TABLE ${old.comicOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.mangaMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.mangaOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.bookMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.bookReleaseRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.bookOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameReleaseRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameEditionRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGamePlaySessionsRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 8');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final account = await db.select(db.providerAccountsCache).getSingle();
    expect(account.id, 'account-1');
    expect(account.username == null, isTrue);
    await (db.update(db.providerAccountsCache)
          ..where((row) => row.id.equals(account.id)))
        .write(const ProviderAccountsCacheCompanion(
      username: Value('new-user'),
    ));
    final migrated = await db.select(db.providerAccountsCache).getSingle();
    expect(migrated.username, 'new-user');
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 30);
  });

  test('migrates v9 owned semantic columns into typed details JSON', () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_owned');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await _insertLegacyCatalogItem(
      old,
      id: 'comic-legacy',
      kind: 'comic',
      payload: {'id': 'comic-legacy', 'kind': 'comic'},
    );
    await _insertLegacyCatalogItem(
      old,
      id: 'tv-legacy',
      kind: 'tv',
      payload: {'id': 'tv-legacy', 'kind': 'tv'},
    );
    await _insertLegacyCatalogItem(
      old,
      id: 'game-legacy',
      kind: 'game',
      payload: {'id': 'game-legacy', 'kind': 'game'},
    );
    await _replaceOwnedItemsWithV9Schema(old);
    final tableName = old.ownedItemsCache.actualTableName;
    final updatedAt = DateTime.utc(2026, 5, 11).millisecondsSinceEpoch;
    final bagBoardDate = DateTime.utc(2026, 5, 10).millisecondsSinceEpoch;
    await old.customStatement('''
      INSERT INTO $tableName (
        id, item_id, quantity, updated_at, raw_or_slabbed, grading_company,
        grader_notes, signed_by, label_type, custom_label, page_quality,
        certification_number, key_comic, key_reason, key_category,
        key_severity, cover_price_cents, last_bag_board_date
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      'owned-comic',
      'comic-legacy',
      1,
      updatedAt,
      'slabbed',
      'CGC',
      '9.8 label',
      'Stan Lee',
      'Universal',
      'Newsstand',
      'White pages',
      '1234567',
      1,
      'First appearance',
      'Origin',
      'High',
      125,
      bagBoardDate,
    ]);
    await old.customStatement('''
      INSERT INTO $tableName (
        id, item_id, quantity, updated_at, features, hdr_formats_json,
        box_set_id, box_set_name, region, packaging, distributor
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      'owned-movie',
      'tv-legacy',
      1,
      updatedAt,
      'Director commentary',
      jsonEncode(['HDR10', 'Dolby Vision']),
      'box-1',
      'The Trilogy',
      'Region A',
      'Steelbook',
      'Criterion',
    ]);
    await old.customStatement('''
      INSERT INTO $tableName (
        id, item_id, quantity, updated_at, game_completeness, game_has_box,
        game_has_manual, game_price_charting_id, game_core_region,
        game_value_is_locked
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      'owned-game',
      'game-legacy',
      1,
      updatedAt,
      'Complete in box',
      1,
      1,
      'pc-123',
      'NTSC-U',
      1,
    ]);
    await old.customStatement(
      'DROP TABLE ${old.boardGameMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameEditionRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGamePlaySessionsRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 9');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final repository = OwnedItemsCacheRepository(db);

    final columns = await db
        .customSelect(
          'PRAGMA table_info(${db.ownedItemsCache.actualTableName})',
        )
        .get();
    final columnNames = columns
        .map((column) => column.data['name']?.toString())
        .whereType<String>()
        .toSet();
    expect(columnNames, containsAll(['kind', 'details_json']));
    expect(columnNames, isNot(contains('grading_company')));
    expect(columnNames, isNot(contains('features')));
    expect(columnNames, isNot(contains('game_completeness')));

    final comic = await repository.findById('owned-comic');
    final movie = await repository.findById('owned-movie');
    final game = await repository.findById('owned-game');
    expect(comic?.details, isA<ComicOwnedDetails>());
    expect((comic!.details as ComicOwnedDetails).gradingCompany, 'CGC');
    expect((comic.details as ComicOwnedDetails).keyComic, isTrue);
    expect((comic.details as ComicOwnedDetails).coverPriceCents, 125);
    expect(movie?.details, isA<TvOwnedDetails>());
    expect((movie!.details as TvOwnedDetails).hdrFormats,
        ['HDR10', 'Dolby Vision']);
    expect((movie.details as TvOwnedDetails).packaging, 'Steelbook');
    expect(game?.details, isA<GameOwnedDetails>());
    expect((game!.details as GameOwnedDetails).completeness, 'Complete in box');
    expect((game.details as GameOwnedDetails).priceChartingId, 'pc-123');
  });

  test('creates kind-owned details tables when migrating from v10', () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_v12');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await old.into(old.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-legacy',
            itemId: 'comic-legacy',
            kind: const Value('comic'),
            detailsJson: Value(jsonEncode({'key_comic': true})),
            updatedAt: DateTime.utc(2026, 5, 11),
          ),
        );
    await old.customStatement(
      'DROP TABLE ${old.comicOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.mangaMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.mangaOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.bookMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.bookReleaseRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.bookOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameReleaseRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameEditionRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGamePlaySessionsRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 10');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final owned = await db.select(db.ownedItemsCache).getSingle();
    final detailsRows = await db.select(db.comicOwnedDetailsRows).get();
    final mangaMediaRows = await db.select(db.mangaMediaRows).get();
    final mangaOwnedDetailsRows =
        await db.select(db.mangaOwnedDetailsRows).get();
    final bookMediaRows = await db.select(db.bookMediaRows).get();
    final bookReleaseRows = await db.select(db.bookReleaseRows).get();
    final bookOwnedDetailsRows = await db.select(db.bookOwnedDetailsRows).get();
    final gameMediaRows = await db.select(db.gameMediaRows).get();
    final gameReleaseRows = await db.select(db.gameReleaseRows).get();
    final gameOwnedDetailsRows = await db.select(db.gameOwnedDetailsRows).get();
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(owned.id, 'owned-legacy');
    expect(owned.detailsJson, jsonEncode({'key_comic': true}));
    expect(detailsRows, isEmpty);
    expect(mangaMediaRows, isEmpty);
    expect(mangaOwnedDetailsRows, isEmpty);
    expect(bookMediaRows, isEmpty);
    expect(bookReleaseRows, isEmpty);
    expect(bookOwnedDetailsRows, isEmpty);
    expect(gameMediaRows, isEmpty);
    expect(gameReleaseRows, isEmpty);
    expect(gameOwnedDetailsRows, isEmpty);
    expect(version.data.values.first, 30);
  });

  test('creates Book, Game, and BoardGame tables when migrating from v12',
      () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_v13');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await old.customStatement(
      'DROP TABLE ${old.bookMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.bookReleaseRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.bookOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameReleaseRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.gameOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameEditionRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGamePlaySessionsRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 12');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    expect(await db.select(db.bookMediaRows).get(), isEmpty);
    expect(await db.select(db.bookReleaseRows).get(), isEmpty);
    expect(await db.select(db.bookOwnedDetailsRows).get(), isEmpty);
    expect(await db.select(db.gameMediaRows).get(), isEmpty);
    expect(await db.select(db.gameReleaseRows).get(), isEmpty);
    expect(await db.select(db.gameOwnedDetailsRows).get(), isEmpty);
    expect(await db.select(db.boardGameMediaRows).get(), isEmpty);
    expect(await db.select(db.boardGameEditionRows).get(), isEmpty);
    expect(await db.select(db.boardGameOwnedDetailsRows).get(), isEmpty);
    expect(await db.select(db.boardGamePlaySessionsRows).get(), isEmpty);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 30);
  });

  test('creates BoardGame play-session table when migrating from v15',
      () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_v15');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await old.customStatement(
      'DROP TABLE ${old.boardGamePlaySessionsRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 15');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    expect(await db.select(db.boardGamePlaySessionsRows).get(), isEmpty);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 30);
  });

  test('creates BoardGame tables when migrating from v14', () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_v14');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await old.customStatement(
      'DROP TABLE ${old.boardGameMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameEditionRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.boardGameOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 14');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    expect(await db.select(db.boardGameMediaRows).get(), isEmpty);
    expect(await db.select(db.boardGameEditionRows).get(), isEmpty);
    expect(await db.select(db.boardGameOwnedDetailsRows).get(), isEmpty);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 30);
  });

  test('owned item repository round-trips opaque kind details', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = OwnedItemsCacheRepository(db);

    await repository.upsertAll([
      testOwnedItem(
        id: 'comic-round-trip',
        itemId: 'comic-round-trip-item',
        kind: 'comic',
        gradingCompany: 'CBCS',
        coverPriceCents: 399,
        keyComic: true,
      ),
      testOwnedItem(
        id: 'video-round-trip',
        itemId: 'video-round-trip-item',
        kind: 'tv',
        features: 'Commentary',
        hdrFormats: ['HDR10'],
        region: 'Region B',
      ),
      testOwnedItem(
        id: 'game-round-trip',
        itemId: 'game-round-trip-item',
        kind: 'game',
        gameCompleteness: 'CIB',
        gameHasBox: true,
        gamePriceChartingId: 'pc-456',
      ),
    ]);

    final rawRows = await db.select(db.ownedItemsCache).get();
    expect(rawRows.every((row) => row.detailsJson != null), isTrue);
    final restored = await repository.listActive();
    final byId = {for (final item in restored) item.id: item};
    expect((byId['comic-round-trip']!.details as ComicOwnedDetails).keyComic,
        isTrue);
    expect((byId['video-round-trip']!.details as TvOwnedDetails).region,
        'Region B');
    expect(
        (byId['game-round-trip']!.details as GameOwnedDetails).priceChartingId,
        'pc-456');

    await db.customStatement('''
      UPDATE ${db.ownedItemsCache.actualTableName}
      SET details_json = ?
      WHERE id = ?
    ''', ['not-json', 'comic-round-trip']);
    final malformed = await repository.findById('comic-round-trip');
    expect(malformed?.details, isA<ComicOwnedDetails>());
    expect((malformed!.details as ComicOwnedDetails).keyComic, isFalse);
  });

  test('creates Movie tables when migrating from v16', () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_v16');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await old.customStatement(
      'DROP TABLE ${old.movieMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.movieReleaseRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.movieOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.movieOwnedItemsRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 16');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    expect(await db.select(db.movieMediaRows).get(), isEmpty);
    expect(await db.select(db.movieReleaseRows).get(), isEmpty);
    expect(await db.select(db.movieOwnedDetailsRows).get(), isEmpty);
    expect(await db.select(db.movieOwnedItemsRows).get(), isEmpty);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 30);
  });

  test('backfills complete Movie owned rows when migrating from v27', () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_v27');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await old.into(old.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'movie-owned-legacy',
            itemId: 'movie-legacy',
            kind: const Value('movie'),
            condition: const Value('Near Mint'),
            grade: const Value('9.5'),
            purchaseDate: Value(DateTime.utc(2026, 6, 1)),
            pricePaidCents: const Value(2499),
            currency: const Value('USD'),
            quantity: const Value(2),
            detailsJson: Value(jsonEncode({
              'region': 'A',
              'packaging': 'SteelBook',
              'distributor': 'Warner Home Video',
            })),
            updatedAt: DateTime.utc(2026, 6, 2),
          ),
        );
    await old.customStatement(
      'DROP TABLE ${old.movieOwnedItemsRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 27');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final restored = await db.select(db.movieOwnedItemsRows).getSingle();
    expect(restored.id, 'movie-owned-legacy');
    expect(restored.itemId, 'movie-legacy');
    expect(restored.condition, 'Near Mint');
    expect(restored.grade, '9.5');
    expect(restored.purchaseDate?.toUtc(), DateTime.utc(2026, 6, 1));
    expect(restored.pricePaidCents, 2499);
    expect(restored.currency, 'USD');
    expect(restored.quantity, 2);
    expect(restored.region, 'A');
    expect(restored.packaging, 'SteelBook');
    expect(restored.distributor, 'Warner Home Video');
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 30);
  });

  test('creates Anime tables when migrating from v19', () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_v19');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await old.customStatement(
      'DROP TABLE ${old.animeMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.animeEpisodeRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.animeReleaseRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.animeOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.animeOwnedItemsRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.animeTrackingRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 19');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    expect(await db.select(db.animeMediaRows).get(), isEmpty);
    expect(await db.select(db.animeEpisodeRows).get(), isEmpty);
    expect(await db.select(db.animeReleaseRows).get(), isEmpty);
    expect(await db.select(db.animeOwnedDetailsRows).get(), isEmpty);
    expect(await db.select(db.animeOwnedItemsRows).get(), isEmpty);
    expect(await db.select(db.animeTrackingRows).get(), isEmpty);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 30);
  });

  test('backfills complete TV owned rows when migrating from v29', () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_v29_tv');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await old.into(old.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'tv-owned-legacy',
            itemId: 'tv-legacy',
            kind: const Value('tv'),
            condition: const Value('Very Good'),
            grade: const Value('8.5'),
            personalNotes: const Value('Complete seasons'),
            quantity: const Value(1),
            detailsJson: Value(jsonEncode({
              'region': 'B',
              'packaging': 'Amaray',
              'distributor': 'BBC Studios',
            })),
            updatedAt: DateTime.utc(2026, 7, 2),
          ),
        );
    await old.customStatement(
      'DROP TABLE ${old.tvOwnedItemsRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 29');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final restored = await db.select(db.tvOwnedItemsRows).getSingle();
    expect(restored.id, 'tv-owned-legacy');
    expect(restored.itemId, 'tv-legacy');
    expect(restored.condition, 'Very Good');
    expect(restored.grade, '8.5');
    expect(restored.personalNotes, 'Complete seasons');
    expect(restored.region, 'B');
    expect(restored.packaging, 'Amaray');
    expect(restored.distributor, 'BBC Studios');
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 30);
  });

  test('creates Music tables when migrating from v20', () async {
    final dir =
        await Directory.systemTemp.createTemp('collectarr_db_v20_music');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    final old = LocalDatabase(NativeDatabase(file));
    await _insertLegacyCatalogItem(
      old,
      id: 'music-1',
      kind: 'music',
      payload: {'id': 'music-1', 'title': 'Preserved'},
    );
    await old.customStatement(
      'DROP TABLE ${old.musicReleaseRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.musicMediaRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.musicTrackRows.actualTableName}',
    );
    await old.customStatement(
      'DROP TABLE ${old.musicOwnedDetailsRows.actualTableName}',
    );
    await old.customStatement('PRAGMA user_version = 20');
    await old.close();

    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    expect(
        (await db.select(db.musicReleaseRows).get()).single.title, 'Preserved');
    expect(await db.select(db.musicMediaRows).get(), isEmpty);
    expect(await db.select(db.musicTrackRows).get(), isEmpty);
    expect(await db.select(db.musicOwnedDetailsRows).get(), isEmpty);
    expect(
        await LibraryCatalogRepository(db).findById('music-1') != null, isTrue);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 30);
  });

  test('destructively rebuilds a higher-versioned cache to the v30 schema',
      () async {
    final dir = await Directory.systemTemp.createTemp('collectarr_db_reset');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cache.sqlite');

    // Simulate a cache created by an older build: a populated table plus a
    // higher on-disk schema version that Drift will not run onUpgrade for.
    final old = LocalDatabase(NativeDatabase(file));
    await _insertLegacyCatalogItem(
      old,
      id: 'comic-1',
      kind: 'comic',
      payload: {
        'id': 'comic-1',
        'kind': 'comic',
        'title': 'Stale Cached Title',
      },
    );
    await old.customStatement('PRAGMA user_version = 28');
    await old.close();

    // Reopening with the reset schema version must wipe and recreate the cache.
    final db = LocalDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final rows = await LibraryCatalogRepository(db).findAll();
    expect(rows, isEmpty, reason: 'destructive rebuild should clear the cache');

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 30);
  });

  test('stores personal collection and wishlist data locally', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'comic-1',
            condition: const Value('Near Mint'),
            grade: const Value('9.8'),
            purchaseDate: Value(DateTime.utc(2026, 5, 11)),
            pricePaidCents: const Value(1299),
            currency: const Value('USD'),
            quantity: const Value(2),
            locationId: const Value('loc-box-6'),
            detailsJson: Value(jsonEncode({'key_comic': true})),
            tags: const Value('signed,key'),
            updatedAt: DateTime.utc(2026, 5, 11),
          ),
        );
    await db.into(db.wishlistItemsCache).insert(
          WishlistItemsCacheCompanion.insert(
            id: 'wish-1',
            itemId: 'comic-2',
            targetPriceCents: const Value(999),
            currency: const Value('USD'),
            createdAt: DateTime.utc(2026, 5, 11),
            updatedAt: DateTime.utc(2026, 5, 11),
          ),
        );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    final wishlist = await db.select(db.wishlistItemsCache).getSingle();

    expect(owned.itemId, 'comic-1');
    expect(owned.purchaseDate?.toUtc(), DateTime.utc(2026, 5, 11));
    expect(owned.pricePaidCents, 1299);
    expect(owned.quantity, 2);
    expect(owned.locationId, 'loc-box-6');
    final ownedDetails = jsonDecode(owned.detailsJson!) as Map<String, dynamic>;
    expect(ownedDetails['key_comic'], isTrue);
    expect(owned.tags, 'signed,key');
    expect(wishlist.itemId, 'comic-2');
    expect(wishlist.targetPriceCents, 999);
  });

  test('stores tracking entries separately from owned copies', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.trackingEntriesCache).insert(
          TrackingEntriesCacheCompanion.insert(
            id: 'track-1',
            itemId: 'movie-1',
            sourceType: const Value('digital'),
            status: const Value('Watched'),
            rating: const Value(9),
            startedAt: Value(DateTime.utc(2026, 5, 23, 18)),
            finishedAt: Value(DateTime.utc(2026, 5, 23, 20, 35)),
            timesCompleted: const Value(1),
            notes: const Value('Watched on Plex'),
            updatedAt: DateTime.utc(2026, 5, 23, 20, 35),
          ),
        );

    final tracking = await db.select(db.trackingEntriesCache).getSingle();

    expect(tracking.itemId, 'movie-1');
    expect(tracking.sourceType, 'digital');
    expect(tracking.status, 'Watched');
    expect(tracking.rating, 9);
    expect(tracking.notes, 'Watched on Plex');
  });

  test('owned items repository preserves location ids', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = OwnedItemsCacheRepository(db);

    await repo.upsert(
      testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        catalogRef: CatalogEntityRef(
          kind: 'comic',
          entityType: CatalogEntityType.work,
          id: 'comic-1',
        ),
        createdAt: DateTime.utc(2026, 5, 21),
        ownerUserId: 'user-1',
        ownerLabel: 'user@example.com',
        locationId: 'loc-1',
        updatedAt: DateTime.utc(2026, 5, 22),
      ),
    );

    final owned = await repo.findById('owned-1');
    final raw = await db.select(db.ownedItemsCache).getSingle();

    expect(owned?.locationId, 'loc-1');
    expect(owned?.createdAt?.toUtc(), DateTime.utc(2026, 5, 21));
    expect(owned?.ownerUserId, 'user-1');
    expect(owned?.ownerLabel, 'user@example.com');
    expect(raw.locationId, 'loc-1');
    expect(raw.createdAt?.toUtc(), DateTime.utc(2026, 5, 21));
    expect(raw.ownerUserId, 'user-1');
    expect(raw.ownerLabel, 'user@example.com');
  });

  test('owned items repository preserves explicit digital flag', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = OwnedItemsCacheRepository(db);

    await repo.upsert(
      testOwnedItem(
        id: 'owned-digital-1',
        itemId: 'movie-1',
        catalogRef: CatalogEntityRef(
          kind: 'movie',
          entityType: CatalogEntityType.work,
          id: 'movie-1',
        ),
        isDigital: true,
        updatedAt: DateTime.utc(2026, 5, 22),
      ),
    );

    final owned = await repo.findById('owned-digital-1');
    final raw = await db.select(db.ownedItemsCache).getSingle();

    expect(owned?.isDigital, isTrue);
    expect(raw.isDigital, isTrue);
  });

  test('tracking entries repository preserves edition and progress refs',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = TrackingEntriesCacheRepository(
      db,
      codecs: collectarrTrackingEntryCodecs,
    );

    await repo.upsert(
      TrackingEntry(
        id: 'track-1',
        catalogRef: testCatalogRef('music-1', kind: 'music'),
        editionId: 'edition-cd',
        variantId: 'variant-deluxe',
        sourceType: 'physical',
        status: 'Listened',
        progressCurrent: 10,
        progressTotal: 10,
        timesCompleted: 2,
        updatedAt: DateTime.utc(2026, 5, 23, 22),
      ),
    );

    final tracking = await repo.findById('track-1');
    final raw = await db.select(db.trackingEntriesCache).getSingle();

    expect(tracking?.editionId, 'edition-cd');
    expect(tracking?.variantId, 'variant-deluxe');
    expect(tracking?.timesCompleted, 2);
    expect(raw.progressCurrent, 10);
    expect(raw.progressTotal, 10);
  });

  test('stores pending personal sync changes locally', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final queue = SyncQueueRepository(db);

    await queue.enqueue(
      SyncChange(
        id: 'sync-1',
        entityType: 'owned_item',
        entityId: 'owned-1',
        action: 'upsert',
        payload: const {'item_id': 'comic-1', 'grade': '9.8'},
        clientChangedAt: DateTime.utc(2026, 5, 11, 10),
      ),
    );

    expect(await queue.pendingCount(), 1);
    final pending = await queue.listPending();
    expect(pending.single.entityType, 'owned_item');
    expect(pending.single.payload['grade'], '9.8');

    await queue.deleteMany(['sync-1']);
    expect(await queue.pendingCount(), 0);
  });

  test('keeps only latest pending sync change per entity', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final queue = SyncQueueRepository(db);

    await queue.enqueue(
      SyncChange(
        id: 'sync-1',
        entityType: 'owned_item',
        entityId: 'owned-1',
        action: 'upsert',
        payload: const {'item_id': 'comic-1', 'grade': '9.8'},
        clientChangedAt: DateTime.utc(2026, 5, 11, 10),
      ),
    );
    await queue.enqueue(
      SyncChange(
        id: 'sync-2',
        entityType: 'owned_item',
        entityId: 'owned-1',
        action: 'upsert',
        payload: const {'item_id': 'comic-1', 'grade': '9.6'},
        clientChangedAt: DateTime.utc(2026, 5, 11, 11),
      ),
    );

    expect(await queue.pendingCount(), 1);
    final pending = await queue.listPending();
    expect(pending.single.id, 'sync-2');
    expect(pending.single.payload['grade'], '9.6');
  });

  test('deletes large sync queue batches without exceeding SQLite variables',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final queue = SyncQueueRepository(db);
    final ids = [for (var index = 0; index < 1005; index++) 'sync-$index'];

    for (final id in ids) {
      await queue.enqueue(
        SyncChange(
          id: id,
          entityType: 'owned_item',
          entityId: 'owned-$id',
          action: 'upsert',
          payload: const {'item_id': 'comic-1'},
          clientChangedAt: DateTime.utc(2026, 5, 11),
        ),
      );
    }

    expect(await queue.pendingCount(), 1005);
    await queue.deleteMany(ids);
    expect(await queue.pendingCount(), 0);
  });

  test('catalog cache repository preserves title sort and series tags',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = LibraryCatalogRepository(db);

    await repo.upsertMetadataItems([
      typedCatalogItemFromMap({
        'id': 'book-1',
        'kind': 'book',
        'title': 'The Fellowship of the Ring',
        'sort_key': 'lord-of-the-rings-001',
        'series': {
          'series_id': 'series-1',
          'series_title': 'The Lord of the Rings',
          'volume_number': '1',
          'tags': 'Epic Fantasy, Middle-earth',
        },
        'publishing': {
          'subtitle': 'Being the First Part',
        },
      }),
    ]);

    final item = await repo.findById('book-1');

    expect(item, isA<CatalogItem>());
    expect(item!.sortKey, 'lord-of-the-rings-001');
    final seriesMap =
        item.payload['series'] is Map ? item.payload['series'] as Map : null;
    expect(seriesMap?['tags'], 'Epic Fantasy, Middle-earth');
    final pubMap = item.payload['publishing'] is Map
        ? item.payload['publishing'] as Map
        : null;
    expect(pubMap?['subtitle'], 'Being the First Part');
  });

  test('catalog cache repository preserves editions and variants', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = LibraryCatalogRepository(db);

    await repo.upsertMetadataItems([
      typedCatalogItemFromMap({
        'id': 'album-1',
        'kind': 'music',
        'title': 'The Sacrament of Sin',
        'editions': [
          {
            'id': 'edition-deluxe',
            'title': 'Deluxe Box',
            'variants': [
              {
                'id': 'variant-red',
                'name': 'Red Vinyl',
                'is_primary': true,
              },
            ],
          },
        ],
      }),
    ]);

    final item = await repo.findById('album-1');

    expect(item?.editions, hasLength(1));
    expect(item?.editions.single.id, 'edition-deluxe');
    expect(item?.editions.single.variants.single.id, 'variant-red');
  });
}

Future<void> _replaceOwnedItemsWithV9Schema(LocalDatabase db) async {
  final tableName = db.ownedItemsCache.actualTableName;
  final currentTableName = '${tableName}_v10';
  await db.customStatement(
    'ALTER TABLE $tableName RENAME TO $currentTableName',
  );
  const universalColumns = [
    'id',
    'item_id',
    'created_at',
    'is_digital',
    'anchor_type',
    'edition_id',
    'variant_id',
    'bundle_release_id',
    'condition',
    'grade',
    'purchase_date',
    'price_paid_cents',
    'currency',
    'personal_notes',
    'quantity',
    'index_number',
    'rating',
    'read_status',
    'started_at',
    'finished_at',
    'tags',
    'updated_at',
    'deleted_at',
    'sold_at',
    'sell_price_cents',
    'sold_to',
    'owner_user_id',
    'owner_label',
    'location_id',
    'purchase_store',
    'collection_status',
    'market_value_cents',
  ];
  await db.customStatement('''
    CREATE TABLE $tableName AS
    SELECT ${universalColumns.join(', ')}
    FROM $currentTableName
    WHERE 0
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN raw_or_slabbed TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN grading_company TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN grader_notes TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN signed_by TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN label_type TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN custom_label TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN page_quality TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN certification_number TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN key_comic INTEGER NOT NULL DEFAULT 0
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN key_reason TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN key_category TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN key_severity TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN cover_price_cents INTEGER
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN features TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN hdr_formats_json TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN box_set_id TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN box_set_name TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN storage_device TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN storage_slot TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN region TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN packaging TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN distributor TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN last_bag_board_date INTEGER
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN game_completeness TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN game_has_box INTEGER
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN game_has_manual INTEGER
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN game_price_charting_id TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN game_core_region TEXT
  ''');
  await db.customStatement('''
    ALTER TABLE $tableName ADD COLUMN game_value_is_locked INTEGER
  ''');
  await db.customStatement('DROP TABLE $currentTableName');
}

Future<void> _insertLegacyCatalogItem(
  LocalDatabase db, {
  required String id,
  required String kind,
  required Map<String, dynamic> payload,
}) async {
  await db.customStatement('''
    CREATE TABLE IF NOT EXISTS catalog_cache (
      id TEXT NOT NULL PRIMARY KEY,
      kind TEXT NOT NULL,
      payload_json TEXT NOT NULL,
      cached_at INTEGER NOT NULL
    )
  ''');
  await db.customStatement(
    'INSERT OR REPLACE INTO catalog_cache '
    '(id, kind, payload_json, cached_at) VALUES (?, ?, ?, ?)',
    [id, kind, jsonEncode(payload), 0],
  );
}
