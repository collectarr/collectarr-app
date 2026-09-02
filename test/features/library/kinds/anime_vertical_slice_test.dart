import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/contracts/anime_contracts.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_fields.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_projector.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Anime Kind Vertical Slice Tests (C2)', () {
    test('AnimeMetadata serializes and deserializes full domain fields', () {
      final metadata = AnimeMetadata(
        nativeTitle: '葬送のフリーレン',
        romajiTitle: 'Sousou no Frieren',
        englishTitle: 'Frieren: Beyond Journey\'s End',
        alternateTitles: const ['Frieren the Slayer'],
        format: AnimeFormat.tv,
        season: AnimeSeason.fall,
        seasonYear: 2023,
        episodeCount: 28,
        episodeRuntimeMinutes: 24,
        airingStatus: AnimeAiringStatus.finished,
        startDate: DateTime(2023, 9, 29),
        endDate: DateTime(2024, 3, 22),
        studios: const ['Madhouse'],
        producers: const ['TOHO animation', 'Shogakukan'],
        licensors: const ['Crunchyroll'],
        sourceMaterial: AnimeSource.manga,
        genres: const ['Adventure', 'Drama', 'Fantasy'],
        themes: const ['Magic', 'Time Skip'],
        country: 'JP',
        language: 'ja',
        relations: const [
          AnimeRelation(
            relationType: AnimeRelationType.sequel,
            targetTitle: 'Sousou no Frieren 2nd Season',
          ),
        ],
      );

      final json = metadata.toJson();
      final restored = AnimeMetadata.fromJson(json);

      expect(restored.nativeTitle, '葬送のフリーレン');
      expect(restored.romajiTitle, 'Sousou no Frieren');
      expect(restored.englishTitle, 'Frieren: Beyond Journey\'s End');
      expect(restored.format, AnimeFormat.tv);
      expect(restored.season, AnimeSeason.fall);
      expect(restored.seasonYear, 2023);
      expect(restored.episodeCount, 28);
      expect(restored.episodeRuntimeMinutes, 24);
      expect(restored.airingStatus, AnimeAiringStatus.finished);
      expect(restored.studios, contains('Madhouse'));
      expect(restored.producers, contains('TOHO animation'));
      expect(restored.sourceMaterial, AnimeSource.manga);
      expect(restored.relations.first.relationType, AnimeRelationType.sequel);
    });

    test('AnimeWorkspaceProjector projects metadata and schema fields', () {
      const animeMeta = AnimeMetadata(
        nativeTitle: '葬送のフリーレン',
        romajiTitle: 'Sousou no Frieren',
        englishTitle: 'Frieren: Beyond Journey\'s End',
        format: AnimeFormat.tv,
        season: AnimeSeason.fall,
        seasonYear: 2023,
        episodeCount: 28,
        airingStatus: AnimeAiringStatus.finished,
        sourceMaterial: AnimeSource.manga,
      );

      final shelfEntry = ShelfEntry(
        itemId: 'anime_1',
        catalogItem: const LibraryMetadataItem(
          identity: LibraryItemIdentity(
            id: 'anime_1',
            mediaKind: CatalogMediaKind.anime,
          ),
          kindMetadata: animeMeta,
        ),
        ownedItem: OwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'anime_1',
            kind: 'anime',
            entityType: CatalogEntityType.work,
          ),
          condition: 'Mint',
          updatedAt: DateTime.now(),
        ),
      );

      const projector = AnimeWorkspaceProjector();
      const node = LibraryTitleNodeRef(
        titleItemId: 'anime_1',
      );
      final dto = projector.projectTitle(
        source: shelfEntry,
        node: node,
      );

      expect(dto.metadata?.nativeTitle, '葬送のフリーレン');
      expect(dto.metadata?.format, AnimeFormat.tv);
      expect(dto.metadata?.season, AnimeSeason.fall);
      expect(dto.metadata?.seasonYear, 2023);
      expect(dto.metadata?.episodeCount, 28);

      final ctx = LibraryProjectionContext<AnimeWorkspaceDto>(
        source: shelfEntry,
        node: node,
        dto: dto,
      );

      expect(AnimeKindSchema.nativeTitle.getValue(ctx), '葬送のフリーレン');
      expect(AnimeKindSchema.format.getValue(ctx), 'TV');
      expect(AnimeKindSchema.season.getValue(ctx), 'Fall');
      expect(AnimeKindSchema.seasonYear.getValue(ctx), 2023);
      expect(AnimeKindSchema.episodeCount.getValue(ctx), 28);
      expect(AnimeKindSchema.airingStatus.getValue(ctx), 'Finished Airing');
      expect(AnimeKindSchema.sourceMaterial.getValue(ctx), 'Manga');
    });

    test(
        'AnimeLibraryKindProviderMapper parses full envelope into AnimeMetadata',
        () {
      const mapper = AnimeLibraryKindProviderMapper();
      final item = mapper.metadataItemFromEnvelope(
        NormalizedProviderEnvelopeV1(
          provider: 'anilist',
          providerItemId: '154587',
          kind: 'anime',
          normalized: const {
            'title': 'Frieren: Beyond Journey\'s End',
            'native_title': '葬送のフリーレン',
            'romaji_title': 'Sousou no Frieren',
            'format': 'tv',
            'season': 'fall',
            'season_year': 2023,
            'episode_count': 28,
            'airing_status': 'finished',
            'source_material': 'manga',
            'studios': ['Madhouse'],
          },
          images: const [],
          provenance: ProviderProvenance(
            fetchedAt: DateTime.now().toIso8601String(),
          ),
          attribution: const ProviderAttribution(required: false),
        ),
      );

      expect(item.kindMetadata, isA<AnimeMetadata>());
      final meta = item.kindMetadata as AnimeMetadata;
      expect(meta.nativeTitle, '葬送のフリーレン');
      expect(meta.format, AnimeFormat.tv);
      expect(meta.season, AnimeSeason.fall);
      expect(meta.seasonYear, 2023);
      expect(meta.episodeCount, 28);
      expect(meta.studios, contains('Madhouse'));
    });

    test('AnimeCatalog and AnimeEntry round-trip and preserve all kind fields',
        () {
      final catalog = AnimeCatalog.fromJson({
        'id': 'anime_frieren',
        'kind': 'anime',
        'title': 'Frieren: Beyond Journey\'s End',
        'native_title': '葬送のフリーレン',
        'romaji_title': 'Sousou no Frieren',
        'english_title': 'Frieren: Beyond Journey\'s End',
        'format': 'tv',
        'season': 'fall',
        'season_year': 2023,
        'episode_count': 28,
        'episode_runtime_minutes': 24,
        'airing_status': 'finished',
        'start_date': '2023-09-29T00:00:00.000Z',
        'end_date': '2024-03-22T00:00:00.000Z',
        'studios': ['Madhouse'],
        'producers': ['TOHO animation', 'Shogakukan'],
        'licensors': ['Crunchyroll'],
        'source_material': 'manga',
        'genres': ['Adventure', 'Drama', 'Fantasy'],
        'themes': ['Magic', 'Time Skip'],
        'country': 'JP',
        'language': 'ja',
        'relations': [
          {
            'relation_type': 'sequel',
            'target_title': 'Sousou no Frieren 2nd Season',
          }
        ],
        'synopsis': 'An elf mage and her companions defeat the Demon King.',
        'cover_image_url': 'https://example.com/frieren.jpg',
        'thumbnail_image_url': 'https://example.com/frieren_thumb.jpg',
      });

      expect(catalog.id, 'anime_frieren');
      expect(catalog.mediaKind, CatalogMediaKind.anime);
      expect(catalog.title, 'Frieren: Beyond Journey\'s End');
      expect(catalog.nativeTitle, '葬送のフリーレン');
      expect(catalog.studio, 'Madhouse');
      expect(catalog.displayCoverUrl, 'https://example.com/frieren_thumb.jpg');
      expect(catalog.relations.first.relationType, AnimeRelationType.sequel);

      final envelope = catalog.toEnvelope();
      expect(envelope.kind, CatalogMediaKind.anime);
      expect(envelope.common.title, 'Frieren: Beyond Journey\'s End');

      final json = catalog.toJson();
      final restored = AnimeCatalog.fromJson(json);
      expect(restored.id, 'anime_frieren');
      expect(restored.studios, contains('Madhouse'));
      expect(restored.seasonYear, 2023);

      final shelfEntry = ShelfEntry(
        itemId: 'anime_frieren',
        catalogItem: LibraryMetadataItem(
          identity: const LibraryItemIdentity(
            id: 'anime_frieren',
            mediaKind: CatalogMediaKind.anime,
          ),
          kindMetadata: AnimeMetadata.fromJson(json),
        ),
      );

      final entry = AnimeEntry.fromShelf(shelfEntry);
      expect(entry.id, 'anime_frieren');
      expect(entry.title, 'Frieren: Beyond Journey\'s End');
    });
  });
}
