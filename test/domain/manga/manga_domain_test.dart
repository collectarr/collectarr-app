import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_domain.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('MangaWork parses chapters and metadata', () {
    final dto = CatalogItemDto.fromJson({
      'id': 'manga-work-1',
      'title': 'Vagabond',
      'description': 'A wandering swordsman.',
      'first_publication_date': '1998-01-01T00:00:00.000Z',
      'original_language': 'ja',
      'sort_title': 'Vagabond',
      'subtitle': 'Chapter Zero',
      'chapters': [
        {'id': 'chapter-1', 'title': 'Chapter 1', 'chapter_number': '1'},
        {'id': 'chapter-2', 'title': 'Chapter 2', 'chapter_number': '2'},
      ],
      'kind': 'manga',
    });

    final work = MangaWork.fromDto(dto);

    expect(work.title, 'Vagabond');
    expect(work.chapters, hasLength(1));
    expect(work.displayEditionLabel, 'Vagabond');
  });

  test('Manga projector keeps work and personal data together', () {
    final catalogItem = CatalogItemDto(
      id: 'manga-1',
      kind: 'manga',
      title: 'Vagabond',
      issueNumber: '1',
      series: const CatalogSeriesDetails(
        seriesId: 'series-1',
        seriesTitle: 'Vagabond',
      ),
      publishing: const CatalogPublishingDetails(subtitle: 'Vol. 1'),
      editions: const [
        CatalogEdition(id: 'edition-1', name: 'Volume 1'),
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

    final item = const MangaWorkspaceProjector().project(
      source: shelf,
      node: const LibraryTitleNodeRef('manga-1'),
    );

    expect(item.dto.seriesTitle, 'Vagabond');
    expect(item.source.catalogItem?.editions, hasLength(1));
  });
}
