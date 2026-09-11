import 'package:collectarr_app/core/api/dto/bundle_release.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/features/library/edit/anchor_selection_helpers.dart';
import 'package:collectarr_app/features/library/edit/draft/common_metadata_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/draft/tracking_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart'
    hide formatDate;
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/edit/draft/common_metadata_draft.dart';
export 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
export 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
export 'package:collectarr_app/features/library/edit/draft/tracking_draft.dart';

class LibraryEditDraft {
  LibraryEditDraft._({
    required TextControllerGroup textControllers,
    required this.type,
    required this.item,
    required this.ownedItem,
    required this.typedOwnedItem,
    required this.wishlistItem,
    required this.trackingLifecycle,
    required this.accent,
    required this.availableBundleReleases,
    required this.physicalFormats,
    required this.customFieldDefinitions,
    required this.customFieldValues,
    required this.itemImages,
    required this.metadata,
    required this.personal,
    required this.tracking,
    required this.kindDetails,
    required this.customFieldEdits,
    required this.itemImageEdits,
  }) : _textControllers = textControllers;

  final TextControllerGroup _textControllers;

  final LibraryKindModule type;
  final CatalogSearchCandidate item;
  final OwnedItemSummary? ownedItem;
  final Object? typedOwnedItem;
  final WishlistItem? wishlistItem;
  final TrackingLifecycle? trackingLifecycle;
  final Color accent;
  final List<BundleReleaseSummary> availableBundleReleases;
  final List<PhysicalMediaFormat> physicalFormats;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;

  /// Modular Sub-Drafts
  final CommonMetadataDraft metadata;
  final PersonalStateDraft personal;
  final TrackingDraft tracking;
  final LibraryEditKindDraft kindDetails;

  Map<String, String?> customFieldEdits;
  List<ItemImageEdit> itemImageEdits;
  List<String> locationOptions = const [];
  List<String> ownerOptions = const [];
  List<String> tagOptions = const [];
  Map<String, List<String>> kindVocabularies = const {};

  // ---------------------------------------------------------------------------
  // Factory Constructors
  // ---------------------------------------------------------------------------

  factory LibraryEditDraft.fromRequest(LibraryEditDialogRequest request) {
    return LibraryEditDraft.fromFields(
      type: request.type,
      item: request.item,
      ownedItem: request.ownedItem,
      typedOwnedItem: request.typedOwnedItem,
      wishlistItem: request.wishlistItem,
      trackingLifecycle: request.trackingLifecycle,
      accent: request.accent,
      availableBundleReleases: request.availableBundleReleases,
      physicalFormats: request.physicalFormats,
      customFieldDefinitions: request.customFieldDefinitions,
      customFieldValues: request.customFieldValues,
      itemImages: request.itemImages,
    );
  }

  factory LibraryEditDraft.fromItem({
    required LibraryKindModule type,
    required CatalogSearchCandidate item,
    OwnedItemSummary? ownedItem,
    Object? typedOwnedItem,
    WishlistItem? wishlistItem,
    TrackingLifecycle? trackingLifecycle,
    required Color accent,
    List<BundleReleaseSummary> availableBundleReleases = const [],
    List<PhysicalMediaFormat> physicalFormats = const [],
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    List<CustomFieldValue> customFieldValues = const [],
    List<ItemImage> itemImages = const [],
  }) {
    return LibraryEditDraft.fromFields(
      type: type,
      item: item,
      ownedItem: ownedItem,
      typedOwnedItem: typedOwnedItem,
      wishlistItem: wishlistItem,
      trackingLifecycle: trackingLifecycle,
      accent: accent,
      availableBundleReleases: availableBundleReleases,
      physicalFormats: physicalFormats,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValues: customFieldValues,
      itemImages: itemImages,
    );
  }

  factory LibraryEditDraft.fromFields({
    required LibraryKindModule type,
    required CatalogSearchCandidate item,
    required OwnedItemSummary? ownedItem,
    Object? typedOwnedItem,
    required WishlistItem? wishlistItem,
    required TrackingLifecycle? trackingLifecycle,
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

    final editionTitle = item.mapTransport(
      (transport) => (item.titleExtension ?? transport.editionTitle)?.trim(),
    );

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
      type.edit.readOwnedCollectionValue(ownedItem) ?? '',
    );
    final purchaseDateController = create(
      ownedItem?.purchaseDate == null
          ? ''
          : formatDate(ownedItem!.purchaseDate!),
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
    final ratingController = create(
      trackingRating?.toString() ?? '',
    );
    final trackingController = create(trackingStatus ?? '');
    final progressCurrentController = create(
      trackingLifecycle?.progressCurrent?.toString() ?? '',
    );
    final progressTotalController = create(
      trackingLifecycle?.progressTotal?.toString() ?? '',
    );
    final timesCompletedController = create(
      trackingLifecycle?.timesCompleted?.toString() ?? '',
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

    final editions = item.mapTransport((transport) => transport.editions);

    final editionSelection = resolveLibraryEditionSelection(
      editions,
      editionId: catalogRefEditionId(ownedItem?.targetRef) ??
          catalogRefEditionId(trackingLifecycle?.catalogRef),
      editionTitle: editionTitle,
      variantId: catalogRefVariantId(ownedItem?.targetRef) ??
          catalogRefVariantId(trackingLifecycle?.catalogRef),
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
      selectedOwnedAnchorType:
          libraryTargetScopeForCatalogRef(ownedItem?.targetRef) ?? 'item',
      selectedEditionId: editionSelection.edition?.id,
      selectedVariantId: editionSelection.variant?.id,
      selectedBundleReleaseId: normalizeLibrarySelectionId(
        catalogRefBundleReleaseId(ownedItem?.targetRef),
      ),
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
      selectedTrackingEditionId:
          catalogRefEditionId(trackingLifecycle?.catalogRef) ??
              editionSelection.edition?.id,
      selectedTrackingVariantId:
          catalogRefVariantId(trackingLifecycle?.catalogRef) ??
              editionSelection.variant?.id,
      startedAt: trackingLifecycle?.startedAt,
      finishedAt: trackingLifecycle?.finishedAt,
    );

    final kindDetails = type.edit.createDraft(
      item: item,
      // Kind edit schemas consume only the concrete aggregate supplied by the
      // typed Library boundary. The generic request value is never decoded by
      // a kind schema.
      typedOwnedItem: typedOwnedItem,
      trackingLifecycle: trackingLifecycle,
      textControllers: textControllers,
    );
    kindDetails.initializePersonalState(personal);

    return LibraryEditDraft._(
      textControllers: textControllers,
      type: type,
      item: item,
      ownedItem: ownedItem,
      typedOwnedItem: typedOwnedItem,
      wishlistItem: wishlistItem,
      trackingLifecycle: trackingLifecycle,
      accent: accent,
      availableBundleReleases: List<BundleReleaseSummary>.unmodifiable(
        availableBundleReleases,
      ),
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
        for (final def in customFieldDefinitions)
          def.id: _initialCustomFieldValue(def.id, customFieldValues),
      },
      itemImageEdits: const [],
    );
  }

  static String? _initialCustomFieldValue(
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

  // ---------------------------------------------------------------------------
  // Domain Helpers & Actions
  // ---------------------------------------------------------------------------

  bool get isOwned => ownedItem != null;
  bool get hasTrackingContext => isOwned || trackingLifecycle != null;
  bool get isTrackingOnly => !isOwned && trackingLifecycle != null;
  bool get hasWishlistContext => wishlistItem != null;
  bool get isVideoKind => item.mediaKind.isVideoLibraryKind;

  PhysicalMediaFormat? physicalFormatForId(String? id) {
    final normalized = emptyToNull(id ?? '');
    return normalized == null
        ? null
        : physicalMediaFormatById(normalized, formats: physicalFormats);
  }

  bool get isDigitalFormat {
    final existingOwnedItem = ownedItem;
    final formatHint = type.edit.resolveOwnedFormatHint(item);
    final format = formatHint.label ?? '';
    return type.edit.resolveOwnedDigitalFlag(
          existingOwnedItem == null ? null : existingOwnedItem,
          item.mapTransport((transport) => transport.editions),
          fallbackFormat: formatHint.format,
          fallbackLabel: format,
          formats: physicalFormats,
        ) ??
        false;
  }

  bool get showPhysicalOwnedFields => isOwned && !isDigitalFormat;

  ({
    String? selectedLocationId,
    DateTime? startedAt,
    DateTime? finishedAt,
    DateTime? soldAt,
    String? selectedEditionId,
    String? selectedVariantId,
    Map<String, String?> customFieldEdits,
    List<ItemImageEdit> itemImageEdits,
  }) cloneDialogState() {
    final editions = item.mapTransport((transport) => transport.editions);
    final editionSelection = resolveLibraryEditionSelection(
      editions,
      editionId: catalogRefEditionId(ownedItem?.targetRef) ??
          catalogRefEditionId(trackingLifecycle?.catalogRef),
      editionTitle:
          item.mapTransport(
            (transport) => (item.titleExtension ?? transport.editionTitle)?.trim(),
          ),
      variantId: catalogRefVariantId(ownedItem?.targetRef) ??
          catalogRefVariantId(trackingLifecycle?.catalogRef),
    );
    return (
      selectedLocationId: personal.selectedLocationId,
      startedAt: tracking.startedAt,
      finishedAt: tracking.finishedAt,
      soldAt: personal.soldAt,
      selectedEditionId: editionSelection.edition?.id,
      selectedVariantId: editionSelection.variant?.id,
      customFieldEdits: Map<String, String?>.from(customFieldEdits),
      itemImageEdits: List<ItemImageEdit>.from(itemImageEdits),
    );
  }

  void updateCustomFieldsAndImages({
    required Map<String, String?> customFieldEdits,
    required List<ItemImageEdit> itemImageEdits,
  }) {
    this.customFieldEdits = Map<String, String?>.from(customFieldEdits);
    this.itemImageEdits = List<ItemImageEdit>.from(itemImageEdits);
  }

  void replaceMediaEdits({
    required Map<String, String?> customFieldEdits,
    required List<ItemImageEdit> itemImageEdits,
  }) =>
      updateCustomFieldsAndImages(
        customFieldEdits: customFieldEdits,
        itemImageEdits: itemImageEdits,
      );

  bool get showsEpisodeTrackingFields => type.kind.isVideoLibraryKind;

  void setExternalLinks(List<TrailerLinkDto> links) {
    kindDetails.setExternalLinks(links);
  }

  LibraryEditSelection toSelection({
    LibraryEditSubmitAction submitAction = LibraryEditSubmitAction.save,
  }) =>
      buildSelection(submitAction: submitAction);

  LibraryEditSelection buildSelection({
    LibraryEditSubmitAction submitAction = LibraryEditSubmitAction.save,
  }) {
    final existingOwnedItem = ownedItem;
    final baseItem = item.copyWith(
      title: metadata.titleController.text.trim(),
      sortKey: emptyToNull(metadata.sortKeyController.text),
      originalTitle: emptyToNull(metadata.originalTitleController.text),
      displayTitle: emptyToNull(metadata.displayTitleController.text),
      localizedTitle: emptyToNull(metadata.localizedTitleController.text),
      searchAliases: _splitList(metadata.searchAliasesController.text),
      synopsis: emptyToNull(metadata.synopsisController.text),
      coverImageUrl: emptyToNull(metadata.coverController.text),
      thumbnailImageUrl: emptyToNull(metadata.thumbnailController.text),
    );
    final baseSelection = LibraryEditSelection(
      item: baseItem,
      personal: ownedItem == null
          ? null
          : LibraryPersonalEditSelection(
              targetRef: catalogRefForOwnedSelection(
                type.kind,
                anchorType: personal.selectedOwnedAnchorType,
                editionId: personal.selectedEditionId,
                variantId: personal.selectedVariantId,
                bundleReleaseId: personal.selectedBundleReleaseId,
              ),
              condition: showPhysicalOwnedFields
                  ? emptyToNull(personal.conditionController.text)
                  : null,
              purchaseDate: parseDate(personal.purchaseDateController.text),
              pricePaidCents: parseMoneyCents(personal.priceController.text),
              currency: emptyToNull(personal.currencyController.text),
              personalNotes: emptyToNull(personal.notesController.text),
              quantity: parseInt(personal.quantityController.text) ?? 1,
              indexNumber: parseInt(personal.indexNumberController.text),
              locationId:
                  showPhysicalOwnedFields ? personal.selectedLocationId : null,
              locationChanged:
                  showPhysicalOwnedFields ? personal.locationChanged : false,
              tags: emptyToNull(personal.tagsController.text),
              soldAt: personal.soldAt,
              sellPriceCents:
                  parseMoneyCents(personal.sellPriceController.text),
              soldTo: emptyToNull(personal.soldToController.text),
              purchaseStore:
                  emptyToNull(personal.purchaseStoreController.text) ??
                      ownedItem?.purchaseStore,
              collectionStatus: personal.collectionStatus,
              marketValueCents:
                  parseMoneyCents(personal.marketValueController.text) ??
                      ownedItem?.marketValueCents,
              ownerLabel: emptyToNull(personal.ownerLabelController.text) ??
                  ownedItem?.ownerLabel,
            ),
      wishlist: wishlistItem == null
          ? null
          : LibraryWishlistEditSelection(
              catalogRef:
                  personal.selectedWishlistCatalogRef ?? item.catalogRef,
              targetPriceCents:
                  parseMoneyCents(personal.wishlistPriceController.text),
              currency: emptyToNull(personal.wishlistCurrencyController.text),
              notes: emptyToNull(personal.wishlistNotesController.text),
            ),
      tracking: !hasTrackingContext
          ? null
          : LibraryTrackingEditSelection(
              targetRef: catalogRefForLibrarySelection(
                item.catalogRef,
                editionId: tracking.selectedTrackingEditionId,
                variantId: tracking.selectedTrackingVariantId,
              ),
              rating: parseInt(tracking.ratingController.text),
              readStatus: emptyToNull(tracking.trackingController.text),
              startedAt: tracking.startedAt,
              finishedAt: tracking.finishedAt,
              progressCurrent:
                  parseInt(tracking.progressCurrentController.text),
              progressTotal: parseInt(tracking.progressTotalController.text),
              timesCompleted: parseInt(tracking.timesCompletedController.text),
              notes: emptyToNull(tracking.trackingNotesController.text),
            ),
      ownedUpdatePayload: existingOwnedItem == null
          ? null
          : kindDetails.buildOwnedUpdatePayload(
              ownedItemId: existingOwnedItem.ref.id.value,
              personal: personal,
            ),
      customFieldEdits: customFieldEdits,
      itemImageEdits: itemImageEdits,
      submitAction: submitAction,
    );
    return kindDetails.applySelectionEdits(baseSelection);
  }

  List<String>? _splitList(String value) {
    final entries = value
        .split(RegExp(r'[,\r\n]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    return entries.isEmpty ? null : entries;
  }

  void dispose() {
    kindDetails.dispose();
    _textControllers.dispose();
  }

  LibraryAddCommonDraft buildCommonDraft() {
    return LibraryAddCommonDraft(
      quantity: parseInt(personal.quantityController.text) ?? 1,
      condition: emptyToNull(personal.conditionController.text),
      purchaseDate: parseDate(personal.purchaseDateController.text),
      pricePaidCents: parseMoneyCents(personal.priceController.text),
      currency: emptyToNull(personal.currencyController.text),
      personalNotes: emptyToNull(personal.notesController.text),
      locationId: personal.selectedLocationId,
      purchaseStore: emptyToNull(personal.purchaseStoreController.text),
      collectionStatus: personal.collectionStatus,
      tags: emptyToNull(personal.tagsController.text),
    );
  }

  JsonEncodable buildDetailsDraft() => libraryKindModuleForKind(
        type.kind,
      ).edit.buildDetailsDraft(kindDetails);

  AddOwnedItemCommand toAddOwnedItemCommand() {
    return type.add.buildCommandFromDetails(
      item,
      buildCommonDraft(),
      buildDetailsDraft(),
      targetRef: catalogRefForLibrarySelection(
        item.catalogRef,
        editionId: personal.selectedEditionId,
        variantId: personal.selectedVariantId,
        bundleReleaseId: personal.selectedBundleReleaseId,
      ),
      kindValue: emptyToNull(personal.gradeController.text),
      tracking: LibraryAddTrackingDraft(
        readStatus: emptyToNull(tracking.trackingController.text),
        notes: emptyToNull(tracking.trackingNotesController.text),
        rating: parseInt(tracking.ratingController.text),
        startedAt: tracking.startedAt,
        finishedAt: tracking.finishedAt,
      ),
    );
  }

  OwnedItemUpdateRequest toUpdateOwnedItemCommand(String ownedItemId) {
    return libraryKindModuleForKind(type.kind).edit.buildUpdateCommand(
          session: this,
          ownedRef: OwnedItemRef(
            kind: type.kind,
            id: OwnedItemId(ownedItemId),
          ),
          kindDraft: kindDetails,
        );
  }
}
