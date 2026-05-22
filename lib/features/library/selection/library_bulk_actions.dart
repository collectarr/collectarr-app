import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';

class LibraryBulkActions {
  const LibraryBulkActions(this.mutations);

  final CollectionMutations mutations;

  Future<void> editSelected({
    required List<ShelfEntry> entries,
    required LibraryBulkEditSelection selection,
  }) async {
    final ownedEntries = [
      for (final entry in entries)
        if (entry.ownedItem != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      final ownedItem = ownedEntries[index].ownedItem!;
      await mutations.updateItem(
        ownedItem,
        condition: selection.condition ?? ownedItem.condition,
        grade: selection.grade ?? ownedItem.grade,
        purchaseDate: ownedItem.purchaseDate,
        pricePaidCents: ownedItem.pricePaidCents,
        currency: ownedItem.currency,
        personalNotes: ownedItem.personalNotes,
        quantity: ownedItem.quantity,
        storageBox: selection.applyLocation ? null : ownedItem.storageBox,
        locationId:
            selection.applyLocation ? selection.locationId : ownedItem.locationId,
        indexNumber: ownedItem.indexNumber,
        coverPriceCents: ownedItem.coverPriceCents,
        rawOrSlabbed: ownedItem.rawOrSlabbed,
        gradingCompany: ownedItem.gradingCompany,
        graderNotes: ownedItem.graderNotes,
        signedBy: ownedItem.signedBy,
        keyComic: ownedItem.keyComic,
        keyReason: ownedItem.keyReason,
        rating: selection.rating ?? ownedItem.rating,
        readStatus: selection.readStatus ?? ownedItem.readStatus,
        tags: selection.tags ?? ownedItem.tags,
        notify: index == ownedEntries.length - 1,
      );
    }
  }

  Future<void> moveSelectedToOwned(
    List<ShelfEntry> entries, {
    String? defaultCondition,
    String? defaultGrade,
  }) async {
    final entriesToOwn = [
      for (final entry in entries)
        if (entry.ownedItem == null) entry,
    ];
    final lastWishlistedIndex =
        entriesToOwn.lastIndexWhere((entry) => entry.isWishlisted);
    for (var index = 0; index < entriesToOwn.length; index++) {
      await mutations.addItem(
        entriesToOwn[index].itemId,
        condition: defaultCondition,
        grade: defaultGrade,
        notify:
            index == entriesToOwn.length - 1 || index == lastWishlistedIndex,
      );
    }
  }

  Future<void> moveSelectedToWishlist(List<ShelfEntry> entries) async {
    for (var index = 0; index < entries.length; index++) {
      await mutations.addToWishlist(
        entries[index].itemId,
        notify: index == entries.length - 1,
      );
    }
    final ownedEntries = [
      for (final entry in entries)
        if (entry.ownedItem != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      await mutations.removeItem(
        ownedEntries[index].ownedItem!,
        notify: index == ownedEntries.length - 1,
      );
    }
  }

  Future<void> removeSelected(List<ShelfEntry> entries) async {
    final ownedEntries = [
      for (final entry in entries)
        if (entry.ownedItem != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      await mutations.removeItem(
        ownedEntries[index].ownedItem!,
        notify: index == ownedEntries.length - 1,
      );
    }
    final wishlistedEntries = [
      for (final entry in entries)
        if (entry.isWishlisted) entry,
    ];
    for (var index = 0; index < wishlistedEntries.length; index++) {
      await mutations.removeFromWishlist(
        wishlistedEntries[index].itemId,
        notify: index == wishlistedEntries.length - 1,
      );
    }
  }
}

List<ShelfEntry> selectedShelfEntries(
  List<LibraryProjectionItem> visibleItems,
  Set<String> selectedItemIds,
) {
  return [
    for (final item in visibleItems)
      if (selectedItemIds.contains(item.entry.id)) item.source,
  ];
}
