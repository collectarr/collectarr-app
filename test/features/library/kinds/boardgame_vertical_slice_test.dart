import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/contracts/boardgame_contracts.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/provider/boardgame_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_fields.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_projector.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

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

      final shelfEntry = ShelfEntry(
        itemId: 'bg_1',
        catalogItem: CatalogItem(
          identity: LibraryItemIdentity(
            id: 'bg_1',
            mediaKind: CatalogMediaKind.boardgame,
          ),
          kindMetadata: bgMeta,
        ),
        ownedItem: OwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'bg_1',
            kind: 'boardgame',
            entityType: CatalogEntityType.work,
          ),
          condition: 'Mint',
          updatedAt: DateTime.now(),
        ),
      );

      const projector = BoardGameWorkspaceProjector();
      const node = LibraryTitleNodeRef(
        titleItemId: 'bg_1',
      );
      final dto = projector.projectTitle(
        source: shelfEntry,
        node: node,
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

      expect(BoardGameKindSchema.minPlayers.getValue(ctx), 2);
      expect(BoardGameKindSchema.maxPlayers.getValue(ctx), 4);
      expect(BoardGameKindSchema.bestPlayers.getValue(ctx), '3-4');
      expect(BoardGameKindSchema.minPlaytimeMinutes.getValue(ctx), 60);
      expect(BoardGameKindSchema.maxPlaytimeMinutes.getValue(ctx), 120);
      expect(BoardGameKindSchema.complexityWeight.getValue(ctx), 3.9);
      expect(BoardGameKindSchema.bggRating.getValue(ctx), 8.6);
      expect(BoardGameKindSchema.bggRank.getValue(ctx), 1);
    });

    test(
        'BoardGameLibraryKindProviderMapper parses BGG envelope into BoardGameMetadata',
        () {
      const mapper = BoardGameLibraryKindProviderMapper();
      final item = mapper.metadataItemFromEnvelope(
        NormalizedProviderEnvelopeV1(
          provider: 'bgg',
          providerItemId: '224517',
          kind: 'boardgame',
          normalized: const {
            'title': 'Brass: Birmingham',
            'year_published': 2018,
            'min_players': 2,
            'max_players': 4,
            'best_players': '3-4',
            'min_playtime_minutes': 60,
            'max_playtime_minutes': 120,
            'complexity_weight': 3.9,
            'bgg_rating': 8.6,
            'bgg_rank': 1,
            'designers': ['Gavan Brown', 'Martin Wallace'],
          },
          images: const [],
          provenance: ProviderProvenance(
            fetchedAt: DateTime.now().toIso8601String(),
          ),
          attribution: const ProviderAttribution(required: false),
        ),
      );

      expect(item.kindMetadata, isA<BoardGameMetadata>());
      final meta = item.kindMetadata as BoardGameMetadata;
      expect(meta.title, 'Brass: Birmingham');
      expect(meta.yearPublished, 2018);
      expect(meta.minPlayers, 2);
      expect(meta.maxPlayers, 4);
      expect(meta.bestPlayers, '3-4');
      expect(meta.bggRank, 1);
      expect(meta.designers, contains('Martin Wallace'));
    });

    test(
        'BoardGameCatalog and BoardGameEntry round-trip and preserve all kind fields',
        () {
      final catalog = BoardGameCatalog.fromJson({
        'id': 'bg_brass_birmingham',
        'kind': 'boardgame',
        'title': 'Brass: Birmingham',
        'original_title': 'Brass: Birmingham',
        'synopsis':
            'Economic strategy board game in Industrial Revolution Britain.',
        'year_published': 2018,
        'min_players': 2,
        'max_players': 4,
        'best_players': '3-4',
        'recommended_players': '2-4',
        'min_playtime_minutes': 60,
        'max_playtime_minutes': 120,
        'minimum_age': 14,
        'complexity_weight': 3.9,
        'designers': ['Gavan Brown', 'Matt Tolman', 'Martin Wallace'],
        'artists': ['Lina Cossette', 'David Forest'],
        'publishers': ['Roxley'],
        'mechanics': ['Hand Management', 'Income', 'Market'],
        'categories': ['Economic', 'Industry'],
        'bgg_rating': 8.6,
        'bgg_rating_count': 45000,
        'bgg_rank': 1,
        'cover_image_url': 'https://example.com/brass.jpg',
        'thumbnail_image_url': 'https://example.com/brass_thumb.jpg',
      });

      expect(catalog.id, 'bg_brass_birmingham');
      expect(catalog.mediaKind, CatalogMediaKind.boardgame);
      expect(catalog.title, 'Brass: Birmingham');
      expect(catalog.designer, 'Gavan Brown');
      expect(catalog.bggRank, 1);
      expect(catalog.displayCoverUrl, 'https://example.com/brass_thumb.jpg');

      final envelope = catalog.toEnvelope();
      expect(envelope.kind, CatalogMediaKind.boardgame);
      expect(envelope.common.title, 'Brass: Birmingham');

      final json = catalog.toJson();
      final restored = BoardGameCatalog.fromJson(json);
      expect(restored.id, 'bg_brass_birmingham');
      expect(restored.yearPublished, 2018);
      expect(restored.complexityWeight, 3.9);

      final shelfEntry = ShelfEntry(
        itemId: 'bg_brass_birmingham',
        catalogItem: CatalogItem(
          identity: const LibraryItemIdentity(
            id: 'bg_brass_birmingham',
            mediaKind: CatalogMediaKind.boardgame,
          ),
          kindMetadata: BoardGameMetadata.fromJson(json),
        ),
      );

      final entry = BoardGameEntry.fromShelf(shelfEntry);
      expect(entry.id, 'bg_brass_birmingham');
      expect(entry.title, 'Brass: Birmingham');
    });
  });
}
