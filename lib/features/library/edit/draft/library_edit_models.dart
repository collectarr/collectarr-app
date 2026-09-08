import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';

// ---------------------------------------------------------------------------
// Selection data classes returned by the edit dialog
// ---------------------------------------------------------------------------

enum LibraryEditSubmitAction {
  save,
  saveAndNext,
}

typedef LibraryTrackingEntryMutation = TrackingEntry Function(
  TrackingEntry entry,
);

class LibraryEditSelection {
  const LibraryEditSelection({
    required this.item,
    required this.personal,
    this.scope = LibraryEditScope.media,
    this.wishlist,
    this.tracking,
    this.trackingEntryMutation,
    this.ownedUpdatePayload,
    this.customFieldEdits = const {},
    this.itemImageEdits = const [],
    this.submitAction = LibraryEditSubmitAction.save,
  });

  final dynamic item;
  final LibraryPersonalEditSelection? personal;
  final LibraryEditScope scope;
  final LibraryWishlistEditSelection? wishlist;
  final LibraryTrackingEditSelection? tracking;
  final LibraryTrackingEntryMutation? trackingEntryMutation;
  final OwnedItemUpdatePayload<Object?>? ownedUpdatePayload;
  final Map<String, String?> customFieldEdits;
  final List<ItemImageEdit> itemImageEdits;
  final LibraryEditSubmitAction submitAction;

  LibraryEditSelection copyWith({
    dynamic item,
    LibraryPersonalEditSelection? personal,
    LibraryEditScope? scope,
    LibraryWishlistEditSelection? wishlist,
    LibraryTrackingEditSelection? tracking,
    LibraryTrackingEntryMutation? trackingEntryMutation,
    OwnedItemUpdatePayload<Object?>? ownedUpdatePayload,
    Map<String, String?>? customFieldEdits,
    List<ItemImageEdit>? itemImageEdits,
    LibraryEditSubmitAction? submitAction,
  }) {
    return LibraryEditSelection(
      item: item ?? this.item,
      personal: personal ?? this.personal,
      scope: scope ?? this.scope,
      wishlist: wishlist ?? this.wishlist,
      tracking: tracking ?? this.tracking,
      trackingEntryMutation:
          trackingEntryMutation ?? this.trackingEntryMutation,
      ownedUpdatePayload: ownedUpdatePayload ?? this.ownedUpdatePayload,
      customFieldEdits: customFieldEdits ?? this.customFieldEdits,
      itemImageEdits: itemImageEdits ?? this.itemImageEdits,
      submitAction: submitAction ?? this.submitAction,
    );
  }
}

class LibraryPersonalEditSelection {
  const LibraryPersonalEditSelection({
    required this.anchor,
    required this.condition,
    required this.purchaseDate,
    required this.pricePaidCents,
    required this.currency,
    required this.personalNotes,
    this.quantity = 1,
    required this.indexNumber,
    required this.locationId,
    this.locationChanged = false,
    required this.tags,
    this.soldAt,
    this.sellPriceCents,
    this.soldTo,
    this.purchaseStore,
    this.collectionStatus,
    this.marketValueCents,
    this.ownerLabel,
  });

  final PersonalItemAnchor? anchor;
  final String? condition;
  final DateTime? purchaseDate;
  final int? pricePaidCents;
  final String? currency;
  final String? personalNotes;
  final int quantity;
  final int? indexNumber;
  final String? locationId;
  final bool locationChanged;
  final String? tags;
  final DateTime? soldAt;
  final int? sellPriceCents;
  final String? soldTo;
  final String? purchaseStore;
  final String? collectionStatus;
  final int? marketValueCents;
  final String? ownerLabel;

  LibraryPersonalEditSelection copyWith({
    PersonalItemAnchor? anchor,
    String? condition,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int? quantity,
    int? indexNumber,
    String? locationId,
    bool? locationChanged,
    String? tags,
    DateTime? soldAt,
    int? sellPriceCents,
    String? soldTo,
    String? purchaseStore,
    String? collectionStatus,
    int? marketValueCents,
    String? ownerLabel,
  }) {
    return LibraryPersonalEditSelection(
      anchor: anchor ?? this.anchor,
      condition: condition ?? this.condition,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaidCents: pricePaidCents ?? this.pricePaidCents,
      currency: currency ?? this.currency,
      personalNotes: personalNotes ?? this.personalNotes,
      quantity: quantity ?? this.quantity,
      indexNumber: indexNumber ?? this.indexNumber,
      locationId: locationId ?? this.locationId,
      locationChanged: locationChanged ?? this.locationChanged,
      tags: tags ?? this.tags,
      soldAt: soldAt ?? this.soldAt,
      sellPriceCents: sellPriceCents ?? this.sellPriceCents,
      soldTo: soldTo ?? this.soldTo,
      purchaseStore: purchaseStore ?? this.purchaseStore,
      collectionStatus: collectionStatus ?? this.collectionStatus,
      marketValueCents: marketValueCents ?? this.marketValueCents,
      ownerLabel: ownerLabel ?? this.ownerLabel,
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
    required this.anchor,
    required this.rating,
    required this.readStatus,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    this.notes,
    this.startedAt,
    this.finishedAt,
  });

  final PersonalItemAnchor? anchor;
  final int? rating;
  final String? readStatus;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final String? notes;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  LibraryTrackingEditSelection copyWith({
    PersonalItemAnchor? anchor,
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
      anchor: anchor ?? this.anchor,
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
