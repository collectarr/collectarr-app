import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/dev/seeds/music_inspector_reference_seed.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';

/// flutter run -d windows -t scripts/seed_music_comparison.dart
/// --dart-define=COLLECTARR_REFERENCE_DB=C:/path/comparison.sqlite
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const path = String.fromEnvironment('COLLECTARR_REFERENCE_DB');
  if (path.isEmpty) {
    throw ArgumentError(
        'COLLECTARR_REFERENCE_DB must name the target database.');
  }
  final fixture = jsonDecode(
    await File('tool/fixtures/music_inspector_reference.json').readAsString(),
  ) as Map<String, dynamic>;
  final database = LocalDatabase(NativeDatabase(File(path)));
  try {
    final entry = await seedMusicInspectorReference(database, fixture, images: {
      'front_cover':
          await File('tool/fixtures/music-inspector-front.png').readAsBytes(),
      'back_cover':
          await File('tool/fixtures/music-inspector-back.png').readAsBytes(),
      'personal:booklet':
          await File('tool/fixtures/music-inspector-back.png').readAsBytes(),
    });
    stdout
        .writeln('Seeded ${entry.id.value}: ${entry.metadata.title} in $path');
  } finally {
    await database.close();
  }
  exit(0);
}
