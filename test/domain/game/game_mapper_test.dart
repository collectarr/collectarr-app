import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/domain/valuation_snapshot.dart';
import 'package:collectarr_app/features/library/kinds/game/game_domain.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('game work dto preserves typed collections', () {
    final dto = GameWorkDto.fromJson({
      'id': 'game-1',
      'title': 'Zelda',
      'platforms': ['Switch', 'switch'],
      'identifiers': ['IGDB:1'],
      'company_roles': ['developer', 'publisher'],
      'age_ratings': ['E10+'],
    });

    expect(dto.platforms, ['Switch']);
    expect(dto.identifiers, ['IGDB:1']);
    expect(dto.companyRoles, ['developer', 'publisher']);
    expect(dto.ageRatings, ['E10+']);
  });

  test('GameKindSchema exposes complete GameOwnedDetails surface', () {
    final catalogItem = testCatalogItem(
      id: 'game-10',
      kind: 'game',
      title: 'Super Mario 64',
      publisher: 'Nintendo',
    );

    final shelf = ShelfEntry(
      itemId: 'game-10',
      catalogItem: catalogItem,
      ownedItem: testOwnedItem(
        id: 'owned-game-10',
        itemId: 'game-10',
        kind: 'game',
        gameCompleteness: 'CIB',
        gameHasBox: true,
        gameHasManual: true,
        gamePriceChartingId: 'pc-12345',
        gameCoreRegion: 'NTSC-U',
        gameValueIsLocked: true,
      ),
    );

    final workspaceDto = const GameWorkspaceProjector().projectTitle(
      source: shelf,
      node: const LibraryTitleNodeRef(titleItemId: 'game-10'),
    );

    final ctx = LibraryProjectionContext<GameWorkspaceDto>(
      source: shelf,
      dto: workspaceDto,
      node: const LibraryTitleNodeRef(titleItemId: 'game-10'),
    );

    expect(GameKindSchema.completeness.getValue(ctx), 'CIB');
    expect(GameKindSchema.hasBox.getValue(ctx), isTrue);
    expect(GameKindSchema.hasManual.getValue(ctx), isTrue);
    expect(GameKindSchema.priceChartingId.getValue(ctx), 'pc-12345');
    expect(GameKindSchema.coreRegion.getValue(ctx), 'NTSC-U');
    expect(GameKindSchema.valueLocked.getValue(ctx), isTrue);
  });

  test('GameCatalogMetadata and GameValuationSet roundtrip', () {
    final valuations = GameValuationSet(
      priceChartingId: 'pc-mario-64',
      loose: ValuationSnapshot(
        source: ValuationSource.priceCharting,
        amountCents: 3500,
        gradeOrCondition: 'Loose',
        capturedAt: DateTime.utc(2026, 8, 1),
      ),
      cib: ValuationSnapshot(
        source: ValuationSource.priceCharting,
        amountCents: 12000,
        gradeOrCondition: 'CIB',
        capturedAt: DateTime.utc(2026, 8, 1),
      ),
      newSealed: ValuationSnapshot(
        source: ValuationSource.priceCharting,
        amountCents: 85000,
        gradeOrCondition: 'New',
        capturedAt: DateTime.utc(2026, 8, 1),
      ),
      graded: ValuationSnapshot(
        source: ValuationSource.priceCharting,
        amountCents: 250000,
        gradeOrCondition: 'WATA 9.8 A++',
        capturedAt: DateTime.utc(2026, 8, 1),
      ),
      boxOnly: ValuationSnapshot(
        source: ValuationSource.priceCharting,
        amountCents: 6500,
        gradeOrCondition: 'Box Only',
        capturedAt: DateTime.utc(2026, 8, 1),
      ),
      manualOnly: ValuationSnapshot(
        source: ValuationSource.priceCharting,
        amountCents: 2500,
        gradeOrCondition: 'Manual Only',
        capturedAt: DateTime.utc(2026, 8, 1),
      ),
    );

    final meta = GameCatalogMetadata(
      title: 'Super Mario 64',
      platform: 'Nintendo 64',
      releaseRegion: 'NTSC-U',
      edition: 'Player Choice',
      developers: const ['Nintendo EAD'],
      publishers: const ['Nintendo'],
      franchise: 'Super Mario',
      series: '3D Mario',
      genres: const ['Platformer', '3D Platformer'],
      ageRating: 'ESRB: E',
      languages: const ['English', 'Japanese'],
      country: 'US',
      priceChartingId: 'pc-mario-64',
      valuations: valuations,
    );

    final json = meta.toJson();
    final fromJson = GameCatalogMetadata.fromJson(json);

    expect(fromJson.title, 'Super Mario 64');
    expect(fromJson.platform, 'Nintendo 64');
    expect(fromJson.developers, contains('Nintendo EAD'));
    expect(fromJson.valuations?.cib?.amountCents, 12000);
    expect(fromJson.valuations?.graded?.amountCents, 250000);
    expect(fromJson.valuations?.manualOnly?.amountCents, 2500);
  });

  test('gameKindModule registers dedicated Game capabilities', () {
    expect(gameKindModule.kind, CatalogMediaKind.game);
    expect(gameKindModule.add.kind, CatalogMediaKind.game);
    expect(gameKindModule.add.createInitialDraft(), isA<GameAddDraft>());
    expect(gameKindModule.ownedDetailsCodec, isA<GameOwnedDetailsCodec>());
    expect(gameKindModule.ownedDetailsCodec.defaultDetails(),
        isA<GameOwnedDetails>());
  });
}
