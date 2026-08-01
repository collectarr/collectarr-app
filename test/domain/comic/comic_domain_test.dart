import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('ComicWork parses issues and missing gaps', () {
    final dto = CatalogItemDto.fromJson({
      'id': 'comic-work-1',
      'title': 'Saga',
      'first_publication_date': '2024-05-01T00:00:00.000Z',
      'original_language': 'en',
      'sort_title': 'Saga',
      'subtitle': 'Chapter Zero',
      'description': 'A sprawling space opera.',
      'contributors': const <dynamic>[],
      'issues': [
        {
          'id': 'issue-1',
          'issue_number': '1',
          'title': 'Chapter One',
          'cover_date': '2024-05-01T00:00:00.000Z',
          'sku': 'SKU-001',
          'barcode': '123456789',
        },
        {
          'id': 'issue-3',
          'issue_number': '3',
          'title': 'Chapter Three',
          'cover_date': '2024-07-01T00:00:00.000Z',
          'sku': 'SKU-003',
          'barcode': '123456791',
        },
      ],
    });

    final work = ComicWork.fromDto(dto);

    expect(work.id, 'comic-work-1');
    expect(work.title, 'Saga');
    expect(work.issues, hasLength(2));
    expect(work.issues.first.issueNumber, '1');
    expect(work.missingIssueNumbers(ownedIssueNumbers: const {'1'}), ['3']);
  });

  test('projects Comic item from shelf entry', () {
    final catalogItem = CatalogItemDto(
      id: 'comic-2',
      kind: 'comic',
      title: 'The Last Ronin',
      issueNumber: '1',
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
      comic: const CatalogComicDetails(
        rawOrSlabbed: 'Raw',
        keyComic: false,
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

    final item = const ComicWorkspaceProjector().project(
      source: shelf,
      node: const LibraryTitleNodeRef('comic-2'),
    );

    expect(item.dto.title, 'The Last Ronin');
    expect(item.dto.itemNumber, '1');
    expect(item.source.catalogItem?.comic?.rawOrSlabbed, 'Raw');
    expect(item.dto.seriesTitle, 'Teenage Mutant Ninja Turtles: The Last Ronin');
  });
}
