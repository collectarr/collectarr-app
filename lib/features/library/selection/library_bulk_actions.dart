import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
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
    String? defaultLocationId,
    String? defaultStorageBox,
    String? defaultReadStatus,
    String? defaultTags,
  }) async {
    final entriesToOwn = [
      for (final entry in entries)
        if (entry.ownedItem == null) entry,
    ];
    final lastWishlistedIndex =
        entriesToOwn.lastIndexWhere((entry) => entry.isWishlisted);
    for (var index = 0; index < entriesToOwn.length; index++) {
      final anchor = resolveLibraryMutationAnchor(
        ownedItem: entriesToOwn[index].ownedItem,
        wishlistItem: entriesToOwn[index].wishlistItem,
      );
      await mutations.addItem(
        entriesToOwn[index].itemId,
        anchorType: anchor.anchorType,
        editionId: anchor.editionId,
        variantId: anchor.variantId,
        bundleReleaseId: anchor.bundleReleaseId,
        condition: defaultCondition,
        grade: defaultGrade,
        locationId: defaultLocationId,
        storageBox: defaultStorageBox,
        readStatus: defaultReadStatus,
        tags: defaultTags,
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

  Future<int> duplicateSelected(List<ShelfEntry> entries) async {
    final ownedEntries = [
      for (final entry in entries)
        if (entry.ownedItem != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      final src = ownedEntries[index].ownedItem!;
      await mutations.addItem(
        src.itemId,
        isDigital: src.isDigital,
        anchorType: src.anchorType,
        editionId: src.editionId,
        variantId: src.variantId,
        bundleReleaseId: src.bundleReleaseId,
        condition: src.condition,
        grade: src.grade,
        purchaseDate: src.purchaseDate,
        pricePaidCents: src.pricePaidCents,
        currency: src.currency,
        personalNotes: src.personalNotes,
        quantity: src.quantity,
        storageBox: src.storageBox,
        locationId: src.locationId,
        indexNumber: src.indexNumber,
        coverPriceCents: src.coverPriceCents,
        rawOrSlabbed: src.rawOrSlabbed,
        gradingCompany: src.gradingCompany,
        graderNotes: src.graderNotes,
        signedBy: src.signedBy,
        keyComic: src.keyComic,
        keyReason: src.keyReason,
        rating: src.rating,
        readStatus: src.readStatus,
        startedAt: src.startedAt,
        finishedAt: src.finishedAt,
        tags: src.tags,
        notify: index == ownedEntries.length - 1,
      );
    }
    return ownedEntries.length;
  }

  Future<void> removeSelected(List<ShelfEntry> entries) async {
    final ownedEntries = [
      for (final entry in entries)
        if (entry.ownedItem != null) entry,
    ];
    final wishlistedEntries = [
      for (final entry in entries)
        if (entry.isWishlisted) entry,
    ];
    final trackedEntries = [
      for (final entry in entries)
        if (entry.trackingEntry != null && entry.ownedItem == null) entry,
    ];
    final totalRemovals =
        ownedEntries.length + wishlistedEntries.length + trackedEntries.length;
    var completedRemovals = 0;
    for (var index = 0; index < ownedEntries.length; index++) {
      completedRemovals += 1;
      await mutations.removeItem(
        ownedEntries[index].ownedItem!,
        notify: completedRemovals == totalRemovals,
      );
    }
    for (var index = 0; index < wishlistedEntries.length; index++) {
      final anchor = resolveLibraryMutationAnchor(
        ownedItem: wishlistedEntries[index].ownedItem,
        wishlistItem: wishlistedEntries[index].wishlistItem,
      );
      completedRemovals += 1;
      await mutations.removeFromWishlist(
        wishlistedEntries[index].itemId,
        wishlistItemId: wishlistedEntries[index].wishlistItem?.id,
        anchorType: anchor.anchorType,
        editionId: anchor.editionId,
        variantId: anchor.variantId,
        bundleReleaseId: anchor.bundleReleaseId,
        notify: completedRemovals == totalRemovals,
      );
    }
    for (var index = 0; index < trackedEntries.length; index++) {
      completedRemovals += 1;
      await mutations.removeTrackingEntry(
        trackedEntries[index].trackingEntry!,
        notify: completedRemovals == totalRemovals,
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
