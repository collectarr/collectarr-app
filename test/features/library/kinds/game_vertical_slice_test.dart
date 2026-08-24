import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/domain/valuation_snapshot.dart';
import 'package:collectarr_app/features/library/kinds/game/contracts/game_contracts.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/features/library/kinds/game/provider/game_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_common_metadata.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

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

      final shelfEntry = ShelfEntry(
        itemId: 'game_1',
        catalogItem: LibraryMetadataItem(
          identity: const LibraryItemIdentity(
            id: 'game_1',
            mediaKind: CatalogMediaKind.game,
          ),
          common: const LibraryCommonMetadata(
            title: 'Super Mario 64',
          ),
          kindMetadata: gameMeta,
        ),
        ownedItem: OwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'game_1',
            kind: 'game',
            entityType: CatalogEntityType.work,
          ),
          condition: 'CIB',
          updatedAt: DateTime.now(),
        ),
      );

      const projector = GameWorkspaceProjector();
      const node = LibraryTitleNodeRef(
        titleItemId: 'game_1',
      );
      final dto = projector.projectTitle(
        source: shelfEntry,
        node: node,
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

      expect(GameKindSchema.title.getValue(ctx), 'Super Mario 64');
      expect(GameKindSchema.franchise.getValue(ctx), 'Super Mario');
      expect(GameKindSchema.edition.getValue(ctx), 'Standard');
      expect(GameKindSchema.ageRating.getValue(ctx), 'ESRB: E');
      expect(GameKindSchema.coreRegion.getValue(ctx), 'NTSC-U');
      expect(GameKindSchema.loosePrice.getValue(ctx), 3500);
      expect(GameKindSchema.cibPrice.getValue(ctx), 9000);
      expect(GameKindSchema.newPrice.getValue(ctx), 35000);
      expect(GameKindSchema.gradedPrice.getValue(ctx), 95000);
    });

    test(
        'GameLibraryKindProviderMapper parses IGDB envelope into GameCatalogMetadata',
        () {
      const mapper = GameLibraryKindProviderMapper();
      final item = mapper.metadataItemFromEnvelope(
        NormalizedProviderEnvelopeV1(
          provider: 'igdb',
          providerItemId: '1234',
          kind: 'game',
          normalized: const {
            'title': 'Super Mario 64',
            'platform': 'Nintendo 64',
            'franchise': 'Super Mario',
            'developers': ['Nintendo EAD'],
            'publishers': ['Nintendo'],
            'age_rating': 'ESRB: E',
            'valuations': {
              'loose': {
                'amount_cents': 3500,
                'source': 'priceCharting',
                'captured_at': '2026-08-20T00:00:00.000Z'
              },
              'cib': {
                'amount_cents': 9000,
                'source': 'priceCharting',
                'captured_at': '2026-08-20T00:00:00.000Z'
              },
              'new_sealed': {
                'amount_cents': 35000,
                'source': 'priceCharting',
                'captured_at': '2026-08-20T00:00:00.000Z'
              },
              'graded': {
                'amount_cents': 95000,
                'source': 'priceCharting',
                'captured_at': '2026-08-20T00:00:00.000Z'
              },
            },
          },
          images: const [],
          provenance: ProviderProvenance(
            fetchedAt: DateTime.now().toIso8601String(),
          ),
          attribution: const ProviderAttribution(required: false),
        ),
      );

      expect(item.kindMetadata, isA<GameCatalogMetadata>());
      final meta = item.kindMetadata as GameCatalogMetadata;
      expect(meta.title, 'Super Mario 64');
      expect(meta.franchise, 'Super Mario');
      expect(meta.ageRating, 'ESRB: E');
      expect(meta.valuations?.cib?.amountCents, 9000);
    });

    test('GameCatalog and GameEntry round-trip and preserve all kind fields',
        () {
      final catalog = GameCatalog.fromJson({
        'id': 'game_zelda_oot',
        'kind': 'game',
        'title': 'The Legend of Zelda: Ocarina of Time',
        'platform': 'Nintendo 64',
        'release_region': 'NTSC-U',
        'edition': 'Collector\'s Edition',
        'developers': ['Nintendo EAD'],
        'publishers': ['Nintendo'],
        'franchise': 'The Legend of Zelda',
        'series': 'The Legend of Zelda',
        'genres': ['Action-Adventure'],
        'age_rating': 'ESRB: E',
        'release_date': '1998-11-23T00:00:00.000Z',
        'barcode': '045496870034',
        'price_charting_id': '12345',
        'valuations': {
          'loose': {
            'amount_cents': 4500,
            'source': 'priceCharting',
            'captured_at': '2026-08-20T00:00:00.000Z'
          },
          'cib': {
            'amount_cents': 12000,
            'source': 'priceCharting',
            'captured_at': '2026-08-20T00:00:00.000Z'
          },
        },
        'synopsis': 'Link must save the land of Hyrule from Ganondorf.',
        'cover_image_url': 'https://example.com/zelda.jpg',
        'thumbnail_image_url': 'https://example.com/zelda_thumb.jpg',
      });

      expect(catalog.id, 'game_zelda_oot');
      expect(catalog.mediaKind, CatalogMediaKind.game);
      expect(catalog.title, 'The Legend of Zelda: Ocarina of Time');
      expect(catalog.platform, 'Nintendo 64');
      expect(catalog.publisher, 'Nintendo');
      expect(catalog.developer, 'Nintendo EAD');
      expect(catalog.displayCoverUrl, 'https://example.com/zelda_thumb.jpg');
      expect(catalog.valuations?.loose?.amountCents, 4500);

      final envelope = catalog.toEnvelope();
      expect(envelope.kind, CatalogMediaKind.game);
      expect(envelope.common.title, 'The Legend of Zelda: Ocarina of Time');

      final json = catalog.toJson();
      final restored = GameCatalog.fromJson(json);
      expect(restored.id, 'game_zelda_oot');
      expect(restored.developers, contains('Nintendo EAD'));
      expect(restored.valuations?.cib?.amountCents, 12000);

      final shelfEntry = ShelfEntry(
        itemId: 'game_zelda_oot',
        catalogItem: LibraryMetadataItem(
          identity: const LibraryItemIdentity(
            id: 'game_zelda_oot',
            mediaKind: CatalogMediaKind.game,
          ),
          common: const LibraryCommonMetadata(
              title: 'The Legend of Zelda: Ocarina of Time'),
          kindMetadata: GameCatalogMetadata.fromJson(json),
        ),
      );

      final entry = GameEntry.fromShelf(shelfEntry);
      expect(entry.id, 'game_zelda_oot');
      expect(entry.title, 'The Legend of Zelda: Ocarina of Time');
    });
  });
}
