import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector_panel.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('music inspector renders CLZ-like panel with disc groups', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 760,
              child: LibraryInspector(
                type: musicLibraryConfig,
                entry: LibraryWorkspaceEntry(
                  id: 'music-1',
                  mediaType: 'music',
                  title: 'Lupus Dei',
                  publisher: 'Metal Blade Records',
                  releaseYear: 2007,
                  barcode: '039841461923',
                  isOwned: true,
                  genres: const ['Heavy Metal', 'Rock'],
                  series: const CatalogSeriesDetails(seriesTitle: 'Powerwolf'),
                  music: MusicCatalogDetails(
                    trackCount: 14,
                    catalogNumber: '3984-14619-2',
                    tracks: const [
                      CatalogTrack(
                        title: 'Lupus Daemonis (Intro)',
                        position: 1,
                        durationSeconds: 77,
                        discNumber: 1,
                      ),
                      CatalogTrack(
                        title: 'Lupus Dei',
                        position: 11,
                        durationSeconds: 370,
                        discNumber: 1,
                      ),
                      CatalogTrack(
                        title: 'Mr Sinister (Live)',
                        position: 2,
                        durationSeconds: 287,
                        discNumber: 2,
                      ),
                    ],
                  ),
                  updatedAt: DateTime.utc(2026, 6, 3, 17, 21, 48),
                ),
                ownedItem: OwnedItem(
                  id: 'owned-music-1',
                  itemId: 'music-1',
                  indexNumber: 1,
                  createdAt: DateTime.utc(2026, 6, 3, 17, 21, 47),
                  updatedAt: DateTime.utc(2026, 6, 3, 17, 21, 48),
                ),
                accent: const Color(0xFFFDAD49),
                onAddOwned: () {},
                onRemoveOwned: () {},
                onAddWishlist: () {},
                onRemoveWishlist: () {},
                onEdit: (_) {},
                onDetailsLayoutChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MusicInspectorPanel), findsOneWidget);
    expect(find.text('Powerwolf'), findsOneWidget);
    expect(find.text('Lupus Dei'), findsWidgets);
    expect(find.text('Disc #1'), findsOneWidget);
    expect(find.text('Disc #2'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
  });
}
