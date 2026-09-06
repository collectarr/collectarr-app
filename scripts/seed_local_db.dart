import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/dev/dev_seed.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = LocalDatabase();
  try {
    await seedLocalDatabase(db, force: true);

    final catalogRows = await LibraryCatalogRepository(db).findAll();
    final catalogCount = catalogRows.length;
    final ownedRows = await db.select(db.ownedItemsCache).get();
    if (ownedRows.any((row) =>
        row.rating != null ||
        row.readStatus != null ||
        row.startedAt != null ||
        row.finishedAt != null)) {
      throw StateError(
        'Seed verification failed: tracking fields must be stored in '
        'tracking_entries_cache, not owned_items_cache',
      );
    }
    final ownedIds = ownedRows.map((row) => row.id).toSet();
    final customFieldValueRows =
        await db.select(db.customFieldValuesCache).get();
    if (customFieldValueRows.any((row) => !ownedIds.contains(row.targetId))) {
      throw StateError(
        'Seed verification failed: a custom-field value targets a missing '
        'owned item',
      );
    }
    final trackingRows = await db.select(db.trackingEntriesCache).get();
    final imageCount = (await db.select(db.itemImagesCache).get()).length;
    final comicOwnedCount =
        (await db.select(db.comicOwnedItemsRows).get()).length;
    final comicReadingCount =
        (await db.select(db.comicReadingRows).get()).length;
    final typedGraphCounts = await devSeedTypedGraphCounts(db);
    for (final entry in devSeedTypedGraphMinimumCounts.entries) {
      final actual = typedGraphCounts[entry.key] ?? 0;
      if (actual < entry.value) {
        throw StateError(
          'Seed verification failed for typed graph ${entry.key}: expected '
          'at least ${entry.value}, found $actual',
        );
      }
    }
    final typedGraphIntegrityIssues =
        await devSeedTypedGraphIntegrityIssues(db);
    if (typedGraphIntegrityIssues.isNotEmpty) {
      throw StateError(
        'Seed verification failed for typed graph relationships:\n'
        '${typedGraphIntegrityIssues.map((issue) => '- $issue').join('\n')}',
      );
    }
    final typedOwnedIntegrityIssues =
        await devSeedTypedOwnedIntegrityIssues(db);
    if (typedOwnedIntegrityIssues.isNotEmpty) {
      throw StateError(
        'Seed verification failed for kind-owned rows:\n'
        '${typedOwnedIntegrityIssues.map((issue) => '- $issue').join('\n')}',
      );
    }
    final typedOwnedCounts = await devSeedTypedOwnedCounts(db);
    for (final entry in devSeedTypedOwnedMinimumCounts.entries) {
      final actual = typedOwnedCounts[entry.key] ?? 0;
      if (actual < entry.value) {
        throw StateError(
          'Seed verification failed for typed owned data ${entry.key}: '
          'expected at least ${entry.value}, found $actual',
        );
      }
    }
    final typedTrackingCounts = await devSeedTypedTrackingCounts(db);
    for (final entry in devSeedTypedTrackingMinimumCounts.entries) {
      final actual = typedTrackingCounts[entry.key] ?? 0;
      if (actual < entry.value) {
        throw StateError(
          'Seed verification failed for typed tracking ${entry.key}: '
          'expected at least ${entry.value}, found $actual',
        );
      }
    }
    final typedTrackingUnitCounts = await devSeedTypedTrackingUnitCounts(db);
    for (final entry in devSeedTypedTrackingUnitMinimumCounts.entries) {
      final actual = typedTrackingUnitCounts[entry.key] ?? 0;
      if (actual < entry.value) {
        throw StateError(
          'Seed verification failed for typed tracking units ${entry.key}: '
          'expected at least ${entry.value}, found $actual',
        );
      }
    }
    final auxiliaryCounts = await devSeedAuxiliaryCounts(db);
    for (final entry in devSeedAuxiliaryMinimumCounts.entries) {
      final actual = auxiliaryCounts[entry.key] ?? 0;
      if (actual < entry.value) {
        throw StateError(
          'Seed verification failed for auxiliary data ${entry.key}: '
          'expected at least ${entry.value}, found $actual',
        );
      }
    }

    final seededCatalogCount =
        catalogRows.where((row) => row.id.startsWith('seed-')).length;
    final expectedSeedCount =
        devSeedCatalogCounts.values.fold<int>(0, (sum, count) => sum + count);
    if (seededCatalogCount != expectedSeedCount) {
      throw StateError(
        'Seed verification failed: expected $expectedSeedCount '
        'seed catalog rows, found $seededCatalogCount',
      );
    }
    for (final entry in devSeedCatalogCounts.entries) {
      final catalogKindCount = catalogRows
          .where((row) => row.id.startsWith('seed-') && row.kind == entry.key)
          .length;
      if (catalogKindCount != entry.value) {
        throw StateError(
          'Seed verification failed for ${entry.key}: expected '
          '${entry.value} catalog rows, found $catalogKindCount',
        );
      }
    }

    final seededOwnedCount =
        ownedRows.where((row) => row.itemId.startsWith('seed-')).length;
    final seededTrackingCount =
        trackingRows.where((row) => row.itemId.startsWith('seed-')).length;
    if (seededOwnedCount != expectedSeedCount ||
        seededTrackingCount != expectedSeedCount) {
      throw StateError(
        'Seed verification failed: expected $expectedSeedCount owned and '
        'tracking rows, found $seededOwnedCount owned and '
        '$seededTrackingCount tracking rows',
      );
    }
    for (final entry in devSeedCatalogCounts.entries) {
      final ownedKindCount = ownedRows
          .where((row) => row.itemId.startsWith('seed-${entry.key}-'))
          .length;
      final trackingKindCount = trackingRows
          .where((row) => row.itemId.startsWith('seed-${entry.key}-'))
          .length;
      if (ownedKindCount != entry.value || trackingKindCount != entry.value) {
        throw StateError(
          'Seed verification failed for ${entry.key}: expected '
          '${entry.value} owned/tracking rows, found '
          '$ownedKindCount/$trackingKindCount',
        );
      }
    }

    stdout.writeln(
      'Local DB seeded. catalog_items=$catalogCount '
      'seed_catalog_items=$seededCatalogCount '
      'owned_items=${ownedRows.length} tracking_entries=${trackingRows.length} '
      'item_images_cache=$imageCount '
      'comic_owned_items=$comicOwnedCount comic_reading_rows=$comicReadingCount '
      'typed_graph=${typedGraphCounts.entries.map((entry) => '${entry.key}:${entry.value}').join(',')} '
      'typed_owned=${typedOwnedCounts.entries.map((entry) => '${entry.key}:${entry.value}').join(',')} '
      'typed_tracking=${typedTrackingCounts.entries.map((entry) => '${entry.key}:${entry.value}').join(',')} '
      'typed_tracking_units=${typedTrackingUnitCounts.entries.map((entry) => '${entry.key}:${entry.value}').join(',')} '
      'auxiliary=${auxiliaryCounts.entries.map((entry) => '${entry.key}:${entry.value}').join(',')} '
      'by_kind=${devSeedCatalogCounts.entries.map((entry) => '${entry.key}:${entry.value}').join(',')}',
    );
  } finally {
    await db.close();
  }

  exit(0);
}
