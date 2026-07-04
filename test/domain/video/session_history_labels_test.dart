import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/kinds/video/watch_history_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sessionHistoryLabelsForKind', () {
    test('reading kinds map to read labels', () {
      for (final kind in ['comic', 'manga', 'book']) {
        expect(sessionHistoryLabelsForKind(kind), SessionHistoryLabels.read);
      }
    });

    test('music maps to listen, games map to play', () {
      expect(sessionHistoryLabelsForKind('music'), SessionHistoryLabels.listen);
      expect(sessionHistoryLabelsForKind('game'), SessionHistoryLabels.play);
      expect(
          sessionHistoryLabelsForKind('boardgame'), SessionHistoryLabels.play);
    });

    test('video kinds fall back to watch labels', () {
      for (final kind in ['movie', 'tv', 'anime']) {
        expect(sessionHistoryLabelsForKind(kind), SessionHistoryLabels.watch);
      }
    });
  });

  testWidgets('book read history renders read semantics', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchSessionsByItemProvider.overrideWithValue(
            const <String, List<WatchSession>>{},
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: WatchHistorySection(
              itemId: 'book-1',
              accent: Colors.teal,
              labels: SessionHistoryLabels.read,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Read history'), findsOneWidget);
    expect(find.text('No reads logged yet.'), findsOneWidget);
    expect(find.byTooltip('Log a read'), findsOneWidget);
    expect(find.text('Watch history'), findsNothing);
  });

  testWidgets('populated read history shows the read count', (tester) async {
    final session = WatchSession(
      id: 'session-1',
      targetRef: const CatalogEntityRef(
        kind: 'book',
        entityType: CatalogEntityType.work,
        id: 'book-1',
      ),
      watchedAt: DateTime.utc(2026, 5, 14),
      updatedAt: DateTime.utc(2026, 5, 14),
      rating: 8,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchSessionsByItemProvider.overrideWithValue(
            <String, List<WatchSession>>{
              'book-1': [session],
            },
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: WatchHistorySection(
              itemId: 'book-1',
              accent: Colors.teal,
              labels: SessionHistoryLabels.read,
            ),
          ),
        ),
      ),
    );

    expect(find.text('1 read'), findsOneWidget);
    expect(find.text('8/10'), findsOneWidget);
  });
}
