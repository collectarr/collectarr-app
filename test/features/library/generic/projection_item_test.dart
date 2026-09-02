import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  test('library projection prefers structured location path', () {
    final source = testShelfEntry(
      itemId: 'comic-1',
      kind: 'comic',
      title: 'Batman',
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        locationId: 'loc-1',
        personalNotes: 'Newsstand copy',
        rawOrSlabbed: 'Slabbed',
        gradingCompany: 'CGC',
        keyComic: true,
        keyReason: 'First appearance',
        updatedAt: DateTime.utc(2026, 5, 22),
      ),
      locationPath: 'Office › Shelf 2 › Short Box 1',
    );
    const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
    final dto = const GenericWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final projection = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    expect(projection.source.locationPath, 'Office › Shelf 2 › Short Box 1');
    expect(projection.source.ownedItem?.personalNotes, 'Newsstand copy');
  });

  test('library projection exposes bundle and release reference labels', () {
    final source1 = testShelfEntry(
      itemId: 'comic-2',
      kind: 'comic',
      title: 'Batman',
      ownedItem: testOwnedItem(
        id: 'owned-2',
        itemId: 'comic-2',
        bundleReleaseId: 'bundle-2',
        updatedAt: DateTime.utc(2026, 5, 23),
      ),
    );
    const node1 = LibraryTitleNodeRef(titleItemId: 'comic-2');
    final dto1 = const GenericWorkspaceProjector().projectTitle(
      source: source1,
      node: node1,
    );
    final bundleProjection = LibraryProjectionItem(
      source: source1,
      node: node1,
      dto: dto1,
    );

    final source2 = ShelfEntry(
      itemId: 'comic-3',
      catalogItem: LibraryMetadataItem.fromCatalogItem(
        testCatalogItem(
          id: 'comic-3',
          kind: 'comic',
          title: 'Detective Comics',
        ),
      ),
      wishlistItem: WishlistItem(
        id: 'wish-3',
        catalogRef: const CatalogEntityRef(
          kind: 'comic',
          entityType: CatalogEntityType.ownedCopy,
          id: 'comic-3',
        ),
        anchorType: 'variant',
        editionId: 'edition-3',
        variantId: 'variant-3',
        createdAt: DateTime.utc(2026, 5, 23),
        updatedAt: DateTime.utc(2026, 5, 23),
      ),
    );
    const node2 = LibraryTitleNodeRef(titleItemId: 'comic-3');
    final dto2 = const GenericWorkspaceProjector().projectTitle(
      source: source2,
      node: node2,
    );
    final wishlistProjection = LibraryProjectionItem(
      source: source2,
      node: node2,
      dto: dto2,
    );

    expect(bundleProjection.dto.title, 'Batman');
    expect(wishlistProjection.dto.title, 'Detective Comics');
  });
}
