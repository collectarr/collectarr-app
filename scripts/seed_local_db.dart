import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/dev/dev_seed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = LocalDatabase();
  try {
    await seedLocalDatabase(db, force: true);
    final report = await verifyDevSeedDatabase(db);

    stdout.writeln(
      'Local DB seeded. catalog_items=${report.catalogCount} '
      'seed_catalog_items=${report.seededCatalogCount} '
      'owned_items=${report.ownedCount} tracking_entries=${report.trackingCount} '
      'item_images_cache=${report.imageCount} '
      'typed_graph=${_formatCounts(report.typedGraphCounts)} '
      'typed_owned=${_formatCounts(report.typedOwnedCounts)} '
      'typed_tracking=${_formatCounts(report.typedTrackingCounts)} '
      'typed_tracking_units=${_formatCounts(report.typedTrackingUnitCounts)} '
      'auxiliary=${_formatCounts(report.auxiliaryCounts)} '
      'by_kind=${_formatCounts(devSeedCatalogCounts)}',
    );
  } finally {
    await db.close();
  }

  exit(0);
}

String _formatCounts(Map<String, int> counts) {
  return counts.entries.map((entry) => '${entry.key}:${entry.value}').join(',');
}
