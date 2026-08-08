import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
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
      await mutations.updateOwnedItem(
        updateCmd,
        notify: index == ownedEntries.length - 1,
      );
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
    final lastWishlistedIndex =
        entriesToOwn.lastIndexWhere((entry) => entry.isWishlisted);
    for (var index = 0; index < entriesToOwn.length; index++) {
      final anchor = resolveLibraryMutationAnchor(
        ownedItem: entriesToOwn[index].ownedItem,
        wishlistItem: entriesToOwn[index].wishlistItem,
      );
      final entry = entriesToOwn[index];
      final addCmd = AddOwnedItemCommand(
        catalogRef: CatalogEntityRef(
          kind: entry.catalogItem?.kind ?? 'unknown',
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
      );
      await mutations.addOwnedItem(
        addCmd,
        notify: index == entriesToOwn.length - 1 || index == lastWishlistedIndex,
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
      final comicDetails = src.typedDetails is ComicOwnedDetails
          ? src.typedDetails as ComicOwnedDetails
          : null;
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
        details: comicDetails != null
            ? ComicOwnedDetailsDraft(
                rawOrSlabbed: comicDetails.rawOrSlabbed,
                gradingCompany: comicDetails.gradingCompany,
                graderNotes: comicDetails.graderNotes,
                signedBy: comicDetails.signedBy,
                labelType: comicDetails.labelType,
                certificationNumber: comicDetails.certificationNumber,
                keyComic: comicDetails.keyComic,
                keyReason: comicDetails.keyReason,
                coverPriceCents: comicDetails.coverPriceCents,
              )
            : const GenericOwnedDetailsDraft(),
      );
      await mutations.addOwnedItem(
        addCmd,
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
      if (selectedItemIds.contains(item.source.itemId)) item.source,
  ];
}
