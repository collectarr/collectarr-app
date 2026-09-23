import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';

// ---------------------------------------------------------------------------
// Selection data classes returned by the edit dialog
// ---------------------------------------------------------------------------

enum LibraryEditSubmitAction {
  save,
  saveAndNext,
}

class LibraryEditSelection {
  const LibraryEditSelection({
    required this.kindItem,
    this.scope = LibraryEntityScope.work,
    this.wishlist,
    this.tracking,
    this.trackingKindPatch,
    this.ownedUpdatePayload,
    this.customFieldEdits = const {},
    this.itemImageEdits = const [],
    this.submitAction = LibraryEditSubmitAction.save,
  });

  /// The concrete catalog candidate returned to the owning kind and catalog
  /// mutation boundary. Generic edit rendering does not inspect it.
  final CatalogSearchCandidate kindItem;
  final LibraryEntityScope scope;
  final LibraryWishlistEditSelection? wishlist;
  final LibraryTrackingEditSelection? tracking;
  final TrackingKindPatch? trackingKindPatch;
  final OwnedItemUpdatePayload? ownedUpdatePayload;
  final Map<String, String?> customFieldEdits;
  final List<ItemImageEdit> itemImageEdits;
  final LibraryEditSubmitAction submitAction;

  LibraryEditSelection copyWith({
    CatalogSearchCandidate? kindItem,
    LibraryEntityScope? scope,
    LibraryWishlistEditSelection? wishlist,
    LibraryTrackingEditSelection? tracking,
    TrackingKindPatch? trackingKindPatch,
    OwnedItemUpdatePayload? ownedUpdatePayload,
    Map<String, String?>? customFieldEdits,
    List<ItemImageEdit>? itemImageEdits,
    LibraryEditSubmitAction? submitAction,
  }) {
    final nextKindItem = kindItem ?? this.kindItem;
    return LibraryEditSelection(
      kindItem: nextKindItem,
      scope: scope ?? this.scope,
      wishlist: wishlist ?? this.wishlist,
      tracking: tracking ?? this.tracking,
      trackingKindPatch: trackingKindPatch ?? this.trackingKindPatch,
      ownedUpdatePayload: ownedUpdatePayload ?? this.ownedUpdatePayload,
      customFieldEdits: customFieldEdits ?? this.customFieldEdits,
      itemImageEdits: itemImageEdits ?? this.itemImageEdits,
      submitAction: submitAction ?? this.submitAction,
    );
  }
}

class LibraryWishlistEditSelection {
  const LibraryWishlistEditSelection({
    required this.catalogRef,
    required this.targetPriceCents,
    required this.currency,
    required this.notes,
  });

  final CatalogEntityRef catalogRef;
  final int? targetPriceCents;
  final String? currency;
  final String? notes;
}

class LibraryTrackingEditSelection {
  const LibraryTrackingEditSelection({
    required this.targetRef,
    required this.rating,
    required this.readStatus,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    this.notes,
    this.startedAt,
    this.finishedAt,
  });

  final CatalogEntityRef? targetRef;
  final int? rating;
  final String? readStatus;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final String? notes;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  LibraryTrackingEditSelection copyWith({
    CatalogEntityRef? targetRef,
    int? rating,
    String? readStatus,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return LibraryTrackingEditSelection(
      targetRef: targetRef ?? this.targetRef,
      rating: rating ?? this.rating,
      readStatus: readStatus ?? this.readStatus,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      timesCompleted: timesCompleted ?? this.timesCompleted,
      notes: notes ?? this.notes,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
}
