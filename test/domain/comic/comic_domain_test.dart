import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('ComicWork parses issues from CatalogItemDto json', () {
    final dto = CatalogItemDto.fromJson({
      'id': 'comic-work-1',
      'title': 'Saga',
      'first_publication_date': '2024-05-01T00:00:00.000Z',
      'original_language': 'en',
      'sort_title': 'Saga',
      'subtitle': 'Chapter Zero',
      'synopsis': 'A sprawling space opera.',
      'kind': 'comic',
    });

    expect(dto.id, 'comic-work-1');
    expect(dto.title, 'Saga');
  });

  test('projects Comic item from shelf entry', () {
    final catalogItem = CatalogItemDto(
      id: 'comic-2',
      kind: 'comic',
      title: 'The Last Ronin',
      itemNumber: '1',
      publisher: 'IDW Publishing',
      synopsis: 'The final turtle seeks justice in a ruined future.',
      series: const CatalogSeriesDetails(
        seriesTitle: 'Teenage Mutant Ninja Turtles: The Last Ronin',
      ),
      publishing: const CatalogPublishingDetails(
        imprint: 'IDW',
        subtitle: 'Director Cut',
        seriesGroup: 'TMNT Event',
      ),
    );

    final shelf = ShelfEntry(
      itemId: 'comic-2',
      catalogItem: catalogItem,
      ownedItem: testOwnedItem(
        id: 'owned-comic-2',
        itemId: 'comic-2',
        kind: 'comic',
        rawOrSlabbed: 'Raw',
        keyComic: false,
        updatedAt: DateTime.utc(2026, 5, 30),
      ),
      trackingEntry: null,
      wishlistItem: null,
      locationPath: 'Shelf B / Box 2',
      watchSessions: const [],
      itemImages: const [],
      fallbackOwnerLabel: 'Andrei',
    );

    final dto = const ComicWorkspaceProjector().projectTitle(
      source: shelf,
      node: const LibraryTitleNodeRef(titleItemId: 'comic-2'),
    );

    expect(dto.title, 'The Last Ronin');
    expect(dto.itemNumber, '1');
    expect(dto.seriesTitle, 'Teenage Mutant Ninja Turtles: The Last Ronin');
  });
}
