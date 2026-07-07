import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('ComicWork parses issues and missing gaps', () {
    final dto = ComicWorkDto.fromJson({
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
          'title': 'Issue #1',
          'variants': [
            {
              'id': 'variant-1a',
              'name': 'A',
              'variant_type': 'foil',
              'is_primary': true,
            }
          ],
          'characters': ['Marko'],
          'story_arcs': ['Opening'],
          'genres': ['Sci-Fi'],
        },
        {
          'id': 'issue-2',
          'issue_number': '2',
          'title': 'Issue #2',
          'variants': const <dynamic>[],
        },
        {
          'id': 'issue-4',
          'issue_number': '4',
          'title': 'Issue #4',
          'variants': const <dynamic>[],
        },
      ],
      'kind': 'comic',
    });

    final work = ComicWork.fromDto(dto);

    expect(work.title, 'Saga');
    expect(work.issues, hasLength(3));
    expect(work.issues.first.variants, hasLength(1));
    expect(work.missingIssueNumbers, [3]);
  });

  test('ComicPersonalOverlay exposes slab and key markers', () {
    final catalogItem = CatalogItem(
      id: 'comic-1',
      kind: 'comic',
      title: 'Saga',
      itemNumber: '1',
      series: const CatalogSeriesDetails(seriesId: 'series-1', seriesTitle: 'Saga'),
      publishing: const CatalogPublishingDetails(subtitle: 'Director Cut'),
    );
    final metadataItem = LibraryMetadataItem.fromCatalogItem(catalogItem);
    final ownedItem = testOwnedItem(
      id: 'owned-comic-1',
      itemId: 'comic-1',
      rawOrSlabbed: 'Slabbed',
      gradingCompany: 'CGC',
      labelType: 'Gold',
      certificationNumber: '123456789',
      keyComic: true,
      keyReason: 'First appearance',
      lastBagBoardDate: DateTime.utc(2026, 5, 30),
      updatedAt: DateTime.utc(2026, 5, 30),
    );
    final shelf = ShelfEntry(
      itemId: 'comic-1',
      catalogItem: metadataItem,
      ownedItem: ownedItem,
      trackingEntry: null,
      wishlistItem: null,
      locationPath: 'Shelf A / Box 1',
      watchSessions: const [],
      itemImages: const [],
      fallbackOwnerLabel: 'Andrei',
    );

    final overlay = ComicPersonalOverlay.fromShelf(shelf);
    final details = overlay.toWorkspaceDetails();

    expect(overlay.isSlabbed, isTrue);
    expect(overlay.keyComic, isTrue);
    expect(overlay.gradingCompany, 'CGC');
    expect(details?.rawOrSlabbed, 'Slabbed');
    expect(details?.keyReason, 'First appearance');
  });

  test('Comic shelf builder keeps work and personal overlays together', () {
    final catalogItem = CatalogItem(
      id: 'comic-2',
      kind: 'comic',
      title: 'The Last Ronin',
      itemNumber: '1',
      series: const CatalogSeriesDetails(
        seriesId: 'series-2',
        seriesTitle: 'Teenage Mutant Ninja Turtles: The Last Ronin',
      ),
      publishing: const CatalogPublishingDetails(subtitle: 'Director Cut'),
    );
    final shelf = ShelfEntry(
      itemId: 'comic-2',
      catalogItem: LibraryMetadataItem.fromCatalogItem(catalogItem),
      ownedItem: testOwnedItem(
        id: 'owned-comic-2',
        itemId: 'comic-2',
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

    final entry = buildComicsLibraryWorkspaceEntryFromShelf(shelf);

    expect(entry.title, 'The Last Ronin');
    expect(entry.itemNumber, '1');
    expect(entry.comic?.rawOrSlabbed, 'Raw');
    expect(entry.series?.seriesTitle, 'Teenage Mutant Ninja Turtles: The Last Ronin');
    expect(entry.publishing?.subtitle, 'Director Cut');
  });
}
