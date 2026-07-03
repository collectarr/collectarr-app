import 'dart:async';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/anchor_selection_helpers.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_list_fields.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_value_tabs.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scaffold.dart';
export 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_edit_image_sections.dart';
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
import 'package:url_launcher/url_launcher.dart';

part 'library_edit_dialog_anchor_widgets.dart';
part 'library_edit_dialog_video_models.dart';
part 'library_edit_dialog_video_tabs.dart';
part '../kinds/comic/library_edit_dialog_comic_tabs.dart';
part 'library_edit_dialog_comic_models.dart';

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
  late final LibraryEditDraft _draft;

  late final TabController _tabController;

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
  TextEditingController get _runtimeController => _draft.runtimeController;
  TextEditingController get _audienceRatingController =>
      _draft.audienceRatingController;
  TextEditingController get _countryController => _draft.countryController;
  TextEditingController get _languageController => _draft.languageController;
  TextEditingController get _ageRatingController => _draft.ageRatingController;
  TextEditingController get _genresEditController =>
      _draft.genresEditController;
  TextEditingController get _titleExtensionController =>
      _draft.titleExtensionController;
  TextEditingController get _crossoverController => _draft.crossoverController;
  TextEditingController get _storyArcsController => _draft.storyArcsController;
  TextEditingController get _seriesTitleController =>
      _draft.seriesTitleController;
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
  TextEditingController get _seasonNumberController =>
      _draft.seasonNumberController;
  TextEditingController get _episodeNumberController =>
      _draft.episodeNumberController;
  TextEditingController get _trackingNotesController =>
      _draft.trackingNotesController;
  TextEditingController get _tagsController => _draft.tagsController;
  List<String> get _tagOptions => _draft.tagOptions;
  set _tagOptions(List<String> value) => _draft.tagOptions = value;
  List<String> _publisherOptions = const [];
  List<String> _imprintOptions = const [];
  List<String> _seriesGroupOptions = const [];
  List<String> _physicalFormatOptions = const [];
  List<String> _ownerOptions = const [];
  List<String> _countryOptions = const [];
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
  final List<EditableVideoCredit> _videoCastCredits = [];
  final List<EditableVideoCredit> _videoCrewCredits = [];
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
  TextEditingController get _audioTracksController =>
      _draft.audioTracksController;
  TextEditingController get _subtitlesController => _draft.subtitlesController;
  TextEditingController get _layersController => _draft.layersController;
  TextEditingController get _colorController => _draft.colorController;
  TextEditingController get _nrDiscsController => _draft.nrDiscsController;

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

  bool get _hasTrackingContext => _isOwned || widget.trackingEntry != null;

  bool get _isTrackingOnly => !_isOwned && widget.trackingEntry != null;

  bool get _hasWishlistContext => widget.wishlistItem != null;

  bool get _isVideoKind {
    return widget.item.mediaKind.isVideoLibraryKind;
  }

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
        _seasonNumberController.text.trim().isNotEmpty ||
        _episodeNumberController.text.trim().isNotEmpty;
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
    _initializeKindSpecificEditors();

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
    for (final credit in _videoCastCredits) {
      credit.dispose();
    }
    for (final credit in _videoCrewCredits) {
      credit.dispose();
    }
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
    _gamePlatformOptions = _mergePickListOptions(
      _splitPickList(_gamePlatformsController.text),
      widget.item.game?.platforms ?? const <String>[],
      const <String>[
        'PlayStation 5',
        'PlayStation 4',
        'Xbox Series X|S',
        'Xbox One',
        'Nintendo Switch',
        'PC',
      ],
    );
  }

  void _initializeComicEditors() {
    _initializeComicEditorsForState();
  }

  void _initializeVideoEditors() {
    _initializeVideoEditorsForState();
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
      onSave: _submit,
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
      case 'value':
        return _valueTabForKind();
      case 'personal':
        return _personalTabForKind();
      case 'read_history':
        return _readHistoryTab();
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
        return _LibraryEditRendererVideoTabs(this)._editionTab();
      case 'specs':
        return _LibraryEditRendererVideoTabs(this)._specsTab();
      case 'cast':
        return _LibraryEditRendererVideoTabs(this)._castTab();
      case 'crew':
        return _LibraryEditRendererVideoTabs(this)._crewTab();
      case 'creators':
        return _comicCreatorsTab();
      case 'characters':
        return _comicCharactersTab();
      case 'discs':
        return _LibraryEditRendererVideoTabs(this)._discsTab();
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

  Widget _linksTabForKind() {
    if (_isComicKind) {
      return _comicLinksTab();
    }
    return _LibraryEditRendererVideoTabs(this)._linksTab();
  }

  Widget _mediaTab() {
    if (_isVideoKind) {
      return _LibraryEditRendererVideoTabs(this)._videoMediaTab();
    }
    return _genericMediaTab();
  }

  Widget _genericMediaTab() {
    return EditTabShell(
      children: [
        _buildMediaSection(),
        if (_showsReleaseSection) _buildReleaseDetailsSection(),
      ],
    );
  }

  bool get _hasMediaTab => _tabSpecs.any((t) => t.id == 'media');
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
          _buildMediaSection(),
          if (_showsReleaseSection) _buildReleaseDetailsSection(),
        ],
        if (_hasTrackingContext)
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
                    _field(
                        controller: _conditionController, label: 'Condition'),
                    _field(controller: _gradeController, label: 'Grade'),
                  ],
                  if (!_isOwned) ...[
                    _trackingEditionSelectionField(),
                    _trackingVariantSelectionField(),
                  ],
                ]),
              ],
            ),
          ),
        if (editPresentation.showsOwnershipReferenceSection && !_hasEditionTab)
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
        if (editPresentation.showsOwnedGradingSection) ...[
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
          if (_isGameKind) ...[
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
              _field(
                controller: _audienceRatingController,
                label: 'Audience rating',
              ),
              TagPickListField(
                controller: _genresEditController,
                options: _gameGenreOptions,
                label: 'Genre',
                hint: 'Comma-separated genres',
              ),
            ]),
          ],
          const SizedBox(height: 10),
          _responsiveFields([
            _field(
              controller: _releaseDateController,
              label: 'Release date',
              hint: 'YYYY-MM-DD',
              validator: optionalDateValidator,
            ),
            _field(
              controller: _releaseYearController,
              label: 'Release year',
              validator: optionalIntValidator,
            ),
          ]),
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
          _responsiveFields([
            _field(
                controller: _editionTitleController,
                label: releaseFields.editionTitleLabel),
            _field(
                controller: _variantController,
                label: releaseFields.variantLabel),
            _field(
                controller: _barcodeController,
                label: releaseFields.barcodeLabel),
          ]),
          if (releaseFields.showPhysicalFormat &&
              (_effectivePhysicalFormats.isNotEmpty ||
                  _physicalFormatOptions.isNotEmpty ||
                  _physicalFormatLabelController.text.trim().isNotEmpty)) ...[
            const SizedBox(height: 10),
            _physicalFormatField(label: 'Physical format'),
          ],
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
      onPickPurchaseDate: _pickPurchaseDate,
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
      soldAt: _soldAt,
      onSoldChanged: (value) {
        setState(() {
          _soldAt = value ? DateTime.now() : null;
        });
      },
      onPickSoldDate: _pickSoldDate,
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
    if (_isVideoKind) {
      return _LibraryEditRendererVideoTabs(this)._videoPersonalTab();
    }
    return EditTabShell(
      children: [
        _personalTrackingSection(),
        if (_showsEpisodeTrackingFields) _videoEpisodeSections(),
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
                seasonNumberController: _seasonNumberController,
                episodeNumberController: _episodeNumberController,
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
              _field(
                controller: _ownerLabelController,
                label: 'Owner',
                hint: 'Name of the owner',
              ),
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
          itemId: widget.item.id,
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
            _field(
              controller: _wishlistCurrencyController,
              label: 'Currency',
            ),
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
              _field(controller: _conditionController, label: 'Condition'),
              _field(controller: _gradeController, label: 'Grade'),
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
            _field(controller: _currencyController, label: 'Currency'),
          ]),
          const SizedBox(height: 10),
          _responsiveFields([
            _field(
              controller: _purchaseDateController,
              label: 'Purchase date',
              hint: 'YYYY-MM-DD',
              validator: optionalDateValidator,
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return;
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Widget _responsiveFields(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 620;
        if (!twoColumns) {
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
              Expanded(child: children[index]),
            ],
          ],
        );
      },
    );
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
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hint),
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

  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() => _availableLocations = locations);
  }

  Future<void> _loadCatalogVocabularyOptions() async {
    final db = ref.read(localDatabaseProvider);
    final seriesRegistry = SeriesRegistryRepository(db);
    final results = await Future.wait<dynamic>([
      loadSingleValuePickListOptions(
        db,
        listName: kPublisherPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _publisherController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kImprintPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _imprintController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kSeriesGroupPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _seriesGroupController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kPhysicalFormatPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        builtInValues: [
          for (final format in _effectivePhysicalFormats) format.label,
        ],
        selectedValue: _physicalFormatLabelController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kCountryPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _countryController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kCrossoverPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _crossoverController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kStoryArcPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _storyArcsController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kPageQualityPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        builtInValues: const [
          'White',
          'Off-White to White',
          'Cream to Off-White',
          'Brittle',
        ],
        selectedValue: _pageQualityController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kKeyCategoryPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        builtInValues: const [
          'First appearance',
          'First issue',
          'Origin',
          'Death',
          'Cameo',
          'Classic cover',
        ],
        selectedValue: _keyCategoryController.text,
      ),
      db.customSelect(
        '''
SELECT DISTINCT owner_label
FROM owned_items_cache
WHERE owner_label IS NOT NULL
  AND TRIM(owner_label) <> ''
ORDER BY owner_label COLLATE NOCASE
''',
      ).get(),
      seriesRegistry.searchEntries(
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedTitle: _titleController.text,
        selectedSeriesId: _selectedSeriesId,
      ),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _publisherOptions = List<String>.from(results[0] as List<String>);
      _imprintOptions = List<String>.from(results[1] as List<String>);
      _seriesGroupOptions = List<String>.from(results[2] as List<String>);
      _physicalFormatOptions = List<String>.from(results[3] as List<String>);
      _countryOptions = List<String>.from(results[4] as List<String>);
      _crossoverOptions = List<String>.from(results[5] as List<String>);
      _storyArcOptions = List<String>.from(results[6] as List<String>);
      _pageQualityOptions = List<String>.from(results[7] as List<String>);
      _keyCategoryOptions = List<String>.from(results[8] as List<String>);
      _ownerOptions = [
        for (final row in (results[9] as List<QueryRow>))
          row.read<String>('owner_label'),
      ];
      _seriesEntries = List<SeriesRegistryEntry>.from(
        results[10] as List<SeriesRegistryEntry>,
      );
    });
  }

  Future<void> _loadTagOptions() async {
    final tagOptions = await loadTagPickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTags: splitPickListValues(_tagsController.text),
    );
    if (!mounted) {
      return;
    }
    setState(() => _tagOptions = tagOptions);
  }

  Future<void> _manageSingleValuePickList({
    required String listName,
    required String label,
    List<String> builtInValues = const [],
  }) async {
    await showPickListEditorDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      listName: listName,
      label: label,
      mediaKind: widget.type.workspace.kind.apiValue,
      builtInValues: builtInValues,
    );
    if (!mounted) {
      return;
    }
    await _loadCatalogVocabularyOptions();
  }

  Future<void> _openSeriesPicker() async {
    final selected = await showSeriesPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTitle: _titleController.text,
      selectedSeriesId: _selectedSeriesId,
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _selectedSeriesId = selected.coreSeriesId;
      _titleController.value = TextEditingValue(
        text: selected.title,
        selection: TextSelection.collapsed(offset: selected.title.length),
      );
    });
    await _loadCatalogVocabularyOptions();
  }

  Widget _seriesField() {
    return SingleValuePickField(
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

  Widget _publisherField({String label = 'Publisher'}) {
    return SingleValuePickField(
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
    return SingleValuePickField(
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
    return SingleValuePickField(
      controller: _seriesGroupController,
      options: _seriesGroupOptions,
      label: label,
      onManage: () => _manageSingleValuePickList(
        listName: kSeriesGroupPickListName,
        label: label,
      ),
    );
  }

  Widget _physicalFormatField({String label = 'Format'}) {
    return SingleValuePickField(
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

  Widget _countryPickField({String label = 'Country'}) {
    return SingleValuePickField(
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
    return SingleValuePickField(
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
    return SingleValuePickField(
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
    return SingleValuePickField(
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
    return SingleValuePickField(
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

  Widget _ownerPickField({String label = 'Owner'}) {
    return SingleValuePickField(
      controller: _ownerLabelController,
      options: _ownerOptions,
      label: label,
      showPickerListAction: true,
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

  Future<void> _pickPurchaseDate() async {
    final picked = await showLibraryDateEntryDialog(
      context,
      label: 'Purchase date',
      initialDate: parseDate(_purchaseDateController.text),
    );
    if (picked != null && mounted) {
      setState(() {
        _purchaseDateController.text = formatDate(picked);
      });
    }
  }

  Future<void> _pickSoldDate() async {
    final picked = await showLibraryDateEntryDialog(
      context,
      label: 'Sold date',
      initialDate: _soldAt,
    );
    if (picked != null && mounted) {
      setState(() => _soldAt = picked);
    }
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    var selection = _draft.buildSelection();
    selection = _applyVideoSelectionEdits(selection);
    selection = _applyComicSelectionEdits(selection);
    selection = _applyGameSelection(selection);
    selection = _normalizeSelectionScope(selection);
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
