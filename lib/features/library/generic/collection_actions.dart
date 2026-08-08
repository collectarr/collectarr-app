import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryCollectionActions {
  const LibraryCollectionActions(this.mutations);

  final CollectionMutations mutations;

  Future<void> addOwned(LibraryProjectionItem item) {
    final anchor = resolveLibraryMutationAnchor(
      item: item,
      ownedItem: item.source.ownedItem,
      wishlistItem: item.source.wishlistItem,
    );
    final catalogItem = item.source.catalogItem!;
    return mutations.addOwnedItem(
      AddOwnedItemCommand(
        catalogRef: CatalogEntityRef(
          kind: catalogItem.kind,
          entityType: CatalogEntityType.ownedCopy,
          id: catalogItem.id,
        ),
        common: OwnedItemCommonDraft(
          editionId: anchor.editionId,
          variantId: anchor.variantId,
          bundleReleaseId: anchor.bundleReleaseId,
        ),
      ),
    );
  }

  Future<void> removeOwned(LibraryProjectionItem item) async {
    final owned = item.source.ownedItem;
    if (owned == null) {
      return;
    }
    await mutations.removeItem(owned);
  }

  Future<void> addWishlist(LibraryProjectionItem item) {
    final anchor = resolveLibraryMutationAnchor(
      item: item,
      ownedItem: item.source.ownedItem,
      wishlistItem: item.source.wishlistItem,
    );
    return mutations.addToWishlist(
      item.source.catalogItem!.id,
      anchorType: anchor.anchorType,
      editionId: anchor.editionId,
      variantId: anchor.variantId,
      bundleReleaseId: anchor.bundleReleaseId,
    );
  }

  Future<void> removeWishlist(LibraryProjectionItem item) {
    final anchor = resolveLibraryMutationAnchor(
      item: item,
      ownedItem: item.source.ownedItem,
      wishlistItem: item.source.wishlistItem,
    );
    return mutations.removeFromWishlist(
      item.source.catalogItem!.id,
      wishlistItemId: item.source.wishlistItem?.id,
      anchorType: anchor.anchorType,
      editionId: anchor.editionId,
      variantId: anchor.variantId,
      bundleReleaseId: anchor.bundleReleaseId,
    );
  }
}

final genericLibraryCollectionActionsProvider =
    Provider<LibraryCollectionActions>((ref) {
  return LibraryCollectionActions(ref.watch(collectionMutationsProvider));
});
