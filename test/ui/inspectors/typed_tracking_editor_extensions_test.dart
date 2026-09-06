import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  testWidgets('TV tracking extension owns episode coordinate editing', (
    tester,
  ) async {
    final entry = TrackingEntry(
      id: 'tv-tracking-1',
      catalogRef: testCatalogRef('tv-1', kind: 'tv'),
      seasonNumber: 1,
      episodeNumber: 2,
      updatedAt: DateTime.utc(2026, 6, 1),
    );
    TrackingEntryEditMutation? mutation;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => tvKindModule.inspector.trackingEditor!.build(
              context,
              entry: entry,
              onChanged: (value) => mutation = value,
              accent: Colors.teal,
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
    final updated = mutation!(entry);
    expect(updated.seasonNumber, 3);
    expect(updated.episodeNumber, 4);
  });

  testWidgets('Anime tracking extension owns episode coordinate editing', (
    tester,
  ) async {
    final entry = TrackingEntry(
      id: 'anime-tracking-1',
      catalogRef: testCatalogRef('anime-1', kind: 'anime'),
      updatedAt: DateTime.utc(2026, 6, 1),
    );
    TrackingEntryEditMutation? mutation;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) =>
                animeKindModule.inspector.trackingEditor!.build(
              context,
              entry: entry,
              onChanged: (value) => mutation = value,
              accent: Colors.purple,
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
    final updated = mutation!(entry);
    expect(updated.seasonNumber, 0);
    expect(updated.episodeNumber, 7);
  });
}
