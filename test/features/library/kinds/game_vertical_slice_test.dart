import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/domain/valuation_snapshot.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  group('Game Kind Vertical Slice Tests (C7)', () {
    test(
        'GameCatalogMetadata and GameValuationSet serialize and deserialize full domain fields',
        () {
      final now = DateTime.now();
      final metadata = GameCatalogMetadata(
        title: 'The Legend of Zelda: Ocarina of Time',
        platform: 'Nintendo 64',
        releaseRegion: 'NTSC-U',
        edition: 'Collector\'s Edition',
        developers: const ['Nintendo EAD'],
        publishers: const ['Nintendo'],
        franchise: 'The Legend of Zelda',
        series: 'The Legend of Zelda',
        genres: const ['Action-Adventure'],
        ageRating: 'ESRB: E',
        releaseDate: DateTime(1998, 11, 23),
        barcode: '045496870034',
        priceChartingId: '12345',
        valuations: GameValuationSet(
          loose: ValuationSnapshot(
            source: ValuationSource.priceCharting,
            amountCents: 4500,
            capturedAt: now,
          ),
          cib: ValuationSnapshot(
            source: ValuationSource.priceCharting,
            amountCents: 12000,
            capturedAt: now,
          ),
          newSealed: ValuationSnapshot(
            source: ValuationSource.priceCharting,
            amountCents: 45000,
            capturedAt: now,
          ),
          graded: ValuationSnapshot(
            source: ValuationSource.priceCharting,
            amountCents: 120000,
            capturedAt: now,
          ),
          boxOnly: ValuationSnapshot(
            source: ValuationSource.priceCharting,
            amountCents: 5000,
            capturedAt: now,
          ),
          manualOnly: ValuationSnapshot(
            source: ValuationSource.priceCharting,
            amountCents: 2500,
            capturedAt: now,
          ),
        ),
      );

      final json = metadata.toJson();
      final restored = GameCatalogMetadata.fromJson(json);

      expect(restored.title, 'The Legend of Zelda: Ocarina of Time');
      expect(restored.platform, 'Nintendo 64');
      expect(restored.releaseRegion, 'NTSC-U');
      expect(restored.edition, 'Collector\'s Edition');
      expect(restored.franchise, 'The Legend of Zelda');
      expect(restored.ageRating, 'ESRB: E');
      expect(restored.valuations?.loose?.amountCents, 4500);
      expect(restored.valuations?.cib?.amountCents, 12000);
      expect(restored.valuations?.newSealed?.amountCents, 45000);
      expect(restored.valuations?.graded?.amountCents, 120000);
    });

    test('GameWorkspaceProjector projects metadata and schema fields', () {
      final now = DateTime.now();
      final gameMeta = GameCatalogMetadata(
        title: 'Super Mario 64',
        platform: 'Nintendo 64',
        releaseRegion: 'NTSC-U',
        edition: 'Standard',
        developers: const ['Nintendo EAD'],
        publishers: const ['Nintendo'],
        franchise: 'Super Mario',
        ageRating: 'ESRB: E',
        valuations: GameValuationSet(
          loose: ValuationSnapshot(
            source: ValuationSource.priceCharting,
            amountCents: 3500,
            capturedAt: now,
          ),
          cib: ValuationSnapshot(
            source: ValuationSource.priceCharting,
            amountCents: 9000,
            capturedAt: now,
          ),
          newSealed: ValuationSnapshot(
            source: ValuationSource.priceCharting,
            amountCents: 35000,
            capturedAt: now,
          ),
          graded: ValuationSnapshot(
            source: ValuationSource.priceCharting,
            amountCents: 95000,
            capturedAt: now,
          ),
        ),
      );

      final shelfEntry = LibraryWorkspaceSource(
        itemId: 'game_1',
        catalogData: testWorkspaceCatalogData(CatalogItemDto(
          identity: const LibraryItemIdentity(
            id: 'game_1',
            mediaKind: CatalogMediaKind.game,
          ),
          kindMetadata: gameMeta,
        ).asShelfCatalogItem),
        ownedSummary: testOwnedSummary(testOwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'game_1',
            kind: CatalogMediaKind.game,
            entityType: CatalogEntityTypeId('work'),
          ),
          condition: 'CIB',
          updatedAt: DateTime.now(),
        )),
      );

      const projector = GameWorkspaceProjector();
      const node = LibraryWorkRef(
        workId: 'game_1',
      );
      final dto = projector.project(
        source: shelfEntry,
        entity: node,
      );

      expect(dto.metadata?.title, 'Super Mario 64');
      expect(dto.franchise, 'Super Mario');
      expect(dto.edition, 'Standard');
      expect(dto.ageRating, 'ESRB: E');
      expect(dto.region, 'NTSC-U');
      expect(dto.loosePrice, 3500);
      expect(dto.cibPrice, 9000);
      expect(dto.newPrice, 35000);
      expect(dto.gradedPrice, 95000);

      final ctx = LibraryProjectionContext<GameWorkspaceDto>(
        source: shelfEntry,
        node: node,
        dto: dto,
      );

      expect(GameWorkWorkspaceFields.title.getValue(ctx), 'Super Mario 64');
      expect(GameWorkWorkspaceFields.franchise.getValue(ctx), 'Super Mario');
      expect(GameReleaseWorkspaceFields.edition.getValue(ctx), 'Standard');
      expect(GameWorkWorkspaceFields.ageRating.getValue(ctx), 'ESRB: E');
      expect(GameCopyWorkspaceFields.coreRegion.getValue(ctx), isNull);
      expect(GameWorkWorkspaceFields.loosePrice.getValue(ctx), 3500);
      expect(GameWorkWorkspaceFields.cibPrice.getValue(ctx), 9000);
      expect(GameWorkWorkspaceFields.newPrice.getValue(ctx), 35000);
      expect(GameWorkWorkspaceFields.gradedPrice.getValue(ctx), 95000);
    });
  });
}
