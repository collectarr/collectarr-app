import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryCollectionActions {
  const LibraryCollectionActions(this.mutations);

  final CollectionMutations mutations;

  Future<void> addOwned(LibraryProjectionItem item) {
    final anchor = resolveLibraryMutationAnchor(
      entry: item.entry,
      ownedItem: item.source.ownedItem,
      wishlistItem: item.source.wishlistItem,
    );
    return mutations.addItem(
      item.entry.id,
      anchorType: anchor.anchorType,
      editionId: anchor.editionId,
      variantId: anchor.variantId,
      bundleReleaseId: anchor.bundleReleaseId,
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
      entry: item.entry,
      ownedItem: item.source.ownedItem,
      wishlistItem: item.source.wishlistItem,
    );
    return mutations.addToWishlist(
      item.entry.id,
      anchorType: anchor.anchorType,
      editionId: anchor.editionId,
      variantId: anchor.variantId,
      bundleReleaseId: anchor.bundleReleaseId,
    );
  }

  Future<void> removeWishlist(LibraryProjectionItem item) {
    final anchor = resolveLibraryMutationAnchor(
      entry: item.entry,
      ownedItem: item.source.ownedItem,
      wishlistItem: item.source.wishlistItem,
    );
    return mutations.removeFromWishlist(
      item.entry.id,
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
  return LibraryCollectionActions(
      ref.watch(collectionMutationsProvider));
});
