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

    final catalogCount = (await LibraryCatalogRepository(db).findAll()).length;
    final imageCount = (await db.select(db.itemImagesCache).get()).length;

    stdout.writeln(
      'Local DB seeded. catalog_items=$catalogCount item_images_cache=$imageCount',
    );
  } finally {
    await db.close();
  }

  exit(0);
}
