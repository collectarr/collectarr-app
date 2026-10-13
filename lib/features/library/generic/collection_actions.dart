import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryCollectionActions {
  const LibraryCollectionActions({
    required this.coordinator,
    required this.entryMutations,
    required this.wishlistMutations,
    required this.catalogSnapshots,
  });

  final CollectionCommandCoordinator coordinator;
  final LibraryEntryMutations entryMutations;
  final WishlistMutations wishlistMutations;
  final CatalogSnapshotRepository catalogSnapshots;

  Future<void> addEntry(LibraryProjectionItem item) async {
    final target = item.target;
    if (target is! CatalogTargetRef) return;
    final catalogRef = target.ref;
    final catalogItem = await catalogSnapshots.findCandidateByRef(catalogRef);
    if (catalogItem == null) return;
    final registration =
        libraryKindRegistrationForKind(catalogItem.summary.kind);
    await coordinator.addLibraryEntry(
      libraryAddForKind(registration.kind).buildCommand(
        catalogItem,
        const LibraryAddCommonDraft(),
        libraryAddForKind(registration.kind).createInitialDraft(),
      ),
    );
  }

  Future<void> removeEntry(LibraryProjectionItem item) async {
    final libraryEntryRef = item.source.libraryEntryRef;
    if (libraryEntryRef == null) {
      return;
    }
    await entryMutations.removeItem(libraryEntryRef);
  }

  Future<void> addWishlist(LibraryProjectionItem item) {
    final targetRef = resolveLibraryMutationTargetFromSummary(
      item: item,
      libraryEntry: item.source.libraryEntrySummary,
      wishlistItem: item.source.wishlistItem,
    );
    final catalogRef = targetRef;
    if (catalogRef == null) return Future<void>.value();
    return wishlistMutations.addToWishlist(catalogRef);
  }

  Future<void> removeWishlist(LibraryProjectionItem item) {
    final targetRef = resolveLibraryMutationTargetFromSummary(
      item: item,
      libraryEntry: item.source.libraryEntrySummary,
      wishlistItem: item.source.wishlistItem,
    );
    final catalogRef = targetRef;
    return wishlistMutations.removeFromWishlist(
      wishlistItemId: item.source.wishlistItem?.id,
      catalogRef: catalogRef,
    );
  }
}

final genericLibraryCollectionActionsProvider =
    Provider<LibraryCollectionActions>((ref) {
  return LibraryCollectionActions(
    coordinator: ref.watch(collectionCommandCoordinatorProvider),
    entryMutations: ref.watch(libraryEntryMutationsProvider),
    wishlistMutations: ref.watch(wishlistMutationsProvider),
    catalogSnapshots: CatalogSnapshotRepository(
      ref.watch(localDatabaseProvider),
    ),
  );
});
