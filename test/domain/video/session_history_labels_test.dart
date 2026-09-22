import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/tracking/session_history_section.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace_contributors.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_topology.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kind-owned session history labels', () {
    test('reading kinds map to read labels', () {
      for (final kind in [
        CatalogMediaKind.comic,
        CatalogMediaKind.manga,
        CatalogMediaKind.book,
      ]) {
        expect(libraryTrackingTopologyForKind(kind).sessionLabels,
            LibraryTrackingSessionLabels.read);
      }
    });

    test('music maps to listen, games map to play', () {
      expect(
          libraryTrackingTopologyForKind(CatalogMediaKind.music).sessionLabels,
          LibraryTrackingSessionLabels.listen);
      expect(
          libraryTrackingTopologyForKind(CatalogMediaKind.game).sessionLabels,
          LibraryTrackingSessionLabels.play);
      expect(
          libraryTrackingTopologyForKind(CatalogMediaKind.boardgame)
              .sessionLabels,
          LibraryTrackingSessionLabels.play);
    });

    test('video kinds fall back to watch labels', () {
      for (final kind in [
        CatalogMediaKind.movie,
        CatalogMediaKind.tv,
        CatalogMediaKind.anime,
      ]) {
        expect(libraryTrackingTopologyForKind(kind).sessionLabels,
            LibraryTrackingSessionLabels.watch);
      }
    });
  });

  testWidgets('book read history renders read semantics', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchSessionsByCatalogRefProvider(
            const CatalogEntityRef(
              kind: CatalogMediaKind.book,
              entityType: CatalogEntityTypeId('work'),
              id: 'book-1',
            ),
          ).overrideWithValue(
            const <WatchSession>[],
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: WatchHistorySection(
              catalogRef: CatalogEntityRef(
                kind: CatalogMediaKind.book,
                entityType: CatalogEntityTypeId('work'),
                id: 'book-1',
              ),
              accent: Colors.teal,
              labels: LibraryTrackingSessionLabels.read,
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
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId('work'),
        id: 'book-1',
      ),
      watchedAt: DateTime.utc(2026, 5, 14),
      updatedAt: DateTime.utc(2026, 5, 14),
      rating: 8,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchSessionsByCatalogRefProvider(
            const CatalogEntityRef(
              kind: CatalogMediaKind.book,
              entityType: CatalogEntityTypeId('work'),
              id: 'book-1',
            ),
          ).overrideWithValue(
            [session],
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: WatchHistorySection(
              catalogRef: CatalogEntityRef(
                kind: CatalogMediaKind.book,
                entityType: CatalogEntityTypeId('work'),
                id: 'book-1',
              ),
              accent: Colors.teal,
              labels: LibraryTrackingSessionLabels.read,
            ),
          ),
        ),
      ),
    );

    expect(find.text('1 read'), findsOneWidget);
    expect(find.text('8/10'), findsOneWidget);
  });
}
