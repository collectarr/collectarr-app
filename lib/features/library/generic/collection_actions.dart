import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryCollectionActions {
  const LibraryCollectionActions({
    required this.coordinator,
    required this.ownedMutations,
    required this.wishlistMutations,
  });

  final CollectionCommandCoordinator coordinator;
  final OwnedItemMutations ownedMutations;
  final WishlistMutations wishlistMutations;

  Future<void> addOwned(LibraryProjectionItem item) {
    final catalogItem = item.source.catalogTransport!;
    final kindModule = libraryKindRegistrationForKind(catalogItem.mediaKind);
    return coordinator.addOwnedItem(
      kindModule.add.buildCommand(
        catalogItem,
        const LibraryAddCommonDraft(),
        kindModule.add.createInitialDraft(),
        targetRef: item.source.ownedSummary?.catalogRef ??
            item.source.wishlistItem?.catalogRef ??
            catalogItem.catalogRef,
      ),
    );
  }

  Future<void> removeOwned(LibraryProjectionItem item) async {
    final ownedRef = item.source.ownedRef;
    if (ownedRef == null) {
      return;
    }
    await ownedMutations.removeItem(ownedRef);
  }

  Future<void> addWishlist(LibraryProjectionItem item) {
    final targetRef = resolveLibraryMutationTargetFromSummary(
      item: item,
      ownedItem: item.source.ownedSummary,
      wishlistItem: item.source.wishlistItem,
    );
    final catalogRef = targetRef ?? item.source.catalogRef;
    if (catalogRef == null) return Future<void>.value();
    return wishlistMutations.addToWishlist(catalogRef);
  }

  Future<void> removeWishlist(LibraryProjectionItem item) {
    final targetRef = resolveLibraryMutationTargetFromSummary(
      item: item,
      ownedItem: item.source.ownedSummary,
      wishlistItem: item.source.wishlistItem,
    );
    return wishlistMutations.removeFromWishlist(
      wishlistItemId: item.source.wishlistItem?.id,
      catalogRef: targetRef ?? item.source.catalogRef,
    );
  }
}

final genericLibraryCollectionActionsProvider =
    Provider<LibraryCollectionActions>((ref) {
  return LibraryCollectionActions(
    coordinator: ref.watch(collectionCommandCoordinatorProvider),
    ownedMutations: ref.watch(ownedItemMutationsProvider),
    wishlistMutations: ref.watch(wishlistMutationsProvider),
  );
});
