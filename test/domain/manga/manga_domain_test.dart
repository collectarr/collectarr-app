import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_domain.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('MangaWork parses chapters and metadata', () {
    final dto = MangaWorkDto.fromJson({
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
    expect(work.chapters, hasLength(2));
    expect(work.displayEditionLabel, 'Chapter 1');
  });

  test('Manga shelf builder keeps work and personal data together', () {
    final catalogItem = CatalogItem(
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
        CatalogEdition(id: 'edition-1', title: 'Volume 1'),
      ],
    );
    final shelf = ShelfEntry(
      itemId: 'manga-1',
      catalogItem: LibraryMetadataItem.fromCatalogItem(catalogItem),
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

    final entry = buildMangaLibraryWorkspaceEntryFromShelf(shelf);

    expect(entry.comic, isNull);
    expect(entry.series?.seriesTitle, 'Vagabond');
    expect(entry.editions, hasLength(1));
  });
}
