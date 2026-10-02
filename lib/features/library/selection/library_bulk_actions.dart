import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/collection_item_commands.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
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
    required this.catalogSnapshots,
  });

  final CollectionCommandCoordinator coordinator;
  final CollectionItemMutations ownedMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;
  final CatalogSnapshotRepository catalogSnapshots;

  Future<void> editSelected({
    required List<LibraryWorkspaceSource> entries,
    required LibraryBulkEditSelection selection,
  }) async {
    final ownedEntries = [
      for (final entry in entries)
        if (entry.collectionItemSummary != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      final entry = ownedEntries[index];
      final collectionItem = entry.collectionItemSummary!;
      final catalogRef = collectionItem.catalogRef ?? entry.catalogRef;
      if (catalogRef == null) {
        continue;
      }
      final registration = libraryKindRegistrationForKind(
        catalogRef.mediaKind,
      );
      final updateCmd =
          libraryOwnedEditForKind(registration.kind).buildBulkUpdateCommand(
        collectionItemRef: collectionItem.ref,
        condition: selection.condition,
        collectionValue: selection.collectionValue,
        locationId: selection.locationId,
        tags: selection.tags,
      );
      await coordinator.updateCollectionItem(updateCmd, syncTracking: false);
      if (selection.rating != null || selection.readStatus != null) {
        await trackingMutations.syncOwnedTrackingState(
          collectionItem.ref,
          catalogRef: catalogRef,
          isDigital: collectionItem.isDigital,
          targetRef: collectionItem.catalogRef ?? catalogRef,
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
        if (entry.collectionItemSummary == null) entry,
    ];
    final wishlistedEntries = [
      for (final entry in entries)
        if (entry.isWishlisted && entry.collectionItemSummary == null) entry,
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
          ? entry.wishlistItem?.catalogRef.kind ??
              entry.trackingSummary?.catalogRef.mediaKind ??
              CatalogMediaKind.unknown
          : entry.mediaKind;
      final common = LibraryAddCommonDraft(
        condition: defaultCondition,
        locationId: defaultLocationId,
        tags: defaultTags,
      );
      final catalogRef = entry.catalogRef;
      if (catalogRef == null || resolvedKind == CatalogMediaKind.unknown) {
        throw StateError(
          'Cannot add selected item without a typed catalog kind: '
          '${entry.itemId}',
        );
      }
      final catalogItem =
          await catalogSnapshots.findCandidateByRef(catalogRef.rootScope);
      if (catalogItem == null) {
        throw StateError(
          'Cannot add selected item without a persisted catalog snapshot: '
          '${entry.itemId}',
        );
      }
      final addCmd = libraryAddForKind(resolvedKind).buildCommand(
        catalogItem,
        common,
        libraryAddForKind(resolvedKind).createInitialDraft(),
        tracking: LibraryAddTrackingDraft(
          readStatus: defaultReadStatus,
        ),
      );
      await coordinator.addCollectionItem(addCmd);
    }
  }

  Future<void> moveSelectedToWishlist(
      List<LibraryWorkspaceSource> entries) async {
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final catalogItemRef = entry.catalogRef?.toCatalogItemRef() ??
          entry.collectionItemSummary?.catalogRef?.toCatalogItemRef() ??
          entry.wishlistItem?.catalogRef ??
          entry.trackingSummary?.catalogRef.toCatalogItemRef();
      if (catalogItemRef == null) {
        throw StateError(
          'Cannot move selected item to wishlist without a catalog reference: '
          '${entry.itemId}',
        );
      }
      await wishlistMutations.addToWishlist(
        catalogItemRef,
      );
    }
    final ownedEntries = [
      for (final entry in entries)
        if (entry.collectionItemSummary != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      await ownedMutations
          .removeItem(ownedEntries[index].collectionItemSummary!.ref);
    }
  }

  Future<int> duplicateSelected(List<LibraryWorkspaceSource> entries) async {
    final ownedEntries = [
      for (final entry in entries)
        if (entry.collectionItemSummary != null) entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      final entry = ownedEntries[index];
      final sourceRef = entry.collectionItemSummary!.ref;
      final tracking = entry.trackingSummary == null
          ? null
          : CollectionItemTrackingDraft(
              status: entry.trackingSummary!.status,
              rating: entry.trackingSummary!.rating,
              startedAt: entry.trackingSummary!.startedAt,
              finishedAt: entry.trackingSummary!.completedAt,
              notes: entry.trackingSummary!.notes,
            );
      final duplicated = await ownedMutations.duplicateItem(
        sourceRef,
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
        if (entry.collectionItemSummary != null) entry,
    ];
    final wishlistedEntries = [
      for (final entry in entries)
        if (entry.isWishlisted) entry,
    ];
    final trackedEntries = [
      for (final entry in entries)
        if (entry.trackingSummary != null &&
            entry.collectionItemSummary == null)
          entry,
    ];
    for (var index = 0; index < ownedEntries.length; index++) {
      await ownedMutations
          .removeItem(ownedEntries[index].collectionItemSummary!.ref);
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
