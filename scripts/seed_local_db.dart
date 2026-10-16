import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/dev/dev_seed.dart';

/// Seeds the development fixture into an explicitly named, isolated database.
///
/// flutter run -d windows -t scripts/seed_local_db.dart
/// --dart-define=COLLECTARR_SEED_DB=C:/path/dev-library.sqlite
///
/// The application's own database is never opened, reset or replaced.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const path = String.fromEnvironment('COLLECTARR_SEED_DB');
  if (path.isEmpty) {
    throw ArgumentError('COLLECTARR_SEED_DB must name an isolated database.');
  }
  if (File(path).uri.pathSegments.last == 'collectarr-library.sqlite') {
    throw ArgumentError('Refusing to seed the application database file.');
  }

  final db = LocalDatabase(NativeDatabase(File(path)));
  try {
    await seedLocalDatabase(db, force: true);
    final report = await verifyDevSeedDatabase(db);

    stdout.writeln(
      'Seeded $path. catalog_items=${report.catalogCount} '
      'seed_catalog_items=${report.seededCatalogCount} '
      'library_entries=${report.entryCount} tracking_entries=${report.trackingCount} '
      'item_images_cache=${report.imageCount} '
      'typed_graph=${_formatCounts(report.typedGraphCounts)} '
      'typed_entries=${_formatCounts(report.typedEntryCounts)} '
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

String _formatCounts(Map<String, int> counts) {
  return counts.entries.map((entry) => '${entry.key}:${entry.value}').join(',');
}
