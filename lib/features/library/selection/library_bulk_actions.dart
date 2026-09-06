import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
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
        tags: selection.tags != null
            ? Patch.set(selection.tags)
            : const Patch.unchanged(),
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
      final tracking = OwnedItemTrackingDraft(
        status: mediaTrackingStatusFromValue(defaultReadStatus),
      );
      final catalogItem = entry.catalogItem;
      final addCmd =
          catalogItem == null || resolvedKind == CatalogMediaKind.unknown
              ? AddOwnedItemCommand(
                  catalogRef: CatalogEntityRef(
                    kind: resolvedKindStr ?? 'comic',
                    entityType: CatalogEntityType.ownedCopy,
                    id: entry.itemId,
                  ),
                  anchor: anchor,
                  common: common.toOwnedItemCommonDraft(),
                  tracking: tracking,
                  details: libraryKindOwnedDetailsDraftForKind(resolvedKind),
                )
              : libraryKindRuntimeForKind(resolvedKind).add.buildCommand(
                    catalogItem,
                    common,
                    libraryKindRuntimeForKind(resolvedKind)
                        .add
                        .createInitialDraft(),
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
      await wishlistMutations.addToWishlist(
        entries[index].itemId,
        fallbackKind: entries[index].catalogItem?.kind ??
            entries[index].ownedItem?.catalogRef.kind,
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
      final runtime = libraryKindRuntimeForKind(
        catalogMediaKindFromApiValue(src.catalogRef.kind),
      );
      final catalogItem = entry.catalogItem;
      final common = LibraryAddCommonDraft(
        isDigital: src.isDigital,
        condition: src.condition,
        grade: src.grade,
        purchaseDate: src.purchaseDate,
        pricePaidCents: src.pricePaidCents,
        currency: src.currency,
        personalNotes: src.personalNotes,
        quantity: src.quantity,
        locationId: src.locationId,
        purchaseStore: src.purchaseStore,
        collectionStatus: src.collectionStatus,
        tags: src.tags,
      );
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
      final details = runtime.ownedDetailsDraftFromDetails(src.details);
      final addCmd =
          catalogItem == null || runtime.kind == CatalogMediaKind.unknown
              ? AddOwnedItemCommand(
                  catalogRef: CatalogEntityRef(
                    kind: src.catalogRef.kind,
                    entityType: CatalogEntityType.ownedCopy,
                    id: src.itemId,
                  ),
                  anchor: src.anchor,
                  common: common.toOwnedItemCommonDraft(),
                  tracking: entry.trackingEntry == null
                      ? null
                      : OwnedItemTrackingDraft(
                          status: entry.trackingEntry!.status,
                          rating: entry.trackingEntry!.rating,
                          startedAt: entry.trackingEntry!.startedAt,
                          finishedAt: entry.trackingEntry!.finishedAt,
                          notes: entry.trackingEntry!.notes,
                        ),
                  details: details,
                )
              : runtime.add.buildCommandFromDetails(
                  catalogItem,
                  common,
                  details,
                  anchor: src.anchor,
                  tracking: tracking ?? const LibraryAddTrackingDraft(),
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
