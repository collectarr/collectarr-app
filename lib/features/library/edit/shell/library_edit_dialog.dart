import 'dart:async';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/anchor_selection_helpers.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/edit/library_edit_value_tabs.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
export 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_edit_image_sections.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/video_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/video_edit_tabs.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_tabs.dart';
import 'package:collectarr_app/features/library/kinds/video/video_season_tracking_section.dart';
import 'package:collectarr_app/features/library/kinds/video/video_episode_rating_section.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/tracking/tracking_editor_widgets.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/series/series_registry_dialog.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show QueryRow;

part '../anchors/library_edit_dialog_anchor_widgets.dart';
part '../../kinds/comic/edit/library_edit_dialog_comic_tabs.dart';
part 'library_edit_dialog_comic_models.dart';
part 'library_edit_dialog_vocabulary.dart';

const List<String> _commonCreatorRoles = <String>[
  'Writer',
  'Artist',
  'Cover Artist',
  'Cover Penciller',
  'Cover Painter',
  'Cover Inker',
  'Cover Colorist',
  'Cover Separator',
  'Penciller',
  'Inker',
  'Colorist',
  'Painter',
  'Letterer',
  'Separator',
  'Layouts',
  'Translator',
  'Plotter',
  'Scripter',
  'Editor',
  'Editor in Chief',
];

class LibraryEditRenderer extends ConsumerStatefulWidget {
  const LibraryEditRenderer({
    super.key,
    required this.type,
    required this.item,
    required this.ownedItem,
    this.wishlistItem,
    this.trackingEntry,
    required this.accent,
    this.availableBundleReleases = const [],
    this.physicalFormats = const [],
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
    this.onPrevious,
    this.onNext,
    this.scope = LibraryEditScope.all,
  }) : draft = null;

  LibraryEditRenderer.fromDraft({
    super.key,
    required LibraryEditDraft draft,
    this.onPrevious,
    this.onNext,
    this.scope = LibraryEditScope.all,
  })  : draft = draft,
        type = draft.type,
        item = draft.item,
        ownedItem = draft.ownedItem,
        wishlistItem = draft.wishlistItem,
        trackingEntry = draft.trackingEntry,
        accent = draft.accent,
        availableBundleReleases = draft.availableBundleReleases,
        physicalFormats = draft.physicalFormats,
        customFieldDefinitions = draft.customFieldDefinitions,
        customFieldValues = draft.customFieldValues,
        itemImages = draft.itemImages;

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
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final LibraryEditScope scope;
  final LibraryEditDraft? draft;

  @override
  ConsumerState<LibraryEditRenderer> createState() =>
      _LibraryEditRendererState();
}

class _LibraryEditRendererState extends ConsumerState<LibraryEditRenderer>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  LibraryEditSubmitAction _submitAction = LibraryEditSubmitAction.save;
  late final LibraryEditDraft _draft;

  late final TabController _tabController;
  late final VideoEditController _videoEdit;

  TextEditingController get _titleController => _draft.titleController;
  TextEditingController get _numberController => _draft.numberController;
  TextEditingController get _publisherController => _draft.publisherController;
  TextEditingController get _coverDateController => _draft.coverDateController;
  TextEditingController get _coverDateYearPartController =>
      _draft.coverDateYearPartController;
  TextEditingController get _coverDateMonthPartController =>
      _draft.coverDateMonthPartController;
  TextEditingController get _coverDateDayPartController =>
      _draft.coverDateDayPartController;
  TextEditingController get _releaseDateController =>
      _draft.releaseDateController;
  TextEditingController get _releaseDateYearPartController =>
      _draft.releaseDateYearPartController;
  TextEditingController get _releaseDateMonthPartController =>
      _draft.releaseDateMonthPartController;
  TextEditingController get _releaseDateDayPartController =>
      _draft.releaseDateDayPartController;
  TextEditingController get _releaseYearController =>
      _draft.releaseYearController;
  TextEditingController get _pageCountController => _draft.pageCountController;
  TextEditingController get _editionTitleController =>
      _draft.editionTitleController;
  TextEditingController get _barcodeController => _draft.barcodeController;
  TextEditingController get _variantController => _draft.variantController;
  TextEditingController get _physicalFormatLabelController =>
      _draft.physicalFormatLabelController;
  TextEditingController get _coverController => _draft.coverController;
  TextEditingController get _thumbnailController => _draft.thumbnailController;
  TextEditingController get _synopsisController => _draft.synopsisController;
  TextEditingController get _sortKeyController => _draft.sortKeyController;
  TextEditingController get _originalTitleController =>
      _draft.originalTitleController;
  TextEditingController get _localizedTitleController =>
      _draft.localizedTitleController;
  TextEditingController get _searchAliasesController =>
      _draft.searchAliasesController;
  TextEditingController get _seriesTitleController =>
      _draft.seriesTitleController;
  TextEditingController get _audienceRatingController =>
      _draft.audienceRatingController;
  TextEditingController get _countryController => _draft.countryController;
  TextEditingController get _languageController => _draft.languageController;
  TextEditingController get _ageRatingController => _draft.ageRatingController;
  TextEditingController get _genresEditController =>
      _draft.genresEditController;
  TextEditingController get _crossoverController => _draft.crossoverController;
  TextEditingController get _storyArcsController => _draft.storyArcsController;
  TextEditingController get _developersController =>
      _draft.developersController;
  TextEditingController get _ownerLabelController =>
      _draft.ownerLabelController;
  TextEditingController get _imprintController => _draft.imprintController;
  TextEditingController get _seriesGroupController =>
      _draft.seriesGroupController;
  TextEditingController get _conditionController => _draft.conditionController;
  TextEditingController get _gradeController => _draft.gradeController;
  TextEditingController get _purchaseDateController =>
      _draft.purchaseDateController;
  TextEditingController get _priceController => _draft.priceController;
  TextEditingController get _currencyController => _draft.currencyController;
  TextEditingController get _quantityController => _draft.quantityController;
  TextEditingController get _indexNumberController =>
      _draft.indexNumberController;
  TextEditingController get _notesController => _draft.notesController;
  TextEditingController get _wishlistPriceController =>
      _draft.wishlistPriceController;
  TextEditingController get _wishlistCurrencyController =>
      _draft.wishlistCurrencyController;
  TextEditingController get _wishlistNotesController =>
      _draft.wishlistNotesController;
  TextEditingController get _ratingController => _draft.ratingController;
  TextEditingController get _trackingController => _draft.trackingController;
  TextEditingController get _progressCurrentController =>
      _draft.progressCurrentController;
  TextEditingController get _progressTotalController =>
      _draft.progressTotalController;
  TextEditingController get _timesCompletedController =>
      _draft.timesCompletedController;
  TextEditingController get _trackingNotesController =>
      _draft.trackingNotesController;
  TextEditingController get _tagsController => _draft.tagsController;
  List<String> get _tagOptions => _draft.tagOptions;
  set _tagOptions(List<String> value) => _draft.tagOptions = value;
  List<String> _genreOptions = const [];
  List<String> _publisherOptions = const [];
  List<String> _imprintOptions = const [];
  List<String> _seriesGroupOptions = const [];
  List<String> _physicalFormatOptions = const [];
  List<String> _conditionOptions = const [];
  List<String> _gradeOptions = const [];
  List<String> _ownerOptions = const [];
  List<String> _countryOptions = const [];
  List<String> _languageOptions = const [];
  List<String> _ageRatingOptions = const [];
  List<String> _audienceRatingOptions = const [];
  List<String> _regionOptions = const [];
  List<String> _packagingOptions = const [];
  List<String> _distributorOptions = const [];
  List<String> _screenRatioOptions = const [];
  List<String> _audioTrackOptions = const [];
  List<String> _subtitleOptions = const [];
  List<String> _layersOptions = const [];
  List<String> _colorOptions = const [];
  List<String> _crossoverOptions = const [];
  List<String> _storyArcOptions = const [];
  List<String> _pageQualityOptions = const [];
  List<String> _keyCategoryOptions = const [];
  List<SeriesRegistryEntry> _seriesEntries = const [];
  late final TextEditingController _gamePlatformsController;
  late final TextEditingController _collectionStatusController;
  List<String> _gameDeveloperOptions = const [];
  List<String> _gameGenreOptions = const [];
  List<String> _gamePlatformOptions = const [];
  final List<_EditableComicCreator> _comicCreators = [];
  final List<_EditableComicCharacter> _comicCharacters = [];
  final List<Map<String, TextEditingController>> _comicLinks = [];
  final TextEditingController _comicCharacterDraftController =
      TextEditingController();
  List<StorageLocation> get _availableLocations => _draft.availableLocations;
  set _availableLocations(List<StorageLocation> value) =>
      _draft.availableLocations = value;
  String? get _selectedLocationId => _draft.selectedLocationId;
  set _selectedLocationId(String? value) => _draft.selectedLocationId = value;
  String get _selectedOwnedAnchorType => _draft.selectedOwnedAnchorType;
  set _selectedOwnedAnchorType(String value) =>
      _draft.selectedOwnedAnchorType = value;
  String? get _selectedEditionId => _draft.selectedEditionId;
  set _selectedEditionId(String? value) => _draft.selectedEditionId = value;
  String? get _selectedVariantId => _draft.selectedVariantId;
  set _selectedVariantId(String? value) => _draft.selectedVariantId = value;
  String? get _selectedBundleReleaseId => _draft.selectedBundleReleaseId;
  set _selectedBundleReleaseId(String? value) =>
      _draft.selectedBundleReleaseId = value;
  String? get _selectedTrackingEditionId => _draft.selectedTrackingEditionId;
  set _selectedTrackingEditionId(String? value) =>
      _draft.selectedTrackingEditionId = value;
  String? get _selectedTrackingVariantId => _draft.selectedTrackingVariantId;
  set _selectedTrackingVariantId(String? value) =>
      _draft.selectedTrackingVariantId = value;
  String get _selectedWishlistAnchorType => _draft.selectedWishlistAnchorType;
  set _selectedWishlistAnchorType(String value) =>
      _draft.selectedWishlistAnchorType = value;
  String? get _selectedWishlistEditionId => _draft.selectedWishlistEditionId;
  set _selectedWishlistEditionId(String? value) =>
      _draft.selectedWishlistEditionId = value;
  String? get _selectedWishlistVariantId => _draft.selectedWishlistVariantId;
  set _selectedWishlistVariantId(String? value) =>
      _draft.selectedWishlistVariantId = value;
  String? get _selectedWishlistBundleReleaseId =>
      _draft.selectedWishlistBundleReleaseId;
  set _selectedWishlistBundleReleaseId(String? value) =>
      _draft.selectedWishlistBundleReleaseId = value;
  set _locationChanged(bool value) => _draft.locationChanged = value;

  TextEditingController get _sellPriceController => _draft.sellPriceController;
  TextEditingController get _soldToController => _draft.soldToController;
  DateTime? get _soldAt => _draft.soldAt;
  set _soldAt(DateTime? value) => _draft.soldAt = value;

  // Reading progress
  DateTime? get _startedAt => _draft.startedAt;
  set _startedAt(DateTime? value) => _draft.startedAt = value;
  DateTime? get _finishedAt => _draft.finishedAt;
  set _finishedAt(DateTime? value) => _draft.finishedAt = value;
  Map<String, int> get _episodeRatings => _draft.episodeRatings;
  set _episodeRatings(Map<String, int> value) => _draft.episodeRatings = value;

  TextEditingController get _rawOrSlabbedController =>
      _draft.rawOrSlabbedController;
  TextEditingController get _gradingCompanyController =>
      _draft.gradingCompanyController;
  TextEditingController get _graderNotesController =>
      _draft.graderNotesController;
  TextEditingController get _signedByController => _draft.signedByController;
  TextEditingController get _labelTypeController => _draft.labelTypeController;
  TextEditingController get _pageQualityController =>
      _draft.pageQualityController;
  TextEditingController get _certificationNumberController =>
      _draft.certificationNumberController;
  TextEditingController get _coverPriceController =>
      _draft.coverPriceController;
  bool get _keyComic => _draft.keyComic;
  set _keyComic(bool value) => _draft.keyComic = value;
  TextEditingController get _keyReasonController => _draft.keyReasonController;
  TextEditingController get _keyCategoryController =>
      _draft.keyCategoryController;

  TextEditingController get _featuresController => _draft.featuresController;
  TextEditingController get _purchaseStoreController =>
      _draft.purchaseStoreController;
  TextEditingController get _boxSetNameController =>
      _draft.boxSetNameController;
  TextEditingController get _storageDeviceController =>
      _draft.storageDeviceController;
  TextEditingController get _storageSlotController =>
      _draft.storageSlotController;
  List<String> get _hdrFormats => _draft.hdrFormats;

  TextEditingController get _regionController => _draft.regionController;
  TextEditingController get _packagingController => _draft.packagingController;
  TextEditingController get _distributorController =>
      _draft.distributorController;
  TextEditingController get _screenRatioController =>
      _draft.screenRatioController;

  // Collection status & bag/board
  String? get _collectionStatus => _draft.collectionStatus;
  set _collectionStatus(String? value) => _draft.collectionStatus = value;
  DateTime? get _lastBagBoardDate => _draft.lastBagBoardDate;
  set _lastBagBoardDate(DateTime? value) => _draft.lastBagBoardDate = value;
  String? get _gameCompleteness => _draft.gameCompleteness;
  set _gameCompleteness(String? value) => _draft.gameCompleteness = value;
  bool get _gameHasBox => _draft.gameHasBox;
  set _gameHasBox(bool value) => _draft.gameHasBox = value;
  bool get _gameHasManual => _draft.gameHasManual;
  set _gameHasManual(bool value) => _draft.gameHasManual = value;
  String? get _gamePriceChartingId => _draft.gamePriceChartingId;
  set _gamePriceChartingId(String? value) => _draft.gamePriceChartingId = value;
  String? get _gameCoreRegion => _draft.gameCoreRegion;
  set _gameCoreRegion(String? value) => _draft.gameCoreRegion = value;
  bool get _gameValueIsLocked => _draft.gameValueIsLocked;
  set _gameValueIsLocked(bool value) => _draft.gameValueIsLocked = value;
  TextEditingController get _marketValueController =>
      _draft.marketValueController;

  String? get _physicalFormatId => _draft.physicalFormatId;
  set _physicalFormatId(String? value) => _draft.physicalFormatId = value;
  String? get _selectedSeriesId => _draft.seriesId;
  set _selectedSeriesId(String? value) => _draft.seriesId = value;
  Map<String, String?> get _customFieldEdits => _draft.customFieldEdits;
  set _customFieldEdits(Map<String, String?> value) =>
      _draft.customFieldEdits = value;
  List<ItemImageEdit> get _itemImageEdits => _draft.itemImageEdits;
  set _itemImageEdits(List<ItemImageEdit> value) =>
      _draft.itemImageEdits = value;

  bool get _isOwned => widget.ownedItem != null;

  bool get _isMediaScope => widget.scope == LibraryEditScope.media;

  bool get _isReleaseScope => widget.scope == LibraryEditScope.release;

  bool get _isAllScope => widget.scope == LibraryEditScope.all;

  bool get _canShowMediaFields => _isMediaScope || _isAllScope;

  bool get _canShowReleaseFields => _isReleaseScope || _isAllScope;

  bool get _canShowPersonalFields => _isReleaseScope || _isAllScope;

  bool get _hasTrackingContext => _isOwned || widget.trackingEntry != null;

  bool get _isTrackingOnly => !_isOwned && widget.trackingEntry != null;

  bool get _hasWishlistContext => widget.wishlistItem != null;

  bool get _isMovieKind => widget.type.workspace.kind.apiValue == 'movie';

  bool get _isGameKind {
    return widget.type.capabilities.usesGameCompletenessFields;
  }

  bool get _isComicKind {
    return widget.type.capabilities.usesComicCollectorFields;
  }

  bool get _hasReleaseAnchor {
    return _selectedOwnedAnchorType != PersonalItemAnchorType.item.apiValue;
  }

  bool get _hasBundleAnchorContext {
    return widget.availableBundleReleases.isNotEmpty ||
        widget.ownedItem?.bundleReleaseId != null ||
        widget.wishlistItem?.bundleReleaseId != null ||
        _selectedBundleReleaseId != null ||
        _selectedWishlistBundleReleaseId != null;
  }

  /// Release-level fields (edition title, variant, barcode, physical format)
  /// are visible when editing a catalog-only item or when the ownership
  /// anchor targets a specific release rather than the abstract media work.
  bool get _showsReleaseSection {
    if (!_canShowReleaseFields) return false;
    if (!_hasTrackingContext) return true; // catalog-only: always show
    return _hasReleaseAnchor;
  }

  LibraryEditPresentationContext get _editPresentationContext {
    return LibraryEditPresentationContext(
      isOwned: _isOwned,
      isTrackingOnly: _isTrackingOnly,
      hasTrackingContext: _hasTrackingContext,
      hasWishlistContext: _hasWishlistContext,
      isDigitalFormat: _isDigitalFormat,
      hasPhysicalFormats: widget.physicalFormats.isNotEmpty,
      hasEditionAnchors: widget.item.editions.isNotEmpty,
      hasBundleReleaseAnchors: _hasBundleAnchorContext,
      hasCustomFields: widget.customFieldDefinitions.isNotEmpty,
      scope: widget.scope,
    );
  }

  LibraryEditPresentationContext get _initialEditPresentationContext {
    return LibraryEditPresentationContext(
      isOwned: _isOwned,
      isTrackingOnly: _isTrackingOnly,
      hasTrackingContext: _hasTrackingContext,
      hasWishlistContext: _hasWishlistContext,
      isDigitalFormat: false,
      hasPhysicalFormats: widget.physicalFormats.isNotEmpty,
      hasEditionAnchors: widget.item.editions.isNotEmpty,
      hasBundleReleaseAnchors: widget.availableBundleReleases.isNotEmpty ||
          widget.ownedItem?.bundleReleaseId != null ||
          widget.wishlistItem?.bundleReleaseId != null,
      hasCustomFields: widget.customFieldDefinitions.isNotEmpty,
      scope: widget.scope,
    );
  }

  List<LibraryEditTabSpec> get _tabSpecs {
    return widget.type.editPresentation.builderForScope(widget.scope).buildTabs(
          context: _editPresentationContext,
        );
  }

  LibraryEditPresentationState get _editPresentation {
    return widget.type.editPresentation.builderForScope(widget.scope).build(
          context: _editPresentationContext,
        );
  }

  bool get _isDigitalFormat {
    return isDigitalPhysicalMediaFormat(
      _physicalFormatId,
      label: _physicalFormatForId(_physicalFormatId)?.label ??
          emptyToNull(_physicalFormatLabelController.text) ??
          widget.item.physicalFormatLabel ??
          _variantController.text,
      formats: widget.physicalFormats.isEmpty
          ? allKnownPhysicalMediaFormats
          : widget.physicalFormats,
    );
  }

  bool get _showPhysicalOwnedFields => _isOwned && !_isDigitalFormat;

  bool get _showsEpisodeTrackingFields {
    final series = widget.item.series;
    return widget.type.trackingProfile.name == videoTrackingProfile.name ||
        series?.seasonNumber != null ||
        series?.episodeNumber != null ||
        _videoEdit.seasonNumberController.text.trim().isNotEmpty ||
        _videoEdit.episodeNumberController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ??
        LibraryEditDraft.fromFields(
          type: widget.type,
          item: widget.item,
          ownedItem: widget.ownedItem,
          wishlistItem: widget.wishlistItem,
          trackingEntry: widget.trackingEntry,
          accent: widget.accent,
          availableBundleReleases: widget.availableBundleReleases,
          physicalFormats: widget.physicalFormats,
          customFieldDefinitions: widget.customFieldDefinitions,
          customFieldValues: widget.customFieldValues,
          itemImages: widget.itemImages,
        );
    _tabController = TabController(
      length: widget.type.editPresentation
          .builderForScope(widget.scope)
          .buildTabs(context: _initialEditPresentationContext)
          .length,
      vsync: this,
    )..addListener(() {
        if (mounted) setState(() {});
      });
    _collectionStatusController = TextEditingController(
      text: _collectionStatusToLabel(_collectionStatus),
    );

    _gamePlatformsController = TextEditingController(
      text: (widget.item.game?.platforms ?? const <String>[]).join(', '),
    );
    _videoEdit = VideoEditController(
      ref: ref,
      type: widget.type,
      item: widget.item,
      draft: _draft,
    );
    _initializeKindSpecificEditors();
    if (_videoEdit.isVideoKind) {
      unawaited(_videoEdit.loadUserExternalLinks().then((_) {
        if (mounted) {
          setState(() {});
        }
      }));
    }

    if (_videoEdit.isTvKind) {
      _videoEdit.tvSeriesFuture = _videoEdit.loadTvSeriesSnapshot().then((series) {
        if (!mounted || series == null) {
          return series;
        }
        setState(() => _videoEdit.primeTvSeriesDraft(series));
        return series;
      });
    }

    unawaited(_loadCatalogVocabularyOptions());

    if (_isOwned) {
      unawaited(_loadAvailableLocations());
      unawaited(_loadTagOptions());
    }
  }

  @override
  void dispose() {
    _collectionStatusController.dispose();
    _comicCharacterDraftController.dispose();
    for (final creator in _comicCreators) {
      creator.dispose();
    }
    for (final character in _comicCharacters) {
      character.dispose();
    }
    for (final link in _comicLinks) {
      link['title']?.dispose();
      link['url']?.dispose();
    }
    _videoEdit.dispose();
    _gamePlatformsController.dispose();
    _tabController.dispose();
    _draft.dispose();
    super.dispose();
  }

  void _initializeGameChipEditors() {
    if (!_isGameKind) {
      return;
    }
    _gameDeveloperOptions =
        _mergePickListOptions(_splitPickList(_developersController.text));
    _gameGenreOptions = _mergePickListOptions(
      _splitPickList(_genresEditController.text),
      widget.item.genres ?? const <String>[],
    );
    _gamePlatformOptions = _splitPickList(_gamePlatformsController.text);
  }

  void _initializeComicEditors() {
    _initializeComicEditorsForState();
  }

  void _initializeVideoEditors() {
    _videoEdit.initializeVideoEditors();
  }

  void _initializeKindSpecificEditors() {
    _initializeGameChipEditors();
    _initializeComicEditors();
    _initializeVideoEditors();
  }

  Map<String, TextEditingController> _createComicLinkControllers({
    String title = '',
    String url = '',
  }) {
    return <String, TextEditingController>{
      'title': TextEditingController(text: title),
      'url': TextEditingController(text: url),
    };
  }

  List<String> _splitPickList(String value) {
    return splitPickListValues(value);
  }

  List<String> _mergePickListOptions(Iterable<String> seed,
      [Iterable<String>? b, Iterable<String>? c, Iterable<String>? d]) {
    final merged = <String>[
      ...seed,
      if (b != null) ...b,
      if (c != null) ...c,
      if (d != null) ...d,
    ];
    final seen = <String>{};
    final output = <String>[];
    for (final candidate in merged) {
      final value = candidate.trim();
      if (value.isEmpty) {
        continue;
      }
      final key = value.toLowerCase();
      if (!seen.add(key)) {
        continue;
      }
      output.add(value);
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    final dialogTitle = _isMovieKind
        ? (() {
            final year =
                widget.item.releaseYear ?? widget.item.releaseDate?.year;
            return year == null
                ? widget.item.title
                : '${widget.item.title} ($year)';
          })()
        : widget.item.title;
    return LibraryEditDialogScaffold(
      formKey: _formKey,
      accent: widget.accent,
      icon: widget.type.workspace.icon,
      title: dialogTitle,
      badges: const <Widget>[],
      tabController: _tabController,
      tabs: [
        for (final tab in _tabSpecs) EditTab(icon: tab.icon, label: tab.label)
      ],
      views: _tabViews(),
      onClose: () => Navigator.of(context).pop(),
      onCancel: () => Navigator.of(context).pop(),
      onSave: () => _submit(LibraryEditSubmitAction.save),
      onPrevious: widget.onPrevious,
      onNext: widget.onNext,
      footerContent: _isOwned ? _ownedSharedFooterRow() : null,
      tabOrderKey: 'edit_tab_order_${widget.type.workspace.kind.apiValue}',
    );
  }

  List<Widget> _tabViews() {
    return [for (final tab in _tabSpecs) _tabViewFor(tab.id)];
  }

  Widget _tabViewFor(String id) {
    switch (id) {
      case 'details':
        return _detailsTab();
      case 'main':
        return _mainTab();
      case 'media':
        return _mediaTab();
      case 'release':
        return _releaseTab();
      case 'episodes':
      case 'tv_episodes':
        return TvEpisodesTab(
          type: widget.type,
          item: widget.item,
          accent: widget.accent,
          videoEdit: _videoEdit,
        );
      case 'release_media':
        return TvReleaseMediaTab(
          type: widget.type,
          item: widget.item,
          accent: widget.accent,
          videoEdit: _videoEdit,
        );
      case 'episode_map':
        return TvEpisodeDiscMapTab(
          type: widget.type,
          item: widget.item,
          accent: widget.accent,
          videoEdit: _videoEdit,
        );
      case 'value':
        return _valueTabForKind();
      case 'personal':
        return _personalTabForKind();
      case 'read_history':
        return _trackingTab();
      case 'sold':
        return _soldTab();
      case 'custom':
        return _customFieldsTab();
      case 'photos':
        return _photosTab();
      case 'cover':
        return _coverTab();
      case 'synopsis':
        return _synopsisTab();
      case 'edition':
        return VideoEditEditionTab(
          type: widget.type,
          draft: _draft,
          accent: widget.accent,
          physicalFormats: _effectivePhysicalFormats,
        );
      case 'specs':
        return VideoEditSpecsTab(
          draft: _draft,
          videoEdit: _videoEdit,
          accent: widget.accent,
          audioTrackOptions: _audioTrackOptions,
          subtitleOptions: _subtitleOptions,
          layersOptions: _layersOptions,
          colorOptions: _colorOptions,
        );
      case 'cast':
        return VideoEditCastTab(
          accent: widget.accent,
          videoEdit: _videoEdit,
        );
      case 'crew':
        return VideoEditCrewTab(
          accent: widget.accent,
          videoEdit: _videoEdit,
        );
      case 'creators':
        return _comicCreatorsTab();
      case 'characters':
        return _comicCharactersTab();
      case 'discs':
        return VideoEditDiscsTab(
          type: widget.type,
          item: widget.item,
          accent: widget.accent,
        );
      case 'links':
        return _linksTabForKind();
      default:
        throw StateError('Unsupported generic edit tab: $id');
    }
  }

  Widget _valueTabForKind() {
    if (_isComicKind) {
      return _ownedComicValueTab();
    }
    return _valueTab();
  }

  Widget _personalTabForKind() {
    if (_isComicKind) {
      return _ownedComicPersonalTab();
    }
    return _personalTab();
  }

  Widget _trackingTab() {
    return EditTabShell(
      children: [
        _personalTrackingSection(),
        if (_showsEpisodeTrackingFields) _videoEpisodeSections(),
      ],
    );
  }

  Widget _linksTabForKind() {
    if (_isComicKind) {
      return _comicLinksTab();
    }
    return VideoEditLinksTab(
      type: widget.type,
      item: widget.item,
      accent: widget.accent,
      videoEdit: _videoEdit,
    );
  }

  Widget _mediaTab() {
    if (_videoEdit.isVideoKind) {
      return VideoEditMediaTab(
        draft: _draft,
        videoEdit: _videoEdit,
        accent: widget.accent,
        countryOptions: _countryOptions,
        languageOptions: _languageOptions,
        ageRatingOptions: _ageRatingOptions,
        audienceRatingOptions: _audienceRatingOptions,
        genreOptions: _genreOptions,
      );
    }
    return _genericMediaTab();
  }

  Widget _releaseTab() {
    return EditTabShell(
      children: [
        if (_showsReleaseSection)
          _buildReleaseDetailsSection()
        else
          const EditSectionStateMessage(
            icon: Icons.album_outlined,
            message: 'Release details apply to a specific edition, printing or '
                'variant. Pick a release anchor on the Main tab to edit them.',
          ),
      ],
    );
  }

  Widget _genericMediaTab() {
    if (_isMediaScope) {
      return EditTabShell(
        children: [
          if (_canShowMediaFields) _buildMediaSection(),
        ],
      );
    }
    if (_isReleaseScope) {
      return EditTabShell(
        children: [
          if (_showsReleaseSection) _buildReleaseDetailsSection(),
        ],
      );
    }
    return EditTabShell(
      children: [
        if (_canShowMediaFields) _buildMediaSection(),
        if (_showsReleaseSection) _buildReleaseDetailsSection(),
      ],
    );
  }

  bool get _hasMediaTab => _tabSpecs.any((t) => t.id == 'media');
  bool get _hasReleaseTab => _tabSpecs.any((t) => t.id == 'release');
  bool get _hasEditionTab => _tabSpecs.any((t) => t.id == 'edition');
  bool get _hasSpecsTab => _tabSpecs.any((t) => t.id == 'specs');
  bool get _hasMainTab => _tabSpecs.any((t) => t.id == 'main');
  bool get _hasValueTab => _tabSpecs.any((t) => t.id == 'value');

  Widget _mainTab() {
    if (_editPresentation.usesOwnedMainArtworkLayout) {
      return _ownedComicMainTab();
    }
    final editPresentation = _editPresentation;
    return EditTabShell(
      children: [
        if (!_hasMediaTab) ...[
          if (_canShowMediaFields) _buildMediaSection(),
          if (!_hasReleaseTab && _showsReleaseSection)
            _buildReleaseDetailsSection(),
        ],
        if (_canShowPersonalFields && _hasTrackingContext)
          EditSection(
            title: editPresentation.trackingSectionTitle,
            accent: widget.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (editPresentation.trackingSectionHint != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      editPresentation.trackingSectionHint!,
                      style: TextStyle(color: appPalette(context).textMuted),
                    ),
                  ),
                _responsiveFields([
                  if (_showPhysicalOwnedFields) ...[
                    _conditionPickField(),
                    _gradePickField(),
                  ],
                  if (!_isOwned) ...[
                    _trackingEditionSelectionField(),
                    _trackingVariantSelectionField(),
                  ],
                ]),
              ],
            ),
          ),
        if (_canShowPersonalFields &&
            editPresentation.showsOwnershipReferenceSection &&
            !_hasEditionTab)
          EditSection(
            title: editPresentation.ownershipReferenceTitle,
            accent: widget.accent,
            child: Column(
              children: [
                _ownershipAnchorSelectionField(),
                if (_selectedOwnedAnchorType ==
                        PersonalItemAnchorType.edition.apiValue ||
                    _selectedOwnedAnchorType ==
                        PersonalItemAnchorType.variant.apiValue) ...[
                  const SizedBox(height: 10),
                  _responsiveFields([
                    _editionSelectionField(),
                    if (_selectedOwnedAnchorType ==
                        PersonalItemAnchorType.variant.apiValue)
                      _variantSelectionField(),
                  ]),
                ],
                if (_selectedOwnedAnchorType ==
                    PersonalItemAnchorType.bundleRelease.apiValue) ...[
                  const SizedBox(height: 10),
                  _bundleReleaseSelectionField(
                    fieldKey: const Key('library-edit-owned-bundle-field'),
                    label: editPresentation.ownedBundleLabel,
                    selectedBundleReleaseId: _selectedBundleReleaseId,
                    onChanged: (value) {
                      setState(() {
                        _selectedBundleReleaseId =
                            normalizeLibrarySelectionId(value);
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        if (_canShowPersonalFields && editPresentation.showsOwnedGradingSection) ...[
          EditSection(
            title: editPresentation.ownedGradingSectionTitle,
            accent: widget.accent,
            child: Column(
              children: [
                if (!_isDigitalFormat) ...[
                  _responsiveFields([
                    _field(
                      controller: _rawOrSlabbedController,
                      label: 'Raw / Slabbed',
                    ),
                    _field(
                      controller: _gradingCompanyController,
                      label: 'Grading company',
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _responsiveFields([
                    _field(
                      controller: _labelTypeController,
                      label: 'Label type',
                    ),
                    _field(
                      controller: _certificationNumberController,
                      label: 'Certification number',
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _field(
                    controller: _graderNotesController,
                    label: 'Grader notes',
                  ),
                  const SizedBox(height: 10),
                  _responsiveFields([
                    _field(controller: _signedByController, label: 'Signed by'),
                    if (editPresentation.showsOwnedCoverPriceField)
                      _field(
                        controller: _coverPriceController,
                        label: 'Cover price',
                        validator: optionalMoneyValidator,
                      ),
                  ]),
                  const SizedBox(height: 10),
                ] else if (editPresentation.ownedGradingSectionHint != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      editPresentation.ownedGradingSectionHint!,
                      style: TextStyle(color: appPalette(context).textMuted),
                    ),
                  ),
                SwitchListTile(
                  value: _keyComic,
                  onChanged: (value) => setState(() => _keyComic = value),
                  title: Text(editPresentation.keyToggleLabel),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                if (_keyComic) ...[
                  const SizedBox(height: 6),
                  _field(
                    controller: _keyReasonController,
                    label: editPresentation.keyReasonLabel,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _detailsTab() {
    if (_editPresentation.usesDetailsTab) {
      return _ownedComicDetailsTab();
    }
    return const SizedBox.shrink();
  }

  Widget _buildMediaSection() {
    final mediaFields = widget.type.mediaFields;
    return EditSection(
      title: 'Media',
      accent: widget.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _responsiveFields([
            _field(
              controller: _titleController,
              label: 'Title',
              validator: (value) =>
                  emptyToNull(value ?? '') == null ? 'Enter a title' : null,
            ),
            if (_isGameKind)
              _field(controller: _sortKeyController, label: 'Sort title')
            else
              _field(
                controller: _numberController,
                label: mediaFields.numberLabel,
              ),
          ]),
          const SizedBox(height: 10),
          _responsiveFields([
            _publisherField(label: mediaFields.publisherLabel),
          ]),
          if (_videoEdit.isVideoKind) ...[
            const SizedBox(height: 10),
            _responsiveFields([
              _videoSeriesField(),
            ]),
          ] else if (_isGameKind) ...[
            const SizedBox(height: 10),
            _responsiveFields([
              _field(controller: _seriesTitleController, label: 'Series'),
              TagPickListField(
                controller: _developersController,
                options: _gameDeveloperOptions,
                label: 'Developer',
                hint: 'Comma-separated developers',
              ),
            ]),
            const SizedBox(height: 10),
            _responsiveFields([
              TagPickListField(
                controller: _gamePlatformsController,
                options: _gamePlatformOptions,
                label: 'Platform',
                hint: 'Comma-separated platforms',
              ),
              _audienceRatingPickField(),
              TagPickListField(
                controller: _genresEditController,
                options: _gameGenreOptions,
                label: 'Genres',
              ),
            ]),
          ],
          if (mediaFields.showPageCount ||
              mediaFields.showImprint ||
              mediaFields.showSeriesGroup) ...[
            const SizedBox(height: 10),
            _responsiveFields([
              if (mediaFields.showPageCount)
                _field(
                  controller: _pageCountController,
                  label: 'Page count',
                  validator: optionalIntValidator,
                ),
              if (mediaFields.showImprint) _imprintField(),
              if (mediaFields.showSeriesGroup)
                _seriesGroupField(label: 'Series group'),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildReleaseDetailsSection() {
    final releaseFields = widget.type.releaseFields;
    return EditSection(
      title: 'Release details',
      accent: widget.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LibraryReleaseIdentityFields(
            editionTitleController: _editionTitleController,
            variantController: _variantController,
            barcodeController: _barcodeController,
            releaseDateController: _releaseDateController,
            releaseYearController: _releaseYearController,
            physicalFormatController: _physicalFormatLabelController,
            physicalFormatOptions: mergePickListValues(
              builtInValues: [
                for (final format in _effectivePhysicalFormats) format.label,
              ],
              customValues: _physicalFormatOptions,
              selectedValues: [_physicalFormatLabelController.text],
            ),
            onPhysicalFormatChanged: (value) {
              final normalized = emptyToNull(value ?? '');
              final format = physicalMediaFormatByLabelOrId(
                normalized,
                formats: _effectivePhysicalFormats,
              );
              final previousFormat = _physicalFormatForId(_physicalFormatId);
              final variant = _variantController.text.trim();
              final shouldReplaceVariant =
                  variant.isEmpty || previousFormat?.label == variant;
              setState(() {
                _physicalFormatId = format?.id;
                if (format != null && shouldReplaceVariant) {
                  _variantController.text = format.label;
                }
              });
            },
            onPhysicalFormatManage: () => _manageSingleValuePickList(
              listName: kPhysicalFormatPickListName,
              label: 'Physical format',
              builtInValues: [
                for (final format in _effectivePhysicalFormats) format.label,
              ],
            ),
            showPhysicalFormat: releaseFields.showPhysicalFormat,
            editionTitleLabel: releaseFields.editionTitleLabel,
            variantLabel: releaseFields.variantLabel,
            barcodeLabel: releaseFields.barcodeLabel,
            releaseDateLabel: widget.type.mediaFields.releaseDateLabel,
          ),
        ],
      ),
    );
  }

  Widget _valueTab() {
    return LibraryEditValueTab(
      accent: widget.accent,
      buildResponsiveFields: _responsiveFields,
      buildField: _field,
      buildDatePickerField: _datePickerField,
      priceController: _priceController,
      currencyController: _currencyController,
      purchaseDateController: _purchaseDateController,
      purchaseStoreController: _purchaseStoreController,
      marketValueController: _marketValueController,
      sellPriceController: _sellPriceController,
      lastBagBoardDate: _lastBagBoardDate,
      onLastBagBoardDateChanged: (value) =>
          setState(() => _lastBagBoardDate = value),
      isGameKind: _isGameKind,
      gameCompleteness: _gameCompleteness,
      onGameCompletenessChanged: (value) =>
          setState(() => _gameCompleteness = value),
      gameHasBox: _gameHasBox,
      onGameHasBoxChanged: (value) => setState(() => _gameHasBox = value),
      gameHasManual: _gameHasManual,
      onGameHasManualChanged: (value) => setState(() => _gameHasManual = value),
      gamePriceChartingId: _gamePriceChartingId,
      onGamePriceChartingIdChanged: (value) =>
          setState(() => _gamePriceChartingId = value),
      gameCoreRegion: _gameCoreRegion,
      onGameCoreRegionChanged: (value) =>
          setState(() => _gameCoreRegion = value),
      gameValueIsLocked: _gameValueIsLocked,
      onGameValueIsLockedChanged: (value) =>
          setState(() => _gameValueIsLocked = value),
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Sold
  // -------------------------------------------------------------------------

  Widget _soldTab() {
    return buildLibraryEditSoldTab(
      context: context,
      accent: widget.accent,
      buildResponsiveFields: _responsiveFields,
      buildField: _field,
      buildDatePickerField: _datePickerField,
      soldAt: _soldAt,
      onSoldChanged: (value) {
        setState(() {
          _soldAt = value ? DateTime.now() : null;
        });
      },
      onSoldDateChanged: (value) => setState(() => _soldAt = value),
      sellPriceController: _sellPriceController,
      soldToController: _soldToController,
      priceController: _priceController,
      currencyController: _currencyController,
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Personal
  // -------------------------------------------------------------------------

  Widget _personalTab() {
    if (!_canShowPersonalFields) {
      return const SizedBox.shrink();
    }
    return EditTabShell(
      children: [
        _personalTrackingSection(),
        if (_showsEpisodeTrackingFields) _videoEpisodeSections(),
        if (_isOwned && !_showPhysicalOwnedFields)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Digital copies do not expose physical storage fields.',
              style: TextStyle(color: appPalette(context).textMuted),
            ),
          ),
        if (_hasWishlistContext) _wishlistReferenceSection(),
        if (_isOwned)
          _ownedNotesSection()
        else if (!_hasWishlistContext)
          _collectionFieldsInfoSection(),
        if (_showPhysicalOwnedFields && !_hasSpecsTab) _physicalMediaSection(),
        if (_isOwned && !_hasMainTab) _ownershipSection(),
        if (_isOwned && !_hasValueTab) _purchaseValueSection(),
      ],
    );
  }

  Widget _personalTrackingSection() {
    return EditSection(
      title: _isOwned
          ? 'Storage & Tracking'
          : _hasWishlistContext
              ? 'Personal'
              : 'Tracking',
      accent: widget.accent,
      child: Column(
        children: [
          if (_isTrackingOnly && widget.item.editions.isNotEmpty) ...[
            _responsiveFields([
              _trackingEditionSelectionField(),
              _trackingVariantSelectionField(),
            ]),
            const SizedBox(height: 10),
          ],
          _responsiveFields([
            SizedBox(
              width: 120,
              child: MediaRatingField(controller: _ratingController),
            ),
            SizedBox(
              width: 180,
              child: MediaTrackingStatusField(
                profile: widget.type.trackingProfile,
                value: _trackingController.text,
                label: 'Tracking status',
                onChanged: (value) {
                  _trackingController.text = value ?? '';
                },
              ),
            ),
          ]),
          const SizedBox(height: 10),
          _responsiveFields(
            buildTrackingProgressFieldWidgets(
              progressCurrentController: _progressCurrentController,
              progressTotalController: _progressTotalController,
              timesCompletedController: _timesCompletedController,
              buildField: (controller, label) => _field(
                controller: controller,
                label: label,
                validator: optionalIntValidator,
              ),
            ),
          ),
          if (_showsEpisodeTrackingFields) ...[
            const SizedBox(height: 10),
            _responsiveFields(
              buildTrackingEpisodeFieldWidgets(
                seasonNumberController: _videoEdit.seasonNumberController,
                episodeNumberController: _videoEdit.episodeNumberController,
                buildField: (controller, label) => _field(
                  controller: controller,
                  label: label,
                  validator: optionalIntValidator,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          TextFormField(
            controller: _trackingNotesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Tracking notes',
              border: OutlineInputBorder(),
            ),
          ),
          if (_isOwned && _isDigitalFormat) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Wishlist-only and digital copies do not expose storage location fields.',
                style: TextStyle(color: appPalette(context).textMuted),
              ),
            ),
          ],
          if (_isOwned) ...[
            const SizedBox(height: 10),
            TagPickListField(
              controller: _tagsController,
              options: _tagOptions,
              label: 'Tags',
              hint: 'Comma-separated tags',
            ),
            const SizedBox(height: 10),
            _responsiveFields([
              _ownerPickField(),
            ]),
            const SizedBox(height: 10),
          ],
          if (_showPhysicalOwnedFields) ...[
            _responsiveFields([
              TextFormField(
                controller: _storageDeviceController,
                decoration: const InputDecoration(
                  labelText: 'Storage Device',
                  hintText: 'e.g. DVD Shelf, Blu-ray Cabinet',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: _storageSlotController,
                decoration: const InputDecoration(
                  labelText: 'Storage Slot',
                  hintText: 'e.g. Row 3, Slot 5',
                  border: OutlineInputBorder(),
                ),
              ),
            ]),
            const SizedBox(height: 10),
          ],
          _responsiveFields([
            _datePickerField(
              label: 'Started',
              value: _startedAt,
              onChanged: (v) => setState(() => _startedAt = v),
            ),
            _datePickerField(
              label: 'Finished',
              value: _finishedAt,
              onChanged: (v) => setState(() => _finishedAt = v),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _videoEpisodeSections() {
    return Column(
      children: [
        VideoSeasonTrackingSection(
          seriesRef: CatalogEntityRef(
            kind: widget.type.workspace.kind.apiValue,
            entityType: CatalogEntityType.work,
            id: widget.item.id,
          ),
          kind: widget.type.workspace.kind.apiValue,
          accent: widget.accent,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: VideoEpisodeRatingSection(
            itemId: widget.item.id,
            kind: widget.type.workspace.kind.apiValue,
            accent: widget.accent,
            trackingEntry: widget.trackingEntry?.copyWith(
              episodeRatings: _episodeRatings,
            ),
            onEpisodeRatingsChanged: (updated) {
              setState(() => _episodeRatings = updated);
            },
          ),
        ),
      ],
    );
  }

  Widget _wishlistReferenceSection() {
    return EditSection(
      title: 'Wishlist reference',
      accent: widget.accent,
      child: Column(
        children: [
          _wishlistAnchorSelectionField(),
          if (_selectedWishlistAnchorType ==
                  PersonalItemAnchorType.edition.apiValue ||
              _selectedWishlistAnchorType ==
                  PersonalItemAnchorType.variant.apiValue) ...[
            const SizedBox(height: 10),
            _responsiveFields([
              _wishlistEditionSelectionField(),
              if (_selectedWishlistAnchorType ==
                  PersonalItemAnchorType.variant.apiValue)
                _wishlistVariantSelectionField(),
            ]),
          ],
          if (_selectedWishlistAnchorType ==
              PersonalItemAnchorType.bundleRelease.apiValue) ...[
            const SizedBox(height: 10),
            _bundleReleaseSelectionField(
              fieldKey: const Key('library-edit-wishlist-bundle-field'),
              label: 'Wishlist bundle',
              selectedBundleReleaseId: _selectedWishlistBundleReleaseId,
              onChanged: (value) {
                setState(() {
                  _selectedWishlistBundleReleaseId =
                      normalizeLibrarySelectionId(value);
                });
              },
            ),
          ],
          const SizedBox(height: 10),
          _responsiveFields([
            _field(
              controller: _wishlistPriceController,
              label: 'Target price',
              validator: optionalMoneyValidator,
            ),
            LibraryCurrencyField(controller: _wishlistCurrencyController),
          ]),
          const SizedBox(height: 10),
          TextFormField(
            controller: _wishlistNotesController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Wishlist notes',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ownedNotesSection() {
    return EditSection(
      title: 'Notes',
      accent: widget.accent,
      child: TextFormField(
        controller: _notesController,
        minLines: 5,
        maxLines: 8,
        decoration: const InputDecoration(
          labelText: 'Personal notes',
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  Widget _collectionFieldsInfoSection() {
    return EditSection(
      title: 'Collection fields',
      accent: widget.accent,
      child: Text(
        'Storage, value, quantity and personal notes are only available once the item has an owned copy. Tracking progress stays editable here.',
        style: TextStyle(color: appPalette(context).textMuted),
      ),
    );
  }

  Widget _physicalMediaSection() {
    return EditSection(
      title: 'Physical media',
      accent: widget.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HDR formats',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final format in const [
                'HDR10',
                'HDR10+',
                'Dolby Vision',
                'HLG',
              ])
                FilterChip(
                  label: Text(format),
                  selected: _hdrFormats.contains(format),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _hdrFormats.add(format);
                      } else {
                        _hdrFormats.remove(format);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          _responsiveFields([
            LibraryVocabularyField(
              label: 'Region',
              controller: _regionController,
              options: _regionOptions,
              onManage: () => _manageSingleValuePickList(
                listName: kRegionPickListName,
                label: 'Region',
              ),
            ),
            LibraryVocabularyField(
              label: 'Packaging',
              controller: _packagingController,
              options: _packagingOptions,
              onManage: () => _manageSingleValuePickList(
                listName: kPackagingPickListName,
                label: 'Packaging',
              ),
            ),
          ]),
          const SizedBox(height: 10),
          _responsiveFields([
            LibraryVocabularyField(
              label: 'Distributor',
              controller: _distributorController,
              options: _distributorOptions,
              onManage: () => _manageSingleValuePickList(
                listName: kDistributorPickListName,
                label: 'Distributor',
              ),
            ),
            LibraryVocabularyField(
              label: 'Screen ratio',
              controller: _screenRatioController,
              options: _screenRatioOptions,
              onManage: () => _manageSingleValuePickList(
                listName: kScreenRatioPickListName,
                label: 'Screen ratio',
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _featuresController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Features',
              hintText: 'Disc features, special editions, bonus content...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _boxSetNameController,
            decoration: const InputDecoration(
              labelText: 'Box Set Name',
              hintText: 'Name of the box set this disc belongs to',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ownershipSection() {
    return EditSection(
      title: 'Ownership',
      accent: widget.accent,
      child: Column(
        children: [
          _responsiveFields([
            if (_showPhysicalOwnedFields) ...[
              _conditionPickField(),
              _gradePickField(),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _purchaseValueSection() {
    return EditSection(
      title: 'Purchase & Value',
      accent: widget.accent,
      child: Column(
        children: [
          _responsiveFields([
            _field(controller: _priceController, label: 'Purchase price'),
            LibraryCurrencyField(controller: _currencyController),
          ]),
          const SizedBox(height: 10),
          _responsiveFields([
            LibraryDateEditField(
              label: 'Purchase date',
              controller: _purchaseDateController,
            ),
            _field(
                controller: _purchaseStoreController, label: 'Purchase store'),
          ]),
          const SizedBox(height: 10),
          _responsiveFields([
            _field(controller: _marketValueController, label: 'Current value'),
          ]),
        ],
      ),
    );
  }

  Widget _customFieldsTab() {
    return EditTabShell(
      children: [
        CustomFieldsEditSection(
          definitions: widget.customFieldDefinitions,
          values: _customFieldEdits,
          accent: widget.accent,
          onChanged: (values) => _customFieldEdits = values,
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Photos
  // -------------------------------------------------------------------------

  Widget _photosTab() {
    if (_editPresentation.usesArtworkPhotosTab) {
      return _comicPhotosTab();
    }
    return EditTabShell(
      children: [
        ItemImagesEditSection(
          images: widget.itemImages,
          accent: widget.accent,
          onChanged: (edits) => _itemImageEdits = edits,
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Cover
  // -------------------------------------------------------------------------

  Widget _coverTab() {
    if (_editPresentation.usesArtworkCoverTab) {
      return _comicCoverTab();
    }
    return EditTabShell(
      children: [
        EditSection(
          title: 'Cover images',
          accent: widget.accent,
          child: _responsiveFields([
            _field(controller: _coverController, label: 'Cover image URL'),
            _field(
                controller: _thumbnailController, label: 'Thumbnail image URL'),
          ]),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Synopsis
  // -------------------------------------------------------------------------

  Widget _synopsisTab() {
    final title = widget.type.editChrome.synopsisLabel;
    return EditTabShell(
      children: [
        EditSection(
          title: title,
          accent: widget.accent,
          child: TextFormField(
            controller: _synopsisController,
            minLines: 5,
            maxLines: 12,
            decoration: InputDecoration(
              labelText: title,
              alignLabelWithHint: true,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab: Links (external links — TMDb, IMDb, etc.)
  // -------------------------------------------------------------------------

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Widget _responsiveFields(List<Widget> children) {
    return LibraryEditResponsiveRow(children: children);
  }

  Widget _flexResponsiveFields(
    List<Widget> children, {
    required List<int> flexes,
    double breakpoint = 880,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                children[index],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(width: 10),
              Expanded(
                flex: flexes[index],
                child: children[index],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return LibraryEditTextField(
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
    );
  }

  Widget _pickField({
    required TextEditingController controller,
    required String label,
    required List<String> options,
    String? hint,
    String? Function(String?)? validator,
    ValueChanged<String?>? onChanged,
    VoidCallback? onManage,
    String? manageTooltip,
    bool showPickerListAction = false,
  }) {
    return SingleValuePickField(
      controller: controller,
      options: options,
      label: label,
      hint: hint,
      validator: validator,
      onChanged: onChanged,
      onManage: onManage,
      manageTooltip: manageTooltip,
      showPickerListAction: showPickerListAction || onManage == null,
    );
  }

  Widget _conditionPickField({String label = 'Condition'}) {
    return _pickField(
      controller: _conditionController,
      label: label,
      options: _conditionOptions,
    );
  }

  Widget _gradePickField({String label = 'Grade'}) {
    return _pickField(
      controller: _gradeController,
      label: label,
      options: _gradeOptions,
    );
  }

  Widget _ownerPickField({String label = 'Owner'}) {
    return _pickField(
      controller: _ownerLabelController,
      label: label,
      options: _ownerOptions,
      showPickerListAction: true,
    );
  }

  Widget _audienceRatingPickField({String label = 'Audience rating'}) {
    return _pickField(
      controller: _audienceRatingController,
      label: label,
      options: _audienceRatingOptions,
    );
  }

  Widget _footerField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: const InputDecoration(
        suffixIcon: SizedBox.shrink(),
        suffixIconConstraints: BoxConstraints(
          minWidth: 0,
          minHeight: 40,
        ),
      ).copyWith(labelText: label),
    );
  }

  Widget _locationField({String label = 'Location'}) {
    final selectedLabel = _selectedLocationLabel;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _pickLocation,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(Icons.place),
        ),
        child: Text(
          selectedLabel ?? 'No location selected',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: selectedLabel == null
                    ? appPalette(context).textMuted
                    : null,
              ),
        ),
      ),
    );
  }

  Widget _collectionStatusField({String label = 'Collection status'}) {
    return SingleValuePickField(
      controller: _collectionStatusController,
      options: const ['In collection', 'For sale', 'On order'],
      label: label,
      showPickerListAction: true,
      onChanged: (selectedLabel) {
        _collectionStatus = _collectionStatusFromLabel(selectedLabel);
      },
    );
  }

  String _collectionStatusToLabel(String? value) {
    return switch (value) {
      'for_sale' => 'For sale',
      'on_order' => 'On order',
      _ => 'In collection',
    };
  }

  String? _collectionStatusFromLabel(String? label) {
    final normalized = label?.trim().toLowerCase();
    return switch (normalized) {
      'for sale' => 'for_sale',
      'on order' => 'on_order',
      _ => null,
    };
  }

  String? get _selectedLocationLabel {
    final locationLabel =
        locationPathForId(_availableLocations, _selectedLocationId);
    if (locationLabel != null) {
      return locationLabel;
    }
    return null;
  }


  Widget _publisherField({String label = 'Publisher'}) {
    return _pickField(
      controller: _publisherController,
      options: _publisherOptions,
      label: label,
      onManage: () => _manageSingleValuePickList(
        listName: kPublisherPickListName,
        label: label,
      ),
    );
  }

  Widget _imprintField() {
    return _pickField(
      controller: _imprintController,
      options: _imprintOptions,
      label: 'Imprint',
      onManage: () => _manageSingleValuePickList(
        listName: kImprintPickListName,
        label: 'Imprint',
      ),
    );
  }

  Widget _seriesGroupField({String label = 'Series Group'}) {
    return _pickField(
      controller: _seriesGroupController,
      options: _seriesGroupOptions,
      label: label,
      onManage: () => _manageSingleValuePickList(
        listName: kSeriesGroupPickListName,
        label: label,
      ),
    );
  }

  Widget _videoSeriesField() {
    return _pickField(
      controller: _seriesTitleController,
      options: [for (final entry in _seriesEntries) entry.title],
      label: 'Series display',
      hint: 'Select or type a series name',
      onChanged: (value) {
        final normalized = emptyToNull(value ?? '');
        final matchingEntry = _seriesEntries.cast<SeriesRegistryEntry?>().firstWhere(
              (entry) =>
                  entry != null &&
                  entry.title.trim().toLowerCase() ==
                      (normalized?.toLowerCase() ?? ''),
              orElse: () => null,
            );
        setState(() {
          _selectedSeriesId = matchingEntry?.coreSeriesId;
        });
      },
      onManage: _openSeriesPicker,
      manageTooltip: 'Select or manage series',
    );
  }

  Widget _countryPickField({String label = 'Country'}) {
    return _pickField(
      controller: _countryController,
      options: _countryOptions,
      label: label,
      onManage: () => _manageSingleValuePickList(
        listName: kCountryPickListName,
        label: label,
      ),
    );
  }

  Widget _crossoverPickField({String label = 'Crossover'}) {
    return _pickField(
      controller: _crossoverController,
      options: _crossoverOptions,
      label: label,
      onManage: () => _manageSingleValuePickList(
        listName: kCrossoverPickListName,
        label: label,
      ),
    );
  }

  Widget _storyArcPickField({String label = 'Story Arc'}) {
    return _pickField(
      controller: _storyArcsController,
      options: _storyArcOptions,
      label: label,
      onManage: () => _manageSingleValuePickList(
        listName: kStoryArcPickListName,
        label: label,
      ),
    );
  }

  Widget _pageQualityPickField({String label = 'Page quality'}) {
    return _pickField(
      controller: _pageQualityController,
      options: _pageQualityOptions,
      label: label,
      onManage: () => _manageSingleValuePickList(
        listName: kPageQualityPickListName,
        label: label,
        builtInValues: const [
          'White',
          'Off-White to White',
          'Cream to Off-White',
          'Brittle',
        ],
      ),
    );
  }

  Widget _keyCategoryPickField({String label = 'Key category'}) {
    return _pickField(
      controller: _keyCategoryController,
      options: _keyCategoryOptions,
      label: label,
      onManage: () => _manageSingleValuePickList(
        listName: kKeyCategoryPickListName,
        label: label,
        builtInValues: const [
          'First appearance',
          'First issue',
          'Origin',
          'Death',
          'Cameo',
          'Classic cover',
        ],
      ),
    );
  }

  Widget _seriesField() {
    return _pickField(
      controller: _titleController,
      options: [for (final entry in _seriesEntries) entry.title],
      label: 'Series',
      validator: (value) =>
          emptyToNull(value ?? '') == null ? 'Enter a title' : null,
      onChanged: (value) {
        final normalized = emptyToNull(value ?? '');
        final matchingEntry =
            _seriesEntries.cast<SeriesRegistryEntry?>().firstWhere(
                  (entry) =>
                      entry != null &&
                      entry.title.trim().toLowerCase() ==
                          (normalized?.toLowerCase() ?? ''),
                  orElse: () => null,
                );
        setState(() {
          _selectedSeriesId = matchingEntry?.coreSeriesId;
        });
      },
      onManage: _openSeriesPicker,
      manageTooltip: 'Select or manage series',
    );
  }

  Widget _physicalFormatField({String label = 'Format'}) {
    return _pickField(
      controller: _physicalFormatLabelController,
      options: mergePickListValues(
        builtInValues: [
          for (final format in _effectivePhysicalFormats) format.label,
        ],
        customValues: _physicalFormatOptions,
        selectedValues: [_physicalFormatLabelController.text],
      ),
      label: label,
      onChanged: (value) {
        final normalized = emptyToNull(value ?? '');
        final format = physicalMediaFormatByLabelOrId(
          normalized,
          formats: _effectivePhysicalFormats,
        );
        final previousFormat = _physicalFormatForId(_physicalFormatId);
        final variant = _variantController.text.trim();
        final shouldReplaceVariant =
            variant.isEmpty || previousFormat?.label == variant;
        setState(() {
          _physicalFormatId = format?.id;
          if (format != null && shouldReplaceVariant) {
            _variantController.text = format.label;
          }
        });
      },
      onManage: () => _manageSingleValuePickList(
        listName: kPhysicalFormatPickListName,
        label: label,
        builtInValues: [
          for (final format in _effectivePhysicalFormats) format.label,
        ],
      ),
    );
  }

  Future<void> _pickTagsFromDropdown({String title = 'Pick Tags'}) async {
    final selected = splitPickListValues(_tagsController.text);
    final options = mergePickListValues(
      builtInValues: _tagOptions,
      selectedValues: selected,
    );
    final draft = <String>{for (final value in selected) value.toLowerCase()};
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 420,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final option in options)
                        CheckboxListTile(
                          value: draft.contains(option.toLowerCase()),
                          dense: true,
                          title: Text(option),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (checked) {
                            setLocalState(() {
                              final key = option.toLowerCase();
                              if (checked ?? false) {
                                draft.add(key);
                              } else {
                                draft.remove(key);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final ordered = [
                      for (final option in options)
                        if (draft.contains(option.toLowerCase())) option,
                    ];
                    Navigator.of(context).pop(ordered);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
    if (!mounted || result == null) {
      return;
    }
    final text = joinPickListValues(result) ?? '';
    _mutateDialogState(() {
      _tagsController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  Widget _tagsDropdownField({String label = 'Tags'}) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _tagsController,
      builder: (context, value, _) {
        final tags = splitPickListValues(value.text);
        return InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: () => _pickTagsFromDropdown(title: 'Pick Tags'),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 72,
                maxWidth: 72,
                minHeight: 40,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _pickTagsFromDropdown(title: 'Pick Tags'),
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.arrow_drop_down, size: 18),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 18,
                    color: Theme.of(context).dividerColor,
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _pickTagsFromDropdown(title: 'Manage Tags'),
                    child: const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.view_list_outlined, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            child: Text(
              tags.isEmpty ? 'Select tags' : tags.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: tags.isEmpty ? appPalette(context).textMuted : null,
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _ownedSharedFooterRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 280,
                  child: _collectionStatusField(label: 'Collection Status'),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 140,
                  child: _footerField(
                    label: 'Index',
                    controller: _indexNumberController,
                    validator: optionalIntValidator,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 140,
                  child: _footerField(
                    controller: _quantityController,
                    label: 'Quantity',
                    validator: positiveIntValidator,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 360,
                  child: _locationField(label: 'Location'),
                ),
              ],
            ),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: _collectionStatusField(label: 'Collection Status'),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _footerField(
                label: 'Index',
                controller: _indexNumberController,
                validator: optionalIntValidator,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _footerField(
                controller: _quantityController,
                label: 'Quantity',
                validator: positiveIntValidator,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: _locationField(label: 'Location'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickLocation() async {
    final result = await showLocationPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      currentLocationId: _selectedLocationId,
    );
    if (result == null) {
      return;
    }
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _locationChanged = true;
      _selectedLocationId = result.isEmpty ? null : result;
      _availableLocations = locations;
    });
  }

  List<PhysicalMediaFormat> get _effectivePhysicalFormats {
    return widget.physicalFormats.isEmpty
        ? allKnownPhysicalMediaFormats
        : widget.physicalFormats;
  }

  void _openEditTab(String id) {
    final index = _tabSpecs.indexWhere((tab) => tab.id == id);
    if (index >= 0) {
      _tabController.animateTo(index);
    }
  }

  Widget _datePickerField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return LibraryDateFieldButton(
      label: label,
      value: value,
      onChanged: onChanged,
    );
  }

  void _mutateDialogState(VoidCallback mutation) {
    setState(mutation);
  }

  Future<void> _submit(LibraryEditSubmitAction submitAction) async {
    if (!_formKey.currentState!.validate()) return;
    _submitAction = submitAction;
    var selection = _draft.buildSelection(submitAction: _submitAction);
    selection = _videoEdit.applyVideoSelectionEdits(selection);
    selection = _applyComicSelectionEdits(selection);
    selection = _applyGameSelection(selection);
    selection = _normalizeSelectionScope(selection);
    await _videoEdit.persistUserExternalLinks();
    if (!mounted) return;
    Navigator.of(context).pop(selection);
  }

  LibraryEditSelection _normalizeSelectionScope(
      LibraryEditSelection selection) {
    if (selection.scope == widget.scope) {
      return selection;
    }
    return LibraryEditSelection(
      scope: widget.scope,
      item: selection.item,
      personal: selection.personal,
      wishlist: selection.wishlist,
      tracking: selection.tracking,
      customFieldEdits: selection.customFieldEdits,
      itemImageEdits: selection.itemImageEdits,
      submitAction: selection.submitAction,
    );
  }

  LibraryEditSelection _applyGameSelection(LibraryEditSelection selection) {
    final currentGame = selection.item.game;
    final updatedGame = GameCatalogDetails(
      platforms: _splitPickList(_gamePlatformsController.text),
      toySubtype: currentGame?.toySubtype,
      toyType: currentGame?.toyType,
    );
    return LibraryEditSelection(
      scope: selection.scope,
      item: selection.item.copyWith(
        game: updatedGame.hasData ? updatedGame : null,
      ),
      personal: selection.personal,
      wishlist: selection.wishlist,
      tracking: selection.tracking,
      customFieldEdits: selection.customFieldEdits,
      itemImageEdits: selection.itemImageEdits,
      submitAction: selection.submitAction,
    );
  }

  PhysicalMediaFormat? _physicalFormatForId(String? id) {
    final normalized = emptyToNull(id ?? '');
    return normalized == null
        ? null
        : physicalMediaFormatById(
            normalized,
            formats: widget.physicalFormats,
          );
  }

  CatalogEdition? _selectedEditionById(String? selectedId) {
    if (selectedId == null) {
      return null;
    }
    for (final edition in widget.item.editions) {
      if (edition.id == selectedId) {
        return edition;
      }
    }
    return null;
  }

  Widget _ownershipAnchorSelectionField() {
    return _anchorSelectionField(
      fieldKey: const Key('library-edit-owned-anchor-field'),
      label: 'Ownership anchor',
      value: _selectedOwnedAnchorType,
      onChanged: _setOwnedAnchorType,
    );
  }

  Widget _wishlistAnchorSelectionField() {
    return _anchorSelectionField(
      fieldKey: const Key('library-edit-wishlist-anchor-field'),
      label: 'Wishlist anchor',
      value: _selectedWishlistAnchorType,
      onChanged: _setWishlistAnchorType,
    );
  }

  Widget _anchorSelectionField({
    required Key fieldKey,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return _LibraryEditAnchorSelector(
      fieldKey: fieldKey,
      label: label,
      value: value,
      editionAvailable: widget.item.editions.isNotEmpty,
      bundleAvailable: widget.availableBundleReleases.isNotEmpty ||
          value == PersonalItemAnchorType.bundleRelease.apiValue,
      onChanged: onChanged,
    );
  }

  Widget _editionSelectionField() {
    return _editionSelectionFieldFor(
      label: 'Owned edition',
      selectedEditionId: _selectedEditionId,
      onChanged: (editionId) {
        final edition = resolveLibraryEditionSelection(
          widget.item.editions,
          editionId: editionId,
        ).edition;
        setState(() {
          _selectedEditionId = edition?.id;
          _selectedVariantId = null;
          _selectedTrackingEditionId = _selectedEditionId;
          _selectedTrackingVariantId = null;
        });
      },
    );
  }

  Widget _trackingEditionSelectionField() {
    return _editionSelectionFieldFor(
      label: 'Tracking edition',
      selectedEditionId: _selectedTrackingEditionId,
      onChanged: (editionId) {
        final edition = resolveLibraryEditionSelection(
          widget.item.editions,
          editionId: editionId,
        ).edition;
        setState(() {
          _selectedTrackingEditionId = edition?.id;
          _selectedTrackingVariantId = null;
        });
      },
    );
  }

  Widget _wishlistEditionSelectionField() {
    return _editionSelectionFieldFor(
      label: 'Wishlist edition',
      selectedEditionId: _selectedWishlistEditionId,
      onChanged: (editionId) {
        final edition = resolveLibraryEditionSelection(
          widget.item.editions,
          editionId: editionId,
        ).edition;
        setState(() {
          _selectedWishlistEditionId = edition?.id;
          _selectedWishlistVariantId = null;
        });
      },
    );
  }

  Widget _editionSelectionFieldFor({
    required String label,
    required String? selectedEditionId,
    required ValueChanged<String?> onChanged,
  }) {
    return _LibraryEditEditionSelector(
      label: label,
      selectedEditionId: selectedEditionId,
      editions: widget.item.editions,
      onChanged: (value) => onChanged(normalizeLibrarySelectionId(value)),
    );
  }

  Widget _variantSelectionField() {
    return _variantSelectionFieldFor(
      label: 'Owned variant',
      selectedEditionId: _selectedEditionId,
      selectedVariantId: _selectedVariantId,
      onChanged: (value) {
        setState(() {
          _selectedVariantId = value;
          _selectedTrackingEditionId = _selectedEditionId;
          _selectedTrackingVariantId = value;
        });
      },
    );
  }

  Widget _trackingVariantSelectionField() {
    return _variantSelectionFieldFor(
      label: 'Tracking variant',
      selectedEditionId: _selectedTrackingEditionId,
      selectedVariantId: _selectedTrackingVariantId,
      onChanged: (value) {
        setState(() {
          _selectedTrackingVariantId = value;
        });
      },
    );
  }

  Widget _wishlistVariantSelectionField() {
    return _variantSelectionFieldFor(
      label: 'Wishlist variant',
      selectedEditionId: _selectedWishlistEditionId,
      selectedVariantId: _selectedWishlistVariantId,
      onChanged: (value) {
        setState(() {
          _selectedWishlistVariantId = value;
        });
      },
    );
  }

  Widget _variantSelectionFieldFor({
    required String label,
    required String? selectedEditionId,
    required String? selectedVariantId,
    required ValueChanged<String?> onChanged,
  }) {
    final edition = _selectedEditionById(selectedEditionId);
    final variants = edition?.variants ?? const <CatalogVariant>[];
    return _LibraryEditVariantSelector(
      label: label,
      selectedVariantId: selectedVariantId,
      variants: variants,
      onChanged: variants.isEmpty
          ? (_) {}
          : (value) => onChanged(normalizeLibrarySelectionId(value)),
    );
  }

  Widget _bundleReleaseSelectionField({
    Key? fieldKey,
    required String label,
    required String? selectedBundleReleaseId,
    required ValueChanged<String?> onChanged,
  }) {
    return _LibraryEditBundleReleaseSelector(
      fieldKey: fieldKey,
      label: label,
      selectedBundleReleaseId: selectedBundleReleaseId,
      bundleReleases: widget.availableBundleReleases,
      onChanged: (value) => onChanged(normalizeLibrarySelectionId(value)),
    );
  }

  void _setOwnedAnchorType(String value) {
    final state = resolveOwnedAnchorSelectionState(
      anchorType: value,
      editions: widget.item.editions,
      selectedEditionId: _selectedEditionId,
      selectedVariantId: _selectedVariantId,
      editionTitle: widget.item.editionTitle,
      variantName: widget.item.variant,
      availableBundleReleaseIds: [
        for (final release in widget.availableBundleReleases) release.id,
      ],
    );
    setState(() {
      _selectedOwnedAnchorType = state.anchorType;
      _selectedEditionId = state.selectedEditionId;
      _selectedVariantId = state.selectedVariantId;
      _selectedBundleReleaseId = state.selectedBundleReleaseId;
      _selectedTrackingEditionId = state.selectedTrackingEditionId;
      _selectedTrackingVariantId = state.selectedTrackingVariantId;
    });
  }

  void _setWishlistAnchorType(String value) {
    final state = resolveWishlistAnchorSelectionState(
      anchorType: value,
      editions: widget.item.editions,
      selectedEditionId: _selectedWishlistEditionId,
      selectedVariantId: _selectedWishlistVariantId,
      editionTitle: widget.item.editionTitle,
      variantName: widget.item.variant,
      availableBundleReleaseIds: [
        for (final release in widget.availableBundleReleases) release.id,
      ],
    );
    setState(() {
      _selectedWishlistAnchorType = state.anchorType;
      _selectedWishlistEditionId = state.selectedEditionId;
      _selectedWishlistVariantId = state.selectedVariantId;
      _selectedWishlistBundleReleaseId = state.selectedBundleReleaseId;
    });
  }
}
