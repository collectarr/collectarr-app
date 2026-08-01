import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('MangaWorkspaceProjector produces a typed dto with correct title', () {
    final dto = CatalogItemDto.fromJson({
      'id': 'manga-work-1',
      'kind': 'manga',
      'title': 'Vagabond',
      'original_language': 'ja',
      'sort_title': 'Vagabond',
    });

    expect(dto.id, 'manga-work-1');
    expect(dto.title, 'Vagabond');
  });

  test('Manga projector keeps work and personal data together', () {
    final catalogItem = CatalogItemDto(
      id: 'manga-1',
      kind: 'manga',
      title: 'Vagabond',
      itemNumber: '1',
      series: const CatalogSeriesDetails(
        seriesId: 'series-1',
        seriesTitle: 'Vagabond',
      ),
      publishing: const CatalogPublishingDetails(subtitle: 'Vol. 1'),
      editions: const [
        CatalogEditionDto(id: 'edition-1', title: 'Volume 1'),
      ],
    );
    final shelf = ShelfEntry(
      itemId: 'manga-1',
      catalogItem: catalogItem,
      ownedItem: testOwnedItem(
        id: 'owned-manga-1',
        itemId: 'manga-1',
        rawOrSlabbed: 'Raw',
        updatedAt: DateTime.utc(2026, 5, 30),
      ),
      trackingEntry: null,
      wishlistItem: null,
      locationPath: 'Shelf A / Box 3',
      watchSessions: const [],
      itemImages: const [],
      fallbackOwnerLabel: 'Andrei',
    );

    final dto = const MangaWorkspaceProjector().projectTitle(
      source: shelf,
      node: const LibraryTitleNodeRef(titleItemId: 'manga-1'),
    );

    expect(dto.seriesTitle, 'Vagabond');
    expect(shelf.catalogItem?.editions, hasLength(1));
  });
}
