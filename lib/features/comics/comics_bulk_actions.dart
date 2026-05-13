import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_bulk_edit.dart';

class ComicsBulkActions {
  const ComicsBulkActions(this.mutations);

  final CollectionMutations mutations;

  Future<void> editSelected({
    required List<ShelfEntry> entries,
    required ComicsBulkEditSelection selection,
  }) async {
    for (final entry in entries) {
      final ownedItem = entry.ownedItem;
      if (ownedItem == null) {
        continue;
      }
      await mutations.updateItem(
        ownedItem,
        condition: selection.condition ?? ownedItem.condition,
        grade: selection.grade ?? ownedItem.grade,
        purchaseDate: ownedItem.purchaseDate,
        pricePaidCents: ownedItem.pricePaidCents,
        currency: ownedItem.currency,
        personalNotes: ownedItem.personalNotes,
        quantity: ownedItem.quantity,
        storageBox: selection.storageBox ?? ownedItem.storageBox,
        indexNumber: ownedItem.indexNumber,
        coverPriceCents: ownedItem.coverPriceCents,
        rawOrSlabbed: ownedItem.rawOrSlabbed,
        gradingCompany: ownedItem.gradingCompany,
        graderNotes: ownedItem.graderNotes,
        signedBy: ownedItem.signedBy,
        keyComic: ownedItem.keyComic,
        keyReason: ownedItem.keyReason,
        rating: ownedItem.rating,
        readStatus: selection.readStatus ?? ownedItem.readStatus,
        tags: selection.tags ?? ownedItem.tags,
      );
    }
  }

  Future<void> moveSelectedToOwned(List<ShelfEntry> entries) async {
    for (final entry in entries) {
      if (entry.ownedItem != null) {
        continue;
      }
      await mutations.addItem(
        entry.itemId,
        condition: 'Near Mint',
        grade: 'Ungraded',
      );
    }
  }

  Future<void> moveSelectedToWishlist(List<ShelfEntry> entries) async {
    for (final entry in entries) {
      await mutations.addToWishlist(entry.itemId);
      final ownedItem = entry.ownedItem;
      if (ownedItem != null) {
        await mutations.removeItem(ownedItem);
      }
    }
  }

  Future<void> removeSelected(List<ShelfEntry> entries) async {
    for (final entry in entries) {
      final ownedItem = entry.ownedItem;
      if (ownedItem != null) {
        await mutations.removeItem(ownedItem);
      }
      if (entry.isWishlisted) {
        await mutations.removeFromWishlist(entry.itemId);
      }
    }
  }
}

List<ShelfEntry> selectedComicsShelfEntries(
  List<ShelfEntry> visibleEntries,
  Set<String> selectedItemIds,
) {
  return [
    for (final entry in visibleEntries)
      if (selectedItemIds.contains(entry.itemId)) entry,
  ];
}
