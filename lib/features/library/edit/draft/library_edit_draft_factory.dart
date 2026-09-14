import 'package:collectarr_app/core/api/dto/bundle_release.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/material.dart';

/// Builds the mutable edit state from the typed Library boundary.
///
/// The draft class owns live form state; this factory owns the one-time
/// boundary-to-controller projection. Keeping the two separate prevents the
/// state object from also becoming the initialization policy for every kind.
LibraryEditDraft createLibraryEditDraft({
  required LibraryKindRegistration type,
  required CatalogSearchCandidate item,
  required OwnedItemSummary? ownedItem,
  LibraryOwnedItemDispatch? ownedItemDispatch,
  required WishlistItem? wishlistItem,
  required TrackingRecord? trackingLifecycle,
  required Color accent,
  List<BundleReleaseSummary> availableBundleReleases = const [],
  List<PhysicalMediaFormat> physicalFormats = const [],
  List<CustomFieldDefinition> customFieldDefinitions = const [],
  List<CustomFieldValue> customFieldValues = const [],
  List<ItemImage> itemImages = const [],
}) {
  final textControllers = TextControllerGroup();
  TextEditingController create([String text = '']) =>
      textControllers.create(text: text);

  final titleController = create(item.title);
  final coverController = create(item.coverImageUrl ?? '');
  final thumbnailController = create(item.thumbnailImageUrl ?? '');
  final synopsisController = create(item.synopsis ?? '');
  final displayTitleController = create(item.displayTitle ?? '');
  final sortKeyController = create(item.sortKey ?? '');
  final originalTitleController = create(item.originalTitle ?? '');
  final localizedTitleController = create(item.localizedTitle ?? '');
  final searchAliasesController = create(
    (item.searchAliases ?? const <String>[]).join(', '),
  );
  final ownerLabelController = create(ownedItem?.ownerLabel ?? '');
  final conditionController = create();
  final gradeController = create(
    type.ownedEdit.readOwnedCollectionValue(ownedItemDispatch) ?? '',
  );
  final purchaseDateController = create(
    ownedItem?.purchaseDate == null ? '' : formatDate(ownedItem!.purchaseDate!),
  );
  final priceController = create(
    ownedItem?.pricePaidCents == null
        ? ''
        : (ownedItem!.pricePaidCents! / 100).toStringAsFixed(2),
  );
  final currencyController = create(ownedItem?.currency ?? '');
  final quantityController = create((ownedItem?.quantity ?? 1).toString());
  final indexNumberController = create();
  final notesController = create(ownedItem?.notes ?? '');
  final wishlistPriceController = create(
    wishlistItem?.targetPriceCents == null
        ? ''
        : (wishlistItem!.targetPriceCents! / 100).toStringAsFixed(2),
  );
  final wishlistCurrencyController = create(wishlistItem?.currency ?? '');
  final wishlistNotesController = create(wishlistItem?.notes ?? '');
  final trackingRating = trackingLifecycle?.rating;
  final trackingStatus = trackingLifecycle?.statusStorageValue;
  final ratingController = create(trackingRating?.toString() ?? '');
  final trackingController = create(trackingStatus ?? '');
  final trackingProgress = trackingLifecycle?.progress;
  final progressCurrentController = create(
    trackingProgress?.current?.toString() ?? '',
  );
  final progressTotalController = create(
    trackingProgress?.total?.toString() ?? '',
  );
  final timesCompletedController = create(
    trackingProgress?.timesCompleted?.toString() ?? '',
  );
  final trackingNotesController = create(trackingLifecycle?.notes ?? '');
  final tagsController = create();
  final sellPriceController = create(
    ownedItem?.sellPriceCents == null
        ? ''
        : (ownedItem!.sellPriceCents! / 100).toStringAsFixed(2),
  );
  final soldToController = create(ownedItem?.soldTo ?? '');
  final purchaseStoreController = create(ownedItem?.purchaseStore ?? '');
  final marketValueController = create(
    ownedItem?.marketValueCents == null
        ? ''
        : (ownedItem!.marketValueCents! / 100).toStringAsFixed(2),
  );

  final metadata = CommonMetadataDraft(
    titleController: titleController,
    displayTitleController: displayTitleController,
    sortKeyController: sortKeyController,
    originalTitleController: originalTitleController,
    localizedTitleController: localizedTitleController,
    searchAliasesController: searchAliasesController,
    synopsisController: synopsisController,
    coverController: coverController,
    thumbnailController: thumbnailController,
  );

  final personal = PersonalStateDraft(
    ownerLabelController: ownerLabelController,
    conditionController: conditionController,
    gradeController: gradeController,
    purchaseDateController: purchaseDateController,
    priceController: priceController,
    currencyController: currencyController,
    quantityController: quantityController,
    indexNumberController: indexNumberController,
    notesController: notesController,
    purchaseStoreController: purchaseStoreController,
    marketValueController: marketValueController,
    wishlistPriceController: wishlistPriceController,
    wishlistCurrencyController: wishlistCurrencyController,
    wishlistNotesController: wishlistNotesController,
    tagsController: tagsController,
    sellPriceController: sellPriceController,
    soldToController: soldToController,
    tagOptions: const [],
    availableLocations: const [],
    selectedLocationId: ownedItem?.locationId,
    selectedOwnedTargetRef: ownedItem?.targetRef,
    selectedWishlistCatalogRef: wishlistItem?.catalogRef,
    locationChanged: false,
    soldAt: ownedItem?.soldAt,
    collectionStatus: null,
  );

  final tracking = TrackingDraft(
    ratingController: ratingController,
    trackingController: trackingController,
    progressCurrentController: progressCurrentController,
    progressTotalController: progressTotalController,
    timesCompletedController: timesCompletedController,
    trackingNotesController: trackingNotesController,
    selectedTargetRef: trackingLifecycle?.catalogRef ?? item.catalogRef,
    startedAt: trackingLifecycle?.startedAt,
    finishedAt: trackingLifecycle?.finishedAt,
  );

  final kindDetails = type.editDraft.createDraft(
    item: item,
    // Kind edit schemas consume only the concrete aggregate supplied by the
    // typed Library boundary. The generic request value is never decoded by
    // a kind schema.
    ownedItemDispatch: ownedItemDispatch,
    trackingLifecycle: trackingLifecycle,
    textControllers: textControllers,
  );
  kindDetails.initializePersonalState(personal);

  return LibraryEditDraft.create(
    textControllers: textControllers,
    type: type,
    item: item,
    ownedItem: ownedItem,
    ownedItemDispatch: ownedItemDispatch,
    wishlistItem: wishlistItem,
    trackingLifecycle: trackingLifecycle,
    accent: accent,
    availableBundleReleases:
        List<BundleReleaseSummary>.unmodifiable(availableBundleReleases),
    physicalFormats: List<PhysicalMediaFormat>.unmodifiable(physicalFormats),
    customFieldDefinitions:
        List<CustomFieldDefinition>.unmodifiable(customFieldDefinitions),
    customFieldValues: List<CustomFieldValue>.unmodifiable(customFieldValues),
    itemImages: List<ItemImage>.unmodifiable(itemImages),
    metadata: metadata,
    personal: personal,
    tracking: tracking,
    kindDetails: kindDetails,
    customFieldEdits: {
      for (final definition in customFieldDefinitions)
        definition.id: _initialCustomFieldValue(
          definition.id,
          customFieldValues,
        ),
    },
    itemImageEdits: const [],
  );
}

String? _initialCustomFieldValue(
  String definitionId,
  List<CustomFieldValue> values,
) {
  for (final value in values) {
    if (value.fieldDefinitionId == definitionId) {
      return value.value;
    }
  }
  return null;
}
