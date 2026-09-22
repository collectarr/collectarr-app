import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_state.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  testWidgets('TV tracking extension owns episode coordinate editing', (
    tester,
  ) async {
    final entry = TvTrackingState(
      id: 'tv-tracking-1',
      catalogRef: testCatalogRef('tv-1', kind: 'tv'),
      coordinates: TvTrackingCoordinates(
        seasonNumber: 1,
        episodeNumber: 2,
      ),
      updatedAt: DateTime.utc(2026, 6, 1),
    );
    TrackingStateEditMutation? mutation;
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final summary = TrackingSummary(
      id: entry.id,
      catalogRef: entry.catalogRef,
      status: entry.status ?? MediaTrackingStatus.planned,
      updatedAt: entry.updatedAt,
      progress: entry.progress,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => tvKindInspector.trackingEditor!.build(
                context,
                summary: summary,
                onChanged: (value) => mutation = value,
                accent: Colors.teal,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Episode tracking'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.enterText(find.byType(TextField).at(0), '3');
    await tester.enterText(find.byType(TextField).at(1), '4');

    expect(mutation, isNotNull);
    final patch = mutation! as TvTrackingCoordinatesPatch;
    final updated = entry.copyWithCoordinates(
      seasonNumber: patch.seasonNumber,
      episodeNumber: patch.episodeNumber,
    );
    expect(updated.coordinates.seasonNumber, 3);
    expect(updated.coordinates.episodeNumber, 4);
  });

  testWidgets('Anime tracking extension owns episode coordinate editing', (
    tester,
  ) async {
    final entry = AnimeTrackingState(
      id: 'anime-tracking-1',
      catalogRef: testCatalogRef('anime-1', kind: 'anime'),
      coordinates: AnimeTrackingCoordinates(),
      updatedAt: DateTime.utc(2026, 6, 1),
    );
    TrackingStateEditMutation? mutation;
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final summary = TrackingSummary(
      id: entry.id,
      catalogRef: entry.catalogRef,
      status: entry.status ?? MediaTrackingStatus.planned,
      updatedAt: entry.updatedAt,
      progress: entry.progress,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => animeKindInspector.trackingEditor!.build(
                context,
                summary: summary,
                onChanged: (value) => mutation = value,
                accent: Colors.purple,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Episode tracking'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.enterText(find.byType(TextField).at(0), '0');
    await tester.enterText(find.byType(TextField).at(1), '7');

    expect(mutation, isNotNull);
    final patch = mutation! as AnimeTrackingCoordinatesPatch;
    final updated = entry.copyWithCoordinates(
      seasonNumber: patch.seasonNumber,
      episodeNumber: patch.episodeNumber,
    );
    expect(updated.coordinates.seasonNumber, 0);
    expect(updated.coordinates.episodeNumber, 7.0);
  });
}
