import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_domain.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  group('Anime Domain & Metadata Tests', () {
    test('Anime work parses metadata and projects correctly', () {
      final dto = CatalogItemDto.fromJson({
        'id': 'anime-series-1',
        'kind': 'anime',
        'title': 'Cowboy Bebop',
        'synopsis': 'A bounty-hunting crew.',
        'original_language': 'ja',
        'sort_title': 'Cowboy Bebop',
      });

      expect(dto.id, 'anime-series-1');
      expect(dto.title, 'Cowboy Bebop');
    });

    test('projects Anime item from shelf entry', () {
      final catalogItem = CatalogItemDto(
        id: 'anime-1',
        kind: 'anime',
        title: 'Cowboy Bebop',
        series: const CatalogSeriesDetailsDto(
          seriesTitle: 'Cowboy Bebop',
        ),
        editions: const [
          CatalogEdition(
            id: 'ed-1',
            title: 'Blu-ray Collector Edition',
            physicalFormat: 'Blu-ray',
            physicalFormatLabel: 'Blu-ray',
          ),
        ],
        video: const {
          'runtime_minutes': 24,
        },
      );

      final shelf = ShelfEntry(
        itemId: 'anime-1',
        catalogItem: catalogItem,
        ownedItem: testOwnedItem(
          id: 'owned-anime-1',
          itemId: 'anime-1',
          updatedAt: DateTime.utc(2026, 5, 30),
        ),
        trackingEntry: null,
        wishlistItem: null,
        locationPath: 'Shelf B / Box 2',
        watchSessions: const [],
        itemImages: const [],
        fallbackOwnerLabel: 'Andrei',
      );

      const node = LibraryTitleNodeRef(titleItemId: 'anime-1');
      final dto = const AnimeWorkspaceProjector().projectTitle(
        source: shelf,
        node: node,
      );
      final item = LibraryProjectionItem(
        source: shelf,
        node: node,
        dto: dto,
      );

      expect(item.dto.seriesTitle, 'Cowboy Bebop');
      expect(item.source.catalogItem?.toCatalogItem().editions, hasLength(1));
    });

    test('AnimeMetadata serialization and deserialization roundtrip', () {
      final metadata = AnimeMetadata(
        nativeTitle: 'カウボーイビバップ',
        romajiTitle: 'Kaubōi Bibappu',
        englishTitle: 'Cowboy Bebop',
        alternateTitles: const ['COWBOY BEBOP'],
        format: AnimeFormat.tv,
        season: AnimeSeason.spring,
        seasonYear: 1998,
        episodeCount: 26,
        episodeRuntimeMinutes: 24,
        airingStatus: AnimeAiringStatus.finished,
        startDate: DateTime.utc(1998, 4, 3),
        endDate: DateTime.utc(1999, 4, 24),
        studios: const ['Sunrise'],
        producers: const ['Bandai Visual'],
        licensors: const ['Funimation', 'Crunchyroll'],
        sourceMaterial: AnimeSource.original,
        genres: const ['Action', 'Sci-Fi'],
        themes: const ['Space', 'Adult Cast'],
        country: 'JP',
        language: 'ja',
        relations: const [
          AnimeRelation(
            relationType: AnimeRelationType.sideStory,
            targetTitle: 'Cowboy Bebop: Knockin\' on Heaven\'s Door',
            targetId: 'movie-1',
          ),
        ],
      );

      final json = metadata.toJson();
      final fromJson = AnimeMetadata.fromJson(json);

      expect(fromJson.nativeTitle, 'カウボーイビバップ');
      expect(fromJson.romajiTitle, 'Kaubōi Bibappu');
      expect(fromJson.englishTitle, 'Cowboy Bebop');
      expect(fromJson.format, AnimeFormat.tv);
      expect(fromJson.season, AnimeSeason.spring);
      expect(fromJson.seasonYear, 1998);
      expect(fromJson.episodeCount, 26);
      expect(fromJson.airingStatus, AnimeAiringStatus.finished);
      expect(fromJson.sourceMaterial, AnimeSource.original);
      expect(fromJson.studios, contains('Sunrise'));
      expect(fromJson.relations, hasLength(1));
      expect(
          fromJson.relations.first.relationType, AnimeRelationType.sideStory);
      expect(fromJson.relations.first.targetTitle, contains('Heaven\'s Door'));
    });

    test('AnimeHierarchy models Title -> Season / Part -> Release -> Copy', () {
      const hierarchy = AnimeTitleHierarchy(
        titleId: 'anime-bebop',
        canonicalTitle: 'Cowboy Bebop',
        seasons: [
          AnimeSeasonHierarchyNode(
            seasonId: 'season-1',
            seasonNumber: 1,
            title: 'Season 1',
            episodeCount: 26,
            releases: ['us-bluray-collector', 'jp-dvd-box'],
          ),
        ],
        movies: ['knockin-on-heavens-door'],
      );

      expect(hierarchy.canonicalTitle, 'Cowboy Bebop');
      expect(hierarchy.seasons, hasLength(1));
      expect(hierarchy.seasons.first.episodeCount, 26);
      expect(hierarchy.seasons.first.releases, contains('us-bluray-collector'));
      expect(hierarchy.movies, contains('knockin-on-heavens-door'));
    });

    test('AnimeKindModule uses Anime-owned capabilities exclusively', () {
      expect(animeKindModule.kind, CatalogMediaKind.anime);
      expect(animeKindModule.add.kind, CatalogMediaKind.anime);
      expect(animeKindModule.add.createInitialDraft(), isA<AnimeAddDraft>());
      expect(animeKindModule.ownedDetailsCodec, isA<AnimeOwnedDetailsCodec>());
      expect(animeKindModule.defaultOwnedDetails(), isA<AnimeOwnedDetails>());
    });
  });
}
