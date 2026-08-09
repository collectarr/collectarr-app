import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
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
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/edit/draft/common_metadata_draft.dart';
export 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
export 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';

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
  final KindEditDraft kindDetails;

  Map<String, String?> customFieldEdits;
  List<ItemImageEdit> itemImageEdits;

  // ---------------------------------------------------------------------------
  // Convenience Forwarding Getters (for backward compatibility with UI code)
  // ---------------------------------------------------------------------------

  // CommonMetadataDraft forwarding
  TextEditingController get titleController => metadata.titleController;
  TextEditingController get numberController => metadata.numberController;
  TextEditingController get publisherController => metadata.publisherController;
  TextEditingController get coverDateController => metadata.coverDateController;
  TextEditingController get coverDateYearPartController =>
      metadata.coverDateYearPartController;
  TextEditingController get coverDateMonthPartController =>
      metadata.coverDateMonthPartController;
  TextEditingController get coverDateDayPartController =>
      metadata.coverDateDayPartController;
  TextEditingController get releaseDateController =>
      metadata.releaseDateController;
  TextEditingController get releaseDateYearPartController =>
      metadata.releaseDateYearPartController;
  TextEditingController get releaseDateMonthPartController =>
      metadata.releaseDateMonthPartController;
  TextEditingController get releaseDateDayPartController =>
      metadata.releaseDateDayPartController;
  TextEditingController get releaseYearController =>
      metadata.releaseYearController;
  TextEditingController get pageCountController => metadata.pageCountController;
  TextEditingController get editionTitleController =>
      metadata.editionTitleController;
  TextEditingController get barcodeController => metadata.barcodeController;
  TextEditingController get variantController => metadata.variantController;
  TextEditingController get physicalFormatLabelController =>
      metadata.physicalFormatLabelController;
  TextEditingController get coverController => metadata.coverController;
  TextEditingController get thumbnailController => metadata.thumbnailController;
  TextEditingController get synopsisController => metadata.synopsisController;
  TextEditingController get displayTitleController =>
      metadata.displayTitleController;
  TextEditingController get sortKeyController => metadata.sortKeyController;
  TextEditingController get originalTitleController =>
      metadata.originalTitleController;
  TextEditingController get localizedTitleController =>
      metadata.localizedTitleController;
  TextEditingController get searchAliasesController =>
      metadata.searchAliasesController;
  TextEditingController get runtimeController => metadata.runtimeController;
  TextEditingController get audienceRatingController =>
      metadata.audienceRatingController;
  TextEditingController get countryController => metadata.countryController;
  TextEditingController get languageController => metadata.languageController;
  TextEditingController get ageRatingController => metadata.ageRatingController;
  TextEditingController get genresEditController =>
      metadata.genresEditController;
  TextEditingController get crossoverController => metadata.crossoverController;
  TextEditingController get storyArcsController => metadata.storyArcsController;
  TextEditingController get seriesTitleController =>
      metadata.seriesTitleController;
  TextEditingController get developersController =>
      metadata.developersController;
  TextEditingController get imprintController => metadata.imprintController;
  TextEditingController get seriesGroupController =>
      metadata.seriesGroupController;

  String? get physicalFormatId => metadata.physicalFormatId;
  set physicalFormatId(String? v) => metadata.physicalFormatId = v;

  String? get seriesId => metadata.seriesId;
  set seriesId(String? v) => metadata.seriesId = v;

  // PersonalStateDraft forwarding
  TextEditingController get ownerLabelController =>
      personal.ownerLabelController;
  TextEditingController get conditionController => personal.conditionController;
  TextEditingController get gradeController => personal.gradeController;
  TextEditingController get purchaseDateController =>
      personal.purchaseDateController;
  TextEditingController get priceController => personal.priceController;
  TextEditingController get currencyController => personal.currencyController;
  TextEditingController get quantityController => personal.quantityController;
  TextEditingController get indexNumberController =>
      personal.indexNumberController;
  TextEditingController get notesController => personal.notesController;
  TextEditingController get purchaseStoreController =>
      personal.purchaseStoreController;
  TextEditingController get marketValueController =>
      personal.marketValueController;
  TextEditingController get wishlistPriceController =>
      personal.wishlistPriceController;
  TextEditingController get wishlistCurrencyController =>
      personal.wishlistCurrencyController;
  TextEditingController get wishlistNotesController =>
      personal.wishlistNotesController;
  TextEditingController get ratingController => personal.ratingController;
  TextEditingController get trackingController => personal.trackingController;
  TextEditingController get progressCurrentController =>
      personal.progressCurrentController;
  TextEditingController get progressTotalController =>
      personal.progressTotalController;
  TextEditingController get timesCompletedController =>
      personal.timesCompletedController;
  TextEditingController get seasonNumberController =>
      personal.seasonNumberController;
  TextEditingController get episodeNumberController =>
      personal.episodeNumberController;
  TextEditingController get trackingNotesController =>
      personal.trackingNotesController;
  TextEditingController get tagsController => personal.tagsController;
  TextEditingController get sellPriceController => personal.sellPriceController;
  TextEditingController get soldToController => personal.soldToController;

  List<String> get tagOptions => personal.tagOptions;
  set tagOptions(List<String> v) => personal.tagOptions = v;

  List<StorageLocation> get availableLocations => personal.availableLocations;
  set availableLocations(List<StorageLocation> v) =>
      personal.availableLocations = v;

  String? get selectedLocationId => personal.selectedLocationId;
  set selectedLocationId(String? v) => personal.selectedLocationId = v;

  String get selectedOwnedAnchorType =>
      personal.selectedOwnedAnchorType.apiValue;
  set selectedOwnedAnchorType(String v) => personal.selectedOwnedAnchorType =
      PersonalItemAnchorType.fromApiValue(v) ?? PersonalItemAnchorType.item;

  String? get selectedEditionId => personal.selectedEditionId;
  set selectedEditionId(String? v) => personal.selectedEditionId = v;

  String? get selectedVariantId => personal.selectedVariantId;
  set selectedVariantId(String? v) => personal.selectedVariantId = v;

  String? get selectedBundleReleaseId => personal.selectedBundleReleaseId;
  set selectedBundleReleaseId(String? v) =>
      personal.selectedBundleReleaseId = v;

  String? get selectedTrackingEditionId => personal.selectedTrackingEditionId;
  set selectedTrackingEditionId(String? v) =>
      personal.selectedTrackingEditionId = v;

  String? get selectedTrackingVariantId => personal.selectedTrackingVariantId;
  set selectedTrackingVariantId(String? v) =>
      personal.selectedTrackingVariantId = v;

  String get selectedWishlistAnchorType =>
      personal.selectedWishlistAnchorType.apiValue;
  set selectedWishlistAnchorType(String v) =>
      personal.selectedWishlistAnchorType =
          PersonalItemAnchorType.fromApiValue(v) ?? PersonalItemAnchorType.item;

  String? get selectedWishlistEditionId => personal.selectedWishlistEditionId;
  set selectedWishlistEditionId(String? v) =>
      personal.selectedWishlistEditionId = v;

  String? get selectedWishlistVariantId => personal.selectedWishlistVariantId;
  set selectedWishlistVariantId(String? v) =>
      personal.selectedWishlistVariantId = v;

  String? get selectedWishlistBundleReleaseId =>
      personal.selectedWishlistBundleReleaseId;
  set selectedWishlistBundleReleaseId(String? v) =>
      personal.selectedWishlistBundleReleaseId = v;

  bool get locationChanged => personal.locationChanged;
  set locationChanged(bool v) => personal.locationChanged = v;

  DateTime? get soldAt => personal.soldAt;
  set soldAt(DateTime? v) => personal.soldAt = v;

  DateTime? get startedAt => personal.startedAt;
  set startedAt(DateTime? v) => personal.startedAt = v;

  DateTime? get finishedAt => personal.finishedAt;
  set finishedAt(DateTime? v) => personal.finishedAt = v;

  Map<String, int> get episodeRatings => personal.episodeRatings;
  set episodeRatings(Map<String, int> v) => personal.episodeRatings = v;

  String? get collectionStatus => personal.collectionStatus;
  set collectionStatus(String? v) => personal.collectionStatus = v;

  // Kind-specific forwarding
  ComicEditDraft? get _comic =>
      kindDetails is ComicEditDraft ? kindDetails as ComicEditDraft : null;
  VideoEditDraft? get _video =>
      kindDetails is VideoEditDraft ? kindDetails as VideoEditDraft : null;
  GameEditDraft? get _game =>
      kindDetails is GameEditDraft ? kindDetails as GameEditDraft : null;
  MusicEditDraft? get _music =>
      kindDetails is MusicEditDraft ? kindDetails as MusicEditDraft : null;

  TextEditingController get rawOrSlabbedController =>
      _comic?.rawOrSlabbedController ?? _dummyController;
  TextEditingController get gradingCompanyController =>
      _comic?.gradingCompanyController ?? _dummyController;
  TextEditingController get graderNotesController =>
      _comic?.graderNotesController ?? _dummyController;
  TextEditingController get signedByController =>
      _comic?.signedByController ?? _dummyController;
  TextEditingController get labelTypeController =>
      _comic?.labelTypeController ?? _dummyController;
  TextEditingController get pageQualityController =>
      _comic?.pageQualityController ?? _dummyController;
  TextEditingController get certificationNumberController =>
      _comic?.certificationNumberController ?? _dummyController;
  TextEditingController get coverPriceController =>
      _comic?.coverPriceController ?? _dummyController;
  TextEditingController get keyReasonController =>
      _comic?.keyReasonController ?? _dummyController;
  TextEditingController get keyCategoryController =>
      _comic?.keyCategoryController ?? _dummyController;
  bool get keyComic => _comic?.keyComic ?? false;
  set keyComic(bool v) {
    if (_comic != null) _comic!.keyComic = v;
  }

  DateTime? get lastBagBoardDate => _comic?.lastBagBoardDate;
  set lastBagBoardDate(DateTime? v) {
    if (_comic != null) _comic!.lastBagBoardDate = v;
  }

  TextEditingController get featuresController =>
      _video?.featuresController ?? _dummyController;
  TextEditingController get boxSetNameController =>
      _video?.boxSetNameController ?? _dummyController;
  TextEditingController get regionController =>
      _video?.regionController ?? _dummyController;
  TextEditingController get packagingController =>
      _video?.packagingController ?? _dummyController;
  TextEditingController get distributorController =>
      _video?.distributorController ?? _dummyController;
  TextEditingController get screenRatioController =>
      _video?.screenRatioController ?? _dummyController;
  TextEditingController get audioTracksController =>
      _video?.audioTracksController ?? _dummyController;
  TextEditingController get subtitlesController =>
      _video?.subtitlesController ?? _dummyController;
  TextEditingController get layersController =>
      _video?.layersController ?? _dummyController;
  TextEditingController get colorController =>
      _video?.colorController ?? _dummyController;
  TextEditingController get nrDiscsController =>
      _video?.nrDiscsController ?? _dummyController;
  List<String> get hdrFormats => _video?.hdrFormats ?? const [];
  set hdrFormats(List<String> v) {
    if (_video != null) _video!.hdrFormats = v;
  }

  String? get gameCompleteness => _game?.gameCompleteness;
  set gameCompleteness(String? v) {
    if (_game != null) _game!.gameCompleteness = v;
  }

  bool get gameHasBox => _game?.gameHasBox ?? true;
  set gameHasBox(bool v) {
    if (_game != null) _game!.gameHasBox = v;
  }

  bool get gameHasManual => _game?.gameHasManual ?? true;
  set gameHasManual(bool v) {
    if (_game != null) _game!.gameHasManual = v;
  }

  String? get gamePriceChartingId => _game?.gamePriceChartingId;
  set gamePriceChartingId(String? v) {
    if (_game != null) _game!.gamePriceChartingId = v;
  }

  String? get gameCoreRegion => _game?.gameCoreRegion;
  set gameCoreRegion(String? v) {
    if (_game != null) _game!.gameCoreRegion = v;
  }

  bool get gameValueIsLocked => _game?.gameValueIsLocked ?? false;
  set gameValueIsLocked(bool v) {
    if (_game != null) _game!.gameValueIsLocked = v;
  }

  TextEditingController get storageDeviceController =>
      _music?.storageDeviceController ?? _dummyController;
  TextEditingController get storageSlotController =>
      _music?.storageSlotController ?? _dummyController;

  static final _dummyController = TextEditingController();

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
    final comicDetails = ownedItem?.typedDetails is ComicOwnedDetails
        ? ownedItem!.typedDetails as ComicOwnedDetails
        : null;
    final videoDetails = ownedItem?.typedDetails is VideoOwnedDetails
        ? ownedItem!.typedDetails as VideoOwnedDetails
        : null;
    final musicDetails = ownedItem?.typedDetails is MusicOwnedDetails
        ? ownedItem!.typedDetails as MusicOwnedDetails
        : null;
    final rawOrSlabbedController = create(comicDetails?.rawOrSlabbed ?? '');
    final gradingCompanyController = create(comicDetails?.gradingCompany ?? '');
    final graderNotesController = create(comicDetails?.graderNotes ?? '');
    final signedByController = create(comicDetails?.signedBy ?? '');
    final labelTypeController = create(comicDetails?.labelType ?? '');
    final pageQualityController = create(comicDetails?.pageQuality ?? '');
    final certificationNumberController = create(
      comicDetails?.certificationNumber ?? '',
    );
    final coverPriceController = create(
      comicDetails?.coverPriceCents == null
          ? ''
          : (comicDetails!.coverPriceCents! / 100).toStringAsFixed(2),
    );
    final keyReasonController = create(comicDetails?.keyReason ?? '');
    final keyCategoryController = create(comicDetails?.keyCategory ?? '');
    final featuresController = create(videoDetails?.features ?? '');
    final purchaseStoreController = create(ownedItem?.purchaseStore ?? '');
    final boxSetNameController = create(videoDetails?.boxSetName ?? '');
    final storageDeviceController = create(musicDetails?.storageDevice ?? '');
    final storageSlotController = create(musicDetails?.storageSlot ?? '');
    final regionController = create(videoDetails?.region ?? '');
    final packagingController = create(videoDetails?.packaging ?? '');
    final distributorController = create(videoDetails?.distributor ?? '');
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
      selectedTrackingEditionId:
          trackingEntry?.editionId ?? editionSelection.edition?.id,
      selectedTrackingVariantId:
          trackingEntry?.variantId ?? editionSelection.variant?.id,
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
      startedAt: trackingEntry?.startedAt ?? ownedItem?.startedAt,
      finishedAt: trackingEntry?.finishedAt ?? ownedItem?.finishedAt,
      episodeRatings:
          Map<String, int>.from(trackingEntry?.episodeRatings ?? const {}),
      collectionStatus: ownedItem?.collectionStatus,
    );

    KindEditDraft kindDetails;
    switch (type.workspace.kind) {
      case CatalogMediaKind.comic:
      case CatalogMediaKind.manga:
        kindDetails = ComicEditDraft(
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
          keyComic: (ownedItem?.typedDetails is ComicOwnedDetails
              ? (ownedItem!.typedDetails as ComicOwnedDetails).keyComic
              : false),
          lastBagBoardDate: (ownedItem?.typedDetails is ComicOwnedDetails
              ? (ownedItem!.typedDetails as ComicOwnedDetails).lastBagBoardDate
              : null),
        );
      case CatalogMediaKind.movie:
      case CatalogMediaKind.tv:
      case CatalogMediaKind.anime:
        kindDetails = VideoEditDraft(
          featuresController: featuresController,
          boxSetNameController: boxSetNameController,
          regionController: regionController,
          packagingController: packagingController,
          distributorController: distributorController,
          screenRatioController: screenRatioController,
          audioTracksController: audioTracksController,
          subtitlesController: subtitlesController,
          layersController: layersController,
          colorController: colorController,
          nrDiscsController: nrDiscsController,
          hdrFormats: List<String>.from(
              (ownedItem?.typedDetails is VideoOwnedDetails
                  ? (ownedItem!.typedDetails as VideoOwnedDetails).hdrFormats
                  : const <String>[])),
        );
      case CatalogMediaKind.game:
        kindDetails = GameEditDraft(
          gameCompleteness: (ownedItem?.typedDetails is GameOwnedDetails
              ? (ownedItem!.typedDetails as GameOwnedDetails).completeness
              : null),
          gameHasBox: (ownedItem?.typedDetails is GameOwnedDetails
              ? (ownedItem!.typedDetails as GameOwnedDetails).hasBox ?? true
              : true),
          gameHasManual: (ownedItem?.typedDetails is GameOwnedDetails
              ? (ownedItem!.typedDetails as GameOwnedDetails).hasManual ?? true
              : true),
          gamePriceChartingId: (ownedItem?.typedDetails is GameOwnedDetails
              ? (ownedItem!.typedDetails as GameOwnedDetails).priceChartingId
              : null),
          gameCoreRegion: (ownedItem?.typedDetails is GameOwnedDetails
              ? (ownedItem!.typedDetails as GameOwnedDetails).coreRegion
              : null),
          gameValueIsLocked: (ownedItem?.typedDetails is GameOwnedDetails
              ? (ownedItem!.typedDetails as GameOwnedDetails).valueIsLocked ??
                  false
              : false),
        );
      case CatalogMediaKind.music:
        kindDetails = MusicEditDraft(
          storageDeviceController: storageDeviceController,
          storageSlotController: storageSlotController,
        );
      default:
        kindDetails = const GenericEditDraft();
    }

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

  LibraryEditSelection buildSelection({
    LibraryEditSubmitAction submitAction = LibraryEditSubmitAction.save,
  }) {
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
        displayTitle: emptyToNull(displayTitleController.text),
        localizedTitle: emptyToNull(localizedTitleController.text),
        searchAliases: _splitList(searchAliasesController.text),
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
              indexNumber: parseInt(indexNumberController.text),
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

  OwnedItemCommonDraft buildCommonDraft() {
    return OwnedItemCommonDraft(
      quantity: parseInt(quantityController.text) ?? 1,
      condition: emptyToNull(conditionController.text),
      grade: emptyToNull(gradeController.text),
      purchaseDate: parseDate(purchaseDateController.text),
      pricePaidCents: parseMoneyCents(priceController.text),
      currency: emptyToNull(currencyController.text),
      personalNotes: emptyToNull(notesController.text),
      locationId: selectedLocationId,
      purchaseStore: emptyToNull(purchaseStoreController.text),
      collectionStatus: collectionStatus,
      tags: emptyToNull(tagsController.text),
      rating: parseInt(ratingController.text),
      readStatus: emptyToNull(trackingController.text),
      startedAt: startedAt,
      finishedAt: finishedAt,
      editionId: selectedEditionId,
      variantId: selectedVariantId,
      bundleReleaseId: selectedBundleReleaseId,
    );
  }

  OwnedDetailsDraft buildDetailsDraft() {
    return switch (type.workspace.kind) {
      CatalogMediaKind.comic ||
      CatalogMediaKind.manga =>
        ComicOwnedDetailsDraft(
          rawOrSlabbed: emptyToNull(rawOrSlabbedController.text),
          gradingCompany: emptyToNull(gradingCompanyController.text),
          graderNotes: emptyToNull(graderNotesController.text),
          signedBy: emptyToNull(signedByController.text),
          labelType: emptyToNull(labelTypeController.text),
          pageQuality: emptyToNull(pageQualityController.text),
          certificationNumber: emptyToNull(certificationNumberController.text),
          keyComic: keyComic,
          keyReason: emptyToNull(keyReasonController.text),
          keyCategory: emptyToNull(keyCategoryController.text),
          coverPriceCents: parseMoneyCents(coverPriceController.text),
          lastBagBoardDate: lastBagBoardDate,
        ),
      CatalogMediaKind.movie ||
      CatalogMediaKind.tv ||
      CatalogMediaKind.anime =>
        VideoOwnedDetailsDraft(
          features: emptyToNull(featuresController.text),
          hdrFormats: hdrFormats,
          boxSetName: emptyToNull(boxSetNameController.text),
          region: emptyToNull(regionController.text),
          packaging: emptyToNull(packagingController.text),
          distributor: emptyToNull(distributorController.text),
        ),
      CatalogMediaKind.game => GameOwnedDetailsDraft(
          completeness: gameCompleteness,
          hasBox: gameHasBox,
          hasManual: gameHasManual,
          priceChartingId: gamePriceChartingId,
          coreRegion: gameCoreRegion,
          valueIsLocked: gameValueIsLocked,
        ),
      CatalogMediaKind.music => MusicOwnedDetailsDraft(
          storageDevice: emptyToNull(storageDeviceController.text),
          storageSlot: storageSlotController.text.trim().isEmpty
              ? null
              : storageSlotController.text.trim(),
        ),
      _ => const GenericOwnedDetailsDraft(),
    };
  }

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
    return UpdateOwnedItemCommand(
      ownedItemId: ownedItemId,
      quantity: Patch.set(parseInt(quantityController.text) ?? 1),
      condition: conditionController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(conditionController.text.trim()),
      grade: gradeController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(gradeController.text.trim()),
      purchaseDate: purchaseDateController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseDate(purchaseDateController.text)),
      pricePaidCents: priceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(priceController.text)),
      currency: currencyController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(currencyController.text.trim()),
      personalNotes: notesController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(notesController.text.trim()),
      locationId: selectedLocationId != null
          ? Patch.set(selectedLocationId)
          : const Patch.clear(),
      purchaseStore: purchaseStoreController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(purchaseStoreController.text.trim()),
      collectionStatus: collectionStatus != null
          ? Patch.set(collectionStatus)
          : const Patch.clear(),
      tags: tagsController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(tagsController.text.trim()),
      rating: ratingController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseInt(ratingController.text)),
      readStatus: trackingController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(trackingController.text.trim()),
      startedAt: startedAt != null ? Patch.set(startedAt) : const Patch.clear(),
      finishedAt:
          finishedAt != null ? Patch.set(finishedAt) : const Patch.clear(),
      soldAt: soldAt != null ? Patch.set(soldAt) : const Patch.clear(),
      sellPriceCents: sellPriceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(sellPriceController.text)),
      soldTo: soldToController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(soldToController.text.trim()),
      details: Patch.set(buildDetailsDraft()),
    );
  }
}
