import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/dev/dev_seed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = LocalDatabase();
  try {
    await seedLocalDatabase(db, force: true);

    final catalogCountExpr = countAll();
    final catalogRow = await (db.selectOnly(db.catalogCache)
          ..addColumns([catalogCountExpr]))
        .getSingle();
    final catalogCount = catalogRow.read(catalogCountExpr) ?? 0;

    final imageCountExpr = countAll();
    final imageRow = await (db.selectOnly(db.itemImagesCache)
          ..addColumns([imageCountExpr]))
        .getSingle();
    final imageCount = imageRow.read(imageCountExpr) ?? 0;

    stdout.writeln(
      'Local DB seeded. catalog_cache=$catalogCount item_images_cache=$imageCount',
    );
  } finally {
    await db.close();
  }

  exit(0);
}
