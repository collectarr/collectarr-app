import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_projector.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  group('BoardGame Kind Vertical Slice Tests (C3)', () {
    test('BoardGameMetadata serializes and deserializes full domain fields',
        () {
      const metadata = BoardGameMetadata(
        title: 'Brass: Birmingham',
        originalTitle: 'Brass: Birmingham',
        synopsis:
            'Economic strategy board game in Industrial Revolution Britain.',
        yearPublished: 2018,
        minPlayers: 2,
        maxPlayers: 4,
        bestPlayers: '3-4',
        recommendedPlayers: '2-4',
        minPlaytimeMinutes: 60,
        maxPlaytimeMinutes: 120,
        minimumAge: 14,
        complexityWeight: 3.9,
        designers: ['Gavan Brown', 'Matt Tolman', 'Martin Wallace'],
        artists: ['Lina Cossette', 'David Forest'],
        publishers: ['Roxley'],
        mechanics: [
          'Hand Management',
          'Income',
          'Market',
          'Network and Route Building'
        ],
        categories: ['Economic', 'Industry / Manufacturing', 'Transportation'],
        bggRating: 8.6,
        bggRatingCount: 45000,
        bggRank: 1,
      );

      final json = metadata.toJson();
      final restored = BoardGameMetadata.fromJson(json);

      expect(restored.title, 'Brass: Birmingham');
      expect(restored.yearPublished, 2018);
      expect(restored.minPlayers, 2);
      expect(restored.maxPlayers, 4);
      expect(restored.bestPlayers, '3-4');
      expect(restored.recommendedPlayers, '2-4');
      expect(restored.minPlaytimeMinutes, 60);
      expect(restored.maxPlaytimeMinutes, 120);
      expect(restored.minimumAge, 14);
      expect(restored.complexityWeight, 3.9);
      expect(restored.designers, contains('Martin Wallace'));
      expect(restored.publishers, contains('Roxley'));
      expect(restored.bggRating, 8.6);
      expect(restored.bggRank, 1);
    });

    test('BoardGameWorkspaceProjector projects metadata and schema fields', () {
      const bgMeta = BoardGameMetadata(
        title: 'Brass: Birmingham',
        minPlayers: 2,
        maxPlayers: 4,
        bestPlayers: '3-4',
        minPlaytimeMinutes: 60,
        maxPlaytimeMinutes: 120,
        complexityWeight: 3.9,
        bggRating: 8.6,
        bggRank: 1,
      );

      final shelfEntry = LibraryWorkspaceSource(
        itemId: 'bg_1',
        catalogData: testWorkspaceCatalogData(CatalogItemDto(
          identity: LibraryItemIdentity(
            id: 'bg_1',
            mediaKind: CatalogMediaKind.boardgame,
          ),
          kindMetadata: bgMeta,
        ).asShelfCatalogItem),
        ownedSummary: testOwnedSummary(testOwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'bg_1',
            kind: CatalogMediaKind.boardgame,
            entityType: CatalogEntityTypeId('work'),
          ),
          condition: 'Mint',
          updatedAt: DateTime.now(),
        )),
      );

      const projector = BoardGameWorkspaceProjector();
      const node = LibraryWorkRef(
        workId: 'bg_1',
      );
      final dto = projector.project(
        source: shelfEntry,
        entity: node,
      );

      expect(dto.metadata?.title, 'Brass: Birmingham');
      expect(dto.metadata?.minPlayers, 2);
      expect(dto.metadata?.maxPlayers, 4);
      expect(dto.metadata?.complexityWeight, 3.9);
      expect(dto.metadata?.bggRating, 8.6);
      expect(dto.metadata?.bggRank, 1);

      final ctx = LibraryProjectionContext<BoardGameWorkspaceDto>(
        source: shelfEntry,
        node: node,
        dto: dto,
      );

      expect(BoardGameWorkWorkspaceFields.minPlayers.getValue(ctx), 2);
      expect(BoardGameWorkWorkspaceFields.maxPlayers.getValue(ctx), 4);
      expect(BoardGameWorkWorkspaceFields.bestPlayers.getValue(ctx), '3-4');
      expect(BoardGameWorkWorkspaceFields.minPlaytimeMinutes.getValue(ctx), 60);
      expect(
          BoardGameWorkWorkspaceFields.maxPlaytimeMinutes.getValue(ctx), 120);
      expect(BoardGameWorkWorkspaceFields.complexityWeight.getValue(ctx), 3.9);
      expect(BoardGameWorkWorkspaceFields.bggRating.getValue(ctx), 8.6);
      expect(BoardGameWorkWorkspaceFields.bggRank.getValue(ctx), 1);
    });
  });
}
