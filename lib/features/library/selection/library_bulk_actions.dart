import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_item.dart';
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
        ownedItem.catalogRef.mediaKind,
      );
      final updateCmd = runtime.edit.buildBulkUpdateCommand(
        ownedRef: ownedItem.ref,
        condition: selection.condition,
        grade: selection.grade,
        locationId: selection.locationId,
        tags: selection.tags,
      );
      await coordinator.updateOwnedItem(updateCmd, syncTracking: false);
      if (selection.rating != null || selection.readStatus != null) {
        await trackingMutations.syncOwnedTrackingEntry(
          ownedItem.ref,
          catalogRef: ownedItem.catalogRef,
          isDigital: ownedItem.isDigital,
          anchor: ownedItem.anchor,
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
      await wishlistMutations.removeFromWishlist(
        wishlistItemId: wishlistedEntries[index].wishlistItem?.id,
        catalogRef: wishlistedEntries[index].wishlistItem?.catalogRef,
      );
    }
    for (var index = 0; index < entriesToOwn.length; index++) {
      final entry = entriesToOwn[index];
      final resolvedKind = entry.catalogItem?.mediaKind ??
          entry.wishlistItem?.catalogRef.mediaKind ??
          entry.trackingEntry?.catalogRef.mediaKind ??
          CatalogMediaKind.unknown;
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
            LibraryAddCatalogItem.fromItem(catalogItem),
            common,
            libraryKindModuleForKind(resolvedKind).add.createInitialDraft(),
            targetRef: entry.ownedItem?.catalogRef ??
                entry.wishlistItem?.catalogRef ??
                entry.catalogItem?.catalogRef,
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
      await ownedMutations.removeItem(ownedEntries[index].ownedItem!.ref);
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
        src.catalogRef.mediaKind,
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
              LibraryAddCatalogItem.fromItem(catalogItem),
              src,
              targetRef: src.catalogRef,
              tracking: tracking ?? const LibraryAddTrackingDraft(),
            );
      if (typedCommand == null) {
        throw StateError(
          'Cannot duplicate ${src.catalogRef.kind.apiValue} item without a typed '
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
      await ownedMutations.removeItem(ownedEntries[index].ownedItem!.ref);
    }
    for (var index = 0; index < wishlistedEntries.length; index++) {
      await wishlistMutations.removeFromWishlist(
        wishlistItemId: wishlistedEntries[index].wishlistItem?.id,
        catalogRef: wishlistedEntries[index].wishlistItem?.catalogRef,
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
