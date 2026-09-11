import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
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
    required List<LibraryWorkspaceSource> entries,
    required LibraryBulkEditSelection selection,
  }) async {
    final ownedEntries = [
      for (final entry in entries)
        if (entry.ownedSummary != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      final entry = ownedEntries[index];
      final ownedItem = entry.ownedSummary!;
      final catalogRef = ownedItem.catalogRef ?? entry.catalogRef;
      if (catalogRef == null) {
        continue;
      }
      final kindModule = libraryKindModuleForKind(
        catalogRef.mediaKind,
      );
      final updateCmd = kindModule.edit.buildBulkUpdateCommand(
        ownedRef: ownedItem.ref,
        condition: selection.condition,
        collectionValue: selection.collectionValue,
        locationId: selection.locationId,
        tags: selection.tags,
      );
      await coordinator.updateOwnedItem(updateCmd, syncTracking: false);
      if (selection.rating != null || selection.readStatus != null) {
        await trackingMutations.syncOwnedTrackingLifecycle(
          ownedItem.ref,
          catalogRef: catalogRef,
          isDigital: entry.typedOwnedItem == null
              ? null
              : collectarrTypedOwnedItemIsDigital(entry.typedOwnedItem!),
          targetRef: catalogRefForLibrarySelection(
            catalogRef,
            editionId: catalogRefEditionId(ownedItem.targetRef),
            variantId: catalogRefVariantId(ownedItem.targetRef),
            bundleReleaseId: catalogRefBundleReleaseId(ownedItem.targetRef),
          ),
          status: mediaTrackingStatusFromValue(selection.readStatus),
          rating: selection.rating,
        );
      }
    }
  }

  Future<void> moveSelectedToOwned(
    List<LibraryWorkspaceSource> entries, {
    String? defaultCondition,
    String? defaultLocationId,
    String? defaultReadStatus,
    String? defaultTags,
  }) async {
    final entriesToOwn = [
      for (final entry in entries)
        if (entry.ownedSummary == null) entry,
    ];
    final wishlistedEntries = [
      for (final entry in entries)
        if (entry.isWishlisted && entry.ownedSummary == null) entry,
    ];
    for (var index = 0; index < wishlistedEntries.length; index++) {
      await wishlistMutations.removeFromWishlist(
        wishlistItemId: wishlistedEntries[index].wishlistItem?.id,
        catalogRef: wishlistedEntries[index].wishlistItem?.catalogRef,
      );
    }
    for (var index = 0; index < entriesToOwn.length; index++) {
      final entry = entriesToOwn[index];
      final resolvedKind = entry.mediaKind == CatalogMediaKind.unknown
          ? entry.wishlistItem?.catalogRef.mediaKind ??
              entry.trackingSummary?.catalogRef.mediaKind ??
              CatalogMediaKind.unknown
          : entry.mediaKind;
      final common = LibraryAddCommonDraft(
        condition: defaultCondition,
        locationId: defaultLocationId,
        tags: defaultTags,
      );
      final catalogItem = entry.catalogTransport;
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
            targetRef: entry.ownedSummary?.catalogRef ??
                entry.wishlistItem?.catalogRef ??
                entry.catalogRef,
            tracking: LibraryAddTrackingDraft(
              readStatus: defaultReadStatus,
            ),
          );
      await coordinator.addOwnedItem(addCmd);
    }
  }

  Future<void> moveSelectedToWishlist(
      List<LibraryWorkspaceSource> entries) async {
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final catalogRef = entry.catalogRef ??
          entry.ownedSummary?.catalogRef ??
          entry.wishlistItem?.catalogRef ??
          entry.trackingSummary?.catalogRef;
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
        if (entry.ownedSummary != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      await ownedMutations.removeItem(ownedEntries[index].ownedSummary!.ref);
    }
  }

  Future<int> duplicateSelected(List<LibraryWorkspaceSource> entries) async {
    final ownedEntries = [
      for (final entry in entries)
        if (entry.ownedSummary != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      final entry = ownedEntries[index];
      final sourceRef = entry.ownedSummary!.ref;
      final tracking = entry.trackingSummary == null
          ? null
          : OwnedItemTrackingDraft(
              status: entry.trackingSummary!.status,
              rating: entry.trackingSummary!.rating,
              startedAt: entry.trackingSummary!.startedAt,
              finishedAt: entry.trackingSummary!.completedAt,
              notes: entry.trackingSummary!.notes,
            );
      final duplicated = await ownedMutations.duplicateItem(
        sourceRef,
        targetRef: entry.catalogRef,
        tracking: tracking,
      );
      if (duplicated == null) {
        throw StateError(
          'Cannot duplicate ${sourceRef.kind.apiValue} item: ${sourceRef.key}',
        );
      }
    }
    return ownedEntries.length;
  }

  Future<void> removeSelected(List<LibraryWorkspaceSource> entries) async {
    final ownedEntries = [
      for (final entry in entries)
        if (entry.ownedSummary != null) entry,
    ];
    final wishlistedEntries = [
      for (final entry in entries)
        if (entry.isWishlisted) entry,
    ];
    final trackedEntries = [
      for (final entry in entries)
        if (entry.trackingSummary != null && entry.ownedSummary == null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      await ownedMutations.removeItem(ownedEntries[index].ownedSummary!.ref);
    }
    for (var index = 0; index < wishlistedEntries.length; index++) {
      await wishlistMutations.removeFromWishlist(
        wishlistItemId: wishlistedEntries[index].wishlistItem?.id,
        catalogRef: wishlistedEntries[index].wishlistItem?.catalogRef,
      );
    }
    for (var index = 0; index < trackedEntries.length; index++) {
      await trackingMutations.removeTrackingByRef(
        trackedEntries[index].trackingSummary!.ref,
      );
    }
  }
}

List<LibraryWorkspaceSource> selectedShelfEntries(
  List<LibraryProjectionItem> visibleItems,
  Set<String> selectedItemIds,
) {
  return [
    for (final item in visibleItems)
      if (selectedItemIds.contains(item.source.itemId)) item.source,
  ];
}
