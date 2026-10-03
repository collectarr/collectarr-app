import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
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
    required this.entryMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
    required this.catalogSnapshots,
  });

  final CollectionCommandCoordinator coordinator;
  final LibraryEntryMutations entryMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;
  final CatalogSnapshotRepository catalogSnapshots;

  Future<void> editSelected({
    required List<LibraryWorkspaceSource> entries,
    required LibraryBulkEditSelection selection,
  }) async {
    final entryEntries = [
      for (final entry in entries)
        if (entry.libraryEntrySummary != null) entry,
    ];
    for (var index = 0; index < entryEntries.length; index++) {
      final entry = entryEntries[index];
      final libraryEntry = entry.libraryEntrySummary!;
      final catalogRef = libraryEntry.ref.localCatalogItemRef;
      final registration = libraryKindRegistrationForKind(
        catalogRef.mediaKind,
      );
      final updateCmd =
          libraryEntryEditForKind(registration.kind).buildBulkUpdateCommand(
        libraryEntryRef: libraryEntry.ref,
        condition: selection.condition,
        collectionValue: selection.collectionValue,
        locationId: selection.locationId,
        tags: selection.tags,
      );
      await coordinator.updateLibraryEntry(updateCmd, syncTracking: false);
      if (selection.rating != null || selection.readStatus != null) {
        await trackingMutations.syncEntryTrackingState(
          libraryEntry.ref,
          status: mediaTrackingStatusFromValue(selection.readStatus),
          rating: selection.rating,
        );
      }
    }
  }

  Future<void> moveSelectedToEntry(
    List<LibraryWorkspaceSource> entries, {
    String? defaultCondition,
    String? defaultLocationId,
    String? defaultReadStatus,
    String? defaultTags,
  }) async {
    final entriesToOwn = [
      for (final entry in entries)
        if (entry.libraryEntrySummary == null) entry,
    ];
    final wishlistedEntries = [
      for (final entry in entries)
        if (entry.isWishlisted && entry.libraryEntrySummary == null) entry,
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
              entry.trackingSummary?.libraryEntryRef.kind ??
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
      await coordinator.addLibraryEntry(addCmd);
    }
  }

  Future<void> moveSelectedToWishlist(
      List<LibraryWorkspaceSource> entries) async {
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final catalogItemRef =
          entry.libraryEntrySummary?.sourceCatalogRef ??
          entry.wishlistItem?.catalogRef;
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
    final entryEntries = [
      for (final entry in entries)
        if (entry.libraryEntrySummary != null) entry,
    ];
    for (var index = 0; index < entryEntries.length; index++) {
      await entryMutations
          .removeItem(entryEntries[index].libraryEntrySummary!.ref);
    }
  }

  Future<int> duplicateSelected(List<LibraryWorkspaceSource> entries) async {
    final entryEntries = [
      for (final entry in entries)
        if (entry.libraryEntrySummary != null) entry,
    ];
    for (var index = 0; index < entryEntries.length; index++) {
      final entry = entryEntries[index];
      final sourceRef = entry.libraryEntrySummary!.ref;
      final tracking = entry.trackingSummary == null
          ? null
          : LibraryEntryTrackingDraft(
              status: entry.trackingSummary!.status,
              rating: entry.trackingSummary!.rating,
              startedAt: entry.trackingSummary!.startedAt,
              finishedAt: entry.trackingSummary!.completedAt,
              notes: entry.trackingSummary!.notes,
            );
      final duplicated = await entryMutations.duplicateItem(
        sourceRef,
        tracking: tracking,
      );
      if (duplicated == null) {
        throw StateError(
          'Cannot duplicate ${sourceRef.kind.apiValue} item: ${sourceRef.key}',
        );
      }
    }
    return entryEntries.length;
  }

  Future<void> removeSelected(List<LibraryWorkspaceSource> entries) async {
    final entryEntries = [
      for (final entry in entries)
        if (entry.libraryEntrySummary != null) entry,
    ];
    final wishlistedEntries = [
      for (final entry in entries)
        if (entry.isWishlisted) entry,
    ];
    final trackedEntries = [
      for (final entry in entries)
        if (entry.trackingSummary != null && entry.libraryEntrySummary == null)
          entry,
    ];
    for (var index = 0; index < entryEntries.length; index++) {
      await entryMutations
          .removeItem(entryEntries[index].libraryEntrySummary!.ref);
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
