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
    final trackingRows = await db.select(db.trackingEntriesCache).get();
    final imageCount = (await db.select(db.itemImagesCache).get()).length;
    final comicOwnedCount =
        (await db.select(db.comicOwnedItemsRows).get()).length;
    final comicReadingCount =
        (await db.select(db.comicReadingRows).get()).length;

    final seededCatalogCount =
        catalogRows.where((row) => row.id.startsWith('seed-')).length;
    if (seededCatalogCount !=
        devSeedCatalogCounts.values.fold<int>(0, (sum, count) => sum + count)) {
      throw StateError(
        'Seed verification failed: expected ${devSeedCatalogCounts.values.fold<int>(0, (sum, count) => sum + count)} '
        'seed catalog rows, found $seededCatalogCount',
      );
    }

    stdout.writeln(
      'Local DB seeded. catalog_items=$catalogCount '
      'seed_catalog_items=$seededCatalogCount '
      'owned_items=${ownedRows.length} tracking_entries=${trackingRows.length} '
      'item_images_cache=$imageCount '
      'comic_owned_items=$comicOwnedCount comic_reading_rows=$comicReadingCount',
    );
  } finally {
    await db.close();
  }

  exit(0);
}
