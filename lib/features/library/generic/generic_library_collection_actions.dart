import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/generic/generic_library_projection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenericLibraryCollectionActions {
  const GenericLibraryCollectionActions(this.mutations);

  final CollectionMutations mutations;

  Future<void> addOwned(GenericLibraryItem item) {
    return mutations.addItem(item.entry.id);
  }

  Future<void> removeOwned(GenericLibraryItem item) async {
    final owned = item.source.ownedItem;
    if (owned == null) {
      return;
    }
    await mutations.removeItem(owned);
  }

  Future<void> addWishlist(GenericLibraryItem item) {
    return mutations.addToWishlist(item.entry.id);
  }

  Future<void> removeWishlist(GenericLibraryItem item) {
    return mutations.removeFromWishlist(item.entry.id);
  }
}

final genericLibraryCollectionActionsProvider =
    Provider<GenericLibraryCollectionActions>((ref) {
  return GenericLibraryCollectionActions(
      ref.watch(collectionMutationsProvider));
});
