import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/catalog/anime_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_projector.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  group('Anime Kind Vertical Slice Tests (C2)', () {
    test('AnimeMetadata serializes and deserializes full domain fields', () {
      final metadata = AnimeMetadata(
        nativeTitle:
            'ÃƒÂ¨Ã¢â‚¬ËœÃ‚Â¬ÃƒÂ©Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â³',
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

      expect(restored.nativeTitle,
          'ÃƒÂ¨Ã¢â‚¬ËœÃ‚Â¬ÃƒÂ©Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â³');
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
        nativeTitle:
            'ÃƒÂ¨Ã¢â‚¬ËœÃ‚Â¬ÃƒÂ©Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â³',
        romajiTitle: 'Sousou no Frieren',
        englishTitle: 'Frieren: Beyond Journey\'s End',
        format: AnimeFormat.tv,
        season: AnimeSeason.fall,
        seasonYear: 2023,
        episodeCount: 28,
        airingStatus: AnimeAiringStatus.finished,
        sourceMaterial: AnimeSource.manga,
      );

      final shelfEntry = LibraryWorkspaceSource(
        itemId: 'anime_1',
        catalogData: testWorkspaceCatalogData(CatalogItemDto(
          identity: LibraryItemIdentity(
            id: 'anime_1',
            mediaKind: CatalogMediaKind.anime,
          ),
          kindMetadata: animeMeta,
        ).asShelfCatalogItem),
        ownedSummary: testOwnedSummary(testOwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'anime_1',
            kind: CatalogMediaKind.anime,
            entityType: CatalogEntityTypeId('work'),
          ),
          condition: 'Mint',
          updatedAt: DateTime.now(),
        )),
      );

      const projector = AnimeWorkspaceProjector();
      const node = LibraryWorkRef(
        workId: 'anime_1',
      );
      final dto = projector.project(
        source: shelfEntry,
        entity: node,
      );

      expect(dto.metadata?.nativeTitle,
          'ÃƒÂ¨Ã¢â‚¬ËœÃ‚Â¬ÃƒÂ©Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â³');
      expect(dto.metadata?.format, AnimeFormat.tv);
      expect(dto.metadata?.season, AnimeSeason.fall);
      expect(dto.metadata?.seasonYear, 2023);
      expect(dto.metadata?.episodeCount, 28);

      final ctx = LibraryProjectionContext<AnimeWorkspaceDto>(
        source: shelfEntry,
        node: node,
        dto: dto,
      );

      expect(AnimeWorkWorkspaceFields.nativeTitle.getValue(ctx),
          'ÃƒÂ¨Ã¢â‚¬ËœÃ‚Â¬ÃƒÂ©Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â³');
      expect(AnimeWorkWorkspaceFields.format.getValue(ctx), 'TV');
      expect(AnimeWorkWorkspaceFields.season.getValue(ctx), 'Fall');
      expect(AnimeWorkWorkspaceFields.seasonYear.getValue(ctx), 2023);
      expect(AnimeWorkWorkspaceFields.episodeCount.getValue(ctx), 28);
      expect(AnimeWorkWorkspaceFields.airingStatus.getValue(ctx),
          'Finished Airing');
      expect(AnimeWorkWorkspaceFields.sourceMaterial.getValue(ctx), 'Manga');
      expect(dto.video, isA<AnimeCatalogItem>());
    });
  });
}
