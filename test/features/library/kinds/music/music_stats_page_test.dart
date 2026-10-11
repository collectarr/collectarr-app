import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/dev/seeds/music_inspector_reference_seed.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/stats/music_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/stats/music_stats_page.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_constants.dart';

void main() {
  testWidgets(
      'statistics deduplicate disc formats and scope every section to collection',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fixture = jsonDecode(
        File('tool/fixtures/music_inspector_reference.json')
            .readAsStringSync()) as Map<String, dynamic>;
    final catalog = fixture['catalog'] as Map;
    catalog.remove('cover_image_url');
    catalog.remove('thumbnail_image_url');
    catalog.remove('back_cover_image_url');
    (catalog['discs'] as List).add({
      ...(catalog['discs'] as List).single as Map,
      'id': '23b4c0a3-9f68-4f39-8d4d-22402c2c45c8',
      'disc_number': 2,
      'tracks': <Object>[],
      'credits': <Object>[]
    });
    final entry = await seedMusicInspectorReference(db, fixture);
    final summary = MusicLibraryEntryProjection.toSummary(entry);
    final state = ShelfState.from(entrySummaries: [
      summary
    ], wishlistItems: [], libraryEntryDispatchesByRef: {
      summary.ref: OpaqueLibraryEntryDispatch(
          ref: summary.ref, kind: CatalogMediaKind.music, value: entry)
    }, kindPresentationByEntryRef: {
      summary.ref: MusicWorkspaceData.fromMusic(entry.metadata)
    });
    expect(MusicStatsCapability.countFormats(state.entries), {'Vinyl': 1});
    expect(entry.metadata.formatSummary, contains('2'));
    final collections = LibraryCollectionRepository(db);
    await collections.assignNewEntry(
        LibraryEntryRef(kind: CatalogMediaKind.music, id: entry.id));
    await collections.create('music', 'Empty reference');
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: MusicStatsPage(state: state))));
    await pumpUntilSettled(tester);
    expect(find.text('2 albums and 1 Artists'), findsOneWidget);
    expect(find.text('Albums by Format'), findsOneWidget);
    await tester.tap(find.text('Empty reference'));
    await pumpUntilSettled(tester);
    expect(find.text('0 albums and 0 Artists'), findsOneWidget);
    expect(find.text(entry.metadata.title), findsNothing);
    await tester.tap(find.text('All Collections'));
    await pumpUntilSettled(tester);
    expect(find.text('2 albums and 1 Artists'), findsOneWidget);
    for (final width in [700.0, 380.0]) {
      await tester.binding.setSurfaceSize(Size(width, 850));
      await pumpUntilSettled(tester);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
