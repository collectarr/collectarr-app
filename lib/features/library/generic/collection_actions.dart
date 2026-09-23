import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryCollectionActions {
  const LibraryCollectionActions({
    required this.coordinator,
    required this.ownedMutations,
    required this.wishlistMutations,
    required this.catalogSnapshots,
  });

  final CollectionCommandCoordinator coordinator;
  final OwnedItemMutations ownedMutations;
  final WishlistMutations wishlistMutations;
  final CatalogSnapshotRepository catalogSnapshots;

  Future<void> addOwned(LibraryProjectionItem item) async {
    final catalogRef = item.source.catalogRef;
    if (catalogRef == null) return;
    final catalogItem =
        await catalogSnapshots.findCandidateByRef(catalogRef.rootScope);
    if (catalogItem == null) return;
    final registration = libraryKindRegistrationForKind(catalogItem.summary.kind);
    final targetRef = item.source.ownedSummary?.targetRef ??
        item.source.wishlistItem?.catalogRef ??
        item.source.catalogRef ??
        catalogItem.reference;
    await coordinator.addOwnedItem(
      libraryAddForKind(registration.kind).buildCommand(
        catalogItem,
        const LibraryAddCommonDraft(),
        libraryAddForKind(registration.kind).createInitialDraft(),
        targetRef: targetRef,
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
    catalogSnapshots: CatalogSnapshotRepository(
      ref.watch(localDatabaseProvider),
    ),
  );
});
