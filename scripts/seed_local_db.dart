import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/dev/dev_seed.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  const resetFromBuild = bool.fromEnvironment('COLLECTARR_SEED_RESET');
  if (args.contains('--reset') || resetFromBuild) {
    await _resetLocalDatabaseFile();
  }

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
      'by_kind=${_formatCounts(
        devSeedCatalogCounts.map(
          (kind, count) => MapEntry(kind.apiValue, count),
        ),
      )}',
    );
  } finally {
    await db.close();
  }

  exit(0);
}

Future<void> _resetLocalDatabaseFile() async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final databasePath = p.join(documentsDirectory.path, 'collectarr.sqlite');
  for (final suffix in ['', '-wal', '-shm']) {
    final file = File('$databasePath$suffix');
    if (await file.exists()) {
      await file.delete();
      stdout.writeln('Removed ${file.path}');
    }
  }
}

String _formatCounts(Map<String, int> counts) {
  return counts.entries.map((entry) => '${entry.key}:${entry.value}').join(',');
}
