import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/catalog_target_option.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/session/library_edit_session_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

/// Builds the mutable edit state from the typed Library boundary.
///
/// The draft class owns live form state; this factory owns the one-time
/// boundary-to-controller projection. Keeping the two separate prevents the
/// state object from also becoming the initialization policy for every kind.
LibraryEditShellState createLibraryEditShellState({
  required LibraryKindRegistration type,
  LibraryEntityRef? node,
  required CatalogSearchCandidate item,
  required OwnedItemSummary? ownedItem,
  LibraryOwnedItemDispatch? ownedItemDispatch,
  required WishlistItem? wishlistItem,
  required TrackingSummary? trackingSummary,
  required Color accent,
  List<CatalogTargetOption> wishlistTargetOptions = const [],
  List<PhysicalMediaFormat> physicalFormats = const [],
  List<CustomFieldDefinition> customFieldDefinitions = const [],
  List<CustomFieldValue> customFieldValues = const [],
  List<ItemImage> itemImages = const [],
}) {
  final textControllers = TextControllerGroup();
  TextEditingController create([String text = '']) =>
      textControllers.create(text: text);

  final commonMetadata = item.editMetadata;
  final titleController = create(commonMetadata.title);
  final coverController = create(commonMetadata.coverImageUrl ?? '');
  final thumbnailController = create(commonMetadata.thumbnailImageUrl ?? '');
  final synopsisController = create(commonMetadata.synopsis ?? '');
  final displayTitleController = create(commonMetadata.displayTitle ?? '');
  final sortKeyController = create(commonMetadata.sortKey ?? '');
  final originalTitleController = create(commonMetadata.originalTitle ?? '');
  final localizedTitleController = create(commonMetadata.localizedTitle ?? '');
  final searchAliasesController = create(
    commonMetadata.searchAliases.join(', '),
  );
  final ownerLabelController = create(ownedItem?.ownerLabel ?? '');
  final conditionController = create();
  final gradeController = create(
    libraryOwnedEditForKind(type.kind)
            .readOwnedCollectionValue(ownedItemDispatch) ??
        '',
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
  final trackingRating = trackingSummary?.rating;
  final trackingStatus = trackingSummary?.statusStorageValue;
  final ratingController = create(trackingRating?.toString() ?? '');
  final trackingController = create(trackingStatus ?? '');
  final trackingProgress = trackingSummary?.progress;
  final progressCurrentController = create(
    trackingProgress?.current?.toString() ?? '',
  );
  final progressTotalController = create(
    trackingProgress?.total?.toString() ?? '',
  );
  final timesCompletedController = create(
    trackingProgress?.timesCompleted?.toString() ?? '',
  );
  final trackingNotesController = create(trackingSummary?.notes ?? '');
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
    selectedTargetRef: trackingSummary?.catalogRef ?? item.catalogRef,
    startedAt: trackingSummary?.startedAt,
    finishedAt: trackingSummary?.completedAt,
  );

  final kindSessionFactory = libraryEditSessionForKind(type.kind).createSession;
  if (kindSessionFactory == null) {
    throw StateError(
      'The ${type.kind.apiValue} kind uses a dedicated typed edit dialog.',
    );
  }
  final kindSessions = kindSessionFactory(
    item: item,
    // Kind edit schemas consume only the concrete aggregate supplied by the
    // typed Library boundary. The generic request value is never decoded by
    // a kind schema.
    ownedItemDispatch: ownedItemDispatch,
    trackingSummary: trackingSummary,
    textControllers: textControllers,
  );
  kindSessions.copySession.initializePersonalState(personal);

  final formatHint =
      libraryOwnedEditForKind(type.kind).resolveOwnedFormatHint(item);
  final isDigitalFormat =
      libraryOwnedEditForKind(type.kind).resolveOwnedDigitalFlag(
            ownedItem,
            libraryPresentationForKind(type.kind)
                .builder
                .buildReleaseOptions(item: item),
            fallbackFormat: formatHint.format,
            fallbackLabel: formatHint.label,
            formats: physicalFormats,
          ) ??
          false;

  return LibraryEditShellState.create(
    textControllers: textControllers,
    type: type,
    node: node,
    item: commonMetadata,
    kindItem: item,
    ownedItem: ownedItem,
    ownedItemDispatch: ownedItemDispatch,
    wishlistItem: wishlistItem,
    trackingSummary: trackingSummary,
    accent: accent,
    wishlistTargetOptions:
        List<CatalogTargetOption>.unmodifiable(wishlistTargetOptions),
    physicalFormats: List<PhysicalMediaFormat>.unmodifiable(physicalFormats),
    customFieldDefinitions:
        List<CustomFieldDefinition>.unmodifiable(customFieldDefinitions),
    customFieldValues: List<CustomFieldValue>.unmodifiable(customFieldValues),
    itemImages: List<ItemImage>.unmodifiable(itemImages),
    isDigitalFormat: isDigitalFormat,
    metadata: metadata,
    personal: personal,
    tracking: tracking,
    session: LibraryEditSessionController(
      workSession: kindSessions.workSession,
      releaseSession: kindSessions.releaseSession,
      copySession: kindSessions.copySession,
      disposeSession: kindSessions.disposeSession,
    ),
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
