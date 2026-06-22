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
import 'package:collectarr_app/features/library/edit/text_controller_group.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:flutter/material.dart';

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
    required this.seriesTitleController,
    required this.developersController,
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
    required this.pageQualityController,
    required this.certificationNumberController,
    required this.coverPriceController,
    required this.keyReasonController,
    required this.keyCategoryController,
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
    required this.gameCompleteness,
    required this.gameHasBox,
    required this.gameHasManual,
    required this.gamePriceChartingId,
    required this.gameCoreRegion,
    required this.gameValueIsLocked,
    required this.physicalFormatId,
    required this.seriesId,
    required this.customFieldEdits,
    required this.itemImageEdits,
  }) : _textControllers = textControllers;

  final TextControllerGroup _textControllers;

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
    final editionTitleController = create(item.editionTitle ?? '');
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
    final sortKeyController = create(item.sortKey ?? '');
    final originalTitleController = create(item.originalTitle ?? '');
    final runtimeController = create(
      item.video?.runtimeMinutes?.toString() ?? '',
    );
    final audienceRatingController = create(item.audienceRating ?? '');
    final countryController = create(item.country ?? '');
    final languageController = create(item.language ?? '');
    final ageRatingController = create(item.ageRating ?? '');
    final genresEditController = create(item.genres?.join(', ') ?? '');
    final titleExtensionController = create(item.titleExtension ?? '');
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
    final rawOrSlabbedController = create(ownedItem?.rawOrSlabbed ?? '');
    final gradingCompanyController = create(ownedItem?.gradingCompany ?? '');
    final graderNotesController = create(ownedItem?.graderNotes ?? '');
    final signedByController = create(ownedItem?.signedBy ?? '');
    final labelTypeController = create(ownedItem?.labelType ?? '');
    final pageQualityController = create(ownedItem?.pageQuality ?? '');
    final certificationNumberController = create(
      ownedItem?.certificationNumber ?? '',
    );
    final coverPriceController = create(
      ownedItem?.coverPriceCents == null
          ? ''
          : (ownedItem!.coverPriceCents! / 100).toStringAsFixed(2),
    );
    final keyReasonController = create(ownedItem?.keyReason ?? '');
    final keyCategoryController = create(ownedItem?.keyCategory ?? '');
    final featuresController = create(ownedItem?.features ?? '');
    final purchaseStoreController = create(ownedItem?.purchaseStore ?? '');
    final boxSetNameController = create(ownedItem?.boxSetName ?? '');
    final storageDeviceController = create(ownedItem?.storageDevice ?? '');
    final storageSlotController = create(ownedItem?.storageSlot ?? '');
    final regionController = create(ownedItem?.region ?? '');
    final packagingController = create(ownedItem?.packaging ?? '');
    final distributorController = create(ownedItem?.distributor ?? '');
    final marketValueController = create(
      ownedItem?.marketValueCents == null
          ? ''
          : (ownedItem!.marketValueCents! / 100).toStringAsFixed(2),
    );
    final screenRatioController = create(item.video?.screenRatio ?? '');
    final audioTracksController = create(item.video?.audioTracks ?? '');
    final subtitlesController = create(item.video?.subtitles ?? '');
    final layersController = create(item.video?.layers ?? '');
    final colorController = create(item.video?.color ?? '');
    final nrDiscsController = create(item.video?.nrDiscs?.toString() ?? '');

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
      seriesTitleController: seriesTitleController,
      developersController: developersController,
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
      pageQualityController: pageQualityController,
      certificationNumberController: certificationNumberController,
      coverPriceController: coverPriceController,
      keyReasonController: keyReasonController,
      keyCategoryController: keyCategoryController,
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
      selectedOwnedAnchorType: ownedItem?.personalAnchor?.apiValue ??
          PersonalItemAnchorType.item.apiValue,
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
      gameCompleteness: ownedItem?.gameCompleteness,
      gameHasBox: ownedItem?.gameHasBox ?? true,
      gameHasManual: ownedItem?.gameHasManual ?? true,
      gamePriceChartingId: ownedItem?.gamePriceChartingId,
      gameCoreRegion: ownedItem?.gameCoreRegion,
      gameValueIsLocked: ownedItem?.gameValueIsLocked ?? false,
      physicalFormatId: initialPhysicalFormatId,
      seriesId: item.series?.seriesId,
      customFieldEdits: {
        for (final value in customFieldValues)
          value.fieldDefinitionId: value.value,
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
  final TextEditingController seriesTitleController;
  final TextEditingController developersController;
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
  final TextEditingController pageQualityController;
  final TextEditingController certificationNumberController;
  final TextEditingController coverPriceController;
  final TextEditingController keyReasonController;
  final TextEditingController keyCategoryController;
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
  String? gameCompleteness;
  bool gameHasBox;
  bool gameHasManual;
  String? gamePriceChartingId;
  String? gameCoreRegion;
  bool gameValueIsLocked;
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
        creators: _buildUpdatedCreators(),
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
              locationChanged:
                  showPhysicalOwnedFields ? locationChanged : false,
              tags: emptyToNull(tagsController.text),
              soldAt: soldAt,
              sellPriceCents: parseMoneyCents(sellPriceController.text),
              soldTo: emptyToNull(soldToController.text),
              rawOrSlabbed: isDigitalFormat
                  ? null
                  : emptyToNull(rawOrSlabbedController.text),
              gradingCompany: isDigitalFormat
                  ? null
                  : emptyToNull(gradingCompanyController.text),
              graderNotes: isDigitalFormat
                  ? null
                  : emptyToNull(graderNotesController.text),
              signedBy:
                  isDigitalFormat ? null : emptyToNull(signedByController.text),
              labelType: isDigitalFormat
                  ? null
                  : emptyToNull(labelTypeController.text),
              pageQuality: isDigitalFormat
                  ? null
                  : emptyToNull(pageQualityController.text),
              certificationNumber: isDigitalFormat
                  ? null
                  : emptyToNull(certificationNumberController.text),
              keyComic: keyComic,
              keyReason: emptyToNull(keyReasonController.text),
              keyCategory: emptyToNull(keyCategoryController.text),
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
              gameCompleteness: gameCompleteness,
              gameHasBox: gameHasBox,
              gameHasManual: gameHasManual,
              gamePriceChartingId: emptyToNull(gamePriceChartingId ?? ''),
              gameCoreRegion: emptyToNull(gameCoreRegion ?? ''),
              gameValueIsLocked: gameValueIsLocked,
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
    _textControllers.dispose();
  }

  CatalogSeriesDetails? _buildUpdatedSeries() {
    final typedSeriesTitle = emptyToNull(seriesTitleController.text);
    final seriesTitle = type.editUsesTitleAsSeries
        ? emptyToNull(titleController.text)
        : typedSeriesTitle;
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

    final developerNames = developersController.text
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
}
