import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';

class LibraryBulkActions {
  const LibraryBulkActions({
    required this.coordinator,
    required this.ownedMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
  });

  final CollectionCommandCoordinator coordinator;
  final OwnedItemMutations ownedMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;

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
      final updateCmd = UpdateOwnedItemCommand(
        ownedItemId: ownedItem.id,
        condition: selection.condition != null
            ? Patch.set(selection.condition)
            : const Patch.unchanged(),
        grade: selection.grade != null
            ? Patch.set(selection.grade)
            : const Patch.unchanged(),
        locationId: selection.locationId != null
            ? Patch.set(selection.locationId)
            : const Patch.unchanged(),
        rating: selection.rating != null
            ? Patch.set(selection.rating)
            : const Patch.unchanged(),
        readStatus: selection.readStatus != null
            ? Patch.set(selection.readStatus)
            : const Patch.unchanged(),
        tags: selection.tags != null
            ? Patch.set(selection.tags)
            : const Patch.unchanged(),
      );
      await coordinator.updateOwnedItem(updateCmd);
    }
  }

  Future<void> moveSelectedToOwned(
    List<ShelfEntry> entries, {
    String? defaultCondition,
    String? defaultGrade,
    String? defaultLocationId,
    String? defaultReadStatus,
    String? defaultTags,
  }) async {
    final entriesToOwn = [
      for (final entry in entries)
        if (entry.ownedItem == null) entry,
    ];
    final wishlistedEntries = [
      for (final entry in entries)
        if (entry.isWishlisted && entry.ownedItem == null) entry,
    ];
    for (var index = 0; index < wishlistedEntries.length; index++) {
      final anchor = resolveLibraryMutationAnchor(
        ownedItem: wishlistedEntries[index].ownedItem,
        wishlistItem: wishlistedEntries[index].wishlistItem,
      );
      await wishlistMutations.removeFromWishlist(
        wishlistedEntries[index].itemId,
        wishlistItemId: wishlistedEntries[index].wishlistItem?.id,
        anchorType: anchor.anchorType,
        editionId: anchor.editionId,
        variantId: anchor.variantId,
        bundleReleaseId: anchor.bundleReleaseId,
      );
    }
    for (var index = 0; index < entriesToOwn.length; index++) {
      final entry = entriesToOwn[index];
      final anchor = resolveLibraryMutationAnchor(
        ownedItem: entry.ownedItem,
        wishlistItem: entry.wishlistItem,
      );
      final addCmd = AddOwnedItemCommand(
        catalogRef: CatalogEntityRef(
          kind: entry.catalogItem?.kind ?? 'comic',
          entityType: CatalogEntityType.ownedCopy,
          id: entry.itemId,
        ),
        common: OwnedItemCommonDraft(
          editionId: anchor.editionId,
          variantId: anchor.variantId,
          bundleReleaseId: anchor.bundleReleaseId,
          condition: defaultCondition,
          grade: defaultGrade,
          locationId: defaultLocationId,
          readStatus: defaultReadStatus,
          tags: defaultTags,
        ),
        details: defaultDetailsDraftForKind(
          catalogMediaKindFromApiValue(entry.catalogItem?.kind),
        ),
      );
      await coordinator.addOwnedItem(addCmd);
    }
  }

  Future<void> moveSelectedToWishlist(List<ShelfEntry> entries) async {
    for (var index = 0; index < entries.length; index++) {
      await wishlistMutations.addToWishlist(entries[index].itemId);
    }
    final ownedEntries = [
      for (final entry in entries)
        if (entry.ownedItem != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      await ownedMutations.removeItem(ownedEntries[index].ownedItem!);
    }
  }

  Future<int> duplicateSelected(List<ShelfEntry> entries) async {
    final ownedEntries = [
      for (final entry in entries)
        if (entry.ownedItem != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      final src = ownedEntries[index].ownedItem!;
      final addCmd = AddOwnedItemCommand(
        catalogRef: CatalogEntityRef(
          kind: src.catalogRef.kind,
          entityType: CatalogEntityType.ownedCopy,
          id: src.itemId,
        ),
        common: OwnedItemCommonDraft(
          isDigital: src.isDigital,
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
          locationId: src.locationId,
          rating: src.rating,
          readStatus: src.readStatus,
          startedAt: src.startedAt,
          finishedAt: src.finishedAt,
          tags: src.tags,
        ),
        details: src.typedDetails.toDraft(),
      );
      await coordinator.addOwnedItem(addCmd);
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
    for (var index = 0; index < ownedEntries.length; index++) {
      await ownedMutations.removeItem(ownedEntries[index].ownedItem!);
    }
    for (var index = 0; index < wishlistedEntries.length; index++) {
      final anchor = resolveLibraryMutationAnchor(
        ownedItem: wishlistedEntries[index].ownedItem,
        wishlistItem: wishlistedEntries[index].wishlistItem,
      );
      await wishlistMutations.removeFromWishlist(
        wishlistedEntries[index].itemId,
        wishlistItemId: wishlistedEntries[index].wishlistItem?.id,
        anchorType: anchor.anchorType,
        editionId: anchor.editionId,
        variantId: anchor.variantId,
        bundleReleaseId: anchor.bundleReleaseId,
      );
    }
    for (var index = 0; index < trackedEntries.length; index++) {
      await trackingMutations.removeTrackingEntry(
        trackedEntries[index].trackingEntry!,
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
      if (selectedItemIds.contains(item.source.itemId)) item.source,
  ];
}
