import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector_panel.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';

void main() {
  testWidgets('music inspector renders CLZ-like panel with disc groups', (
    tester,
  ) async {
    final ownedItem = testOwnedItem(
      id: 'owned-music-1',
      itemId: 'music-1',
      indexNumber: 1,
      createdAt: DateTime.utc(2026, 6, 3, 17, 21, 47),
      updatedAt: DateTime.utc(2026, 6, 3, 17, 21, 48),
    );
    final cat = testCatalogItem(
      id: 'music-1',
      kind: 'music',
      title: 'Lupus Dei',
      publisher: 'Metal Blade Records',
      barcode: '039841461923',
      genres: const ['Heavy Metal', 'Rock'],
      series: const CatalogSeriesDetailsDto(seriesTitle: 'Powerwolf'),
      music: const {
        'track_count': 14,
        'catalog_number': '3984-14619-2',
        'tracks': [
          {
            'title': 'Lupus Daemonis (Intro)',
            'position': '1',
            'duration_seconds': 77,
            'disc_number': 1,
          },
          {
            'title': 'Lupus Dei',
            'position': '11',
            'duration_seconds': 370,
            'disc_number': 1,
          },
          {
            'title': 'Mr Sinister (Live)',
            'position': '2',
            'duration_seconds': 287,
            'disc_number': 2,
          },
        ],
      },
    );
    final source = ShelfEntry(
      itemId: 'music-1',
      catalogItem: cat,
      ownedItem: ownedItem,
    );
    const node = LibraryTitleNodeRef(titleItemId: 'music-1');
    final dto = const MusicWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(source: source, node: node, dto: dto);

    final inspectorRequest = LibraryInspectorRequest(
      type: musicLibraryConfig,
      item: item,
      ownedItem: ownedItem,
      ownedCopies: [ownedItem],
      trackingEntry: null,
      accent: const Color(0xFFFDAD49),
      detailsLayout: LibraryDetailsLayout.hidden,
      onFilterByValue: (_) {},
      searchQuery: null,
      searchTarget: LibrarySearchTarget.all,
    );
    final request = LibraryInspectorPanelRequest(
      inspector: inspectorRequest,
      hero: const SizedBox.shrink(),
      primarySections: const [],
      trailingSections: const [],
      ownedCopies: [ownedItem],
      selectedOwnedItemId: ownedItem.id,
      extraActions: const [],
      onAddCopy: () {},
      onOpenDetails: () {},
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 760,
              child: MusicInspectorPanel(request: request),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MusicInspectorPanel), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Powerwolf'), findsWidgets);
    expect(find.text('Disc #1'), findsWidgets);
    expect(find.text('Disc #2'), findsWidgets);
    expect(find.text('Front cover'), findsOneWidget);
    expect(find.text('Back cover'), findsOneWidget);
    expect(find.text('Back cover not in metadata'), findsOneWidget);
  });

  testWidgets('music inspector highlights matching tracks for track search', (
    tester,
  ) async {
    final ownedItem = testOwnedItem(
      id: 'owned-music-2',
      itemId: 'music-2',
      createdAt: DateTime.utc(2026, 6, 3, 17, 21, 47),
      updatedAt: DateTime.utc(2026, 6, 3, 17, 21, 48),
    );
    final cat = testCatalogItem(
      id: 'music-2',
      kind: 'music',
      title: 'Lupus Dei',
      series: const CatalogSeriesDetailsDto(seriesTitle: 'Powerwolf'),
      music: const {
        'tracks': [
          {
            'title': 'Lupus Daemonis (Intro)',
            'position': '1',
            'disc_number': 1,
          },
          {
            'title': 'Prayer In The Dark',
            'position': '3',
            'disc_number': 1,
          },
        ],
      },
    );
    final source = ShelfEntry(
      itemId: 'music-2',
      catalogItem: cat,
      ownedItem: ownedItem,
    );
    const node = LibraryTitleNodeRef(titleItemId: 'music-2');
    final dto = const MusicWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(source: source, node: node, dto: dto);

    final inspectorRequest = LibraryInspectorRequest(
      type: musicLibraryConfig,
      item: item,
      ownedItem: ownedItem,
      ownedCopies: [ownedItem],
      trackingEntry: null,
      accent: const Color(0xFFFDAD49),
      detailsLayout: LibraryDetailsLayout.hidden,
      onFilterByValue: (_) {},
      searchQuery: 'prayer',
      searchTarget: LibrarySearchTarget.tracksOnly,
    );

    final request = LibraryInspectorPanelRequest(
      inspector: inspectorRequest,
      hero: const SizedBox.shrink(),
      primarySections: const [],
      trailingSections: const [],
      ownedCopies: [ownedItem],
      selectedOwnedItemId: ownedItem.id,
      extraActions: const [],
      onAddCopy: () {},
      onOpenDetails: () {},
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 760,
              child: MusicInspectorPanel(request: request),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final matchingRow = find.byKey(
      const ValueKey('music-track-row-1-3-Prayer In The Dark'),
    );
    final nonMatchingRow = find.byKey(
      const ValueKey('music-track-row-1-1-Lupus Daemonis (Intro)'),
    );
    expect(matchingRow, findsOneWidget);
    expect(nonMatchingRow, findsOneWidget);

    final matchingDecoratedBox = tester.widget<DecoratedBox>(matchingRow);
    final nonMatchingDecoratedBox = tester.widget<DecoratedBox>(nonMatchingRow);
    final matchingDecoration = matchingDecoratedBox.decoration as BoxDecoration;
    final nonMatchingDecoration =
        nonMatchingDecoratedBox.decoration as BoxDecoration;
    expect(matchingDecoration.color, isNot(equals(Colors.transparent)));
    expect(nonMatchingDecoration.color, equals(Colors.transparent));
  });
}
