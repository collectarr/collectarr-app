import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
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
      final runtime = libraryKindModuleForKind(
        catalogMediaKindFromApiValue(ownedItem.catalogRef.kind),
      );
      final updateCmd = runtime.edit.withTypedUpdatePayload(
        OwnedItemPatchCommand<OwnedDetailsDraft>(
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
          tags: selection.tags != null
              ? Patch.set(selection.tags)
              : const Patch.unchanged(),
        ),
      );
      await coordinator.updateOwnedItem(updateCmd, syncTracking: false);
      if (selection.rating != null || selection.readStatus != null) {
        await trackingMutations.syncOwnedTrackingEntry(
          ownedItem,
          status: mediaTrackingStatusFromValue(selection.readStatus),
          rating: selection.rating,
        );
      }
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
        anchor: anchor,
      );
    }
    for (var index = 0; index < entriesToOwn.length; index++) {
      final entry = entriesToOwn[index];
      final anchor = resolveLibraryMutationAnchor(
        ownedItem: entry.ownedItem,
        wishlistItem: entry.wishlistItem,
      );
      final resolvedKindStr = entry.catalogItem?.kind ??
          entry.wishlistItem?.catalogRef.kind ??
          entry.trackingEntry?.catalogRef.kind;
      final resolvedKind = catalogMediaKindFromApiValue(resolvedKindStr);
      final common = LibraryAddCommonDraft(
        condition: defaultCondition,
        grade: defaultGrade,
        locationId: defaultLocationId,
        tags: defaultTags,
      );
      final catalogItem = entry.catalogItem;
      if (catalogItem == null || resolvedKind == CatalogMediaKind.unknown) {
        throw StateError(
          'Cannot add selected item without a typed catalog kind: '
          '${entry.itemId}',
        );
      }
      final addCmd = libraryKindModuleForKind(resolvedKind).add.buildCommand(
            catalogItem,
            common,
            libraryKindModuleForKind(resolvedKind).add.createInitialDraft(),
            anchor: anchor,
            tracking: LibraryAddTrackingDraft(
              readStatus: defaultReadStatus,
            ),
          );
      await coordinator.addOwnedItem(addCmd);
    }
  }

  Future<void> moveSelectedToWishlist(List<ShelfEntry> entries) async {
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final catalogRef = entry.catalogItem?.catalogRefForPersonalAnchor(null) ??
          entry.ownedItem?.catalogRef ??
          entry.wishlistItem?.catalogRef ??
          entry.trackingEntry?.catalogRef;
      if (catalogRef == null) {
        throw StateError(
          'Cannot move selected item to wishlist without a catalog reference: '
          '${entry.itemId}',
        );
      }
      await wishlistMutations.addToWishlist(
        catalogRef,
      );
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
      final entry = ownedEntries[index];
      final src = entry.ownedItem!;
      final runtime = libraryKindModuleForKind(
        catalogMediaKindFromApiValue(src.catalogRef.kind),
      );
      final catalogItem = entry.catalogItem;
      final tracking = entry.trackingEntry == null
          ? null
          : LibraryAddTrackingDraft(
              readStatus: mediaTrackingStatusToStorageValue(
                entry.trackingEntry!.status,
              ),
              rating: entry.trackingEntry!.rating,
              startedAt: entry.trackingEntry!.startedAt,
              finishedAt: entry.trackingEntry!.finishedAt,
              notes: entry.trackingEntry!.notes,
            );
      final typedCommand = catalogItem == null
          ? null
          : runtime.add.buildCommandFromOwnedItem(
              catalogItem,
              src,
              anchor: src.anchor,
              tracking: tracking ?? const LibraryAddTrackingDraft(),
            );
      if (typedCommand == null) {
        throw StateError(
          'Cannot duplicate ${src.catalogRef.kind} item without a typed '
          'catalog payload: ${src.itemId}',
        );
      }
      final addCmd = typedCommand;
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
        anchor: anchor,
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
