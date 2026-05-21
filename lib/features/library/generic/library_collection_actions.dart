import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/generic/library_projection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryCollectionActions {
  const LibraryCollectionActions(this.mutations);

  final CollectionMutations mutations;

  Future<void> addOwned(LibraryProjectionItem item) {
    return mutations.addItem(item.entry.id);
  }

  Future<void> removeOwned(LibraryProjectionItem item) async {
    final owned = item.source.ownedItem;
    if (owned == null) {
      return;
    }
    await mutations.removeItem(owned);
  }

  Future<void> addWishlist(LibraryProjectionItem item) {
    return mutations.addToWishlist(item.entry.id);
  }

  Future<void> removeWishlist(LibraryProjectionItem item) {
    return mutations.removeFromWishlist(item.entry.id);
  }
}

final genericLibraryCollectionActionsProvider =
    Provider<LibraryCollectionActions>((ref) {
  return LibraryCollectionActions(
      ref.watch(collectionMutationsProvider));
});
