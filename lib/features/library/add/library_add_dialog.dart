import 'dart:async';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/add/services/library_add_queue_flow.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/services/library_provider_action_service.dart';
import 'package:collectarr_app/features/library/add/models/library_add_content_scope.dart';
import 'package:collectarr_app/features/library/add/services/library_add_search_operations.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
export 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/services/provider_add_result_merge.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_add_registry.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/series/series_registry_dialog.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'controllers/library_add_comparisons.dart';
import 'controllers/library_add_controller.dart';
import 'controllers/library_add_dialog_requests.dart';
import 'controllers/library_add_manual_draft.dart';
import 'controllers/library_add_preview_controller.dart';
import 'controllers/library_add_search_controller.dart';
import 'controllers/library_add_selection_controller.dart';
import 'panes/library_add_bottom_bar.dart';
import 'panes/library_add_manual_pane.dart';
import 'panes/library_add_mode_bar.dart';
import 'panes/library_add_preview_pane.dart';
import 'panes/library_add_search_pane.dart';
import 'panes/library_add_search_unified.dart';
import 'shell/library_add_shell.dart';

// Re-export request/builder types so callers that import library_add_dialog.dart
// continue to see LibraryAddManualPaneRequest, LibraryAddBottomBarRequest, etc.
export 'controllers/library_add_dialog_requests.dart';
// Standalone classes available for external consumers.
export 'controllers/library_add_kind_adapter.dart';
export 'controllers/library_add_manual_draft.dart';
export 'panes/library_add_preview_pane.dart';

String buildPreviewCatalogItemId({
  required String kind,
  required String provider,
  required String providerItemId,
}) {
  final previewKey = '$kind:$provider:$providerItemId';
  return 'preview-$kind-${const Uuid().v5(Namespace.url.value, previewKey)}';
}

/// Default manual pane builder: delegates to the generic tabbed manual UI.
/// Registered by kinds that want the standard manual-add interface.
Widget buildDefaultManualPane(
    BuildContext context, LibraryAddManualPaneRequest request) {
  return LibraryAddManualPane(request: request);
}

class LibraryAddDialog extends ConsumerStatefulWidget {
  const LibraryAddDialog({
    super.key,
    required this.type,
    this.accent,
    this.initialQuery,
    this.initialBarcode,
    this.autoLookupInitialBarcode = true,
    this.coverScanService = const LocalLibraryCoverScanService(),
    this.manualPaneBuilder,
    this.previewPaneBuilder,
    this.headerBuilder,
    this.modeBarBuilder,
    this.searchPaneBuilder,
    this.bottomBarBuilder,
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
  });

  final LibraryTypeConfig type;
  final Color? accent;
  final String? initialQuery;
  final String? initialBarcode;
  final bool autoLookupInitialBarcode;
  final LibraryCoverScanService coverScanService;
  final LibraryAddManualPaneBuilder? manualPaneBuilder;
  final LibraryAddPreviewPaneBuilder? previewPaneBuilder;
  final LibraryAddHeaderBuilder? headerBuilder;
  final LibraryAddModeBarBuilder? modeBarBuilder;
  final LibraryAddSearchPaneBuilder? searchPaneBuilder;
  final LibraryAddBottomBarBuilder? bottomBarBuilder;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;

  @override
  ConsumerState<LibraryAddDialog> createState() => LibraryAddDialogState();
}

class LibraryAddDialogState extends ConsumerState<LibraryAddDialog> {
  void _rebuild([VoidCallback? fn]) {
    // ignore: invalid_use_of_protected_member
    setState(fn ?? () {});
  }

  late final LibraryAddManualDraft _manualDraft;
  late final LibraryAddSearchController _searchState;
  late final LibraryAddSelectionController _selectionState;
  late final LibraryAddPreviewController _previewState;
  late final LibraryAddController _addController;
  final _uuid = const Uuid();

  bool _isAdding = false;
  LibraryAddDialogMode _mode = LibraryAddDialogMode.search;
  LibraryAddTarget _addTarget = LibraryAddTarget.owned;
  String? _physicalFormatId;
  String _defaultCondition = 'Near Mint';
  String _defaultGrade = 'Ungraded';
  DateTime? _defaultPurchaseDate;
  String? _defaultReadStatus;
  String? _defaultTags;
  List<StorageLocation> _availableLocations = const [];
  List<String> _conditionOptions = const [];
  List<String> _gradeOptions = const [];
  List<String> _tagOptions = const [];
  String? _defaultLocationId;
  double _resultsPaneWidth = 480;
  static const _providerSearchDebounce = Duration(milliseconds: 450);
  static const _coreSearchTimeout = Duration(seconds: 35);
  static const _minResultsPaneWidth = 280.0;
  static const _maxResultsPaneWidth = 860.0;
  static const _minPreviewPaneWidth = 360.0;
  double? _dialogWidth;
  double? _dialogHeight;
  static const _defaultDialogWidth = 1320.0;
  static const _defaultDialogHeight = 860.0;
  static const _minDialogWidth = 760.0;
  static const _maxDialogWidth = 1800.0;
  static const _minDialogHeight = 560.0;
  static const _maxDialogHeight = 1200.0;
  static const _autocompleteDebounce = Duration(milliseconds: 350);
  static const _autocompleteLimit = 8;
  late final LibraryProviderActionService _providerActionService;

  TextEditingController get _queryController => _searchState.queryController;
  TextEditingController get _barcodeController =>
      _searchState.barcodeController;
  TextEditingController get _searchSeriesController =>
      _searchState.searchSeriesController;
  TextEditingController get _searchNumberController =>
      _searchState.searchNumberController;
  TextEditingController get _searchPublisherController =>
      _searchState.searchPublisherController;
  TextEditingController get _searchYearController =>
      _searchState.searchYearController;
  bool get _showAdvancedSearch => _searchState.showAdvancedSearch;
  set _showAdvancedSearch(bool value) =>
      _searchState.showAdvancedSearch = value;
  List<LibraryMetadataItem> get _results => _searchState.results;
  set _results(List<LibraryMetadataItem> value) => _searchState.results = value;
  List<ProviderCandidate> get _providerResults => _searchState.providerResults;
  set _providerResults(List<ProviderCandidate> value) =>
      _searchState.providerResults = value;
  String? get _error => _searchState.error;
  set _error(String? value) => _searchState.error = value;
  bool get _searchedProvider => _searchState.searchedProvider;
  set _searchedProvider(bool value) => _searchState.searchedProvider = value;
  bool get _isSearching => _searchState.isSearching;
  set _isSearching(bool value) => _searchState.isSearching = value;
  bool get _isSearchingProvider => _searchState.isSearchingProvider;
  set _isSearchingProvider(bool value) =>
      _searchState.isSearchingProvider = value;
  bool get _isScanningCover => _searchState.isScanningCover;
  set _isScanningCover(bool value) => _searchState.isScanningCover = value;
  DateTime? get _lastProviderSearchAt => _searchState.lastProviderSearchAt;
  set _lastProviderSearchAt(DateTime? value) =>
      _searchState.lastProviderSearchAt = value;
  String? get _lastProviderSearchSignature =>
      _searchState.lastProviderSearchSignature;
  set _lastProviderSearchSignature(String? value) =>
      _searchState.lastProviderSearchSignature = value;
  int get _coreSearchGeneration => _searchState.coreSearchGeneration;
  set _coreSearchGeneration(int value) =>
      _searchState.coreSearchGeneration = value;
  int get _providerSearchGeneration => _searchState.providerSearchGeneration;
  set _providerSearchGeneration(int value) =>
      _searchState.providerSearchGeneration = value;
  Timer? get _autocompleteTimer => _searchState.autocompleteTimer;
  set _autocompleteTimer(Timer? value) =>
      _searchState.autocompleteTimer = value;
  List<LibraryMetadataItem> get _suggestions => _searchState.suggestions;
  set _suggestions(List<LibraryMetadataItem> value) =>
      _searchState.suggestions = value;
  bool get _showSuggestions => _searchState.showSuggestions;
  set _showSuggestions(bool value) => _searchState.showSuggestions = value;
  Set<String> get _videoKindFilters => _searchState.videoKindFilters;

  TextEditingController get _titleController => _manualDraft.titleController;
  TextEditingController get _numberController => _manualDraft.numberController;
  TextEditingController get _publisherController =>
      _manualDraft.publisherController;
  TextEditingController get _yearController => _manualDraft.yearController;
  TextEditingController get _variantController =>
      _manualDraft.variantController;
  TextEditingController get _physicalFormatLabelController =>
      _manualDraft.physicalFormatLabelController;
  TextEditingController get _coverController => _manualDraft.coverController;
  TextEditingController get _backCoverController =>
      _manualDraft.backCoverController;
  TextEditingController get _creatorsController =>
      _manualDraft.creatorsController;
  TextEditingController get _charactersController =>
      _manualDraft.charactersController;
  TextEditingController get _linksController => _manualDraft.linksController;
  TextEditingController get _editionTitleController =>
      _manualDraft.editionTitleController;
  TextEditingController get _releaseDateController =>
      _manualDraft.releaseDateController;
  TextEditingController get _pageCountController =>
      _manualDraft.pageCountController;
  TextEditingController get _imprintController =>
      _manualDraft.imprintController;
  TextEditingController get _seriesGroupController =>
      _manualDraft.seriesGroupController;
  TextEditingController get _countryController =>
      _manualDraft.countryController;
  TextEditingController get _languageController =>
      _manualDraft.languageController;
  TextEditingController get _ageRatingController =>
      _manualDraft.ageRatingController;
  TextEditingController get _genresEditController =>
      _manualDraft.genresEditController;
  TextEditingController get _synopsisController =>
      _manualDraft.synopsisController;
  TextEditingController get _tagsController => _manualDraft.tagsController;
  TextEditingController get _personalNotesController =>
      _manualDraft.personalNotesController;
  TextEditingController get _rawOrSlabbedController =>
      _manualDraft.rawOrSlabbedController;
  TextEditingController get _gradingCompanyController =>
      _manualDraft.gradingCompanyController;
  TextEditingController get _graderNotesController =>
      _manualDraft.graderNotesController;
  TextEditingController get _signedByController =>
      _manualDraft.signedByController;
  TextEditingController get _labelTypeController =>
      _manualDraft.labelTypeController;
  TextEditingController get _certificationNumberController =>
      _manualDraft.certificationNumberController;
  TextEditingController get _coverPriceController =>
      _manualDraft.coverPriceController;
  TextEditingController get _priceController => _manualDraft.priceController;
  TextEditingController get _purchaseDateController =>
      _manualDraft.purchaseDateController;
  TextEditingController get _purchaseStoreController =>
      _manualDraft.purchaseStoreController;
  TextEditingController get _sellPriceController =>
      _manualDraft.sellPriceController;
  TextEditingController get _soldDateController =>
      _manualDraft.soldDateController;
  TextEditingController get _ownerLabelController =>
      _manualDraft.ownerLabelController;
  Map<String, dynamic> get _manualKindSpecific => _manualDraft.kindSpecific;
  set _manualKindSpecific(Map<String, dynamic> value) =>
      _manualDraft.kindSpecific = value;
  DateTime? get _soldAt => _manualDraft.soldAt;
  List<String> get _publisherOptions => _manualDraft.publisherOptions;
  set _publisherOptions(List<String> value) =>
      _manualDraft.publisherOptions = value;
  List<String> get _imprintOptions => _manualDraft.imprintOptions;
  set _imprintOptions(List<String> value) =>
      _manualDraft.imprintOptions = value;
  List<String> get _seriesGroupOptions => _manualDraft.seriesGroupOptions;
  set _seriesGroupOptions(List<String> value) =>
      _manualDraft.seriesGroupOptions = value;
  List<String> get _physicalFormatOptions => _manualDraft.physicalFormatOptions;
  set _physicalFormatOptions(List<String> value) =>
      _manualDraft.physicalFormatOptions = value;
  List<SeriesRegistryEntry> get _manualSeriesEntries =>
      _manualDraft.seriesEntries;
  set _manualSeriesEntries(List<SeriesRegistryEntry> value) =>
      _manualDraft.seriesEntries = value;
  Map<String, String?> get _manualCustomFieldValues =>
      _manualDraft.customFieldValues;
  set _manualCustomFieldValues(Map<String, String?> value) =>
      _manualDraft.customFieldValues = value;
  List<ItemImage> get _manualItemImages => _manualDraft.itemImages;
  set _manualItemImages(List<ItemImage> value) =>
      _manualDraft.itemImages = value;
  LibraryCoverScanResult? get _coverScanPrefill =>
      _manualDraft.coverScanPrefill;
  set _coverScanPrefill(LibraryCoverScanResult? value) =>
      _manualDraft.coverScanPrefill = value;
  String? get _selectedManualSeriesId => _manualDraft.selectedSeriesId;
  set _selectedManualSeriesId(String? value) =>
      _manualDraft.selectedSeriesId = value;

  Set<String> get _checkedResultIds => _selectionState.checkedResultIds;
  Set<String> get _checkedProviderIds => _selectionState.checkedProviderIds;
  LibraryAddReferenceType get _referenceType => _selectionState.referenceType;
  set _referenceType(LibraryAddReferenceType value) =>
      _selectionState.referenceType = value;
  String? get _selectedResultId => _selectionState.selectedResultId;
  set _selectedResultId(String? value) =>
      _selectionState.selectedResultId = value;
  String? get _selectedProviderCandidateId =>
      _selectionState.selectedProviderCandidateId;
  set _selectedProviderCandidateId(String? value) =>
      _selectionState.selectedProviderCandidateId = value;
  String? get _selectedBundleReleaseId =>
      _selectionState.selectedBundleReleaseId;
  set _selectedBundleReleaseId(String? value) =>
      _selectionState.selectedBundleReleaseId = value;
  String? get _selectedReferenceEditionId =>
      _selectionState.selectedReferenceEditionId;
  set _selectedReferenceEditionId(String? value) =>
      _selectionState.selectedReferenceEditionId = value;
  String? get _selectedReferenceVariantId =>
      _selectionState.selectedReferenceVariantId;
  set _selectedReferenceVariantId(String? value) =>
      _selectionState.selectedReferenceVariantId = value;
  bool get _showCoreResults => _selectionState.showCoreResults;
  set _showCoreResults(bool value) => _selectionState.showCoreResults = value;
  bool get _showProviderResults => _selectionState.showProviderResults;
  set _showProviderResults(bool value) =>
      _selectionState.showProviderResults = value;
  bool get _showMediaResults => _selectionState.showMediaResults;
  set _showMediaResults(bool value) => _selectionState.showMediaResults = value;
  bool get _showSeasonResults => _selectionState.showSeasonResults;
  set _showSeasonResults(bool value) =>
      _selectionState.showSeasonResults = value;
  bool get _showReleaseResults => _selectionState.showReleaseResults;
  set _showReleaseResults(bool value) =>
      _selectionState.showReleaseResults = value;
  bool get _hideComicOwnedResults => _selectionState.hideComicOwnedResults;
  set _hideComicOwnedResults(bool value) =>
      _selectionState.hideComicOwnedResults = value;
  bool get _hideComicVariantResults => _selectionState.hideComicVariantResults;
  set _hideComicVariantResults(bool value) =>
      _selectionState.hideComicVariantResults = value;
  bool get _compactComicIssues => _selectionState.compactComicIssues;
  set _compactComicIssues(bool value) =>
      _selectionState.compactComicIssues = value;

  Map<String, AdminProviderPreview> get _providerPreviews =>
      _previewState.providerPreviews;
  Map<String, LibraryMetadataItem> get _hydratedResults =>
      _previewState.hydratedResults;
  Map<String, List<BundleReleaseSummary>> get _bundleReleasesByItemId =>
      _previewState.bundleReleasesByItemId;
  Map<String, LibraryQueuedProviderIngest> get _queuedProviderIngests =>
      _previewState.queuedProviderIngests;
  Set<String> get _pendingHydratedResultIds =>
      _previewState.pendingHydratedResultIds;
  Set<String> get _pendingBundleReleaseItemIds =>
      _previewState.pendingBundleReleaseItemIds;
  Set<String> get _pendingBundleReleaseDetailIds =>
      _previewState.pendingBundleReleaseDetailIds;
  Set<String> get _pendingProviderPreviewIds =>
      _previewState.pendingProviderPreviewIds;
  bool get _isQueueingIngest => _previewState.isQueueingIngest;
  set _isQueueingIngest(bool value) => _previewState.isQueueingIngest = value;

  @override
  void initState() {
    super.initState();
    registerLibraryAddBuilders();
    final defaultFilters = widget.type.addChrome.defaultVideoKindFilters
        .map(_canonicalVideoSearchKind)
        .toSet();
    _manualDraft = LibraryAddManualDraft(
      customFieldValues: widget.customFieldValues,
      itemImages: widget.itemImages,
    );
    _manualDraft.syncKindSpecificFactoryValues(widget.type.workspace.kind);
    _searchState = LibraryAddSearchController(
      selectedProvider: widget.type.defaultSupportedMetadataProvider,
      initialVideoKindFilters: defaultFilters.isEmpty
          ? {
              _canonicalVideoSearchKind(widget.type.workspace.kind.apiValue),
            }
          : defaultFilters,
    );
    _selectionState = LibraryAddSelectionController();
    _previewState = LibraryAddPreviewController();
    _addController = LibraryAddController(
      search: _searchState,
      selection: _selectionState,
      preview: _previewState,
    );
    _providerActionService = const LibraryProviderActionService();
    if (_isMovieDesktopChrome) {
      _resultsPaneWidth = 720;
    }
    _conditionOptions = widget.type.conditions;
    _gradeOptions = widget.type.grades;
    _loadAvailableLocations();
    _loadPickListOptions();
    _loadPrefillDefaults();
    _searchState.setInitialInput(
      query: widget.initialQuery,
      barcode: widget.initialBarcode,
    );
    _titleController.text = _queryController.text;
    _soldDateController.text = '';
    if (_barcodeController.text.isNotEmpty && widget.autoLookupInitialBarcode) {
      _mode = LibraryAddDialogMode.barcode;
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookupBarcode());
    } else if (_barcodeController.text.isNotEmpty) {
      _mode = LibraryAddDialogMode.barcode;
    }
  }

  @override
  void didUpdateWidget(covariant LibraryAddDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type.workspace.kind != widget.type.workspace.kind) {
      _disposeManualKindSpecificControllers();
      _syncManualKindSpecificFactoryValues();
    }
  }

  @override
  void dispose() {
    _addController.search.dispose();
    _manualDraft.dispose();
    super.dispose();
  }

  void _disposeManualKindSpecificControllers() {
    _manualDraft.disposeKindSpecificFactoryValues();
  }

  void _syncManualKindSpecificFactoryValues() {
    _manualDraft.syncKindSpecificFactoryValues(widget.type.workspace.kind);
  }

  Map<String, dynamic> _kindSpecificFactoryValues() {
    return _manualDraft.kindSpecificFactoryValues;
  }

  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    _rebuild(() {
      _availableLocations = locations;
    });
  }

  Future<void> _loadPrefillDefaults() async {
    final defaults = await PrefillDefaults.load();
    if (!mounted) {
      return;
    }
    _rebuild(() {
      if (defaults.condition?.trim().isNotEmpty == true) {
        _defaultCondition = defaults.condition!.trim();
      }
      if (defaults.grade?.trim().isNotEmpty == true) {
        _defaultGrade = defaults.grade!.trim();
      }
      _defaultReadStatus = defaults.readStatus;
      _defaultTags = defaults.tags;
      _defaultLocationId = defaults.locationId;
    });
    await _loadPickListOptions();
  }

  Future<void> _loadPickListOptions() async {
    final options = await loadConditionGradePickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      builtInConditions: widget.type.conditions,
      builtInGrades: widget.type.grades,
      selectedCondition: _defaultCondition,
      selectedGrade: _defaultGrade,
    );
    final tagOptions = await loadTagPickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTags: splitPickListValues(_defaultTags),
    );
    final db = ref.read(localDatabaseProvider);
    final vocabularyResults = await Future.wait<dynamic>([
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
          for (final format in _currentPhysicalFormats()) format.label,
        ],
        selectedValue: _physicalFormatLabelController.text,
      ),
      SeriesRegistryRepository(db).searchEntries(
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedTitle: _titleController.text,
        selectedSeriesId: _selectedManualSeriesId,
      ),
    ]);
    if (!mounted) {
      return;
    }
    _rebuild(() {
      _conditionOptions = options.conditions;
      _gradeOptions = options.grades;
      _tagOptions = tagOptions;
      _publisherOptions =
          List<String>.from(vocabularyResults[0] as List<String>);
      _imprintOptions = List<String>.from(vocabularyResults[1] as List<String>);
      _seriesGroupOptions =
          List<String>.from(vocabularyResults[2] as List<String>);
      _physicalFormatOptions =
          List<String>.from(vocabularyResults[3] as List<String>);
      _manualSeriesEntries = List<SeriesRegistryEntry>.from(
        vocabularyResults[4] as List<SeriesRegistryEntry>,
      );
    });
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
    await _loadPickListOptions();
  }

  Future<void> _openManualSeriesPicker() async {
    final selected = await showSeriesPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTitle: _titleController.text,
      selectedSeriesId: _selectedManualSeriesId,
    );
    if (!mounted || selected == null) {
      return;
    }
    _rebuild(() {
      _selectedManualSeriesId = selected.coreSeriesId;
      _titleController.value = TextEditingValue(
        text: selected.title,
        selection: TextSelection.collapsed(offset: selected.title.length),
      );
    });
    await _loadPickListOptions();
  }

  void _setManualSeries(String? value) {
    final normalized = _emptyToNull(value ?? '');
    final match = _manualSeriesEntries.cast<SeriesRegistryEntry?>().firstWhere(
          (entry) =>
              entry != null &&
              entry.title.trim().toLowerCase() ==
                  (normalized?.toLowerCase() ?? ''),
          orElse: () => null,
        );
    _rebuild(() {
      _selectedManualSeriesId = match?.coreSeriesId;
    });
  }

  List<String> get _manualPhysicalFormatOptions {
    return mergePickListValues(
      builtInValues: [
        for (final format in _currentPhysicalFormats()) format.label
      ],
      customValues: _physicalFormatOptions,
      selectedValues: [_physicalFormatLabelController.text],
    );
  }

  Future<void> _showDefaultTagsEditor() async {
    final controller = TextEditingController(text: _defaultTags ?? '');
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AccentAlertDialog(
          title: const Text('Owned default tags'),
          content: SizedBox(
            width: 440,
            child: TagPickListField(
              controller: controller,
              options: _tagOptions,
              label: 'Tags',
              hint: 'Comma-separated tags',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                joinPickListValues(splitPickListValues(controller.text)) ?? '',
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      );
      if (!mounted || result == null) {
        return;
      }
      _rebuild(() {
        _defaultTags = result.isEmpty ? null : result;
      });
    } finally {
      controller.dispose();
    }
  }

  String? get _defaultLocationLabel =>
      locationPathForId(_availableLocations, _defaultLocationId);

  Future<void> _pickDefaultLocation() async {
    final result = await showLocationPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      currentLocationId: _defaultLocationId,
    );
    if (result == null) {
      return;
    }
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    _rebuild(() {
      _defaultLocationId = result.isEmpty ? null : result;
      _availableLocations = locations;
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final physicalFormats = physicalMediaFormatsForKind(
      catalog,
      widget.type.workspace.kind,
    );
    final selectedProvider = _activeProvider;
    final isBusy = _isSearching || _isSearchingProvider;
    final accent = widget.accent ??
        LibraryAccentScope.accentOf(context, fallback: kAppAccent);
    final selectedResult = _selectedResult;
    final selectedCandidate = _selectedProviderCandidate;
    final selectedProviderLabel = selectedCandidate == null
        ? widget.type.metadataProviderLabel(selectedProvider)
        : widget.type.metadataProviderLabel(selectedCandidate.provider);
    final selectedQueuedIngest = selectedCandidate == null
        ? null
        : _queuedProviderIngests[selectedCandidate.localCatalogId];
    final isFetchingSelectedResultPreview = selectedResult != null &&
        _pendingHydratedResultIds.contains(selectedResult.id) &&
        !_hydratedResults.containsKey(selectedResult.id);
    final isFetchingSelectedCandidatePreview = selectedCandidate != null &&
        _pendingProviderPreviewIds.contains(selectedCandidate.localCatalogId) &&
        !_providerPreviews.containsKey(selectedCandidate.localCatalogId);
    final ownedByCatalogId = ref.watch(collectionByCatalogItemProvider);
    final headerRequest = LibraryAddHeaderRequest(
      type: widget.type,
      accent: accent,
      isMovieDesktopChrome: _isMovieDesktopChrome,
      onClose: () => Navigator.of(context).pop(),
    );
    final modeBarRequest = LibraryAddModeBarRequest(
      type: widget.type,
      accent: accent,
      isMovieDesktopChrome: _isMovieDesktopChrome,
      mode: _mode,
      queryController: _queryController,
      barcodeController: _barcodeController,
      isSearching: _isSearching,
      isSearchingProvider: _isSearchingProvider,
      onModeChanged: (mode) {
        if (mode == LibraryAddDialogMode.manual) {
          setState(() => _mode = LibraryAddDialogMode.manual);
          return;
        }
        setState(() => _mode = mode);
      },
      onSearch: () {
        _dismissSuggestions();
        _search();
      },
      onQueryChanged: _onQueryChanged,
      suggestions: _suggestions,
      showSuggestions: _showSuggestions,
      onSelectSuggestion: _selectSuggestion,
      onDismissSuggestions: _dismissSuggestions,
      canScanCover: widget.type.capabilities.canScanCover,
      isScanningCover: _isScanningCover,
      onScanCover: _scanCover,
      onLookupBarcode: _lookupBarcode,
      onManual: () => setState(() => _mode = LibraryAddDialogMode.manual),
      showAdvanced: _showAdvancedSearch,
      onToggleAdvanced: () =>
          setState(() => _showAdvancedSearch = !_showAdvancedSearch),
      seriesController: _searchSeriesController,
      numberController: _searchNumberController,
      publisherController: _searchPublisherController,
      yearController: _searchYearController,
      videoKindFilters: _showsVideoKindFilters ? _videoKindFilters : null,
      onVideoKindFilterChanged: _showsVideoKindFilters
          ? (kind, checked) {
              final canonicalKind = _canonicalVideoSearchKind(kind);
              setState(() {
                if (checked) {
                  _videoKindFilters.add(canonicalKind);
                } else {
                  _videoKindFilters.remove(canonicalKind);
                }
              });
            }
          : null,
    );
    return LibraryAddShell(
      accent: accent,
      width: _dialogWidth ?? _defaultDialogWidth,
      height: _dialogHeight ?? _defaultDialogHeight,
      minWidth: _minDialogWidth,
      maxWidth: _maxDialogWidth,
      minHeight: _minDialogHeight,
      maxHeight: _maxDialogHeight,
      onResizeWidth: (delta) => setState(() {
        _dialogWidth = ((_dialogWidth ?? _defaultDialogWidth) + delta)
            .clamp(_minDialogWidth, _maxDialogWidth);
      }),
      onResizeHeight: (delta) => setState(() {
        _dialogHeight = ((_dialogHeight ?? _defaultDialogHeight) + delta)
            .clamp(_minDialogHeight, _maxDialogHeight);
      }),
      header: const SizedBox.shrink(),
      body: Column(
        children: [
          widget.headerBuilder?.call(context, headerRequest) ??
              LibraryAddRegistry.headerBuilderFor(widget.type.workspace.kind)
                  ?.call(context, headerRequest) ??
              AccentDialogHeader(
                title: 'Add ${headerRequest.type.pluralLabel}',
                accent: headerRequest.accent,
                icon: headerRequest.type.workspace.icon,
                onClose: () => Navigator.of(context).pop(),
              ),
          widget.modeBarBuilder?.call(context, modeBarRequest) ??
              LibraryAddRegistry.modeBarBuilderFor(widget.type.workspace.kind)
                  ?.call(context, modeBarRequest) ??
              LibraryAddModeBar(
                type: modeBarRequest.type,
                accent: modeBarRequest.accent,
                isMovieDesktopChrome: modeBarRequest.isMovieDesktopChrome,
                mode: modeBarRequest.mode,
                queryController: modeBarRequest.queryController,
                barcodeController: modeBarRequest.barcodeController,
                isSearching: modeBarRequest.isSearching,
                isSearchingProvider: modeBarRequest.isSearchingProvider,
                onModeChanged: modeBarRequest.onModeChanged,
                onSearch: modeBarRequest.onSearch,
                onQueryChanged: modeBarRequest.onQueryChanged,
                suggestions: modeBarRequest.suggestions,
                showSuggestions: modeBarRequest.showSuggestions,
                onSelectSuggestion: modeBarRequest.onSelectSuggestion,
                onDismissSuggestions: modeBarRequest.onDismissSuggestions,
                canScanCover: modeBarRequest.canScanCover,
                isScanningCover: modeBarRequest.isScanningCover,
                onScanCover: modeBarRequest.onScanCover,
                onLookupBarcode: modeBarRequest.onLookupBarcode,
                onManual: modeBarRequest.onManual,
                showAdvanced: modeBarRequest.showAdvanced,
                onToggleAdvanced: modeBarRequest.onToggleAdvanced,
                seriesController: modeBarRequest.seriesController,
                numberController: modeBarRequest.numberController,
                publisherController: modeBarRequest.publisherController,
                yearController: modeBarRequest.yearController,
                videoKindFilters: modeBarRequest.videoKindFilters,
                onVideoKindFilterChanged:
                    modeBarRequest.onVideoKindFilterChanged,
              ),
          if (_barcodeController.text.trim().isNotEmpty)
            LibraryAddBarcodePrefillBanner(
              type: widget.type,
              barcode: _barcodeController.text.trim(),
            ),
          if (_coverScanPrefill != null)
            LibraryCoverScanPrefillBanner(result: _coverScanPrefill!),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final visibleResults = _visibleCoreResults();
                final visibleProviderResults = _visibleProviderResults();
                final searchPaneRequest = LibraryAddSearchPaneRequest(
                  type: widget.type,
                  isBusy: isBusy,
                  isMovieDesktopChrome: _isMovieDesktopChrome,
                  error: _error,
                  accent: accent,
                  results: visibleResults,
                  providerResults: visibleProviderResults,
                  queuedProviderIngests: _queuedProviderIngests,
                  selectedProvider: selectedProvider,
                  searchedProvider: _searchedProvider,
                  selectedResultId: _selectedResultId,
                  selectedProviderCandidateId: _selectedProviderCandidateId,
                  checkedResultIds: _checkedResultIds,
                  checkedProviderIds: _checkedProviderIds,
                  ownedCatalogItemIds: ownedByCatalogId.keys.toSet(),
                  providerQueryText: _queryController.text,
                  providerSeriesText: _searchSeriesController.text,
                  providerNumberText: _searchNumberController.text,
                  providerPublisherText: _searchPublisherController.text,
                  providerYearText: _searchYearController.text,
                  isWideLayout: constraints.maxWidth >= 720,
                  showCoreResults: _showCoreResults,
                  showProviderResults: _showProviderResults,
                  showMediaResults: _showMediaResults,
                  showSeasonResults: _showSeasonResults,
                  showReleaseResults: _showReleaseResults,
                  hideComicOwnedResults: _hideComicOwnedResults,
                  hideComicVariantResults: _hideComicVariantResults,
                  compactComicIssues: _compactComicIssues,
                  onSelectResult: _selectCoreResult,
                  onSelectProviderCandidate: _selectProviderCandidate,
                  onToggleResultCheck: (id) =>
                      setState(() => _selectionState.toggleCheckedResult(id)),
                  onToggleProviderCheck: (id) => setState(
                    () => _selectionState.toggleCheckedProvider(id),
                  ),
                  onShowCoreResultsChanged: (_) {},
                  onShowProviderResultsChanged: (_) {},
                  onShowMediaResultsChanged: (_) {},
                  onShowSeasonResultsChanged: (_) {},
                  onShowReleaseResultsChanged: (_) {},
                  onHideComicOwnedResultsChanged: (value) => setState(() {
                    _hideComicOwnedResults = value;
                    _pruneSelectionsForVisibility(
                      visibleResults: _visibleCoreResults(),
                      visibleProviderResults: _visibleProviderResults(),
                    );
                  }),
                  onHideComicVariantResultsChanged: (value) => setState(() {
                    _hideComicVariantResults = value;
                    _pruneSelectionsForVisibility(
                      visibleResults: _visibleCoreResults(),
                      visibleProviderResults: _visibleProviderResults(),
                    );
                  }),
                  onCompactComicIssuesChanged: (value) =>
                      setState(() => _compactComicIssues = value),
                  onSearchCore: _search,
                );
                final searchPane = widget.searchPaneBuilder
                        ?.call(context, searchPaneRequest) ??
                    LibraryAddRegistry.searchBuilderFor(
                            widget.type.workspace.kind)
                        ?.call(context, searchPaneRequest) ??
                    LibraryAddSearchPane(
                      type: searchPaneRequest.type,
                      isBusy: searchPaneRequest.isBusy,
                      isMovieDesktopChrome:
                          searchPaneRequest.isMovieDesktopChrome,
                      error: searchPaneRequest.error,
                      accent: searchPaneRequest.accent,
                      results: searchPaneRequest.results,
                      providerResults: searchPaneRequest.providerResults,
                      queuedProviderIngests:
                          searchPaneRequest.queuedProviderIngests,
                      selectedProvider: searchPaneRequest.selectedProvider,
                      searchedProvider: searchPaneRequest.searchedProvider,
                      selectedResultId: searchPaneRequest.selectedResultId,
                      selectedProviderCandidateId:
                          searchPaneRequest.selectedProviderCandidateId,
                      checkedResultIds: searchPaneRequest.checkedResultIds,
                      checkedProviderIds: searchPaneRequest.checkedProviderIds,
                      ownedCatalogItemIds:
                          searchPaneRequest.ownedCatalogItemIds,
                      providerQueryText: searchPaneRequest.providerQueryText,
                      providerSeriesText: searchPaneRequest.providerSeriesText,
                      providerNumberText: searchPaneRequest.providerNumberText,
                      providerPublisherText:
                          searchPaneRequest.providerPublisherText,
                      providerYearText: searchPaneRequest.providerYearText,
                      isWideLayout: searchPaneRequest.isWideLayout,
                      showCoreResults: searchPaneRequest.showCoreResults,
                      showProviderResults:
                          searchPaneRequest.showProviderResults,
                      showMediaResults: searchPaneRequest.showMediaResults,
                      showSeasonResults: searchPaneRequest.showSeasonResults,
                      showReleaseResults: searchPaneRequest.showReleaseResults,
                      hideComicOwnedResults:
                          searchPaneRequest.hideComicOwnedResults,
                      hideComicVariantResults:
                          searchPaneRequest.hideComicVariantResults,
                      compactComicIssues: searchPaneRequest.compactComicIssues,
                      onSelectResult: searchPaneRequest.onSelectResult,
                      onSelectProviderCandidate:
                          searchPaneRequest.onSelectProviderCandidate,
                      onToggleResultCheck:
                          searchPaneRequest.onToggleResultCheck,
                      onToggleProviderCheck:
                          searchPaneRequest.onToggleProviderCheck,
                      onShowCoreResultsChanged:
                          searchPaneRequest.onShowCoreResultsChanged,
                      onShowProviderResultsChanged:
                          searchPaneRequest.onShowProviderResultsChanged,
                      onShowMediaResultsChanged:
                          searchPaneRequest.onShowMediaResultsChanged,
                      onShowSeasonResultsChanged:
                          searchPaneRequest.onShowSeasonResultsChanged,
                      onShowReleaseResultsChanged:
                          searchPaneRequest.onShowReleaseResultsChanged,
                      onHideComicOwnedResultsChanged:
                          searchPaneRequest.onHideComicOwnedResultsChanged,
                      onHideComicVariantResultsChanged:
                          searchPaneRequest.onHideComicVariantResultsChanged,
                      onCompactComicIssuesChanged:
                          searchPaneRequest.onCompactComicIssuesChanged,
                      onSearchCore: searchPaneRequest.onSearchCore,
                    );
                final searchPaneWithSourceToggles = (_results.isNotEmpty ||
                        _providerResults.isNotEmpty)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LibraryAddSearchSourceToggles(
                            type: widget.type,
                            showCoreResults: _showCoreResults,
                            showProviderResults: _showProviderResults,
                            onShowCoreResultsChanged: (value) => setState(() {
                              _showCoreResults = value;
                              if (!value) {
                                _selectedResultId = null;
                                _checkedResultIds.clear();
                              }
                            }),
                            onShowProviderResultsChanged: (value) =>
                                setState(() {
                              _showProviderResults = value;
                              if (!value) {
                                _selectedProviderCandidateId = null;
                                _checkedProviderIds.clear();
                              }
                            }),
                            showMediaResults: _showMediaResults,
                            showSeasonResults: _showSeasonResults,
                            showReleaseResults: _showReleaseResults,
                            onShowMediaResultsChanged: (value) => setState(() {
                              if (!value &&
                                  !_showSeasonResults &&
                                  !_showReleaseResults) {
                                return;
                              }
                              _showMediaResults = value;
                              _pruneSelectionsForVisibility(
                                visibleResults: _visibleCoreResults(),
                                visibleProviderResults:
                                    _visibleProviderResults(),
                              );
                            }),
                            onShowSeasonResultsChanged: (value) => setState(() {
                              if (!value &&
                                  !_showMediaResults &&
                                  !_showReleaseResults) {
                                return;
                              }
                              _showSeasonResults = value;
                              _pruneSelectionsForVisibility(
                                visibleResults: _visibleCoreResults(),
                                visibleProviderResults:
                                    _visibleProviderResults(),
                              );
                            }),
                            onShowReleaseResultsChanged: (value) =>
                                setState(() {
                              if (!value &&
                                  !_showMediaResults &&
                                  !_showSeasonResults) {
                                return;
                              }
                              _showReleaseResults = value;
                              _pruneSelectionsForVisibility(
                                visibleResults: _visibleCoreResults(),
                                visibleProviderResults:
                                    _visibleProviderResults(),
                              );
                            }),
                          ),
                          Expanded(child: searchPane),
                        ],
                      )
                    : searchPane;
                final previewPane = LibraryAddPreviewPane(
                  type: widget.type,
                  accent: accent,
                  isMovieDesktopChrome: _isMovieDesktopChrome,
                  previewPaneBuilder: widget.previewPaneBuilder ??
                      LibraryAddRegistry.previewBuilderFor(
                          widget.type.workspace.kind),
                  item: selectedResult,
                  candidate: selectedCandidate,
                  candidatePreview: selectedCandidate == null
                      ? null
                      : _providerPreviews[selectedCandidate.localCatalogId],
                  isFetchingPreview: isFetchingSelectedCandidatePreview ||
                      isFetchingSelectedResultPreview,
                  providerLabel: selectedProviderLabel,
                  searched: _results.isNotEmpty || _searchedProvider,
                  addTarget: _addTarget,
                  referenceType: _referenceType,
                  availableBundleReleases: selectedResult == null
                      ? const <BundleReleaseSummary>[]
                      : _bundleReleasesByItemId[selectedResult.id] ??
                          const <BundleReleaseSummary>[],
                  selectedBundleReleaseId: _selectedBundleReleaseId,
                  selectedBundleReleaseDetail: _selectedBundleReleaseDetail,
                  selectedEditionId: _selectedReferenceEditionId,
                  selectedVariantId: _selectedReferenceVariantId,
                  isLoadingBundleReleases: selectedResult != null &&
                      _pendingBundleReleaseItemIds.contains(selectedResult.id),
                  isLoadingBundleReleaseDetail:
                      _selectedBundleReleaseId != null &&
                          _pendingBundleReleaseDetailIds
                              .contains(_selectedBundleReleaseId),
                  onReferenceTypeChanged: (value) {
                    _handleReferenceTypeChanged(selectedResult, value);
                  },
                  onEditionSelected: (editionId) {
                    _handleReferenceEditionSelected(
                      _selectedResult,
                      editionId,
                    );
                  },
                  onVariantSelected: _handleReferenceVariantSelected,
                  onBundleReleaseSelected: (bundleReleaseId) {
                    _handleBundleReleaseSelected(bundleReleaseId);
                  },
                );
                final kindSpecificMap = {
                  'personalNotesController': _personalNotesController,
                  'rawOrSlabbedController': _rawOrSlabbedController,
                  'gradingCompanyController': _gradingCompanyController,
                  'graderNotesController': _graderNotesController,
                  'signedByController': _signedByController,
                  'labelTypeController': _labelTypeController,
                  'certificationNumberController':
                      _certificationNumberController,
                  'coverPriceController': _coverPriceController,
                  'purchasePriceController': _priceController,
                  'purchaseDateController': _purchaseDateController,
                  'purchaseStoreController': _purchaseStoreController,
                  'soldPriceController': _sellPriceController,
                  'soldDateController': _soldDateController,
                  'ownerLabelController': _ownerLabelController,
                  'linksController': _linksController,
                };
                // If a kind provides a factory for kind-specific values,
                // invoke it and merge its results so the kind can own
                // controllers while the dialog remains responsible for
                // disposing them.
                _manualKindSpecific = Map<String, dynamic>.from(
                  kindSpecificMap,
                )..addAll(_kindSpecificFactoryValues());

                final manualRequest = LibraryAddManualPaneRequest(
                  type: widget.type,
                  accent: accent,
                  titleController: _titleController,
                  numberController: _numberController,
                  publisherController: _publisherController,
                  yearController: _yearController,
                  barcodeController: _barcodeController,
                  variantController: _variantController,
                  physicalFormatLabelController: _physicalFormatLabelController,
                  coverController: _coverController,
                  backCoverController: _backCoverController,
                  creatorsController: _creatorsController,
                  charactersController: _charactersController,
                  physicalFormats: physicalFormats,
                  physicalFormatId: _physicalFormatId,
                  onPhysicalFormatChanged: _setPhysicalFormat,
                  onPhysicalFormatLabelChanged: _setPhysicalFormatLabel,
                  isAdding: _isAdding,
                  defaultCondition: _defaultCondition,
                  defaultGrade: _defaultGrade,
                  defaultLocationLabel: _defaultLocationLabel,
                  defaultPurchaseDate: _defaultPurchaseDate,
                  defaultTags: _defaultTags,
                  onAddOwned: () => _addManual(LibraryAddTarget.owned),
                  onAddTrack: () => _addManual(LibraryAddTarget.track),
                  onAddWishlist: () => _addManual(LibraryAddTarget.wishlist),
                  editionTitleController: _editionTitleController,
                  releaseDateController: _releaseDateController,
                  pageCountController: _pageCountController,
                  imprintController: _imprintController,
                  seriesGroupController: _seriesGroupController,
                  countryController: _countryController,
                  languageController: _languageController,
                  ageRatingController: _ageRatingController,
                  genresEditController: _genresEditController,
                  synopsisController: _synopsisController,
                  tagsController: _tagsController,
                  publisherOptions: _publisherOptions,
                  imprintOptions: _imprintOptions,
                  seriesGroupOptions: _seriesGroupOptions,
                  physicalFormatOptions: _manualPhysicalFormatOptions,
                  seriesEntries: _manualSeriesEntries,
                  onManagePublishers: () => _manageSingleValuePickList(
                    listName: kPublisherPickListName,
                    label: widget.type.mediaFields.publisherLabel,
                  ),
                  onManageImprints: () => _manageSingleValuePickList(
                    listName: kImprintPickListName,
                    label: 'Imprint',
                  ),
                  onManageSeriesGroups: () => _manageSingleValuePickList(
                    listName: kSeriesGroupPickListName,
                    label: 'Series Group',
                  ),
                  onManagePhysicalFormats: () => _manageSingleValuePickList(
                    listName: kPhysicalFormatPickListName,
                    label: 'Physical format',
                    builtInValues: [
                      for (final format in _currentPhysicalFormats())
                        format.label,
                    ],
                  ),
                  onManageSeries: _openManualSeriesPicker,
                  onSeriesChanged: _setManualSeries,
                  kindSpecific: _manualKindSpecific,
                  customFieldDefinitions: widget.customFieldDefinitions,
                  customFieldValues: _manualCustomFieldValues,
                  onCustomFieldValuesChanged: (m) =>
                      setState(() => _manualCustomFieldValues = Map.of(m)),
                  itemImages: _manualItemImages,
                  onItemImagesChanged: (edits) {
                    setState(() {
                      final byId = {
                        for (final img in _manualItemImages) img.id: img
                      };
                      final next = <ItemImage>[];
                      for (final e in edits) {
                        if (e.deleted) continue;
                        final existing = byId[e.id];
                        if (existing != null) {
                          next.add(existing.copyWith(
                            imageData: e.imageData ?? existing.imageData,
                            caption: e.caption ?? existing.caption,
                            sortOrder: e.sortOrder,
                          ));
                        } else {
                          if (e.imageData != null) {
                            next.add(ItemImage(
                              id: e.id,
                              ownedItemId: '',
                              imageData: e.imageData!,
                              caption: e.caption,
                              sortOrder: e.sortOrder,
                              createdAt: DateTime.now().toUtc(),
                            ));
                          }
                        }
                      }
                      _manualItemImages = next;
                    });
                  },
                );
                final manualPane =
                    widget.manualPaneBuilder?.call(context, manualRequest) ??
                        LibraryAddRegistry.manualBuilderFor(
                                widget.type.workspace.kind)
                            ?.call(context, manualRequest) ??
                        LibraryAddManualPane(request: manualRequest);
                if (_mode == LibraryAddDialogMode.manual) {
                  return manualPane;
                }
                if (constraints.maxWidth < 720) {
                  final searchHeight = constraints.maxHeight > 400
                      ? 300.0
                      : constraints.maxHeight * 0.5;
                  return Column(
                    children: [
                      SizedBox(
                        height: searchHeight,
                        child: searchPaneWithSourceToggles,
                      ),
                      Expanded(child: previewPane),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: _clampedResultsPaneWidth(
                        constraints.maxWidth,
                      ),
                      child: searchPaneWithSourceToggles,
                    ),
                    LibraryAddPaneResizeDivider(
                      onDragDelta: (delta) => _resizeResultsPane(
                        delta,
                        constraints.maxWidth,
                      ),
                    ),
                    Expanded(child: previewPane),
                  ],
                );
              },
            ),
          ),
          if (_mode != LibraryAddDialogMode.manual)
            Builder(
              builder: (context) {
                final checkedItems = [
                  for (final item in _results)
                    if (_checkedResultIds.contains(item.id)) item,
                ];
                final checkedProviderCandidates = [
                  for (final candidate in _providerResults)
                    if (_checkedProviderIds.contains(candidate.localCatalogId))
                      candidate,
                ];
                final addItems = checkedItems.isNotEmpty
                    ? checkedItems
                    : [if (selectedResult != null) selectedResult];
                final addCount = addItems.isNotEmpty
                    ? addItems.length
                    : checkedProviderCandidates.isNotEmpty
                        ? checkedProviderCandidates.length
                        : selectedCandidate != null
                            ? 1
                            : 0;
                final selectedEditionSelection = selectedResult == null
                    ? null
                    : _selectedEditionSelectionForItem(selectedResult);
                final requiresBundleSelection =
                    _addTarget != LibraryAddTarget.track &&
                        _referenceType == LibraryAddReferenceType.bundleRelease;
                final requiresEditionSelection =
                    _addTarget != LibraryAddTarget.track &&
                        _referenceType == LibraryAddReferenceType.edition;
                final canAddBundleSelection = !requiresBundleSelection ||
                    (addCount == 1 &&
                        selectedResult != null &&
                        _selectedBundleReleaseId != null);
                final canAddEditionSelection = !requiresEditionSelection ||
                    (addCount == 1 &&
                        selectedResult != null &&
                        selectedEditionSelection != null);
                final bottomBarRequest = LibraryAddBottomBarRequest(
                  type: widget.type,
                  isMovieDesktopChrome: _isMovieDesktopChrome,
                  conditions: _conditionOptions,
                  grades: _gradeOptions,
                  defaultTags: _defaultTags,
                  accent: accent,
                  selectedItem: selectedResult,
                  selectedCandidate: selectedCandidate,
                  selectedQueuedIngest: selectedQueuedIngest,
                  providerLabel: selectedProviderLabel,
                  addTarget: _addTarget,
                  addCount: addCount,
                  isAdding: _isAdding,
                  isQueueingIngest: _isQueueingIngest,
                  isAdmin: ref.watch(authControllerProvider).isAdmin,
                  defaultCondition: _defaultCondition,
                  defaultGrade: _defaultGrade,
                  defaultLocationLabel: _defaultLocationLabel,
                  defaultPurchaseDate: _defaultPurchaseDate,
                  onAddTargetChanged: (value) => setState(() {
                    _addTarget = value;
                    if (value == LibraryAddTarget.track) {
                      _referenceType = LibraryAddReferenceType.media;
                      _selectedBundleReleaseId = null;
                      _selectedReferenceEditionId = null;
                      _selectedReferenceVariantId = null;
                    }
                  }),
                  onDefaultConditionChanged: (value) =>
                      setState(() => _defaultCondition = value),
                  onDefaultGradeChanged: (value) =>
                      setState(() => _defaultGrade = value),
                  onEditDefaultTagsPressed: _showDefaultTagsEditor,
                  onDefaultLocationPressed: _pickDefaultLocation,
                  onDefaultPurchaseDateChanged: (value) =>
                      setState(() => _defaultPurchaseDate = value),
                  onAdd: (addItems.isEmpty &&
                              selectedCandidate == null &&
                              checkedProviderCandidates.isEmpty) ||
                          (checkedProviderCandidates.isEmpty &&
                              (!canAddBundleSelection ||
                                  !canAddEditionSelection))
                      ? null
                      : () async {
                          if (selectedCandidate == null &&
                              checkedProviderCandidates.isNotEmpty) {
                            for (final candidate in checkedProviderCandidates) {
                              await _addProviderCandidate(
                                candidate,
                                _addTarget,
                              );
                            }
                            return;
                          }
                          if (addItems.isNotEmpty) {
                            final resolvedItems =
                                await _resolveCoreItemsForAdd(addItems);
                            await _addItems(
                              resolvedItems,
                              _addTarget,
                              referenceType: _referenceType,
                              editionSelectionsByItemId: selectedResult ==
                                          null ||
                                      selectedEditionSelection == null ||
                                      addCount != 1
                                  ? const <String, LibraryAddEditionSelection>{}
                                  : <String, LibraryAddEditionSelection>{
                                      selectedResult.id:
                                          selectedEditionSelection,
                                    },
                              bundleReleaseIdsByItemId:
                                  selectedResult == null ||
                                          _selectedBundleReleaseId == null
                                      ? const <String, String>{}
                                      : <String, String>{
                                          selectedResult.id:
                                              _selectedBundleReleaseId!,
                                        },
                            );
                            return;
                          }
                          final candidate = selectedCandidate;
                          if (candidate != null) {
                            await _addProviderCandidate(
                              candidate,
                              _addTarget,
                            );
                          }
                        },
                  onQueueIngest: selectedCandidate == null
                      ? null
                      : () => _queueProviderIngest(
                            selectedCandidate,
                          ),
                  onPropose: selectedCandidate == null
                      ? null
                      : () => _proposeCandidate(
                            selectedCandidate,
                          ),
                );
                return widget.bottomBarBuilder
                        ?.call(context, bottomBarRequest) ??
                    LibraryAddRegistry.bottomBarBuilderFor(
                            widget.type.workspace.kind)
                        ?.call(context, bottomBarRequest) ??
                    LibraryAddBottomBar(
                      type: bottomBarRequest.type,
                      isMovieDesktopChrome:
                          bottomBarRequest.isMovieDesktopChrome,
                      conditions: bottomBarRequest.conditions,
                      grades: bottomBarRequest.grades,
                      defaultTags: bottomBarRequest.defaultTags,
                      accent: bottomBarRequest.accent,
                      selectedItem: bottomBarRequest.selectedItem,
                      selectedCandidate: bottomBarRequest.selectedCandidate,
                      selectedQueuedIngest:
                          bottomBarRequest.selectedQueuedIngest,
                      providerLabel: bottomBarRequest.providerLabel,
                      addTarget: bottomBarRequest.addTarget,
                      addCount: bottomBarRequest.addCount,
                      isAdding: bottomBarRequest.isAdding,
                      isQueueingIngest: bottomBarRequest.isQueueingIngest,
                      isAdmin: bottomBarRequest.isAdmin,
                      defaultCondition: bottomBarRequest.defaultCondition,
                      defaultGrade: bottomBarRequest.defaultGrade,
                      defaultLocationLabel:
                          bottomBarRequest.defaultLocationLabel,
                      defaultPurchaseDate: bottomBarRequest.defaultPurchaseDate,
                      onAddTargetChanged: bottomBarRequest.onAddTargetChanged,
                      onDefaultConditionChanged:
                          bottomBarRequest.onDefaultConditionChanged,
                      onDefaultGradeChanged:
                          bottomBarRequest.onDefaultGradeChanged,
                      onEditDefaultTagsPressed:
                          bottomBarRequest.onEditDefaultTagsPressed,
                      onDefaultLocationPressed:
                          bottomBarRequest.onDefaultLocationPressed,
                      onDefaultPurchaseDateChanged:
                          bottomBarRequest.onDefaultPurchaseDateChanged,
                      onAdd: bottomBarRequest.onAdd,
                      onQueueIngest: bottomBarRequest.onQueueIngest,
                      onPropose: bottomBarRequest.onPropose,
                    );
              },
            ),
        ],
      ),
    );
  }

  double _clampedResultsPaneWidth(double availableWidth) {
    final maxWidth = (availableWidth - _minPreviewPaneWidth)
        .clamp(_minResultsPaneWidth, _maxResultsPaneWidth)
        .toDouble();
    return _resultsPaneWidth.clamp(_minResultsPaneWidth, maxWidth).toDouble();
  }

  void _resizeResultsPane(double delta, double availableWidth) {
    setState(() {
      final maxWidth = (availableWidth - _minPreviewPaneWidth)
          .clamp(_minResultsPaneWidth, _maxResultsPaneWidth)
          .toDouble();
      _resultsPaneWidth =
          (_resultsPaneWidth + delta).clamp(_minResultsPaneWidth, maxWidth);
    });
  }

  Future<void> _search() async {
    final searchLabels = libraryMediaSearchFieldLabels(widget.type);
    final query = _queryController.text.trim();
    if (query.isEmpty &&
        _searchSeriesController.text.trim().isEmpty &&
        _searchNumberController.text.trim().isEmpty &&
        _searchPublisherController.text.trim().isEmpty &&
        _searchYearController.text.trim().isEmpty) {
      setState(() => _error = searchLabels.emptySearchMessage);
      return;
    }
    final searchGeneration = ++_coreSearchGeneration;
    setState(() {
      _isSearching = true;
      _error = null;
      _providerResults = const [];
      _providerPreviews.clear();
      _searchedProvider = false;
    });
    final series = _searchSeriesController.text.trim();
    final issueNumber = _searchNumberController.text.trim();
    final publisher = _searchPublisherController.text.trim();
    final yearText = _searchYearController.text.trim();
    final year = yearText.isNotEmpty ? int.tryParse(yearText) : null;
    try {
      final api = ref.read(apiClientProvider);
      final searchResult = await runLibraryAddCoreSearch(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        input: LibraryMetadataSearchInput(
          query: query.isNotEmpty ? query : null,
          series: series.isNotEmpty ? series : null,
          issueNumber: issueNumber.isNotEmpty ? issueNumber : null,
          publisher: publisher.isNotEmpty ? publisher : null,
          year: year,
          limit: 20,
        ),
        timeout: _coreSearchTimeout,
        rerankHints: _searchState.buildLocalRerankHints(),
        providerSearchAvailable:
            widget.type.supportedMetadataProviders.isNotEmpty,
      );
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() {
          _results = searchResult.items;
          _selectedResultId = null;
          _selectedProviderCandidateId = null;
          _resetReferenceSelection();
          _clearSelectionCaches();
        });
        _precacheMetadataCovers(searchResult.items);
      }
      if (mounted &&
          searchGeneration == _coreSearchGeneration &&
          searchResult.shouldSearchProvider) {
        await _searchProvider(
          queryOverride: query,
          bypassDebounce: true,
        );
      }
    } catch (error) {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        if (await _clearRejectedMetadataSession(error, 'Core search')) {
          return;
        }
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Core search failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)} Manual add still works.',
        );
      }
    } finally {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    if (query.length < 2) {
      _autocompleteTimer?.cancel();
      if (_showSuggestions) {
        setState(() {
          _suggestions = const [];
          _showSuggestions = false;
        });
      }
      return;
    }
    _autocompleteTimer?.cancel();
    _autocompleteTimer = Timer(_autocompleteDebounce, () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final api = ref.read(apiClientProvider);
      final filtered = await fetchLibraryAddSuggestions(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        query: query,
        limit: _autocompleteLimit,
      );
      if (!mounted) return;
      setState(() {
        _suggestions = filtered;
        _showSuggestions = filtered.isNotEmpty;
      });
    } catch (_) {
      // Silently ignore autocomplete failures — the user can still press Search.
    }
  }

  void _selectSuggestion(LibraryMetadataItem item) {
    _queryController.text = item.title;
    setState(() {
      _showSuggestions = false;
      _suggestions = const [];
      _results = [item];
      _selectedResultId = item.id;
      _selectedProviderCandidateId = null;
      _resetReferenceSelection();
      _clearSelectionCaches();
    });
    _ensureSelectedResultLoaded(item.id);
    _ensureBundleReleasesLoaded(item.id);
  }

  void _dismissSuggestions() {
    if (_showSuggestions) {
      setState(() => _showSuggestions = false);
    }
  }

  Future<void> _scanCover() async {
    if (_isScanningCover) {
      return;
    }
    setState(() {
      _isScanningCover = true;
      _error = null;
    });
    try {
      final result = await widget.coverScanService.scanCover(
        context: context,
        type: widget.type,
      );
      if (!mounted || result == null) {
        return;
      }
      if (!result.hasAnyHint) {
        setState(() {
          _error = result.warnings.isEmpty
              ? 'Cover scan did not extract usable search hints yet.'
              : result.warnings.first;
          _coverScanPrefill = null;
        });
        return;
      }
      final query = (result.query ?? result.series ?? '').trim();
      setState(() {
        _mode = LibraryAddDialogMode.search;
        _queryController.text = query;
        _searchSeriesController.text = result.series?.trim() ?? '';
        _searchNumberController.text = result.issueNumber?.trim() ?? '';
        _searchPublisherController.text = result.publisher?.trim() ?? '';
        _searchYearController.text = result.year?.toString() ?? '';
        _showAdvancedSearch = result.showAdvancedFields;
        _coverScanPrefill = result;
        _results = const [];
        _providerResults = const [];
        _selectedResultId = null;
        _selectedProviderCandidateId = null;
        _resetReferenceSelection();
        _clearSelectionCaches();
        _providerPreviews.clear();
        _searchedProvider = false;
      });
      await _search();
    } finally {
      if (mounted) {
        setState(() => _isScanningCover = false);
      }
    }
  }

  Future<void> _lookupBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      setState(() => _error = 'Enter a barcode / UPC / ISBN.');
      return;
    }
    final searchGeneration = ++_coreSearchGeneration;
    setState(() {
      _isSearching = true;
      _error = null;
      _providerResults = const [];
      _providerPreviews.clear();
      _searchedProvider = false;
    });
    try {
      final api = ref.read(apiClientProvider);
      final lookupResult = await runLibraryAddBarcodeLookup(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        barcode: barcode,
        timeout: _coreSearchTimeout,
        providerSearchAvailable:
            widget.type.supportedMetadataProviders.isNotEmpty,
      );
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() {
          _results = lookupResult.items;
          _selectedResultId = null;
          _selectedProviderCandidateId = null;
          _resetReferenceSelection();
          _clearSelectionCaches();
          _error = lookupResult.items.isEmpty &&
                  widget.type.supportedMetadataProviders.isEmpty
              ? 'No item found for barcode $barcode.'
              : null;
        });
        _precacheMetadataCovers(lookupResult.items);
      }
      if (mounted &&
          searchGeneration == _coreSearchGeneration &&
          lookupResult.shouldSearchProvider) {
        await _searchProvider(queryOverride: barcode);
      }
    } catch (error) {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        if (await _clearRejectedMetadataSession(error, 'Barcode lookup')) {
          return;
        }
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Barcode lookup failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)} Manual add keeps the scanned code.',
        );
      }
    } finally {
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _addManual(LibraryAddTarget target) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Manual item needs a title.');
      return;
    }
    await _openManualEditor(target);
  }

  Future<void> _openManualEditor(LibraryAddTarget target) async {
    final draft = _buildManualDraftItem();
    final customFieldValuesForEdit = _manualCustomFieldValues.entries
        .map((e) => CustomFieldValue(
              id: 'local-${e.key}-${_uuid.v4()}',
              targetId: 'local-${e.key}',
              targetScope: CustomFieldTargetScope.ownedCopy,
              fieldDefinitionId: e.key,
              value: e.value,
              updatedAt: DateTime.now().toUtc(),
            ))
        .toList(growable: false);
    final result = await showLibraryEditDialog(
      context: context,
      request: LibraryEditDialogRequest(
        type: widget.type,
        item: draft,
        ownedItem: _manualDraftOwnedItem(draft, target),
        accent: LibraryAccentScope.accentOf(context),
        physicalFormats: _currentPhysicalFormats(),
        customFieldDefinitions: widget.customFieldDefinitions,
        customFieldValues: customFieldValuesForEdit,
        itemImages: _manualItemImages,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    await _addItems(
      [result.item],
      target,
      defaults: const LibraryAddDefaults(),
      ownedDetailsByItemId: result.personal == null
          ? const <String, LibraryAddOwnedDetails>{}
          : {
              result.item.id: _ownedDetailsFromSelection(result),
            },
    );
  }

  LibraryMetadataItem _buildManualDraftItem() {
    TextEditingController ctl(String key, TextEditingController fallback) {
      final e = _manualKindSpecific[key];
      if (e is TextEditingController) return e;
      return fallback;
    }

    final year =
        int.tryParse(ctl('yearController', _yearController).text.trim());
    final coverUrl =
        _emptyToNull(ctl('coverController', _coverController).text);
    final releaseDate =
        parseDate(ctl('releaseDateController', _releaseDateController).text);
    final pageCount =
        parseInt(ctl('pageCountController', _pageCountController).text);
    final genres = ctl('genresEditController', _genresEditController)
        .text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    final creatorNames = ctl('creatorsController', _creatorsController)
        .text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    final creators = creatorNames.isEmpty
        ? null
        : [
            for (final n in creatorNames) {'name': n}
          ];
    final characterNames = ctl('charactersController', _charactersController)
        .text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    final characters = characterNames.isEmpty ? null : characterNames;
    final linkCandidates = ctl('linksController', _linksController)
        .text
        .split(RegExp(r'[\n,]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    final trailerUrls = linkCandidates.isEmpty
        ? const <TrailerLink>[]
        : [
            for (final u in linkCandidates)
              TrailerLink(url: u, isAutomatic: false)
          ];
    return LibraryMetadataItem(
      id: 'local-${widget.type.workspace.kind.apiValue}-${_uuid.v4()}',
      kind: widget.type.workspace.kind.apiValue,
      title: _titleController.text.trim(),
      itemNumber: _emptyToNull(ctl('numberController', _numberController).text),
      editionTitle: _emptyToNull(
          ctl('editionTitleController', _editionTitleController).text),
      physicalFormat: _physicalFormatId,
      physicalFormatLabel: _emptyToNull(_physicalFormatLabelController.text) ??
          _physicalFormatForId(_physicalFormatId)?.label,
      publisher:
          _emptyToNull(ctl('publisherController', _publisherController).text),
      releaseDate: releaseDate,
      releaseYear: year,
      barcode: _emptyToNull(ctl('barcodeController', _barcodeController).text),
      variant: _emptyToNull(ctl('variantController', _variantController).text),
      coverImageUrl: coverUrl,
      thumbnailImageUrl: coverUrl,
      synopsis:
          _emptyToNull(ctl('synopsisController', _synopsisController).text),
      genres: genres.isEmpty ? null : genres,
      creators: creators,
      characters: characters,
      trailerUrls: trailerUrls,
      country: _emptyToNull(ctl('countryController', _countryController).text),
      language:
          _emptyToNull(ctl('languageController', _languageController).text),
      ageRating:
          _emptyToNull(ctl('ageRatingController', _ageRatingController).text),
      series: widget.type.manualAddUsesTitleAsSeries
          ? CatalogSeriesDetails(
              seriesId: _selectedManualSeriesId,
              seriesTitle: _emptyToNull(_titleController.text),
            )
          : null,
      publishing: (pageCount != null ||
              _imprintController.text.trim().isNotEmpty ||
              _seriesGroupController.text.trim().isNotEmpty)
          ? CatalogPublishingDetails(
              pageCount: pageCount,
              imprint: _emptyToNull(
                  ctl('imprintController', _imprintController).text),
              seriesGroup: _emptyToNull(
                  ctl('seriesGroupController', _seriesGroupController).text),
            )
          : null,
    );
  }

  OwnedItem? _manualDraftOwnedItem(
    LibraryMetadataItem item,
    LibraryAddTarget target,
  ) {
    if (target != LibraryAddTarget.owned) {
      return null;
    }
    TextEditingController ctl(String key, TextEditingController fallback) {
      final e = _manualKindSpecific[key];
      if (e is TextEditingController) return e;
      return fallback;
    }

    String? ctlTextOrNull(String key, [TextEditingController? fallback]) {
      final e = _manualKindSpecific[key];
      final controller = e is TextEditingController ? e : fallback;
      final value = controller?.text.trim() ?? '';
      return value.isEmpty ? null : value;
    }

    final purchaseDate = parseDate(
            ctl('purchaseDateController', _purchaseDateController).text) ??
        _defaultPurchaseDate;
    final pricePaidCents =
        parseMoneyCents(ctl('purchasePriceController', _priceController).text);
    final coverPriceCents = parseMoneyCents(
        ctl('coverPriceController', _coverPriceController).text);
    final sellPriceCents =
        parseMoneyCents(ctl('soldPriceController', _sellPriceController).text);
    final soldAt = _soldAt;
    return OwnedItem(
      id: 'manual-owned-${_uuid.v4()}',
      catalogRef: CatalogEntityRef(
        kind: item.kind,
        entityType: CatalogEntityType.work,
        id: item.id,
      ),
      condition: _defaultCondition,
      grade: _defaultGrade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: null,
      personalNotes: ctl('personalNotesController', _personalNotesController)
              .text
              .trim()
              .isEmpty
          ? null
          : ctl('personalNotesController', _personalNotesController)
              .text
              .trim(),
      quantity: 1,
      coverPriceCents: coverPriceCents,
      rawOrSlabbed:
          ctlTextOrNull('rawOrSlabbedController', _rawOrSlabbedController),
      gradingCompany:
          ctlTextOrNull('gradingCompanyController', _gradingCompanyController),
      graderNotes:
          ctlTextOrNull('graderNotesController', _graderNotesController),
      signedBy: ctlTextOrNull('signedByController', _signedByController),
      labelType: ctlTextOrNull('labelTypeController', _labelTypeController),
      pageQuality: ctlTextOrNull('pageQualityController'),
      certificationNumber: ctlTextOrNull(
        'certificationNumberController',
        _certificationNumberController,
      ),
      updatedAt: DateTime.now().toUtc(),
      soldAt: soldAt,
      sellPriceCents: sellPriceCents,
      ownerLabel:
          ctl('ownerLabelController', _ownerLabelController).text.trim().isEmpty
              ? null
              : ctl('ownerLabelController', _ownerLabelController).text.trim(),
      locationId: _defaultLocationId,
      tags: ctl('tagsController', _tagsController).text.trim().isEmpty
          ? null
          : ctl('tagsController', _tagsController).text.trim(),
      purchaseStore: ctl('purchaseStoreController', _purchaseStoreController)
              .text
              .trim()
              .isEmpty
          ? null
          : ctl('purchaseStoreController', _purchaseStoreController)
              .text
              .trim(),
    );
  }

  LibraryAddOwnedDetails _ownedDetailsFromSelection(
    LibraryEditSelection selection,
  ) {
    final personal = selection.personal;
    if (personal == null) {
      return const LibraryAddOwnedDetails();
    }
    return LibraryAddOwnedDetails(
      editionId: personal.editionId,
      variantId: personal.variantId,
      condition: personal.condition,
      grade: personal.grade,
      purchaseDate: personal.purchaseDate,
      pricePaidCents: personal.pricePaidCents,
      currency: personal.currency,
      personalNotes: personal.personalNotes,
      quantity: personal.quantity,
      locationId: personal.locationId,
      coverPriceCents: personal.coverPriceCents,
      rawOrSlabbed: personal.rawOrSlabbed,
      gradingCompany: personal.gradingCompany,
      graderNotes: personal.graderNotes,
      signedBy: personal.signedBy,
      labelType: personal.labelType,
      certificationNumber: personal.certificationNumber,
      keyComic: personal.keyComic ?? false,
      keyReason: personal.keyReason,
      rating: selection.tracking?.rating,
      readStatus: selection.tracking?.readStatus,
      startedAt: selection.tracking?.startedAt,
      finishedAt: selection.tracking?.finishedAt,
      progressCurrent: selection.tracking?.progressCurrent,
      progressTotal: selection.tracking?.progressTotal,
      timesCompleted: selection.tracking?.timesCompleted,
      trackingNotes: selection.tracking?.notes,
      seasonNumber: selection.tracking?.seasonNumber,
      episodeNumber: selection.tracking?.episodeNumber,
      tags: personal.tags,
      soldAt: personal.soldAt,
      sellPriceCents: personal.sellPriceCents,
      soldTo: personal.soldTo,
    );
  }

  void _setPhysicalFormat(String? value) {
    final format = _physicalFormatForId(value);
    final previousFormat = _physicalFormatForId(_physicalFormatId);
    final shouldReplaceVariant = _variantController.text.trim().isEmpty ||
        previousFormat?.label == _variantController.text.trim();
    setState(() {
      _physicalFormatId = format?.id;
      _physicalFormatLabelController.text = format?.label ?? '';
      if (format != null && shouldReplaceVariant) {
        _variantController.text = format.label;
      }
    });
  }

  void _setPhysicalFormatLabel(String? value) {
    final normalized = _emptyToNull(value ?? '');
    final format = physicalMediaFormatByLabelOrId(
      normalized,
      formats: _currentPhysicalFormats(),
    );
    final previousFormat = _physicalFormatForId(_physicalFormatId);
    final shouldReplaceVariant = _variantController.text.trim().isEmpty ||
        previousFormat?.label == _variantController.text.trim();
    setState(() {
      _physicalFormatId = format?.id;
      if (format != null && shouldReplaceVariant) {
        _variantController.text = format.label;
      }
    });
  }

  PhysicalMediaFormat? _physicalFormatForId(String? id) {
    final normalized = _emptyToNull(id ?? '');
    if (normalized == null) {
      return null;
    }
    return physicalMediaFormatById(
      normalized,
      formats: _currentPhysicalFormats(),
    );
  }

  List<PhysicalMediaFormat> _currentPhysicalFormats() {
    return physicalMediaFormatsForKind(
      ref.read(mediaCatalogProvider).maybeWhen(
            data: (value) => value,
            orElse: () => fallbackMediaCatalog,
          ),
      widget.type.workspace.kind,
    );
  }

  void _resetReferenceSelection() {
    _selectedBundleReleaseId = null;
    _selectedReferenceEditionId = null;
    _selectedReferenceVariantId = null;
    _referenceType = LibraryAddReferenceType.media;
  }

  void _clearSelectionCaches() => _previewState.clearSelectionCaches();

  void _selectCoreResult(String id) {
    setState(() {
      _selectedResultId = id;
      _selectedProviderCandidateId = null;
      _resetReferenceSelection();
    });
    unawaited(_ensureSelectedResultLoaded(id));
    unawaited(_ensureBundleReleasesLoaded(id));
  }

  void _selectProviderCandidate(String id) {
    setState(() {
      _selectedProviderCandidateId = id;
      _selectedResultId = null;
      _resetReferenceSelection();
    });
    unawaited(_ensureProviderPreviewLoaded(id));
  }

  void _handleReferenceTypeChanged(
    LibraryMetadataItem? selectedResult,
    LibraryAddReferenceType value,
  ) {
    if (_addTarget == LibraryAddTarget.track) {
      return;
    }
    final bundles = _previewState.bundleReleasesForItem(selectedResult);
    setState(() {
      _referenceType = value;
      if (value != LibraryAddReferenceType.bundleRelease) {
        _selectedBundleReleaseId = null;
      } else {
        _selectedBundleReleaseId = _selectedBundleReleaseId ??
            (bundles.isNotEmpty ? bundles.first.id : null);
      }
      if (value != LibraryAddReferenceType.edition) {
        _selectedReferenceEditionId = null;
        _selectedReferenceVariantId = null;
      }
    });
    final bundleReleaseId = _selectedBundleReleaseId;
    if (value == LibraryAddReferenceType.bundleRelease &&
        bundleReleaseId != null) {
      unawaited(_ensureBundleReleaseDetailLoaded(bundleReleaseId));
    }
  }

  void _handleReferenceEditionSelected(
    LibraryMetadataItem? item,
    String editionId,
  ) {
    if (item == null) {
      return;
    }
    final selectedEdition = previewEditionForItem(item, editionId);
    setState(() {
      _selectedReferenceEditionId = selectedEdition?.id;
      _selectedReferenceVariantId = null;
    });
  }

  void _handleReferenceVariantSelected(String variantId) {
    setState(() {
      _selectedReferenceVariantId = _emptyToNull(variantId);
    });
  }

  void _handleBundleReleaseSelected(String bundleReleaseId) {
    setState(() {
      _selectedBundleReleaseId = bundleReleaseId;
    });
    unawaited(_ensureBundleReleaseDetailLoaded(bundleReleaseId));
  }

  bool _isProviderReleaseResult(ProviderCandidate candidate) =>
      !isSeriesCandidate(candidate);

  bool _matchesEntityScopeForCore(LibraryMetadataItem item) {
    return libraryAddMatchesContentScope(
      type: widget.type,
      item: item,
      showSeriesResults: _showMediaResults,
      showSeasonResults: _showSeasonResults,
      showReleaseResults: _showReleaseResults,
    );
  }

  bool _matchesEntityScopeForProvider(ProviderCandidate candidate) {
    if (_showMediaResults && _showReleaseResults) {
      return true;
    }
    final isRelease = _isProviderReleaseResult(candidate);
    return isRelease ? _showReleaseResults : _showMediaResults;
  }

  List<LibraryMetadataItem> _visibleCoreResults() {
    if (!_showCoreResults) {
      return const <LibraryMetadataItem>[];
    }
    return _results.where((item) {
      if (!_matchesEntityScopeForCore(item)) {
        return false;
      }
      if (widget.type.workspace.kind.apiValue != 'comic') {
        return true;
      }
      if (_hideComicOwnedResults && _isOwnedCatalogItem(item.id)) {
        return false;
      }
      if (_hideComicVariantResults && _isComicVariantResult(item)) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  List<ProviderCandidate> _visibleProviderResults() {
    if (!_showProviderResults) {
      return const <ProviderCandidate>[];
    }
    return _providerResults.where((candidate) {
      if (!_matchesEntityScopeForProvider(candidate)) {
        return false;
      }
      if (widget.type.workspace.kind.apiValue != 'comic') {
        return true;
      }
      return !_hideComicVariantResults || !candidate.isVariant;
    }).toList(growable: false);
  }

  bool _isOwnedCatalogItem(String id) =>
      ref.read(collectionByCatalogItemProvider).containsKey(id);

  bool _isComicVariantResult(LibraryMetadataItem item) {
    final variantText = item.variant?.trim();
    return variantText != null && variantText.isNotEmpty;
  }

  void _pruneSelectionsForVisibility({
    required List<LibraryMetadataItem> visibleResults,
    required List<ProviderCandidate> visibleProviderResults,
  }) {
    final visibleResultIds = visibleResults.map((item) => item.id).toSet();
    final visibleProviderIds =
        visibleProviderResults.map((item) => item.localCatalogId).toSet();
    if (_selectedResultId != null &&
        !visibleResultIds.contains(_selectedResultId)) {
      _selectedResultId = null;
    }
    if (_selectedProviderCandidateId != null &&
        !visibleProviderIds.contains(_selectedProviderCandidateId)) {
      _selectedProviderCandidateId = null;
    }
    _checkedResultIds.removeWhere((id) => !visibleResultIds.contains(id));
    _checkedProviderIds.removeWhere((id) => !visibleProviderIds.contains(id));
  }

  Future<void> _searchProvider({
    String? queryOverride,
    bool bypassDebounce = false,
  }) async {
    final query = queryOverride?.trim().isNotEmpty == true
        ? queryOverride!.trim()
        : _providerQuery;
    if (query.isEmpty) {
      setState(() => _error = 'Enter a title, barcode, or keyword.');
      return;
    }
    final provider = _activeProvider;
    ++_providerSearchGeneration;
    final debounceDecision = evaluateLibraryAddProviderSearchDebounce(
      provider: provider,
      query: query,
      debounce: _providerSearchDebounce,
      now: DateTime.now(),
      previousSignature: _lastProviderSearchSignature,
      previousAt: _lastProviderSearchAt,
    );
    _lastProviderSearchSignature = debounceDecision.signature;
    _lastProviderSearchAt = debounceDecision.at;
    if (_isSearchingProvider ||
        (!bypassDebounce && debounceDecision.shouldSkip)) {
      return;
    }
    setState(() {
      _isSearchingProvider = true;
      _searchedProvider = true;
      _providerResults = const [];
      _providerPreviews.clear();
      _pendingProviderPreviewIds.clear();
      _selectedProviderCandidateId = null;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final kindsToSearch = _isVideoKind
          ? (_videoKindFilters.isEmpty
              ? _allVideoSearchKinds
              : _videoKindFilters
                  .map(_canonicalVideoSearchKind)
                  .toSet()
                  .toList())
          : <String>[];
      final seriesText = _searchSeriesController.text.trim().isNotEmpty
          ? _searchSeriesController.text.trim()
          : null;
      final issueText = _searchNumberController.text.trim().isNotEmpty
          ? _searchNumberController.text.trim()
          : null;
      final yearValue = _searchYearController.text.trim().isNotEmpty
          ? int.tryParse(_searchYearController.text.trim())
          : null;
      final rerankHints = _searchState.buildLocalRerankHints();

      List<ProviderCandidate> results;
      if (kindsToSearch.length > 1) {
        // Run parallel provider searches for each checked video kind.
        final futures = kindsToSearch.map((kind) async {
          try {
            return await runLibraryAddProviderSearch(
              api: api,
              type: widget.type,
              provider: provider,
              query: query,
              rerankHints: rerankHints,
              series: seriesText,
              issueNumber: issueText,
              year: yearValue,
              kindOverride: kind,
            );
          } catch (_) {
            return <ProviderCandidate>[];
          }
        });
        final allResults = await Future.wait(futures);
        results = allResults.expand((r) => r).toList();
      } else if (kindsToSearch.length == 1) {
        results = await runLibraryAddProviderSearch(
          api: api,
          type: widget.type,
          provider: provider,
          query: query,
          rerankHints: rerankHints,
          series: seriesText,
          issueNumber: issueText,
          year: yearValue,
          kindOverride: kindsToSearch.first,
        );
      } else {
        results = await runLibraryAddProviderSearch(
          api: api,
          type: widget.type,
          provider: provider,
          query: query,
          rerankHints: rerankHints,
          series: seriesText,
          issueNumber: issueText,
          year: yearValue,
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _providerResults = results;
        _selectedProviderCandidateId = null;
        _pendingProviderPreviewIds.clear();
      });
      _precacheProviderCandidateCovers(results);
    } catch (error) {
      if (mounted) {
        if (_isMissingBearerTokenError(error)) {
          // Provider candidates are optional; keep the add dialog usable without
          // surfacing an auth-only failure banner for anonymous sessions.
          setState(() => _error = null);
          return;
        }
        if (await _clearRejectedMetadataSession(error, 'Provider search')) {
          return;
        }
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Provider search failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearchingProvider = false);
      }
    }
  }

  Future<void> _ensureProviderPreviewLoaded(String candidateId) async {
    if (_previewState.providerPreviewFor(candidateId) != null ||
        _previewState.isProviderPreviewPending(candidateId)) {
      return;
    }
    ProviderCandidate? candidate;
    for (final value in _providerResults) {
      if (value.localCatalogId == candidateId) {
        candidate = value;
        break;
      }
    }
    if (candidate == null || candidate.isStub) {
      return;
    }
    final searchGeneration = _providerSearchGeneration;
    setState(() {
      _previewState.markProviderPreviewPending(candidateId);
    });
    try {
      final api = ref.read(apiClientProvider);
      final preview = await api.providerPreview(
        provider: candidate.provider,
        providerItemId: candidate.providerItemId,
      );
      if (!mounted || searchGeneration != _providerSearchGeneration) {
        return;
      }
      setState(() {
        _previewState.setProviderPreview(candidateId, preview);
      });
      _precacheProviderPreviewCovers([preview]);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message:
            'Failed to load provider preview for ${candidate.provider}:${candidate.providerItemId}.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _providerSearchGeneration) {
        return;
      }
      setState(() {
        _previewState.pendingProviderPreviewIds.remove(candidateId);
      });
    }
  }

  Future<void> _ensureSelectedResultLoaded(String itemId) async {
    if (_previewState.hasHydratedResult(itemId) ||
        _previewState.isHydratedResultPending(itemId)) {
      return;
    }
    LibraryMetadataItem? selected;
    for (final item in _results) {
      if (item.id == itemId) {
        selected = item;
        break;
      }
    }
    if (selected == null) {
      return;
    }
    final searchGeneration = _coreSearchGeneration;
    setState(() {
      _previewState.pendingHydratedResultIds.add(itemId);
    });
    try {
      final hydrated = await ref
          .read(apiClientProvider)
          .getTypedMetadataItem(
            kind: selected.kind,
            id: itemId,
          )
          .then((dto) {
        final sourceSelection = selected!;
        final raw = <String, dynamic>{
          ...dto.raw,
          'id': dto.id,
          'title': dto.title,
          'kind': dto.kind,
          if (!dto.raw.containsKey('editions') &&
              sourceSelection.editions.isNotEmpty)
            'editions': [
              for (final edition in sourceSelection.editions) edition.toJson(),
            ],
          if (!dto.raw.containsKey('track_count') &&
              sourceSelection.music?.trackCount != null)
            'track_count': sourceSelection.music!.trackCount,
          if (!dto.raw.containsKey('tracks') &&
              (sourceSelection.music?.tracks.isNotEmpty ?? false))
            'tracks': [
              for (final track in sourceSelection.music!.tracks) track.toJson(),
            ],
        };
        return CatalogItem.fromJson(raw);
      });
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      final hydratedItem = LibraryMetadataItem.fromCatalogItem(hydrated);
      final mergedItem = hydratedItem.copyWith(
        editions: hydratedItem.editions.isNotEmpty
            ? hydratedItem.editions
            : selected.editions,
        coverImageUrl: hydratedItem.displayCoverUrl != null
            ? hydratedItem.coverImageUrl
            : selected.coverImageUrl,
        thumbnailImageUrl: hydratedItem.displayCoverUrl != null
            ? hydratedItem.thumbnailImageUrl
            : selected.thumbnailImageUrl ?? selected.coverImageUrl,
      );
      setState(() {
        _previewState.setHydratedResult(itemId, mergedItem);
      });
      _precacheMetadataCovers([mergedItem]);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to hydrate add-result metadata for item $itemId.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _previewState.pendingHydratedResultIds.remove(itemId);
      });
    }
  }

  Future<void> _ensureBundleReleasesLoaded(String itemId) async {
    if (_previewState.bundleReleasesByItemId.containsKey(itemId) ||
        _previewState.isBundleReleasesPending(itemId)) {
      return;
    }
    final searchGeneration = _coreSearchGeneration;
    setState(() {
      _previewState.pendingBundleReleaseItemIds.add(itemId);
    });
    try {
      final bundleReleases =
          await ref.read(apiClientProvider).getItemBundleReleases(itemId);
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      final firstBundleId = _selectedBundleReleaseId ??
          (bundleReleases.isNotEmpty ? bundleReleases.first.id : null);
      setState(() {
        _previewState.setBundleReleases(itemId, bundleReleases);
        if (_referenceType == LibraryAddReferenceType.bundleRelease) {
          _selectedBundleReleaseId = firstBundleId;
        }
      });
      if (_referenceType == LibraryAddReferenceType.bundleRelease &&
          firstBundleId != null) {
        unawaited(_ensureBundleReleaseDetailLoaded(firstBundleId));
      }
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to load bundle releases for $itemId.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _previewState.setBundleReleases(itemId, const <BundleReleaseSummary>[]);
      });
    }
  }

  Future<void> _ensureBundleReleaseDetailLoaded(String bundleReleaseId) async {
    if (_previewState.bundleReleaseDetailsById.containsKey(bundleReleaseId) ||
        _previewState.isBundleReleaseDetailPending(bundleReleaseId)) {
      return;
    }
    final searchGeneration = _coreSearchGeneration;
    setState(() {
      _previewState.pendingBundleReleaseDetailIds.add(bundleReleaseId);
    });
    try {
      final bundleRelease =
          await ref.read(apiClientProvider).getBundleRelease(bundleReleaseId);
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _previewState.setBundleReleaseDetail(bundleReleaseId, bundleRelease);
      });
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to load bundle release detail for $bundleReleaseId.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _previewState.pendingBundleReleaseDetailIds.remove(bundleReleaseId);
      });
    }
  }

  void _precacheMetadataCovers(List<LibraryMetadataItem> items) {
    unawaited(
      _precacheCoverUrls([
        for (final item in items) item.coverImageUrl,
        for (final item in items) item.thumbnailImageUrl,
      ]),
    );
  }

  void _precacheProviderCandidateCovers(List<ProviderCandidate> candidates) {
    unawaited(
      _precacheCoverUrls([
        for (final candidate in candidates) candidate.imageUrl,
      ]),
    );
  }

  void _precacheProviderPreviewCovers(Iterable<AdminProviderPreview> previews) {
    unawaited(
      _precacheCoverUrls([
        for (final preview in previews) preview.coverImageUrl,
      ]),
    );
  }

  Future<void> _precacheCoverUrls(Iterable<String?> urls) async {
    if (!mounted) {
      return;
    }
    // Best-effort warm-up was causing noisy decode errors for malformed or
    // stale image URLs. Let the normal image widgets load and fall back.
    return;
  }

  bool _isMissingBearerTokenError(Object error) {
    if (error is! DioException) {
      return false;
    }
    if (error.response?.statusCode != 401) {
      return false;
    }
    final data = error.response?.data;
    if (data is! Map) {
      return false;
    }
    final code = data['code']?.toString().trim();
    return code == 'missing_bearer_token';
  }

  Future<bool> _clearRejectedMetadataSession(
    Object error,
    String action,
  ) async {
    final cleared =
        await ref.read(authControllerProvider.notifier).clearSessionIfRejected(
              error,
            );
    if (!cleared) {
      return false;
    }
    if (!mounted) {
      return true;
    }
    setState(() {
      _isSearching = false;
      _isSearchingProvider = false;
      _isAdding = false;
      _isQueueingIngest = false;
      _error = 'Saved metadata session was cleared after $action was rejected. '
          'Retry the action. Sign in again only if you need authenticated tools.';
    });
    return true;
  }

  Future<LibraryMetadataItem> _providerAddItemForCandidate(
    ProviderCandidate candidate,
  ) async {
    if (candidate.isStub) {
      return candidate.placeholderItem();
    }
    final cachedPreview =
        _previewState.providerPreviewFor(candidate.localCatalogId);
    if (cachedPreview != null) {
      return metadataItemFromPreview(cachedPreview);
    }
    try {
      final preview = await ref.read(apiClientProvider).providerPreview(
            provider: candidate.provider,
            providerItemId: candidate.providerItemId,
          );
      if (mounted) {
        _rebuild(() {
          _previewState.setProviderPreview(candidate.localCatalogId, preview);
        });
      }
      return metadataItemFromPreview(preview);
    } catch (error) {
      if (mounted && _isMissingBearerTokenError(error)) {
        _rebuild(
          () => _error =
              'Provider preview needs authentication. Adding basic provider metadata only.',
        );
        return candidate.placeholderItem();
      }
      rethrow;
    }
  }

  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    final series = preview.series;
    final publishing = preview.publishing;
    final music = preview.music;
    final video = preview.video;
    final game = preview.game;
    return LibraryMetadataItem(
      id: buildPreviewCatalogItemId(
        kind: preview.kind,
        provider: preview.provider,
        providerItemId: preview.providerItemId,
      ),
      kind: preview.kind,
      title: preview.title,
      itemNumber: preview.itemNumber,
      synopsis: preview.synopsis,
      coverImageUrl: preview.coverImageUrl,
      thumbnailImageUrl: preview.coverImageUrl,
      editionTitle: preview.editionTitle,
      physicalFormat: preview.physicalFormat,
      physicalFormatLabel: preview.physicalFormatLabel,
      publisher: preview.publisher,
      releaseDate: preview.releaseDate,
      releaseYear: preview.releaseDate?.year ?? preview.series?.volumeStartYear,
      barcode: preview.barcode,
      variant: preview.variantName,
      series: series,
      publishing: publishing,
      music: music,
      video: video,
      game: game,
      country: preview.country,
      language: preview.language,
      ageRating: preview.ageRating,
      audienceRating: preview.audienceRating,
      creators: [
        for (final creator in preview.creators)
          {
            'name': creator.name,
            if (creator.role != null) 'role': creator.role,
            if (creator.imageUrl != null) 'image_url': creator.imageUrl,
          },
      ],
      characters: preview.characters,
      storyArcs: preview.storyArcs,
      genres: preview.genres,
    );
  }

  Future<void> applyIngestCorrections({
    required String kind,
    required String itemId,
    required LibraryMetadataItem preview,
    required LibraryMetadataItem edited,
  }) async {
    final corrections = <String, dynamic>{};
    if (edited.title != preview.title) corrections['title'] = edited.title;
    if (edited.titleExtension != preview.titleExtension) {
      corrections['title_extension'] = edited.titleExtension;
    }
    if (edited.sortKey != preview.sortKey) {
      corrections['sort_key'] = edited.sortKey;
    }
    if (edited.originalTitle != preview.originalTitle) {
      corrections['original_title'] = edited.originalTitle;
    }
    if (edited.localizedTitle != preview.localizedTitle) {
      corrections['localized_title'] = edited.localizedTitle;
    }
    if (!sameStringList(edited.searchAliases, preview.searchAliases)) {
      corrections['search_aliases'] = edited.searchAliases;
    }
    if (edited.itemNumber != preview.itemNumber) {
      corrections['item_number'] = edited.itemNumber;
    }
    if (edited.synopsis != preview.synopsis) {
      corrections['synopsis'] = edited.synopsis;
    }
    if (edited.crossover != preview.crossover) {
      corrections['crossover'] = edited.crossover;
    }
    if (edited.plotSummary != preview.plotSummary) {
      corrections['plot_summary'] = edited.plotSummary;
    }
    if (edited.plotDescription != preview.plotDescription) {
      corrections['plot_description'] = edited.plotDescription;
    }
    if (edited.publisher != preview.publisher) {
      corrections['publisher'] = edited.publisher;
    }
    if (edited.releaseDate != preview.releaseDate) {
      corrections['release_date'] = edited.releaseDate?.toIso8601String();
    }
    if (edited.barcode != preview.barcode) {
      corrections['barcode'] = edited.barcode;
    }
    if (edited.variant != preview.variant) {
      corrections['variant_name'] = edited.variant;
    }
    if (edited.editionTitle != preview.editionTitle) {
      corrections['edition_title'] = edited.editionTitle;
    }
    if (edited.publishing?.pageCount != preview.publishing?.pageCount) {
      corrections['page_count'] = edited.publishing?.pageCount;
    }
    if (edited.publishing?.imprint != preview.publishing?.imprint) {
      corrections['imprint'] = edited.publishing?.imprint;
    }
    if (edited.publishing?.subtitle != preview.publishing?.subtitle) {
      corrections['subtitle'] = edited.publishing?.subtitle;
    }
    if (edited.publishing?.seriesGroup != preview.publishing?.seriesGroup) {
      corrections['series_group'] = edited.publishing?.seriesGroup;
    }
    if (edited.video?.runtimeMinutes != preview.video?.runtimeMinutes) {
      corrections['runtime_minutes'] = edited.video?.runtimeMinutes;
    }
    if (edited.physicalFormat != preview.physicalFormat) {
      corrections['physical_format'] = edited.physicalFormat;
    }
    if (edited.country != preview.country) {
      corrections['country'] = edited.country;
    }
    if (edited.language != preview.language) {
      corrections['language'] = edited.language;
    }
    if (edited.ageRating != preview.ageRating) {
      corrections['age_rating'] = edited.ageRating;
    }
    if (edited.audienceRating != preview.audienceRating) {
      corrections['audience_rating'] = edited.audienceRating;
    }
    if (!sameStringList(edited.genres, preview.genres)) {
      corrections['genres'] = edited.genres;
    }
    if (!sameStringList(edited.game?.platforms, preview.game?.platforms)) {
      corrections['platforms'] = edited.game?.platforms;
    }
    if (!sameTracks(edited.music?.tracks, preview.music?.tracks)) {
      corrections['tracks'] = edited.music?.tracks;
    }
    if (!sameCreators(edited.creators, preview.creators)) {
      corrections['creators'] = edited.creators;
    }
    if (!sameStringList(edited.characters, preview.characters)) {
      corrections['characters'] = edited.characters;
    }
    if (!sameStringList(edited.storyArcs, preview.storyArcs)) {
      corrections['story_arcs'] = edited.storyArcs;
    }
    if (edited.video?.color != preview.video?.color) {
      corrections['color'] = edited.video?.color;
    }
    if (edited.video?.nrDiscs != preview.video?.nrDiscs) {
      corrections['nr_discs'] = edited.video?.nrDiscs;
    }
    if (edited.video?.screenRatio != preview.video?.screenRatio) {
      corrections['screen_ratio'] = edited.video?.screenRatio;
    }
    if (edited.video?.audioTracks != preview.video?.audioTracks) {
      corrections['audio_tracks'] = edited.video?.audioTracks;
    }
    if (edited.video?.subtitles != preview.video?.subtitles) {
      corrections['subtitles'] = edited.video?.subtitles;
    }
    if (edited.video?.layers != preview.video?.layers) {
      corrections['layers'] = edited.video?.layers;
    }
    if (!sameTrailerLinks(edited.trailerUrls, preview.trailerUrls)) {
      corrections['external_links'] = edited.trailerUrls;
    }
    if (edited.music?.catalogNumber != preview.music?.catalogNumber) {
      corrections['catalog_number'] = edited.music?.catalogNumber;
    }
    if (edited.music?.releaseStatus != preview.music?.releaseStatus) {
      corrections['release_status'] = edited.music?.releaseStatus;
    }
    if (edited.coverImageUrl != preview.coverImageUrl) {
      corrections['cover_image_url'] = edited.coverImageUrl;
    }
    if (edited.thumbnailImageUrl != preview.thumbnailImageUrl) {
      corrections['thumbnail_image_url'] = edited.thumbnailImageUrl;
    }
    if (corrections.isEmpty) return;
    await ref.read(apiClientProvider).adminUpdateCatalogItem(
          kind: kind,
          id: itemId,
          title: corrections['title'] as String?,
          titleExtension: corrections['title_extension'] as String?,
          sortKey: corrections['sort_key'] as String?,
          originalTitle: corrections['original_title'] as String?,
          localizedTitle: corrections['localized_title'] as String?,
          searchAliases: corrections.containsKey('search_aliases')
              ? edited.searchAliases
              : null,
          itemNumber: corrections['item_number'] as String?,
          synopsis: corrections['synopsis'] as String?,
          editionTitle: corrections['edition_title'] as String?,
          pageCount: corrections.containsKey('page_count')
              ? edited.publishing?.pageCount
              : null,
          publisher: corrections['publisher'] as String?,
          releaseDate: corrections.containsKey('release_date')
              ? edited.releaseDate
              : null,
          runtimeMinutes: corrections.containsKey('runtime_minutes')
              ? edited.video?.runtimeMinutes
              : null,
          imprint: corrections['imprint'] as String?,
          subtitle: corrections['subtitle'] as String?,
          seriesGroup: corrections['series_group'] as String?,
          country: corrections['country'] as String?,
          language: corrections['language'] as String?,
          ageRating: corrections['age_rating'] as String?,
          audienceRating: corrections['audience_rating'] as String?,
          genres: corrections.containsKey('genres') ? edited.genres : null,
          platforms: corrections.containsKey('platforms')
              ? edited.game?.platforms
              : null,
          tracks:
              corrections.containsKey('tracks') ? edited.music?.tracks : null,
          creators: corrections.containsKey('creators')
              ? normalizeCreators(edited.creators)
              : null,
          characters:
              corrections.containsKey('characters') ? edited.characters : null,
          storyArcs:
              corrections.containsKey('story_arcs') ? edited.storyArcs : null,
          color: corrections['color'] as String?,
          nrDiscs: corrections.containsKey('nr_discs')
              ? edited.video?.nrDiscs
              : null,
          screenRatio: corrections['screen_ratio'] as String?,
          audioTracks: corrections['audio_tracks'] as String?,
          subtitles: corrections['subtitles'] as String?,
          layers: corrections['layers'] as String?,
          externalLinks: corrections.containsKey('external_links')
              ? edited.trailerUrls
              : null,
          crossover: corrections['crossover'] as String?,
          plotSummary: corrections['plot_summary'] as String?,
          plotDescription: corrections['plot_description'] as String?,
          catalogNumber: corrections['catalog_number'] as String?,
          releaseStatus: corrections['release_status'] as String?,
          barcode: corrections['barcode'] as String?,
          variantName: corrections['variant_name'] as String?,
          physicalFormat: corrections['physical_format'] as String?,
          coverImageUrl: corrections['cover_image_url'] as String?,
          thumbnailImageUrl: corrections['thumbnail_image_url'] as String?,
          explicitFields: corrections.keys.toSet(),
        );
  }

  Future<void> _addProviderCandidate(
    ProviderCandidate candidate,
    LibraryAddTarget target,
  ) async {
    final isAdmin = ref.read(authControllerProvider).isAdmin;
    if (!isAdmin || candidate.isStub) {
      final previewItem = await _providerAddItemForCandidate(candidate);
      await _addItems([previewItem], target);
      return;
    }
    var currentCandidate = candidate;
    try {
      while (mounted) {
        final preview = await _providerActionService.fetchPreview(
          api: ref.read(apiClientProvider),
          candidate: currentCandidate,
        );
        if (!mounted) return;

        final previewItem = metadataItemFromPreview(preview);
        final catalog = ref.read(mediaCatalogProvider).maybeWhen(
              data: (value) => value,
              orElse: () => fallbackMediaCatalog,
            );
        final visibleCandidates = _visibleProviderResults();
        final currentIndex = visibleCandidates.indexWhere(
          (entry) => entry.localCatalogId == currentCandidate.localCatalogId,
        );
        ProviderCandidate? navigateCandidate;

        final result = await showLibraryEditDialog(
          context: context,
          request: LibraryEditDialogRequest(
            type: widget.type,
            item: previewItem,
            ownedItem: null,
            accent: LibraryAccentScope.accentOf(context),
            scope: LibraryEditScope.all,
            physicalFormats: physicalMediaFormatsForKind(
              catalog,
              widget.type.workspace.kind,
            ),
            onPrevious: currentIndex > 0
                ? () {
                    navigateCandidate = visibleCandidates[currentIndex - 1];
                    Navigator.of(context).pop();
                  }
                : null,
            onNext:
                currentIndex >= 0 && currentIndex < visibleCandidates.length - 1
                    ? () {
                        navigateCandidate = visibleCandidates[currentIndex + 1];
                        Navigator.of(context).pop();
                      }
                    : null,
          ),
        );
        if (!mounted) return;
        if (navigateCandidate != null) {
          currentCandidate = navigateCandidate!;
          continue;
        }
        if (result == null) return;

        final ingest = await _providerActionService.ingestCandidate(
          api: ref.read(apiClientProvider),
          candidate: currentCandidate,
        );

        final edited = result.item;
        final ingested = metadataItemFromIngestResult(ingest.item);
        if (mounted) {
          await applyIngestCorrections(
            kind: ingested.kind,
            itemId: ingest.itemId,
            preview: previewItem,
            edited: edited,
          );
        }

        final finalItem = mergeProviderAddResult(
          ingested: ingested,
          edited: edited,
        );
        await _addItems([finalItem], target);
        return;
      }
    } catch (error) {
      if (mounted &&
          await _clearRejectedMetadataSession(error, 'Provider ingest')) {
        return;
      }
      if (mounted) {
        final api = ref.read(apiClientProvider);
        _rebuild(
          () => _error =
              'Provider ingest failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)}',
        );
      }
    }
  }

  Future<void> _proposeCandidate(ProviderCandidate candidate) async {
    if (_isAdding) {
      return;
    }
    var currentCandidate = candidate;
    LibraryEditSelection? result;
    while (mounted) {
      final visibleCandidates = _visibleProviderResults();
      final currentIndex = visibleCandidates.indexWhere(
        (entry) => entry.localCatalogId == currentCandidate.localCatalogId,
      );
      ProviderCandidate? navigateCandidate;
      result = await showLibraryEditDialog(
        context: context,
        request: LibraryEditDialogRequest(
          type: widget.type,
          item: proposalDraftFromCandidate(currentCandidate),
          ownedItem: null,
          accent: LibraryAccentScope.accentOf(context),
          physicalFormats: _currentPhysicalFormats(),
          onPrevious: currentIndex > 0
              ? () {
                  navigateCandidate = visibleCandidates[currentIndex - 1];
                  Navigator.of(context).pop();
                }
              : null,
          onNext:
              currentIndex >= 0 && currentIndex < visibleCandidates.length - 1
                  ? () {
                      navigateCandidate = visibleCandidates[currentIndex + 1];
                      Navigator.of(context).pop();
                    }
                  : null,
        ),
      );
      if (!mounted) {
        return;
      }
      if (navigateCandidate != null) {
        currentCandidate = navigateCandidate!;
        continue;
      }
      break;
    }
    if (result == null || !mounted) {
      return;
    }
    _rebuild(() {
      _isAdding = true;
      _error = null;
    });
    try {
      final proposalItem = result.item;
      await _providerActionService.proposeMetadata(
        api: ref.read(apiClientProvider),
        type: widget.type,
        candidate: currentCandidate,
        proposalItem: proposalItem,
      );
      if (!mounted) {
        return;
      }
      showAppToast(
        context,
        '${widget.type.singularLabel} metadata proposal sent for review.',
        tone: AppToastTone.success,
      );
      Navigator.of(context).pop(
        LibraryAddDialogResult(
          target: LibraryAddTarget.track,
          itemIds: [result.item.id],
        ),
      );
    } catch (error) {
      if (mounted) {
        showAppToast(
          context,
          _describeMetadataProposalError(error),
          tone: AppToastTone.error,
        );
      }
    } finally {
      if (mounted) {
        _rebuild(() => _isAdding = false);
      }
    }
  }

  Future<void> _queueProviderIngest(ProviderCandidate candidate) async {
    if (_isQueueingIngest ||
        _queuedProviderIngests.containsKey(candidate.localCatalogId)) {
      return;
    }
    await queueLibraryAddProviderIngestFlow(
      context: context,
      api: ref.read(apiClientProvider),
      candidate: candidate,
      providerActionService: _providerActionService,
      mounted: mounted,
      isQueueingIngest: _isQueueingIngest,
      clearRejectedMetadataSession: _clearRejectedMetadataSession,
      rebuild: _rebuild,
      setQueueingIngest: (value) => _isQueueingIngest = value,
      onQueued: (ingest) {
        _queuedProviderIngests[candidate.localCatalogId] = ingest;
      },
      setError: (message) => _error = message,
    );
  }

  LibraryMetadataItem proposalDraftFromCandidate(ProviderCandidate candidate) {
    return LibraryMetadataItem(
      id: buildPreviewCatalogItemId(
        kind: widget.type.workspace.kind.apiValue,
        provider: candidate.provider,
        providerItemId: candidate.providerItemId,
      ),
      kind: widget.type.workspace.kind.apiValue,
      title: candidate.title,
      synopsis: candidate.summary,
      coverImageUrl: candidate.imageUrl,
      thumbnailImageUrl: candidate.imageUrl,
    );
  }

  String _describeMetadataProposalError(Object error) {
    if (error case DioException dioError) {
      final statusCode = dioError.response?.statusCode;
      if (statusCode != null) {
        return 'Couldn\'t send the metadata proposal. Server responded with $statusCode.';
      }
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout) {
        return 'Couldn\'t send the metadata proposal. The request timed out.';
      }
      return 'Couldn\'t send the metadata proposal right now. Try again.';
    }
    final text = error.toString().trim();
    if (text.startsWith('StateError: ')) {
      return text.substring('StateError: '.length);
    }
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }
    return 'Couldn\'t send the metadata proposal. $text';
  }

  String get _activeProvider {
    final providers = widget.type.supportedMetadataProviders;
    for (final provider in providers) {
      if (provider.id == _searchState.selectedProvider) {
        return provider.id;
      }
    }
    return widget.type.defaultSupportedMetadataProvider;
  }

  LibraryMetadataItem? get _selectedResult {
    final id = _selectedResultId;
    if (id == null) {
      return null;
    }
    final hydrated = _previewState.hydratedResultFor(id);
    if (hydrated != null) {
      return hydrated;
    }
    for (final item in _results) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  BundleReleaseDetail? get _selectedBundleReleaseDetail {
    final bundleReleaseId = _selectedBundleReleaseId;
    if (bundleReleaseId == null) {
      return null;
    }
    return _previewState.bundleReleaseDetailForId(bundleReleaseId);
  }

  LibraryAddEditionSelection? _selectedEditionSelectionForItem(
    LibraryMetadataItem item,
  ) {
    final edition = previewEditionForItem(item, _selectedReferenceEditionId);
    if (edition == null) {
      return null;
    }
    final variant = selectedVariantForEdition(
      edition,
      _selectedReferenceVariantId,
    );
    return LibraryAddEditionSelection(
      editionId: edition.id,
      variantId: variant?.id,
    );
  }

  ProviderCandidate? get _selectedProviderCandidate {
    final id = _selectedProviderCandidateId;
    if (id == null) {
      return null;
    }
    for (final candidate in _providerResults) {
      if (candidate.localCatalogId == id) {
        return candidate;
      }
    }
    return null;
  }

  String get _providerQuery {
    return buildLibraryAddProviderQuery([
      _queryController.text,
      _searchSeriesController.text,
      _searchNumberController.text,
      _searchPublisherController.text,
      _searchYearController.text,
      _barcodeController.text,
    ]);
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _canonicalVideoSearchKind(String kind) =>
      catalogMediaKindFromValue(kind).apiValue;

  bool get _isVideoKind => widget.type.capabilities.supportsVideoKindFilters;

  bool get _showsVideoKindFilters =>
      _isVideoKind && widget.type.addChrome.videoKindFilterOptions.isNotEmpty;

  List<String> get _allVideoSearchKinds {
    final configured = widget.type.addChrome.videoKindFilterOptions
        .map((option) => _canonicalVideoSearchKind(option.kind))
        .toSet()
        .toList();
    return configured.isEmpty
        ? [_canonicalVideoSearchKind(widget.type.workspace.kind.apiValue)]
        : configured;
  }

  bool get _isMovieDesktopChrome => widget.type.capabilities.wideDialog;

  Future<List<LibraryMetadataItem>> _resolveCoreItemsForAdd(
    List<LibraryMetadataItem> items,
  ) async {
    if (items.isEmpty) {
      return const <LibraryMetadataItem>[];
    }
    final api = ref.read(apiClientProvider);
    final resolved = await Future.wait(
      items.map((item) async {
        final hydrated = _previewState.hydratedResultFor(item.id);
        if (hydrated != null) {
          return hydrated;
        }
        if (item.id.startsWith('local-') ||
            item.id.startsWith('preview-') ||
            item.id.startsWith('provider:')) {
          return item;
        }
        try {
          final full = await api
              .getTypedMetadataItem(
                kind: item.kind,
                id: item.id,
              )
              .then(
                (dto) => CatalogItem.fromJson({
                  ...dto.raw,
                  'id': dto.id,
                  'title': dto.title,
                  'kind': dto.kind,
                }),
              );
          var fullItem = LibraryMetadataItem.fromCatalogItem(full);
          if (fullItem.editions.isEmpty && item.editions.isNotEmpty) {
            fullItem = fullItem.copyWith(editions: item.editions);
          }
          final fallbackMusic = item.music;
          final currentMusic = fullItem.music;
          if (fallbackMusic != null && currentMusic != null) {
            final mergedMusic = MusicCatalogDetails(
              trackCount: currentMusic.trackCount ?? fallbackMusic.trackCount,
              tracks: currentMusic.tracks.isNotEmpty
                  ? currentMusic.tracks
                  : fallbackMusic.tracks,
              discs: currentMusic.discs.isNotEmpty
                  ? currentMusic.discs
                  : fallbackMusic.discs,
              catalogNumber:
                  currentMusic.catalogNumber ?? fallbackMusic.catalogNumber,
              releaseStatus:
                  currentMusic.releaseStatus ?? fallbackMusic.releaseStatus,
              originalReleaseDate: currentMusic.originalReleaseDate ??
                  fallbackMusic.originalReleaseDate,
              recordingDate:
                  currentMusic.recordingDate ?? fallbackMusic.recordingDate,
              studio: currentMusic.studio ?? fallbackMusic.studio,
              rpm: currentMusic.rpm ?? fallbackMusic.rpm,
              spars: currentMusic.spars ?? fallbackMusic.spars,
              soundType: currentMusic.soundType ?? fallbackMusic.soundType,
              vinylColor: currentMusic.vinylColor ?? fallbackMusic.vinylColor,
              vinylWeight:
                  currentMusic.vinylWeight ?? fallbackMusic.vinylWeight,
              mediaCondition:
                  currentMusic.mediaCondition ?? fallbackMusic.mediaCondition,
              instrument: currentMusic.instrument ?? fallbackMusic.instrument,
              isLive: currentMusic.isLive ?? fallbackMusic.isLive,
              composition:
                  currentMusic.composition ?? fallbackMusic.composition,
            );
            if (mergedMusic.hasData) {
              fullItem = fullItem.copyWith(music: mergedMusic);
            }
          } else if (currentMusic == null && fallbackMusic != null) {
            fullItem = fullItem.copyWith(music: fallbackMusic);
          }
          final hasCover = fullItem.displayCoverUrl != null;
          return hasCover
              ? fullItem
              : fullItem.copyWith(
                  coverImageUrl: item.coverImageUrl,
                  thumbnailImageUrl:
                      item.thumbnailImageUrl ?? item.coverImageUrl,
                );
        } catch (error, stackTrace) {
          logRecoverableError(
            source: 'library_add',
            message:
                'Falling back to lightweight add payload for ${item.kind}:${item.id}.',
            error: error,
            stackTrace: stackTrace,
          );
          return item;
        }
      }),
    );
    return resolved;
  }

  Future<void> _addItems(
    List<LibraryMetadataItem> items,
    LibraryAddTarget target, {
    LibraryAddReferenceType referenceType = LibraryAddReferenceType.media,
    LibraryAddDefaults? defaults,
    Map<String, LibraryAddOwnedDetails> ownedDetailsByItemId =
        const <String, LibraryAddOwnedDetails>{},
    Map<String, LibraryAddEditionSelection> editionSelectionsByItemId =
        const <String, LibraryAddEditionSelection>{},
    Map<String, String> bundleReleaseIdsByItemId = const <String, String>{},
  }) async {
    if (items.isEmpty || _isAdding) {
      return;
    }
    setState(() {
      _isAdding = true;
      _error = null;
    });
    try {
      await addLibraryItemsToTarget(
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        mutations: ref.read(collectionMutationsProvider),
        items: items,
        target: target,
        referenceType: referenceType,
        defaults: defaults ??
            LibraryAddDefaults(
              condition: _defaultCondition,
              grade: _defaultGrade,
              purchaseDate: _defaultPurchaseDate,
              locationId: _defaultLocationId,
              readStatus: _defaultReadStatus,
              tags: _defaultTags,
            ),
        ownedDetailsByItemId: ownedDetailsByItemId,
        editionSelectionsByItemId: editionSelectionsByItemId,
        bundleReleaseIdsByItemId: bundleReleaseIdsByItemId,
      );
      if (mounted) {
        Navigator.of(context).pop(
          LibraryAddDialogResult(
            target: target,
            itemIds: [for (final item in items) item.id],
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Add failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }
}
