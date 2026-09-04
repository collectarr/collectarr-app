import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('boardgame workspace projector builds typed boardgame dto', () {
    final source = ShelfEntry(
      itemId: 'boardgame-1',
      catalogItem: testCatalogItem(
        id: 'boardgame-1',
        title: 'Catan',
        kind: 'boardgame',
      ),
    );

    final dto = const BoardGameWorkspaceProjector().projectTitle(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'boardgame-1'),
    );

    expect(dto.title, 'Catan');
    expect(source.catalogItem?.kind, 'boardgame');
  });

  test('boardgame workspace projector applies release and copy projections',
      () {
    final edition = CatalogEditionDto(
      id: 'edition-1',
      title: 'Deluxe Edition',
      publisher: 'Board Games Co.',
      upc: '123456789',
      language: 'English',
      releaseDate: DateTime.utc(2026, 2, 3),
    );
    final source = ShelfEntry(
      itemId: 'boardgame-1',
      catalogItem: testCatalogItem(
        id: 'boardgame-1',
        kind: 'boardgame',
        title: 'Catan',
        editions: [edition],
      ),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'boardgame-1',
        kind: 'boardgame',
      ),
    );
    const projector = BoardGameWorkspaceProjector();
    final releaseDto = projector.projectRelease(
      source: source,
      node: LibraryReleaseNodeRef(
        titleItemId: 'boardgame-1',
        releaseId: 'edition-1',
        edition: edition,
      ),
      releaseState: const LibraryReleaseState(
        isOwned: false,
        isWishlisted: true,
        isTracked: false,
        referenceEditionId: 'edition-1',
      ),
    );

    expect(releaseDto.boardgame.editions.single.id, 'edition-1');
    expect(releaseDto.publisher, 'Board Games Co.');
    expect(releaseDto.barcode, '123456789');
    expect(releaseDto.language, 'English');
    expect(releaseDto.releaseDate, DateTime.utc(2026, 2, 3));
    expect(releaseDto.personal.isOwned, isFalse);
    expect(releaseDto.personal.isWishlisted, isTrue);

    final copyDto = projector.projectCopy(
      source: source,
      node: const LibraryCopyNodeRef(
        titleItemId: 'boardgame-1',
        ownedItemId: 'owned-1',
      ),
    );
    expect(copyDto.title, 'Catan');
    expect(copyDto.personal.isOwned, isTrue);
  });

  testWidgets('boardgame module exposes typed inspector sections',
      (tester) async {
    final source = ShelfEntry(
      itemId: 'boardgame-1',
      catalogItem: testCatalogItem(
        id: 'boardgame-1',
        kind: 'boardgame',
        title: 'Catan',
        payload: {
          'board_game_stats': {
            'bgg_rank': 7,
            'bgg_rating': 8.2,
          },
        },
      ),
    );
    final item = boardGameKindModule.project(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'boardgame-1'),
    );
    final inspector = LibraryInspectorRequest(
      type: boardGameKindModule,
      item: item,
      ownedItem: null,
      trackingEntry: null,
      accent: Colors.amber,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              final sections = boardGameKindModule.inspector.buildSections(
                context,
                inspector,
              );
              return Scaffold(
                body: ListView(children: sections),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Play stats'), findsOneWidget);
    expect(find.text('BGG rank'), findsOneWidget);
    expect(find.text('BGG rating'), findsOneWidget);
  });
}
