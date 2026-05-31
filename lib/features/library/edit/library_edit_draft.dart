import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/anchor_selection_helpers.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:flutter/material.dart';

class LibraryEditDraft {
  LibraryEditDraft._({
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
    required this.titleController,
    required this.numberController,
    required this.publisherController,
    required this.coverDateController,
    required this.coverDateYearPartController,
    required this.coverDateMonthPartController,
    required this.coverDateDayPartController,
    required this.releaseDateController,
    required this.releaseDateYearPartController,
    required this.releaseDateMonthPartController,
    required this.releaseDateDayPartController,
    required this.releaseYearController,
    required this.pageCountController,
    required this.editionTitleController,
    required this.barcodeController,
    required this.variantController,
    required this.physicalFormatLabelController,
    required this.coverController,
    required this.thumbnailController,
    required this.synopsisController,
    required this.sortKeyController,
    required this.originalTitleController,
    required this.runtimeController,
    required this.audienceRatingController,
    required this.countryController,
    required this.languageController,
    required this.ageRatingController,
    required this.genresEditController,
    required this.titleExtensionController,
    required this.crossoverController,
    required this.storyArcsController,
    required this.ownerLabelController,
    required this.imprintController,
    required this.seriesGroupController,
    required this.conditionController,
    required this.gradeController,
    required this.purchaseDateController,
    required this.priceController,
    required this.currencyController,
    required this.quantityController,
    required this.notesController,
    required this.wishlistPriceController,
    required this.wishlistCurrencyController,
    required this.wishlistNotesController,
    required this.ratingController,
    required this.trackingController,
    required this.progressCurrentController,
    required this.progressTotalController,
    required this.timesCompletedController,
    required this.seasonNumberController,
    required this.episodeNumberController,
    required this.trackingNotesController,
    required this.tagsController,
    required this.sellPriceController,
    required this.soldToController,
    required this.rawOrSlabbedController,
    required this.gradingCompanyController,
    required this.graderNotesController,
    required this.signedByController,
    required this.labelTypeController,
    required this.certificationNumberController,
    required this.coverPriceController,
    required this.keyReasonController,
    required this.featuresController,
    required this.purchaseStoreController,
    required this.boxSetNameController,
    required this.storageDeviceController,
    required this.storageSlotController,
    required this.regionController,
    required this.packagingController,
    required this.distributorController,
    required this.screenRatioController,
    required this.marketValueController,
    required this.audioTracksController,
    required this.subtitlesController,
    required this.layersController,
    required this.colorController,
    required this.nrDiscsController,
    required this.tagOptions,
    required this.availableLocations,
    required this.selectedLocationId,
    required this.selectedOwnedAnchorType,
    required this.selectedEditionId,
    required this.selectedVariantId,
    required this.selectedBundleReleaseId,
    required this.selectedTrackingEditionId,
    required this.selectedTrackingVariantId,
    required this.selectedWishlistAnchorType,
    required this.selectedWishlistEditionId,
    required this.selectedWishlistVariantId,
    required this.selectedWishlistBundleReleaseId,
    required this.locationChanged,
    required this.soldAt,
    required this.startedAt,
    required this.finishedAt,
    required this.episodeRatings,
    required this.keyComic,
    required this.hdrFormats,
    required this.collectionStatus,
    required this.lastBagBoardDate,
    required this.physicalFormatId,
    required this.seriesId,
    required this.customFieldEdits,
    required this.itemImageEdits,
  });

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
    final initialPhysicalFormatId = _initialPhysicalFormatId(item, physicalFormats);
    final effectiveFormats = physicalFormats.isEmpty
        ? allKnownPhysicalMediaFormats
        : physicalFormats;
    final titleController = TextEditingController(text: item.title);
    final numberController = TextEditingController(text: item.itemNumber ?? '');
    final publisherController = TextEditingController(text: item.publisher ?? '');
    final coverDateController = TextEditingController(
      text: item.coverDate == null ? '' : formatDate(item.coverDate!),
    );
    final coverDateYearPartController = TextEditingController(
      text: item.coverDate?.year.toString() ?? '',
    );
    final coverDateMonthPartController = TextEditingController(
      text: item.coverDate == null
          ? ''
          : item.coverDate!.month.toString().padLeft(2, '0'),
    );
    final coverDateDayPartController = TextEditingController(
      text: item.coverDate == null
          ? ''
          : item.coverDate!.day.toString().padLeft(2, '0'),
    );
    final releaseDateController = TextEditingController(
      text: item.releaseDate == null ? '' : formatDate(item.releaseDate!),
    );
    final releaseDateYearPartController = TextEditingController(
      text: item.releaseDate?.year.toString() ?? '',
    );
    final releaseDateMonthPartController = TextEditingController(
      text: item.releaseDate == null
          ? ''
          : item.releaseDate!.month.toString().padLeft(2, '0'),
    );
    final releaseDateDayPartController = TextEditingController(
      text: item.releaseDate == null
          ? ''
          : item.releaseDate!.day.toString().padLeft(2, '0'),
    );
    final releaseYearController = TextEditingController(
      text: item.releaseYear?.toString() ?? '',
    );
    final pageCountController = TextEditingController(
      text: item.publishing?.pageCount?.toString() ?? '',
    );
    final editionTitleController =
        TextEditingController(text: item.editionTitle ?? '');
    final barcodeController = TextEditingController(text: item.barcode ?? '');
    final variantController = TextEditingController(text: item.variant ?? '');
    final physicalFormatLabelController = TextEditingController(
      text: item.physicalFormatLabel ??
          (type.workspace.kind.apiValue == 'comic' ? item.variant : null) ??
          (initialPhysicalFormatId == null
              ? null
              : physicalMediaFormatById(
                  initialPhysicalFormatId,
                  formats: effectiveFormats,
            )?.label) ??
          '',
    );
    final coverController = TextEditingController(text: item.coverImageUrl ?? '');
    final thumbnailController =
        TextEditingController(text: item.thumbnailImageUrl ?? '');
    final synopsisController = TextEditingController(text: item.synopsis ?? '');
    final sortKeyController = TextEditingController(text: item.sortKey ?? '');
    final originalTitleController =
        TextEditingController(text: item.originalTitle ?? '');
    final runtimeController = TextEditingController(
      text: item.video?.runtimeMinutes?.toString() ?? '',
    );
    final audienceRatingController =
        TextEditingController(text: item.audienceRating ?? '');
    final countryController = TextEditingController(text: item.country ?? '');
    final languageController = TextEditingController(text: item.language ?? '');
    final ageRatingController = TextEditingController(text: item.ageRating ?? '');
    final genresEditController =
        TextEditingController(text: item.genres?.join(', ') ?? '');
    final titleExtensionController =
        TextEditingController(text: item.titleExtension ?? '');
    final crossoverController =
      TextEditingController(text: item.crossover?.trim() ?? '');
    final storyArcsController = TextEditingController(
      text: (item.storyArcs ?? const <String>[]).join(', '),
    );
    final ownerLabelController =
        TextEditingController(text: ownedItem?.ownerLabel ?? '');
    final imprintController =
        TextEditingController(text: item.publishing?.imprint ?? '');
    final seriesGroupController =
        TextEditingController(text: item.publishing?.seriesGroup ?? '');
    final conditionController =
        TextEditingController(text: ownedItem?.condition ?? '');
    final gradeController = TextEditingController(text: ownedItem?.grade ?? '');
    final purchaseDateController = TextEditingController(
      text: ownedItem?.purchaseDate == null
          ? ''
          : formatDate(ownedItem!.purchaseDate!),
    );
    final priceController = TextEditingController(
      text: ownedItem?.pricePaidCents == null
          ? ''
          : (ownedItem!.pricePaidCents! / 100).toStringAsFixed(2),
    );
    final currencyController = TextEditingController(text: ownedItem?.currency ?? '');
    final quantityController = TextEditingController(
      text: (ownedItem?.quantity ?? 1).toString(),
    );
    final notesController =
        TextEditingController(text: ownedItem?.personalNotes ?? '');
    final wishlistPriceController = TextEditingController(
      text: wishlistItem?.targetPriceCents == null
          ? ''
          : (wishlistItem!.targetPriceCents! / 100).toStringAsFixed(2),
    );
    final wishlistCurrencyController =
        TextEditingController(text: wishlistItem?.currency ?? '');
    final wishlistNotesController =
        TextEditingController(text: wishlistItem?.notes ?? '');
    final ratingController = TextEditingController(
      text: (trackingEntry?.rating ?? ownedItem?.rating)?.toString() ?? '',
    );
    final trackingController = TextEditingController(
      text: trackingEntry?.statusStorageValue ?? ownedItem?.readStatus ?? '',
    );
    final progressCurrentController = TextEditingController(
      text: trackingEntry?.progressCurrent?.toString() ?? '',
    );
    final progressTotalController = TextEditingController(
      text: trackingEntry?.progressTotal?.toString() ?? '',
    );
    final timesCompletedController = TextEditingController(
      text: trackingEntry?.timesCompleted?.toString() ?? '',
    );
    final seasonNumberController = TextEditingController(
      text: (trackingEntry?.seasonNumber ?? item.series?.seasonNumber)
              ?.toString() ??
          '',
    );
    final episodeNumberController = TextEditingController(
      text: (trackingEntry?.episodeNumber ?? item.series?.episodeNumber)
              ?.toString() ??
          '',
    );
    final trackingNotesController =
        TextEditingController(text: trackingEntry?.notes ?? '');
    final tagsController = TextEditingController(text: ownedItem?.tags ?? '');
    final sellPriceController = TextEditingController(
      text: ownedItem?.sellPriceCents == null
          ? ''
          : (ownedItem!.sellPriceCents! / 100).toStringAsFixed(2),
    );
    final soldToController = TextEditingController(text: ownedItem?.soldTo ?? '');
    final rawOrSlabbedController =
        TextEditingController(text: ownedItem?.rawOrSlabbed ?? '');
    final gradingCompanyController =
        TextEditingController(text: ownedItem?.gradingCompany ?? '');
    final graderNotesController =
        TextEditingController(text: ownedItem?.graderNotes ?? '');
    final signedByController =
        TextEditingController(text: ownedItem?.signedBy ?? '');
    final labelTypeController =
        TextEditingController(text: ownedItem?.labelType ?? '');
    final certificationNumberController =
        TextEditingController(text: ownedItem?.certificationNumber ?? '');
    final coverPriceController = TextEditingController(
      text: ownedItem?.coverPriceCents == null
          ? ''
          : (ownedItem!.coverPriceCents! / 100).toStringAsFixed(2),
    );
    final keyReasonController =
        TextEditingController(text: ownedItem?.keyReason ?? '');
    final featuresController =
        TextEditingController(text: ownedItem?.features ?? '');
    final purchaseStoreController =
        TextEditingController(text: ownedItem?.purchaseStore ?? '');
    final boxSetNameController =
        TextEditingController(text: ownedItem?.boxSetName ?? '');
    final storageDeviceController =
        TextEditingController(text: ownedItem?.storageDevice ?? '');
    final storageSlotController =
        TextEditingController(text: ownedItem?.storageSlot ?? '');
    final regionController = TextEditingController(text: ownedItem?.region ?? '');
    final packagingController =
        TextEditingController(text: ownedItem?.packaging ?? '');
    final distributorController =
        TextEditingController(text: ownedItem?.distributor ?? '');
    final marketValueController = TextEditingController(
      text: ownedItem?.marketValueCents == null
          ? ''
          : (ownedItem!.marketValueCents! / 100).toStringAsFixed(2),
    );
    final screenRatioController =
        TextEditingController(text: item.video?.screenRatio ?? '');
    final audioTracksController =
        TextEditingController(text: item.video?.audioTracks ?? '');
    final subtitlesController =
        TextEditingController(text: item.video?.subtitles ?? '');
    final layersController = TextEditingController(text: item.video?.layers ?? '');
    final colorController = TextEditingController(text: item.video?.color ?? '');
    final nrDiscsController =
        TextEditingController(text: item.video?.nrDiscs?.toString() ?? '');

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

    return LibraryEditDraft._(
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
      sortKeyController: sortKeyController,
      originalTitleController: originalTitleController,
      runtimeController: runtimeController,
      audienceRatingController: audienceRatingController,
      countryController: countryController,
      languageController: languageController,
      ageRatingController: ageRatingController,
      genresEditController: genresEditController,
      titleExtensionController: titleExtensionController,
      crossoverController: crossoverController,
      storyArcsController: storyArcsController,
      ownerLabelController: ownerLabelController,
      imprintController: imprintController,
      seriesGroupController: seriesGroupController,
      conditionController: conditionController,
      gradeController: gradeController,
      purchaseDateController: purchaseDateController,
      priceController: priceController,
      currencyController: currencyController,
      quantityController: quantityController,
      notesController: notesController,
      wishlistPriceController: wishlistPriceController,
      wishlistCurrencyController: wishlistCurrencyController,
      wishlistNotesController: wishlistNotesController,
      ratingController: ratingController,
      trackingController: trackingController,
      progressCurrentController: progressCurrentController,
      progressTotalController: progressTotalController,
      timesCompletedController: timesCompletedController,
      seasonNumberController: seasonNumberController,
      episodeNumberController: episodeNumberController,
      trackingNotesController: trackingNotesController,
      tagsController: tagsController,
      sellPriceController: sellPriceController,
      soldToController: soldToController,
      rawOrSlabbedController: rawOrSlabbedController,
      gradingCompanyController: gradingCompanyController,
      graderNotesController: graderNotesController,
      signedByController: signedByController,
      labelTypeController: labelTypeController,
      certificationNumberController: certificationNumberController,
      coverPriceController: coverPriceController,
      keyReasonController: keyReasonController,
      featuresController: featuresController,
      purchaseStoreController: purchaseStoreController,
      boxSetNameController: boxSetNameController,
      storageDeviceController: storageDeviceController,
      storageSlotController: storageSlotController,
      regionController: regionController,
      packagingController: packagingController,
      distributorController: distributorController,
      screenRatioController: screenRatioController,
      marketValueController: marketValueController,
      audioTracksController: audioTracksController,
      subtitlesController: subtitlesController,
      layersController: layersController,
      colorController: colorController,
      nrDiscsController: nrDiscsController,
      tagOptions: splitPickListValues(ownedItem?.tags),
      availableLocations: const [],
      selectedLocationId: ownedItem?.locationId,
      selectedOwnedAnchorType:
          ownedItem?.personalAnchor?.apiValue ?? PersonalItemAnchorType.item.apiValue,
      selectedEditionId: editionSelection.edition?.id,
      selectedVariantId: editionSelection.variant?.id,
      selectedBundleReleaseId:
          normalizeLibrarySelectionId(ownedItem?.bundleReleaseId),
      selectedTrackingEditionId:
          trackingEntry?.editionId ?? editionSelection.edition?.id,
      selectedTrackingVariantId:
          trackingEntry?.variantId ?? editionSelection.variant?.id,
      selectedWishlistAnchorType: wishlistItem?.personalAnchor?.apiValue ??
          PersonalItemAnchorType.item.apiValue,
      selectedWishlistEditionId: wishlistEditionSelection.edition?.id,
      selectedWishlistVariantId: wishlistEditionSelection.variant?.id,
      selectedWishlistBundleReleaseId:
          normalizeLibrarySelectionId(wishlistItem?.bundleReleaseId),
      locationChanged: false,
      soldAt: ownedItem?.soldAt,
      startedAt: trackingEntry?.startedAt ?? ownedItem?.startedAt,
      finishedAt: trackingEntry?.finishedAt ?? ownedItem?.finishedAt,
      episodeRatings:
          Map<String, int>.from(trackingEntry?.episodeRatings ?? const {}),
      keyComic: ownedItem?.keyComic ?? false,
      hdrFormats: List<String>.from(ownedItem?.hdrFormats ?? const <String>[]),
      collectionStatus: ownedItem?.collectionStatus,
      lastBagBoardDate: ownedItem?.lastBagBoardDate,
      physicalFormatId: initialPhysicalFormatId,
      seriesId: item.series?.seriesId,
      customFieldEdits: {
        for (final value in customFieldValues) value.fieldDefinitionId: value.value,
      },
      itemImageEdits: const [],
    );
  }

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

  final TextEditingController titleController;
  final TextEditingController numberController;
  final TextEditingController publisherController;
  final TextEditingController coverDateController;
  final TextEditingController coverDateYearPartController;
  final TextEditingController coverDateMonthPartController;
  final TextEditingController coverDateDayPartController;
  final TextEditingController releaseDateController;
  final TextEditingController releaseDateYearPartController;
  final TextEditingController releaseDateMonthPartController;
  final TextEditingController releaseDateDayPartController;
  final TextEditingController releaseYearController;
  final TextEditingController pageCountController;
  final TextEditingController editionTitleController;
  final TextEditingController barcodeController;
  final TextEditingController variantController;
  final TextEditingController physicalFormatLabelController;
  final TextEditingController coverController;
  final TextEditingController thumbnailController;
  final TextEditingController synopsisController;
  final TextEditingController sortKeyController;
  final TextEditingController originalTitleController;
  final TextEditingController runtimeController;
  final TextEditingController audienceRatingController;
  final TextEditingController countryController;
  final TextEditingController languageController;
  final TextEditingController ageRatingController;
  final TextEditingController genresEditController;
  final TextEditingController titleExtensionController;
  final TextEditingController crossoverController;
  final TextEditingController storyArcsController;
  final TextEditingController ownerLabelController;
  final TextEditingController imprintController;
  final TextEditingController seriesGroupController;
  final TextEditingController conditionController;
  final TextEditingController gradeController;
  final TextEditingController purchaseDateController;
  final TextEditingController priceController;
  final TextEditingController currencyController;
  final TextEditingController quantityController;
  final TextEditingController notesController;
  final TextEditingController wishlistPriceController;
  final TextEditingController wishlistCurrencyController;
  final TextEditingController wishlistNotesController;
  final TextEditingController ratingController;
  final TextEditingController trackingController;
  final TextEditingController progressCurrentController;
  final TextEditingController progressTotalController;
  final TextEditingController timesCompletedController;
  final TextEditingController seasonNumberController;
  final TextEditingController episodeNumberController;
  final TextEditingController trackingNotesController;
  final TextEditingController tagsController;
  final TextEditingController sellPriceController;
  final TextEditingController soldToController;
  final TextEditingController rawOrSlabbedController;
  final TextEditingController gradingCompanyController;
  final TextEditingController graderNotesController;
  final TextEditingController signedByController;
  final TextEditingController labelTypeController;
  final TextEditingController certificationNumberController;
  final TextEditingController coverPriceController;
  final TextEditingController keyReasonController;
  final TextEditingController featuresController;
  final TextEditingController purchaseStoreController;
  final TextEditingController boxSetNameController;
  final TextEditingController storageDeviceController;
  final TextEditingController storageSlotController;
  final TextEditingController regionController;
  final TextEditingController packagingController;
  final TextEditingController distributorController;
  final TextEditingController screenRatioController;
  final TextEditingController marketValueController;
  final TextEditingController audioTracksController;
  final TextEditingController subtitlesController;
  final TextEditingController layersController;
  final TextEditingController colorController;
  final TextEditingController nrDiscsController;

  List<String> tagOptions;
  List<StorageLocation> availableLocations;
  String? selectedLocationId;
  String selectedOwnedAnchorType;
  String? selectedEditionId;
  String? selectedVariantId;
  String? selectedBundleReleaseId;
  String? selectedTrackingEditionId;
  String? selectedTrackingVariantId;
  String selectedWishlistAnchorType;
  String? selectedWishlistEditionId;
  String? selectedWishlistVariantId;
  String? selectedWishlistBundleReleaseId;
  bool locationChanged;
  DateTime? soldAt;
  DateTime? startedAt;
  DateTime? finishedAt;
  Map<String, int> episodeRatings;
  bool keyComic;
  List<String> hdrFormats;
  String? collectionStatus;
  DateTime? lastBagBoardDate;
  String? physicalFormatId;
  String? seriesId;
  Map<String, String?> customFieldEdits;
  List<ItemImageEdit> itemImageEdits;

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
      physicalFormatId,
      label: physicalFormatForId(physicalFormatId)?.label ??
          emptyToNull(physicalFormatLabelController.text) ??
          item.physicalFormatLabel ??
          variantController.text,
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
      selectedLocationId: selectedLocationId,
      startedAt: startedAt,
      finishedAt: finishedAt,
      soldAt: soldAt,
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
        seasonNumberController.text.trim().isNotEmpty ||
        episodeNumberController.text.trim().isNotEmpty;
  }

  LibraryEditSelection buildSelection() {
    final updatedPublishing = CatalogPublishingDetails(
      pageCount: parseInt(pageCountController.text),
      coverPriceCents: item.publishing?.coverPriceCents,
      currency: item.publishing?.currency,
      imprint: emptyToNull(imprintController.text),
      subtitle: item.publishing?.subtitle,
      seriesGroup: emptyToNull(seriesGroupController.text),
    );
    final parsedStoryArcs = storyArcsController.text
      .split(RegExp(r'[,\r\n]+'))
        .map((storyArc) => storyArc.trim())
        .where((storyArc) => storyArc.isNotEmpty)
        .toList();
    final updatedVideo = VideoCatalogDetails(
      runtimeMinutes: int.tryParse(runtimeController.text),
      color: emptyToNull(colorController.text),
      nrDiscs: int.tryParse(nrDiscsController.text),
      screenRatio: emptyToNull(screenRatioController.text),
      audioTracks: emptyToNull(audioTracksController.text),
      subtitles: emptyToNull(subtitlesController.text),
      layers: emptyToNull(layersController.text),
    );
    final parsedGenres = genresEditController.text
      .split(RegExp(r'[,\r\n]+'))
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toList();
    return LibraryEditSelection(
      item: item.copyWith(
        title: titleController.text.trim(),
        sortKey: emptyToNull(sortKeyController.text),
        originalTitle: emptyToNull(originalTitleController.text),
        titleExtension: emptyToNull(titleExtensionController.text),
        itemNumber: emptyToNull(numberController.text),
        synopsis: emptyToNull(synopsisController.text),
        coverImageUrl: emptyToNull(coverController.text),
        thumbnailImageUrl: emptyToNull(thumbnailController.text),
        editionTitle: emptyToNull(editionTitleController.text),
        physicalFormat: physicalFormatId,
        physicalFormatLabel: emptyToNull(physicalFormatLabelController.text) ??
          physicalFormatForId(physicalFormatId)?.label,
        publisher: emptyToNull(publisherController.text),
        coverDate: parseDate(coverDateController.text),
        releaseDate: parseDate(releaseDateController.text),
        releaseYear: parseInt(releaseYearController.text),
        barcode: emptyToNull(barcodeController.text),
        variant: emptyToNull(variantController.text),
        crossover: emptyToNull(crossoverController.text),
        series: _buildUpdatedSeries(),
        country: emptyToNull(countryController.text),
        language: emptyToNull(languageController.text),
        ageRating: emptyToNull(ageRatingController.text),
        audienceRating: emptyToNull(audienceRatingController.text),
        genres: parsedGenres.isEmpty ? null : parsedGenres,
        storyArcs: parsedStoryArcs.isEmpty ? null : parsedStoryArcs,
        publishing: updatedPublishing.hasData ? updatedPublishing : null,
        video: updatedVideo.hasData ? updatedVideo : null,
      ),
      personal: ownedItem == null
          ? null
          : LibraryPersonalEditSelection(
              anchorType: selectedOwnedAnchorType,
              editionId: selectedOwnedAnchorType ==
                          PersonalItemAnchorType.edition.apiValue ||
                      selectedOwnedAnchorType ==
                          PersonalItemAnchorType.variant.apiValue
                  ? selectedEditionId
                  : null,
              variantId: selectedOwnedAnchorType ==
                      PersonalItemAnchorType.variant.apiValue
                  ? selectedVariantId
                  : null,
              bundleReleaseId: selectedOwnedAnchorType ==
                      PersonalItemAnchorType.bundleRelease.apiValue
                  ? selectedBundleReleaseId
                  : null,
              condition: showPhysicalOwnedFields
                  ? emptyToNull(conditionController.text)
                  : null,
              grade: showPhysicalOwnedFields
                  ? emptyToNull(gradeController.text)
                  : null,
              purchaseDate: parseDate(purchaseDateController.text),
              pricePaidCents: parseMoneyCents(priceController.text),
              currency: emptyToNull(currencyController.text),
              personalNotes: emptyToNull(notesController.text),
              quantity: parseInt(quantityController.text) ?? 1,
              locationId: showPhysicalOwnedFields ? selectedLocationId : null,
              locationChanged: showPhysicalOwnedFields ? locationChanged : false,
              tags: emptyToNull(tagsController.text),
              soldAt: soldAt,
              sellPriceCents: parseMoneyCents(sellPriceController.text),
              soldTo: emptyToNull(soldToController.text),
              rawOrSlabbed:
                  isDigitalFormat ? null : emptyToNull(rawOrSlabbedController.text),
              gradingCompany: isDigitalFormat
                  ? null
                  : emptyToNull(gradingCompanyController.text),
              graderNotes:
                  isDigitalFormat ? null : emptyToNull(graderNotesController.text),
              signedBy:
                  isDigitalFormat ? null : emptyToNull(signedByController.text),
              labelType:
                  isDigitalFormat ? null : emptyToNull(labelTypeController.text),
              certificationNumber: isDigitalFormat
                  ? null
                  : emptyToNull(certificationNumberController.text),
              keyComic: keyComic,
              keyReason: emptyToNull(keyReasonController.text),
              coverPriceCents: isDigitalFormat
                  ? null
                  : parseMoneyCents(coverPriceController.text),
              features: emptyToNull(featuresController.text),
              hdrFormats: hdrFormats.isEmpty ? null : hdrFormats,
              purchaseStore: emptyToNull(purchaseStoreController.text),
              boxSetName: emptyToNull(boxSetNameController.text),
              storageDevice: emptyToNull(storageDeviceController.text),
              storageSlot: emptyToNull(storageSlotController.text),
              region: emptyToNull(regionController.text),
              packaging: emptyToNull(packagingController.text),
              distributor: emptyToNull(distributorController.text),
              screenRatio: emptyToNull(screenRatioController.text),
              audioTracks: emptyToNull(audioTracksController.text),
              subtitles: emptyToNull(subtitlesController.text),
              layers: emptyToNull(layersController.text),
              color: emptyToNull(colorController.text),
              nrDiscs: int.tryParse(nrDiscsController.text),
              collectionStatus: collectionStatus,
              lastBagBoardDate: lastBagBoardDate,
              marketValueCents: parseMoneyCents(marketValueController.text),
              ownerLabel: emptyToNull(ownerLabelController.text),
            ),
      wishlist: wishlistItem == null
          ? null
          : LibraryWishlistEditSelection(
              anchorType: selectedWishlistAnchorType,
              editionId: selectedWishlistAnchorType ==
                          PersonalItemAnchorType.edition.apiValue ||
                      selectedWishlistAnchorType ==
                          PersonalItemAnchorType.variant.apiValue
                  ? selectedWishlistEditionId
                  : null,
              variantId: selectedWishlistAnchorType ==
                      PersonalItemAnchorType.variant.apiValue
                  ? selectedWishlistVariantId
                  : null,
              bundleReleaseId: selectedWishlistAnchorType ==
                      PersonalItemAnchorType.bundleRelease.apiValue
                  ? selectedWishlistBundleReleaseId
                  : null,
              targetPriceCents: parseMoneyCents(wishlistPriceController.text),
              currency: emptyToNull(wishlistCurrencyController.text),
              notes: emptyToNull(wishlistNotesController.text),
            ),
      tracking: !hasTrackingContext
          ? null
          : LibraryTrackingEditSelection(
              editionId: selectedTrackingEditionId,
              variantId: selectedTrackingVariantId,
              rating: parseInt(ratingController.text),
              readStatus: emptyToNull(trackingController.text),
              startedAt: startedAt,
              finishedAt: finishedAt,
              progressCurrent: parseInt(progressCurrentController.text),
              progressTotal: parseInt(progressTotalController.text),
              timesCompleted: parseInt(timesCompletedController.text),
              notes: emptyToNull(trackingNotesController.text),
              seasonNumber: parseInt(seasonNumberController.text),
              episodeNumber: parseInt(episodeNumberController.text),
              episodeRatings: episodeRatings.isEmpty ? null : episodeRatings,
            ),
      customFieldEdits: customFieldEdits,
      itemImageEdits: itemImageEdits,
    );
  }

  void dispose() {
    for (final controller in [
      titleController,
      numberController,
      publisherController,
      coverDateController,
      coverDateYearPartController,
      coverDateMonthPartController,
      coverDateDayPartController,
      releaseDateController,
      releaseDateYearPartController,
      releaseDateMonthPartController,
      releaseDateDayPartController,
      releaseYearController,
      pageCountController,
      editionTitleController,
      barcodeController,
      variantController,
      physicalFormatLabelController,
      coverController,
      thumbnailController,
      synopsisController,
      sortKeyController,
      originalTitleController,
      runtimeController,
      audienceRatingController,
      countryController,
      languageController,
      ageRatingController,
      genresEditController,
      titleExtensionController,
      crossoverController,
      storyArcsController,
      ownerLabelController,
      imprintController,
      seriesGroupController,
      conditionController,
      gradeController,
      purchaseDateController,
      priceController,
      currencyController,
      quantityController,
      notesController,
      wishlistPriceController,
      wishlistCurrencyController,
      wishlistNotesController,
      ratingController,
      trackingController,
      progressCurrentController,
      progressTotalController,
      timesCompletedController,
      seasonNumberController,
      episodeNumberController,
      trackingNotesController,
      tagsController,
      sellPriceController,
      soldToController,
      rawOrSlabbedController,
      gradingCompanyController,
      graderNotesController,
      signedByController,
      labelTypeController,
      certificationNumberController,
      coverPriceController,
      keyReasonController,
      featuresController,
      purchaseStoreController,
      boxSetNameController,
      storageDeviceController,
      storageSlotController,
      regionController,
      packagingController,
      distributorController,
      screenRatioController,
      marketValueController,
      audioTracksController,
      subtitlesController,
      layersController,
      colorController,
      nrDiscsController,
    ]) {
      controller.dispose();
    }
  }

  CatalogSeriesDetails? _buildUpdatedSeries() {
    if (type.workspace.kind.apiValue != 'comic') {
      return item.series;
    }
    final seriesTitle = emptyToNull(titleController.text);
    final currentSeries = item.series;
    if (seriesTitle == null && currentSeries == null) {
      return null;
    }
    return CatalogSeriesDetails(
      seriesId: seriesId,
      seriesTitle: seriesTitle,
      volumeName: currentSeries?.volumeName,
      volumeNumber: currentSeries?.volumeNumber,
      volumeStartYear: currentSeries?.volumeStartYear,
      seasonNumber: currentSeries?.seasonNumber,
      episodeNumber: currentSeries?.episodeNumber,
      tags: currentSeries?.tags ?? const <String>[],
    );
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
        : physicalMediaFormatById(item.physicalFormat!, formats: effectiveFormats);
    if (configured != null) {
      return configured.id;
    }
    final byLabel = physicalMediaFormatByLabelOrId(
      item.physicalFormatLabel ?? item.variant,
      formats: effectiveFormats,
    );
    return byLabel?.id;
  }
}