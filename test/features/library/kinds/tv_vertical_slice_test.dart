import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/contracts/tv_contracts.dart';
import 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TV Kind Vertical Slice Tests (C5)', () {
    test('TvSeriesMetadata serializes and deserializes full domain fields', () {
      final metadata = TvSeriesMetadata(
        title: 'Breaking Bad',
        originalTitle: 'Breaking Bad',
        synopsis:
            'A high school chemistry teacher diagnosed with lung cancer turns to manufacturing methamphetamine.',
        firstAirDate: DateTime(2008, 1, 20),
        lastAirDate: DateTime(2013, 9, 29),
        status: 'Ended',
        network: 'AMC',
        streamingService: 'Netflix',
        productionCompanies: const [
          'Sony Pictures Television',
          'High Bridge Productions'
        ],
        genres: const ['Crime', 'Drama', 'Thriller'],
        contentRating: 'TV-MA',
        seasonCount: 5,
        episodeCount: 62,
        episodeRuntimeMinutes: 47,
        seasons: [
          TvSeasonMetadata(
            seasonNumber: 1,
            title: 'Season 1',
            airDate: DateTime(2008, 1, 20),
            episodeCount: 7,
            episodes: [
              TvEpisodeMetadata(
                number: 1,
                title: 'Pilot',
                airDate: DateTime(2008, 1, 20),
                runtimeMinutes: 58,
              ),
            ],
          ),
        ],
      );

      final json = metadata.toJson();
      final restored = TvSeriesMetadata.fromJson(json);

      expect(restored.title, 'Breaking Bad');
      expect(restored.network, 'AMC');
      expect(restored.streamingService, 'Netflix');
      expect(restored.status, 'Ended');
      expect(restored.seasonCount, 5);
      expect(restored.episodeCount, 62);
      expect(restored.episodeRuntimeMinutes, 47);
      expect(restored.contentRating, 'TV-MA');
      expect(restored.seasons.first.seasonNumber, 1);
      expect(restored.seasons.first.episodes.first.title, 'Pilot');
    });

    test('TvWorkspaceProjector projects metadata and schema fields', () {
      final tvMeta = TvSeriesMetadata(
        title: 'Breaking Bad',
        firstAirDate: DateTime(2008, 1, 20),
        lastAirDate: DateTime(2013, 9, 29),
        status: 'Ended',
        network: 'AMC',
        streamingService: 'Netflix',
        contentRating: 'TV-MA',
        seasonCount: 5,
        episodeCount: 62,
        episodeRuntimeMinutes: 47,
      );

      final shelfEntry = ShelfEntry(
        itemId: 'tv_1',
        catalogItem: CatalogItem(
          identity: const LibraryItemIdentity(
            id: 'tv_1',
            mediaKind: CatalogMediaKind.tv,
          ),
          kindMetadata: tvMeta,
        ),
        ownedItem: OwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'tv_1',
            kind: 'tv',
            entityType: CatalogEntityType.work,
          ),
          details: const GenericOwnedDetails(),
          condition: 'Mint',
          updatedAt: DateTime.now(),
        ),
      );

      const projector = TvWorkspaceProjector();
      const node = LibraryTitleNodeRef(
        titleItemId: 'tv_1',
      );
      final dto = projector.projectTitle(
        source: shelfEntry,
        node: node,
      );

      expect(dto.metadata?.title, 'Breaking Bad');
      expect(dto.metadata?.network, 'AMC');
      expect(dto.metadata?.status, 'Ended');
      expect(dto.metadata?.seasonCount, 5);
      expect(dto.metadata?.episodeCount, 62);
      expect(dto.video, isA<TvCatalogItem>());

      final ctx = LibraryProjectionContext<TvWorkspaceDto>(
        source: shelfEntry,
        node: node,
        dto: dto,
      );

      expect(TvKindSchema.title.getValue(ctx), 'Breaking Bad');
      expect(TvKindSchema.tvStatus.getValue(ctx), 'Ended');
      expect(TvKindSchema.streamingService.getValue(ctx), 'Netflix');
      expect(TvKindSchema.contentRating.getValue(ctx), 'TV-MA');
      expect(TvKindSchema.seasonCount.getValue(ctx), 5);
      expect(TvKindSchema.episodeCount.getValue(ctx), 62);
      expect(TvKindSchema.episodeRuntimeMinutes.getValue(ctx), 47);
    });

    test(
        'TvLibraryKindProviderMapper parses TMDb envelope into TvSeriesMetadata',
        () {
      const mapper = TvLibraryKindProviderMapper();
      final item = mapper.metadataItemFromEnvelope(
        NormalizedProviderEnvelopeV1(
          provider: 'tmdb',
          providerItemId: '1396',
          kind: 'tv',
          normalized: const {
            'title': 'Breaking Bad',
            'status': 'Ended',
            'network': 'AMC',
            'streaming_service': 'Netflix',
            'season_count': 5,
            'episode_count': 62,
            'episode_runtime_minutes': 47,
            'content_rating': 'TV-MA',
          },
          images: const [],
          provenance: ProviderProvenance(
            fetchedAt: DateTime.now().toIso8601String(),
          ),
          attribution: const ProviderAttribution(required: false),
        ),
      );

      expect(item.kindMetadata, isA<TvSeriesMetadata>());
      final meta = item.kindMetadata as TvSeriesMetadata;
      expect(meta.title, 'Breaking Bad');
      expect(meta.status, 'Ended');
      expect(meta.network, 'AMC');
      expect(meta.seasonCount, 5);
      expect(meta.episodeCount, 62);
    });

    test('TvCatalog and TvEntry round-trip and preserve all kind fields', () {
      final catalog = TvCatalog.fromJson({
        'id': 'tv_breaking_bad',
        'kind': 'tv',
        'title': 'Breaking Bad',
        'original_title': 'Breaking Bad',
        'synopsis':
            'A high school chemistry teacher turns to meth manufacturing.',
        'first_air_date': '2008-01-20T00:00:00.000Z',
        'last_air_date': '2013-09-29T00:00:00.000Z',
        'status': 'Ended',
        'network': 'AMC',
        'streaming_service': 'Netflix',
        'country': 'US',
        'original_language': 'en',
        'genres': ['Crime', 'Drama', 'Thriller'],
        'content_rating': 'TV-MA',
        'season_count': 5,
        'episode_count': 62,
        'episode_runtime_minutes': 47,
        'seasons': [
          {
            'season_number': 1,
            'title': 'Season 1',
            'air_date': '2008-01-20T00:00:00.000Z',
            'episode_count': 7,
            'episodes': [
              {
                'number': 1,
                'title': 'Pilot',
                'air_date': '2008-01-20T00:00:00.000Z',
                'runtime_minutes': 58,
              }
            ],
          }
        ],
        'cover_image_url': 'https://example.com/bb.jpg',
        'thumbnail_image_url': 'https://example.com/bb_thumb.jpg',
      });

      expect(catalog.id, 'tv_breaking_bad');
      expect(catalog.mediaKind, CatalogMediaKind.tv);
      expect(catalog.title, 'Breaking Bad');
      expect(catalog.network, 'AMC');
      expect(catalog.seasonCount, 5);
      expect(catalog.episodeCount, 62);
      expect(catalog.displayCoverUrl, 'https://example.com/bb_thumb.jpg');
      expect(catalog.seasons.first.episodes.first.title, 'Pilot');

      final envelope = catalog.toEnvelope();
      expect(envelope.kind, CatalogMediaKind.tv);
      expect(envelope.common.title, 'Breaking Bad');

      final json = catalog.toJson();
      final restored = TvCatalog.fromJson(json);
      expect(restored.id, 'tv_breaking_bad');
      expect(restored.seasonCount, 5);
      expect(restored.network, 'AMC');

      final shelfEntry = ShelfEntry(
        itemId: 'tv_breaking_bad',
        catalogItem: CatalogItem(
          identity: const LibraryItemIdentity(
            id: 'tv_breaking_bad',
            mediaKind: CatalogMediaKind.tv,
          ),
          kindMetadata: TvSeriesMetadata.fromJson(json),
        ),
      );

      final entry = TvEntry.fromShelf(shelfEntry);
      expect(entry.id, 'tv_breaking_bad');
      expect(entry.title, 'Breaking Bad');
    });
  });
}
