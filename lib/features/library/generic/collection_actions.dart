import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_item.dart';
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
    final anchor = resolveLibraryMutationAnchor(
      item: item,
      ownedItem: item.source.ownedItem,
      wishlistItem: item.source.wishlistItem,
    );
    final catalogItem = item.source.catalogItem!;
    final runtime = libraryKindModuleForKind(
      catalogMediaKindFromApiValue(catalogItem.kind),
    );
    return coordinator.addOwnedItem(
      runtime.add.buildCommand(
        LibraryAddCatalogItem.fromItem(catalogItem),
        const LibraryAddCommonDraft(),
        runtime.add.createInitialDraft(),
        anchor: anchor,
      ),
    );
  }

  Future<void> removeOwned(LibraryProjectionItem item) async {
    final owned = item.source.ownedItem;
    if (owned == null) {
      return;
    }
    await ownedMutations.removeItem(owned.ref);
  }

  Future<void> addWishlist(LibraryProjectionItem item) {
    final anchor = resolveLibraryMutationAnchor(
      item: item,
      ownedItem: item.source.ownedItem,
      wishlistItem: item.source.wishlistItem,
    );
    return wishlistMutations.addToWishlist(
      item.source.catalogItem!.catalogRefForPersonalAnchor(anchor),
    );
  }

  Future<void> removeWishlist(LibraryProjectionItem item) {
    final anchor = resolveLibraryMutationAnchor(
      item: item,
      ownedItem: item.source.ownedItem,
      wishlistItem: item.source.wishlistItem,
    );
    return wishlistMutations.removeFromWishlist(
      wishlistItemId: item.source.wishlistItem?.id,
      catalogRef: item.source.catalogItem!.catalogRefForPersonalAnchor(anchor),
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
