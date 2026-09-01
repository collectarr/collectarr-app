import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';

import '../../../helpers/test_data_factories.dart';

LibraryProjectionRuntime _makeItem(
  String id, {
  String? title,
  String? locationPath,
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem,
}) {
  final cat = testCatalogItem(
    id: id,
    kind: 'comic',
    title: title ?? 'Batman #1',
  );
  final source = ShelfEntry(
    itemId: id,
    catalogItem: cat,
    ownedItem: ownedItem,
    wishlistItem: wishlistItem,
    locationPath: locationPath,
  );
  final node = LibraryTitleNodeRef(titleItemId: id);
  final dto = const GenericWorkspaceProjector().projectTitle(
    source: source,
    node: node,
  );
  return LibraryProjectionItem(source: source, node: node, dto: dto);
}

void main() {
  test('leaves unsupported group identifiers opaque', () {
    final item = _makeItem('comic-1', title: 'Batman #1');

    final bucket = genericLibraryBucketLabelBuilder(
      LibraryBucketingContext(
        source: item.source,
        item: item,
        groupId: const DynamicLibraryGroupId('series'),
      ),
    );

    expect(bucket, 'series');
  });

  test('uses semantic fallback for a missing location', () {
    final item = _makeItem('comic-1');

    final bucket = genericLibraryBucketLabelBuilder(
      LibraryBucketingContext(
        source: item.source,
        item: item,
        groupId: LibraryStandardGroupIds.location,
      ),
    );

    expect(bucket, 'No location');
  });

  test('uses semantic fallback for an empty title', () {
    final item = _makeItem('comic-1', title: '   ');

    final bucket = genericLibraryBucketLabelBuilder(
      LibraryBucketingContext(
        source: item.source,
        item: item,
        groupId: LibraryStandardGroupIds.title,
      ),
    );

    expect(bucket, 'Unknown');
  });

  test('uses semantic fallbacks for ownership states', () {
    final catalogOnly = _makeItem('catalog-only');
    final owned = _makeItem(
      'owned',
      ownedItem: testOwnedItem(id: 'owned-1', itemId: 'owned', kind: 'comic'),
    );
    final wishlisted = _makeItem(
      'wishlisted',
      wishlistItem: testWishlistItem(itemId: 'wishlisted'),
    );

    String bucketFor(LibraryProjectionRuntime item) {
      return genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: item.source,
          item: item,
          groupId: LibraryStandardGroupIds.ownership,
        ),
      );
    }

    expect(bucketFor(catalogOnly), 'Catalog only');
    expect(bucketFor(owned), 'Owned');
    expect(bucketFor(wishlisted), 'Wishlist');
  });
}
