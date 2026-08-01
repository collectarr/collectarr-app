import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_domain.dart';
import 'package:collectarr_app/features/library/kinds/anime/presentation.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('AnimeSeries parses episodes and metadata', () {
    final dto = CatalogItemDto.fromJson({
      'id': 'anime-series-1',
      'title': 'Cowboy Bebop',
      'description': 'A bounty-hunting crew.',
      'original_air_date': '1998-04-03T00:00:00.000Z',
      'original_language': 'ja',
      'sort_title': 'Cowboy Bebop',
      'status': 'Finished',
      'episode_count': 26,
      'episodes': [
        {'id': 'ep-1', 'title': 'Asteroid Blues', 'episode_number': '1'},
        {'id': 'ep-2', 'title': 'Stray Dog Strut', 'episode_number': '2'},
      ],
    });

    final series = AnimeSeries.fromDto(dto);

    expect(series.id, 'anime-series-1');
    expect(series.title, 'Cowboy Bebop');
    expect(series.episodes, hasLength(2));
    expect(series.episodes.first.title, 'Asteroid Blues');
  });

  test('projects Anime item from shelf entry', () {
    final catalogItem = CatalogItemDto(
      id: 'anime-1',
      kind: 'anime',
      title: 'Cowboy Bebop',
      series: const CatalogSeriesDetails(
        seriesTitle: 'Cowboy Bebop',
      ),
      editions: const [
        CatalogEdition(
          id: 'ed-1',
          name: 'Blu-ray Collector Edition',
          physicalFormat: 'Blu-ray',
          physicalFormatLabel: 'Blu-ray',
        ),
      ],
      video: const CatalogVideoDetails(
        runtimeMinutes: 24,
      ),
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

    final item = const AnimeWorkspaceProjector().project(
      source: shelf,
      node: const LibraryTitleNodeRef('anime-1'),
    );

    expect(item.dto.seriesTitle, 'Cowboy Bebop');
    expect(item.source.catalogItem?.editions, hasLength(1));
  });
}
