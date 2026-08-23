import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/anchor_selection_helpers.dart';
import 'package:collectarr_app/features/library/edit/draft/common_metadata_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/draft/tracking_draft.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/edit/draft/common_metadata_draft.dart';
export 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
export 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
export 'package:collectarr_app/features/library/edit/draft/tracking_draft.dart';

class LibraryEditDraft {
  LibraryEditDraft._({
    required TextControllerGroup textControllers,
    required this.type,
    required this.item,
    required this.ownedItem,
    required this.wishlistItem,
    required this.trackingEntry,
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

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final OwnedItem? ownedItem;
  final WishlistItem? wishlistItem;
  final TrackingEntry? trackingEntry;
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
  final KindEditDraft kindDetails;

  Map<String, String?> customFieldEdits;
  List<ItemImageEdit> itemImageEdits;

  // ---------------------------------------------------------------------------
  // Factory Constructors
  // ---------------------------------------------------------------------------

  factory LibraryEditDraft.fromRequest(LibraryEditDialogRequest request) {
    return LibraryEditDraft.fromFields(
      type: request.type,
      item: request.item,
      ownedItem: request.ownedItem,
      wishlistItem: request.wishlistItem,
      trackingEntry: request.trackingEntry,
      accent: request.accent,
      availableBundleReleases: request.availableBundleReleases,
      physicalFormats: request.physicalFormats,
      customFieldDefinitions: request.customFieldDefinitions,
      customFieldValues: request.customFieldValues,
      itemImages: request.itemImages,
    );
  }

  factory LibraryEditDraft.fromItem({
    required LibraryTypeConfig type,
    required LibraryMetadataItem item,
    OwnedItem? ownedItem,
    WishlistItem? wishlistItem,
    TrackingEntry? trackingEntry,
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
      wishlistItem: wishlistItem,
      trackingEntry: trackingEntry,
      accent: accent,
      availableBundleReleases: availableBundleReleases,
      physicalFormats: physicalFormats,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValues: customFieldValues,
      itemImages: itemImages,
    );
  }

  factory LibraryEditDraft.fromFields({
    required LibraryTypeConfig type,
    required LibraryMetadataItem item,
    required OwnedItem? ownedItem,
    required WishlistItem? wishlistItem,
    required TrackingEntry? trackingEntry,
    required Color accent,
    List<BundleReleaseSummary> availableBundleReleases = const [],
    List<PhysicalMediaFormat> physicalFormats = const [],
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    List<CustomFieldValue> customFieldValues = const [],
    List<ItemImage> itemImages = const [],
  }) {
    final initialPhysicalFormatId =
        _initialPhysicalFormatId(item, physicalFormats);
    final effectiveFormats = physicalFormats.isEmpty
        ? allKnownPhysicalMediaFormats
        : physicalFormats;
    final textControllers = TextControllerGroup();
    TextEditingController create([String text = '']) =>
        textControllers.create(text: text);

    final titleController = create(item.title);
    final numberController = create(item.itemNumber ?? '');
    final publisherController = create(item.publisher ?? '');
    final coverDateController = create(
      item.coverDate == null ? '' : formatDate(item.coverDate!),
    );
    final coverDateYearPartController =
        create(item.coverDate?.year.toString() ?? '');
    final coverDateMonthPartController = create(
      item.coverDate == null
          ? ''
          : item.coverDate!.month.toString().padLeft(2, '0'),
    );
    final coverDateDayPartController = create(
      item.coverDate == null
          ? ''
          : item.coverDate!.day.toString().padLeft(2, '0'),
    );
    final releaseDateController = create(
      item.releaseDate == null ? '' : formatDate(item.releaseDate!),
    );
    final releaseDateYearPartController = create(
      item.releaseDate?.year.toString() ?? '',
    );
    final releaseDateMonthPartController = create(
      item.releaseDate == null
          ? ''
          : item.releaseDate!.month.toString().padLeft(2, '0'),
    );
    final releaseDateDayPartController = create(
      item.releaseDate == null
          ? ''
          : item.releaseDate!.day.toString().padLeft(2, '0'),
    );
    final releaseYearController = create(item.releaseYear?.toString() ?? '');
    final pageCountController = create(
      item.publishing?.pageCount?.toString() ?? '',
    );
    final editionTitleController =
        create(item.editionTitle ?? item.titleExtension ?? '');
    final barcodeController = create(item.barcode ?? '');
    final variantController = create(item.variant ?? '');
    final physicalFormatLabelController = create(
      item.physicalFormatLabel ??
          (type.releaseFields.variantSeedsPhysicalFormatLabel
              ? item.variant
              : null) ??
          (initialPhysicalFormatId == null
              ? null
              : physicalMediaFormatById(
                  initialPhysicalFormatId,
                  formats: effectiveFormats,
                )?.label) ??
          '',
    );
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
    final runtimeController = create(
      item.video?.runtimeMinutes?.toString() ?? '',
    );
    final audienceRatingController = create(item.audienceRating ?? '');
    final countryController = create(item.country ?? '');
    final languageController = create(item.language ?? '');
    final ageRatingController = create(item.ageRating ?? '');
    final genresEditController = create(item.genres?.join(', ') ?? '');
    final crossoverController = create(item.crossover?.trim() ?? '');
    final storyArcsController = create(
      (item.storyArcs ?? const <String>[]).join(', '),
    );
    final seriesTitleController = create(item.series?.seriesTitle ?? '');
    final developersController = create(
      _creatorNamesForRoles(item.creators, const ['developer']).join(', '),
    );
    final ownerLabelController = create(ownedItem?.ownerLabel ?? '');
    final imprintController = create(item.publishing?.imprint ?? '');
    final seriesGroupController = create(item.publishing?.seriesGroup ?? '');
    final conditionController = create(ownedItem?.condition ?? '');
    final gradeController = create(ownedItem?.grade ?? '');
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
    final indexNumberController =
        create(ownedItem?.indexNumber?.toString() ?? '');
    final notesController = create(ownedItem?.personalNotes ?? '');
    final wishlistPriceController = create(
      wishlistItem?.targetPriceCents == null
          ? ''
          : (wishlistItem!.targetPriceCents! / 100).toStringAsFixed(2),
    );
    final wishlistCurrencyController = create(wishlistItem?.currency ?? '');
    final wishlistNotesController = create(wishlistItem?.notes ?? '');
    final ratingController = create(
      (trackingEntry?.rating ?? ownedItem?.rating)?.toString() ?? '',
    );
    final trackingController = create(
      trackingEntry?.statusStorageValue ?? ownedItem?.readStatus ?? '',
    );
    final progressCurrentController = create(
      trackingEntry?.progressCurrent?.toString() ?? '',
    );
    final progressTotalController = create(
      trackingEntry?.progressTotal?.toString() ?? '',
    );
    final timesCompletedController = create(
      trackingEntry?.timesCompleted?.toString() ?? '',
    );
    final seasonNumberController = create(
      (trackingEntry?.seasonNumber ?? item.series?.seasonNumber)?.toString() ??
          '',
    );
    final episodeNumberController = create(
      (trackingEntry?.episodeNumber ?? item.series?.episodeNumber)
              ?.toString() ??
          '',
    );
    final trackingNotesController = create(trackingEntry?.notes ?? '');
    final tagsController = create(ownedItem?.tags ?? '');
    final sellPriceController = create(
      ownedItem?.sellPriceCents == null
          ? ''
          : (ownedItem!.sellPriceCents! / 100).toStringAsFixed(2),
    );
    final soldToController = create(ownedItem?.soldTo ?? '');
    final signedByController = create();
    final purchaseStoreController = create(ownedItem?.purchaseStore ?? '');
    final marketValueController = create(
      ownedItem?.marketValueCents == null
          ? ''
          : (ownedItem!.marketValueCents! / 100).toStringAsFixed(2),
    );

    final editionSelection = resolveLibraryEditionSelection(
      item.editions,
      editionId: ownedItem?.editionId ?? trackingEntry?.editionId,
      editionTitle: item.editionTitle,
      variantId: ownedItem?.variantId ?? trackingEntry?.variantId,
      variantName: item.variant,
    );
    final wishlistEditionSelection = resolveLibraryEditionSelection(
      item.editions,
      editionId: wishlistItem?.editionId,
      editionTitle: item.editionTitle,
      variantId: wishlistItem?.variantId,
      variantName: item.variant,
    );

    final metadata = CommonMetadataDraft(
      titleController: titleController,
      numberController: numberController,
      publisherController: publisherController,
      coverDateController: coverDateController,
      coverDateYearPartController: coverDateYearPartController,
      coverDateMonthPartController: coverDateMonthPartController,
      coverDateDayPartController: coverDateDayPartController,
      releaseDateController: releaseDateController,
      releaseDateYearPartController: releaseDateYearPartController,
      releaseDateMonthPartController: releaseDateMonthPartController,
      releaseDateDayPartController: releaseDateDayPartController,
      releaseYearController: releaseYearController,
      pageCountController: pageCountController,
      editionTitleController: editionTitleController,
      barcodeController: barcodeController,
      variantController: variantController,
      physicalFormatLabelController: physicalFormatLabelController,
      coverController: coverController,
      thumbnailController: thumbnailController,
      synopsisController: synopsisController,
      displayTitleController: displayTitleController,
      sortKeyController: sortKeyController,
      originalTitleController: originalTitleController,
      localizedTitleController: localizedTitleController,
      searchAliasesController: searchAliasesController,
      runtimeController: runtimeController,
      audienceRatingController: audienceRatingController,
      countryController: countryController,
      languageController: languageController,
      ageRatingController: ageRatingController,
      genresEditController: genresEditController,
      crossoverController: crossoverController,
      storyArcsController: storyArcsController,
      seriesTitleController: seriesTitleController,
      developersController: developersController,
      imprintController: imprintController,
      seriesGroupController: seriesGroupController,
      physicalFormatId: initialPhysicalFormatId,
      seriesId: item.series?.seriesId,
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
      signedByController: signedByController,
      sellPriceController: sellPriceController,
      soldToController: soldToController,
      tagOptions: splitPickListValues(ownedItem?.tags),
      availableLocations: const [],
      selectedLocationId: ownedItem?.locationId,
      selectedOwnedAnchorType: PersonalItemAnchorType.fromApiValue(
            ownedItem?.personalAnchor?.apiValue,
          ) ??
          PersonalItemAnchorType.item,
      selectedEditionId: editionSelection.edition?.id,
      selectedVariantId: editionSelection.variant?.id,
      selectedBundleReleaseId:
          normalizeLibrarySelectionId(ownedItem?.bundleReleaseId),
      selectedWishlistAnchorType: PersonalItemAnchorType.fromApiValue(
            wishlistItem?.personalAnchor?.apiValue,
          ) ??
          PersonalItemAnchorType.item,
      selectedWishlistEditionId: wishlistEditionSelection.edition?.id,
      selectedWishlistVariantId: wishlistEditionSelection.variant?.id,
      selectedWishlistBundleReleaseId:
          normalizeLibrarySelectionId(wishlistItem?.bundleReleaseId),
      locationChanged: false,
      soldAt: ownedItem?.soldAt,
      collectionStatus: ownedItem?.collectionStatus,
    );

    final tracking = TrackingDraft(
      ratingController: ratingController,
      trackingController: trackingController,
      progressCurrentController: progressCurrentController,
      progressTotalController: progressTotalController,
      timesCompletedController: timesCompletedController,
      seasonNumberController: seasonNumberController,
      episodeNumberController: episodeNumberController,
      trackingNotesController: trackingNotesController,
      selectedTrackingEditionId:
          trackingEntry?.editionId ?? editionSelection.edition?.id,
      selectedTrackingVariantId:
          trackingEntry?.variantId ?? editionSelection.variant?.id,
      startedAt: trackingEntry?.startedAt ?? ownedItem?.startedAt,
      finishedAt: trackingEntry?.finishedAt ?? ownedItem?.finishedAt,
      episodeRatings:
          Map<String, int>.from(trackingEntry?.episodeRatings ?? const {}),
    );

    final kindDetails = defaultLibraryKindRegistry
        .getByKind(type.workspace.kind)
        .edit
        .createDraft(
          item: item,
          ownedItem: ownedItem,
          trackingEntry: trackingEntry,
          textControllers: textControllers,
        );

    return LibraryEditDraft._(
      textControllers: textControllers,
      type: type,
      item: item,
      ownedItem: ownedItem,
      wishlistItem: wishlistItem,
      trackingEntry: trackingEntry,
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
        for (final value in customFieldValues)
          value.fieldDefinitionId: value.value,
      },
      itemImageEdits: const [],
    );
  }

  // ---------------------------------------------------------------------------
  // Domain Helpers & Actions
  // ---------------------------------------------------------------------------

  bool get isOwned => ownedItem != null;
  bool get hasTrackingContext => isOwned || trackingEntry != null;
  bool get isTrackingOnly => !isOwned && trackingEntry != null;
  bool get hasWishlistContext => wishlistItem != null;
  bool get isVideoKind => item.mediaKind.isVideoLibraryKind;

  PhysicalMediaFormat? physicalFormatForId(String? id) {
    final normalized = emptyToNull(id ?? '');
    return normalized == null
        ? null
        : physicalMediaFormatById(normalized, formats: physicalFormats);
  }

  bool get isDigitalFormat {
    return isDigitalPhysicalMediaFormat(
      metadata.physicalFormatId,
      label: physicalFormatForId(metadata.physicalFormatId)?.label ??
          emptyToNull(metadata.physicalFormatLabelController.text) ??
          item.physicalFormatLabel ??
          metadata.variantController.text,
      formats: physicalFormats.isEmpty
          ? allKnownPhysicalMediaFormats
          : physicalFormats,
    );
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
    final editionSelection = resolveLibraryEditionSelection(
      item.editions,
      editionId: ownedItem?.editionId ?? trackingEntry?.editionId,
      editionTitle: item.editionTitle,
      variantId: ownedItem?.variantId ?? trackingEntry?.variantId,
      variantName: item.variant,
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

  void replaceMediaEdits({
    required Map<String, String?> customFieldEdits,
    required List<ItemImageEdit> itemImageEdits,
  }) {
    this.customFieldEdits = Map<String, String?>.from(customFieldEdits);
    this.itemImageEdits = List<ItemImageEdit>.from(itemImageEdits);
  }

  bool get showsEpisodeTrackingFields {
    final series = item.series;
    return type.trackingProfile.name == videoTrackingProfile.name ||
        series?.seasonNumber != null ||
        series?.episodeNumber != null ||
        tracking.seasonNumberController.text.trim().isNotEmpty ||
        tracking.episodeNumberController.text.trim().isNotEmpty;
  }

  LibraryEditSelection toSelection({
    LibraryEditSubmitAction submitAction = LibraryEditSubmitAction.save,
  }) =>
      buildSelection(submitAction: submitAction);

  LibraryEditSelection buildSelection({
    LibraryEditSubmitAction submitAction = LibraryEditSubmitAction.save,
  }) {
    final updatedPublishing = CatalogPublishingDetails(
      pageCount: parseInt(metadata.pageCountController.text),
      coverPriceCents: item.publishing?.coverPriceCents,
      currency: item.publishing?.currency,
      imprint: emptyToNull(metadata.imprintController.text),
      subtitle: item.publishing?.subtitle,
      seriesGroup: emptyToNull(metadata.seriesGroupController.text),
    );
    final parsedStoryArcs = metadata.storyArcsController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((storyArc) => storyArc.trim())
        .where((storyArc) => storyArc.isNotEmpty)
        .toList();
    final updatedVideo = VideoCatalogDetails(
      runtimeMinutes: int.tryParse(metadata.runtimeController.text),
    );
    final parsedGenres = metadata.genresEditController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toList();
    return LibraryEditSelection(
      item: item.copyWith(
        title: metadata.titleController.text.trim(),
        sortKey: emptyToNull(metadata.sortKeyController.text),
        originalTitle: emptyToNull(metadata.originalTitleController.text),
        displayTitle: emptyToNull(metadata.displayTitleController.text),
        localizedTitle: emptyToNull(metadata.localizedTitleController.text),
        searchAliases: _splitList(metadata.searchAliasesController.text),
        itemNumber: emptyToNull(metadata.numberController.text),
        synopsis: emptyToNull(metadata.synopsisController.text),
        coverImageUrl: emptyToNull(metadata.coverController.text),
        thumbnailImageUrl: emptyToNull(metadata.thumbnailController.text),
        editionTitle: emptyToNull(metadata.editionTitleController.text),
        physicalFormat: metadata.physicalFormatId,
        physicalFormatLabel:
            emptyToNull(metadata.physicalFormatLabelController.text) ??
                physicalFormatForId(metadata.physicalFormatId)?.label,
        publisher: emptyToNull(metadata.publisherController.text),
        coverDate: parseDate(metadata.coverDateController.text),
        releaseDate: parseDate(metadata.releaseDateController.text),
        releaseYear: parseInt(metadata.releaseYearController.text),
        barcode: emptyToNull(metadata.barcodeController.text),
        variant: emptyToNull(metadata.variantController.text),
        crossover: emptyToNull(metadata.crossoverController.text),
        series: _buildUpdatedSeries(),
        creators: _buildUpdatedCreators(),
        country: emptyToNull(metadata.countryController.text),
        language: emptyToNull(metadata.languageController.text),
        ageRating: emptyToNull(metadata.ageRatingController.text),
        audienceRating: emptyToNull(metadata.audienceRatingController.text),
        genres: parsedGenres.isEmpty ? null : parsedGenres,
        storyArcs: parsedStoryArcs.isEmpty ? null : parsedStoryArcs,
        publishing: updatedPublishing.hasData ? updatedPublishing : null,
        video: updatedVideo.hasData ? updatedVideo : null,
      ),
      personal: ownedItem == null
          ? null
          : LibraryPersonalEditSelection(
              anchorType: personal.selectedOwnedAnchorType.apiValue,
              editionId: personal.selectedOwnedAnchorType ==
                          PersonalItemAnchorType.edition ||
                      personal.selectedOwnedAnchorType ==
                          PersonalItemAnchorType.variant
                  ? personal.selectedEditionId
                  : null,
              variantId: personal.selectedOwnedAnchorType ==
                      PersonalItemAnchorType.variant
                  ? personal.selectedVariantId
                  : null,
              bundleReleaseId: personal.selectedOwnedAnchorType ==
                      PersonalItemAnchorType.bundleRelease
                  ? personal.selectedBundleReleaseId
                  : null,
              condition: showPhysicalOwnedFields
                  ? emptyToNull(personal.conditionController.text)
                  : null,
              grade: showPhysicalOwnedFields
                  ? emptyToNull(personal.gradeController.text)
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
              rawOrSlabbed: null,
              gradingCompany: null,
              graderNotes: null,
              signedBy: isDigitalFormat
                  ? null
                  : emptyToNull(personal.signedByController.text),
              labelType: null,
              pageQuality: null,
              certificationNumber: null,
              keyComic: null,
              keyReason: null,
              keyCategory: null,
              coverPriceCents: null,
              purchaseStore: emptyToNull(personal.purchaseStoreController.text),
              collectionStatus: personal.collectionStatus,
              marketValueCents:
                  parseMoneyCents(personal.marketValueController.text),
              ownerLabel: emptyToNull(personal.ownerLabelController.text),
            ),
      wishlist: wishlistItem == null
          ? null
          : LibraryWishlistEditSelection(
              anchorType: personal.selectedWishlistAnchorType.apiValue,
              editionId: personal.selectedWishlistAnchorType ==
                          PersonalItemAnchorType.edition ||
                      personal.selectedWishlistAnchorType ==
                          PersonalItemAnchorType.variant
                  ? personal.selectedWishlistEditionId
                  : null,
              variantId: personal.selectedWishlistAnchorType ==
                      PersonalItemAnchorType.variant
                  ? personal.selectedWishlistVariantId
                  : null,
              bundleReleaseId: personal.selectedWishlistAnchorType ==
                      PersonalItemAnchorType.bundleRelease
                  ? personal.selectedWishlistBundleReleaseId
                  : null,
              targetPriceCents:
                  parseMoneyCents(personal.wishlistPriceController.text),
              currency: emptyToNull(personal.wishlistCurrencyController.text),
              notes: emptyToNull(personal.wishlistNotesController.text),
            ),
      tracking: !hasTrackingContext
          ? null
          : LibraryTrackingEditSelection(
              editionId: tracking.selectedTrackingEditionId,
              variantId: tracking.selectedTrackingVariantId,
              rating: parseInt(tracking.ratingController.text),
              readStatus: emptyToNull(tracking.trackingController.text),
              startedAt: tracking.startedAt,
              finishedAt: tracking.finishedAt,
              progressCurrent:
                  parseInt(tracking.progressCurrentController.text),
              progressTotal: parseInt(tracking.progressTotalController.text),
              timesCompleted: parseInt(tracking.timesCompletedController.text),
              notes: emptyToNull(tracking.trackingNotesController.text),
              seasonNumber: parseInt(tracking.seasonNumberController.text),
              episodeNumber: parseInt(tracking.episodeNumberController.text),
              episodeRatings: tracking.episodeRatings.isEmpty
                  ? null
                  : tracking.episodeRatings,
            ),
      customFieldEdits: customFieldEdits,
      itemImageEdits: itemImageEdits,
      submitAction: submitAction,
    );
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
    _textControllers.dispose();
  }

  CatalogSeriesDetails? _buildUpdatedSeries() {
    final typedSeriesTitle = emptyToNull(metadata.seriesTitleController.text);
    final seriesTitle = type.editUsesTitleAsSeries
        ? emptyToNull(metadata.titleController.text)
        : typedSeriesTitle;
    final currentSeries = item.series;
    if (seriesTitle == null && currentSeries == null) {
      return null;
    }
    return CatalogSeriesDetails(
      seriesId: metadata.seriesId,
      seriesTitle: seriesTitle,
      volumeName: currentSeries?.volumeName,
      volumeNumber: currentSeries?.volumeNumber,
      volumeStartYear: currentSeries?.volumeStartYear,
      seasonNumber: currentSeries?.seasonNumber,
      episodeNumber: currentSeries?.episodeNumber,
      tags: currentSeries?.tags,
    );
  }

  List<Map<String, dynamic>>? _buildUpdatedCreators() {
    if (type.workspace.kind.apiValue != 'game') {
      return item.creators;
    }

    final existing = item.creators ?? const <Map<String, dynamic>>[];
    final preserved = <Map<String, dynamic>>[];
    for (final entry in existing) {
      final role = entry['role']?.toString().toLowerCase() ?? '';
      if (role.contains('developer')) {
        continue;
      }
      preserved.add(Map<String, dynamic>.from(entry));
    }

    final developerNames = metadata.developersController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    final merged = <Map<String, dynamic>>[
      ...preserved,
      for (final name in developerNames)
        <String, dynamic>{'name': name, 'role': 'Developer'},
    ];
    return merged.isEmpty
        ? null
        : List<Map<String, dynamic>>.unmodifiable(merged);
  }

  static List<String> _creatorNamesForRoles(
    List<Map<String, dynamic>>? creators,
    List<String> roles,
  ) {
    if (creators == null || creators.isEmpty) {
      return const <String>[];
    }

    final names = <String>[];
    for (final entry in creators) {
      final role = entry['role']?.toString().toLowerCase() ?? '';
      if (!roles.any(role.contains)) {
        continue;
      }
      final name = entry['name']?.toString().trim();
      if (name == null || name.isEmpty || names.contains(name)) {
        continue;
      }
      names.add(name);
    }
    return List<String>.unmodifiable(names);
  }

  static String? _initialPhysicalFormatId(
    LibraryMetadataItem item,
    List<PhysicalMediaFormat> physicalFormats,
  ) {
    final effectiveFormats = physicalFormats.isEmpty
        ? allKnownPhysicalMediaFormats
        : physicalFormats;
    final configured = item.physicalFormat == null
        ? null
        : physicalMediaFormatById(item.physicalFormat!,
            formats: effectiveFormats);
    if (configured != null) {
      return configured.id;
    }
    final byLabel = physicalMediaFormatByLabelOrId(
      item.physicalFormatLabel ?? item.variant,
      formats: effectiveFormats,
    );
    return byLabel?.id;
  }

  OwnedItemCommonDraft buildCommonDraft() {
    return OwnedItemCommonDraft(
      quantity: parseInt(personal.quantityController.text) ?? 1,
      condition: emptyToNull(personal.conditionController.text),
      grade: emptyToNull(personal.gradeController.text),
      purchaseDate: parseDate(personal.purchaseDateController.text),
      pricePaidCents: parseMoneyCents(personal.priceController.text),
      currency: emptyToNull(personal.currencyController.text),
      personalNotes: emptyToNull(personal.notesController.text),
      locationId: personal.selectedLocationId,
      purchaseStore: emptyToNull(personal.purchaseStoreController.text),
      collectionStatus: personal.collectionStatus,
      tags: emptyToNull(personal.tagsController.text),
      rating: parseInt(tracking.ratingController.text),
      readStatus: emptyToNull(tracking.trackingController.text),
      startedAt: tracking.startedAt,
      finishedAt: tracking.finishedAt,
      editionId: personal.selectedEditionId,
      variantId: personal.selectedVariantId,
      bundleReleaseId: personal.selectedBundleReleaseId,
    );
  }

  OwnedDetailsDraft buildDetailsDraft() => defaultLibraryKindRegistry
      .getByKind(type.workspace.kind)
      .edit
      .buildDetailsDraft(kindDetails);

  AddOwnedItemCommand toAddOwnedItemCommand() {
    return AddOwnedItemCommand(
      catalogRef: CatalogEntityRef(
        kind: type.workspace.kind.apiValue,
        entityType: CatalogEntityType.ownedCopy,
        id: item.id,
      ),
      common: buildCommonDraft(),
      details: buildDetailsDraft(),
    );
  }

  UpdateOwnedItemCommand toUpdateOwnedItemCommand(String ownedItemId) {
    return defaultLibraryKindRegistry
        .getByKind(type.workspace.kind)
        .edit
        .buildUpdateCommand(
          session: this,
          ownedItemId: ownedItemId,
          kindDraft: kindDetails,
        );
  }
}
