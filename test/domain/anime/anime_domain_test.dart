import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_domain.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
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
    final item = VideoCatalogItem.fromDto(dto);
    expect(item.work.title, 'Cowboy Bebop');
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
          title: 'Blu-ray Collector Edition',
          physicalFormat: 'Blu-ray',
          physicalFormatLabel: 'Blu-ray',
        ),
      ],
      video: const VideoCatalogDetails(
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
    expect(item.source.catalogItem?.editions, hasLength(1));
  });
}
