import 'dart:async';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/add/compact_controls.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/models/library_add_content_scope.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/services/library_add_search_operations.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/library_add_mode_tab.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
export 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/services/provider_add_result_merge.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_add_registry.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/series/series_registry_dialog.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_search.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/error_banner.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

part '../panes/library_add_mode_bar.dart';
part '../panes/library_add_search_pane.dart';
part '../panes/library_add_search_comic.dart';
part '../panes/library_add_search_unified.dart';
part '../panes/library_add_preview_pane.dart';
part '../panes/library_add_bottom_bar.dart';
part '../panes/library_add_manual_pane.dart';
part '../controllers/library_add_controller.dart';
part '../controllers/library_add_search_controller.dart';
part '../controllers/library_add_selection_controller.dart';
part '../controllers/library_add_preview_controller.dart';
part '../controllers/library_add_kind_adapter.dart';
part '../controllers/library_add_manual_draft.dart';
part '../controllers/library_add_selection_state.dart';
part '../controllers/library_add_search_state.dart';
part 'library_add_shell.dart';
part '../controllers/library_add_dialog_selection_state.dart';
part '../controllers/library_add_provider_ingest.dart';
part '../controllers/library_add_dialog_requests.dart';

String buildPreviewCatalogItemId({
  required String kind,
  required String provider,
  required String providerItemId,
}) {
  final previewKey = '$kind:$provider:$providerItemId';
  return 'preview-$kind-${const Uuid().v5(Namespace.url.value, previewKey)}';
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
  ConsumerState<LibraryAddDialog> createState() => _LibraryAddDialogState();
}


class _LibraryAddDialogState extends ConsumerState<LibraryAddDialog>
    with LibraryAddDialogSelectionStateMixin,
        LibraryAddDefaultsControllerMixin,
        LibraryAddProviderIngestMixin {
  /// Wrapper so part-file extensions can call setState without triggering
  /// invalid_use_of_protected_member.
  void _rebuild([VoidCallback? fn]) {
    // ignore: invalid_use_of_protected_member
    setState(fn ?? () {});
  }

  final _queryController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _variantController = TextEditingController();
  final _physicalFormatLabelController = TextEditingController();
  final _coverController = TextEditingController();
  final _backCoverController = TextEditingController();
  final _creatorsController = TextEditingController();
  final _charactersController = TextEditingController();
  final _linksController = TextEditingController();
  final _editionTitleController = TextEditingController();
  final _releaseDateController = TextEditingController();
  final _pageCountController = TextEditingController();
  final _imprintController = TextEditingController();
  final _seriesGroupController = TextEditingController();
  final _countryController = TextEditingController();
  final _languageController = TextEditingController();
  final _ageRatingController = TextEditingController();
  final _genresEditController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _tagsController = TextEditingController();
  final _personalNotesController = TextEditingController();
  final _rawOrSlabbedController = TextEditingController();
  final _gradingCompanyController = TextEditingController();
  final _graderNotesController = TextEditingController();
  final _signedByController = TextEditingController();
  final _labelTypeController = TextEditingController();
  final _certificationNumberController = TextEditingController();
  final _coverPriceController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _purchaseStoreController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _soldDateController = TextEditingController();
  final _ownerLabelController = TextEditingController();
  // Holds the last-built manual pane kindSpecific map so helper accessors
  // can prefer kind-owned controllers when present.
  DateTime? _soldAt;
  final _uuid = const Uuid();

  // Advanced search fields
  final _searchSeriesController = TextEditingController();
  final _searchNumberController = TextEditingController();
  final _searchPublisherController = TextEditingController();
  final _searchYearController = TextEditingController();
  late final LibraryAddManualDraft _manualDraft;
  late final LibraryAddSelectionState _selectionState;
  late final LibraryAddSearchState _searchState;
  static const _providerSearchDebounce = Duration(milliseconds: 450);
  static const _coreSearchTimeout = Duration(seconds: 35);
  static const _minResultsPaneWidth = 280.0;
  static const _maxResultsPaneWidth = 860.0;
  static const _minPreviewPaneWidth = 360.0;
  static const _defaultDialogWidth = 1320.0;
  static const _defaultDialogHeight = 860.0;
  static const _minDialogWidth = 760.0;
  static const _maxDialogWidth = 1800.0;
  static const _minDialogHeight = 560.0;
  static const _maxDialogHeight = 1200.0;

  // ── Autocomplete ──
  Timer? _autocompleteTimer;
  static const _autocompleteDebounce = Duration(milliseconds: 350);
  static const _autocompleteLimit = 8;

  /// Video-kind filter for movie library: allows searching across releases and box sets.
  late final Set<String> _videoKindFilters;
  late final _LibraryAddController _controller;
  late final _LibraryAddSearchController _searchController;
  late final _LibraryAddSelectionController _selectionController;
  late final _LibraryAddPreviewController _previewController;

  String? get _error => _selectionState.error;
  set _error(String? value) => _selectionState.error = value;
  bool get _searchedProvider => _selectionState.searchedProvider;
  set _searchedProvider(bool value) => _selectionState.searchedProvider = value;
  bool get _isSearching => _selectionState.isSearching;
  set _isSearching(bool value) => _selectionState.isSearching = value;
  bool get _isSearchingProvider => _selectionState.isSearchingProvider;
  set _isSearchingProvider(bool value) =>
      _selectionState.isSearchingProvider = value;
  bool get _showCoreResults => _selectionState.showCoreResults;
  set _showCoreResults(bool value) => _selectionState.showCoreResults = value;
  bool get _showProviderResults => _selectionState.showProviderResults;
  set _showProviderResults(bool value) =>
      _selectionState.showProviderResults = value;
  bool get _showMediaResults => _selectionState.showMediaResults;
  set _showMediaResults(bool value) => _selectionState.showMediaResults = value;
  bool get _showSeasonResults => _selectionState.showSeasonResults;
  set _showSeasonResults(bool value) => _selectionState.showSeasonResults = value;
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
  set _compactComicIssues(bool value) => _selectionState.compactComicIssues = value;
  String? get _selectedResultId => _selectionState.selectedResultId;
  set _selectedResultId(String? value) => _selectionState.selectedResultId = value;
  String? get _selectedProviderCandidateId =>
      _selectionState.selectedProviderCandidateId;
  set _selectedProviderCandidateId(String? value) =>
      _selectionState.selectedProviderCandidateId = value;
  String? get _selectedBundleReleaseId => _selectionState.selectedBundleReleaseId;
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

  bool get _showAdvancedSearch => _searchState.showAdvancedSearch;
  set _showAdvancedSearch(bool value) =>
      _searchState.showAdvancedSearch = value;
  List<LibraryMetadataItem> get _results => _searchState.results;
  set _results(List<LibraryMetadataItem> value) => _searchState.results = value;
  List<ProviderCandidate> get _providerResults => _searchState.providerResults;
  set _providerResults(List<ProviderCandidate> value) =>
      _searchState.providerResults = value;
  Map<String, LibraryQueuedProviderIngest> get _queuedProviderIngests =>
      _searchState.queuedProviderIngests;
  Set<String> get _checkedResultIds => _searchState.checkedResultIds;
  Set<String> get _checkedProviderIds => _searchState.checkedProviderIds;
  String? get _selectedProvider => _searchState.selectedProvider;
  set _selectedProvider(String? value) => _searchState.selectedProvider = value;
  bool get _isQueueingIngest => _searchState.isQueueingIngest;
  set _isQueueingIngest(bool value) => _searchState.isQueueingIngest = value;
  bool get _isAdding => _searchState.isAdding;
  set _isAdding(bool value) => _searchState.isAdding = value;
  LibraryAddDialogMode get _mode => _searchState.mode;
  set _mode(LibraryAddDialogMode value) => _searchState.mode = value;
  LibraryAddTarget get _addTarget => _searchState.addTarget;
  set _addTarget(LibraryAddTarget value) => _searchState.addTarget = value;
  LibraryAddReferenceType get _referenceType => _searchState.referenceType;
  set _referenceType(LibraryAddReferenceType value) =>
      _searchState.referenceType = value;
  Map<String, AdminProviderPreview> get _providerPreviews =>
      _searchState.providerPreviews;
  Map<String, LibraryMetadataItem> get _hydratedResults =>
      _searchState.hydratedResults;
  Map<String, List<BundleReleaseSummary>> get _bundleReleasesByItemId =>
      _searchState.bundleReleasesByItemId;
  Map<String, BundleReleaseDetail> get _bundleReleaseDetailsById =>
      _searchState.bundleReleaseDetailsById;
  String? get _physicalFormatId => _searchState.physicalFormatId;
  set _physicalFormatId(String? value) => _searchState.physicalFormatId = value;
  String get _defaultCondition => _searchState.defaultCondition;
  set _defaultCondition(String value) => _searchState.defaultCondition = value;
  String get _defaultGrade => _searchState.defaultGrade;
  set _defaultGrade(String value) => _searchState.defaultGrade = value;
  DateTime? get _defaultPurchaseDate => _searchState.defaultPurchaseDate;
  set _defaultPurchaseDate(DateTime? value) =>
      _searchState.defaultPurchaseDate = value;
  String? get _defaultReadStatus => _searchState.defaultReadStatus;
  set _defaultReadStatus(String? value) =>
      _searchState.defaultReadStatus = value;
  String? get _defaultTags => _searchState.defaultTags;
  set _defaultTags(String? value) => _searchState.defaultTags = value;
  DateTime? get _lastProviderSearchAt => _searchState.lastProviderSearchAt;
  set _lastProviderSearchAt(DateTime? value) =>
      _searchState.lastProviderSearchAt = value;
  String? get _lastProviderSearchSignature =>
      _searchState.lastProviderSearchSignature;
  set _lastProviderSearchSignature(String? value) =>
      _searchState.lastProviderSearchSignature = value;
  int get _coreSearchGeneration => _searchState.coreSearchGeneration;
  set _coreSearchGeneration(int value) => _searchState.coreSearchGeneration = value;
  int get _providerSearchGeneration => _searchState.providerSearchGeneration;
  set _providerSearchGeneration(int value) =>
      _searchState.providerSearchGeneration = value;
  Set<String> get _pendingHydratedResultIds =>
      _searchState.pendingHydratedResultIds;
  Set<String> get _pendingBundleReleaseItemIds =>
      _searchState.pendingBundleReleaseItemIds;
  Set<String> get _pendingBundleReleaseDetailIds =>
      _searchState.pendingBundleReleaseDetailIds;
  Set<String> get _pendingProviderPreviewIds =>
      _searchState.pendingProviderPreviewIds;
  List<StorageLocation> get _availableLocations =>
      _searchState.availableLocations;
  set _availableLocations(List<StorageLocation> value) =>
      _searchState.availableLocations = value;
  List<String> get _conditionOptions => _searchState.conditionOptions;
  set _conditionOptions(List<String> value) =>
      _searchState.conditionOptions = value;
  List<String> get _gradeOptions => _searchState.gradeOptions;
  set _gradeOptions(List<String> value) => _searchState.gradeOptions = value;
  List<String> get _tagOptions => _searchState.tagOptions;
  set _tagOptions(List<String> value) => _searchState.tagOptions = value;
  List<String> get _publisherOptions => _searchState.publisherOptions;
  set _publisherOptions(List<String> value) =>
      _searchState.publisherOptions = value;
  List<String> get _imprintOptions => _searchState.imprintOptions;
  set _imprintOptions(List<String> value) => _searchState.imprintOptions = value;
  List<String> get _seriesGroupOptions => _searchState.seriesGroupOptions;
  set _seriesGroupOptions(List<String> value) =>
      _searchState.seriesGroupOptions = value;
  List<String> get _physicalFormatOptions => _searchState.physicalFormatOptions;
  set _physicalFormatOptions(List<String> value) =>
      _searchState.physicalFormatOptions = value;
  String? get _defaultLocationId => _searchState.defaultLocationId;
  set _defaultLocationId(String? value) => _searchState.defaultLocationId = value;
  bool get _isScanningCover => _searchState.isScanningCover;
  set _isScanningCover(bool value) => _searchState.isScanningCover = value;
  double? get _dialogWidth => _searchState.dialogWidth;
  set _dialogWidth(double? value) => _searchState.dialogWidth = value;
  double? get _dialogHeight => _searchState.dialogHeight;
  set _dialogHeight(double? value) => _searchState.dialogHeight = value;
  double get _resultsPaneWidth => _searchState.resultsPaneWidth;
  set _resultsPaneWidth(double value) => _searchState.resultsPaneWidth = value;
  List<LibraryMetadataItem> get _suggestions => _searchState.suggestions;
  set _suggestions(List<LibraryMetadataItem> value) =>
      _searchState.suggestions = value;
  bool get _showSuggestions => _searchState.showSuggestions;
  set _showSuggestions(bool value) => _searchState.showSuggestions = value;

  Map<String, dynamic> get _manualKindSpecific => _manualDraft.kindSpecific;
  set _manualKindSpecific(Map<String, dynamic> value) {
    _manualDraft.kindSpecific = value;
  }

  Map<String, dynamic> get _manualKindSpecificFactoryValues =>
      _manualDraft.kindSpecificFactoryValues;
  set _manualKindSpecificFactoryValues(Map<String, dynamic> value) {
    _manualDraft.kindSpecificFactoryValues = value;
  }

  Set<TextEditingController> get _manualKindSpecificCreatedControllers =>
      _manualDraft.createdControllers;

  List<SeriesRegistryEntry> get _manualSeriesEntries =>
      _manualDraft.seriesEntries;
  set _manualSeriesEntries(List<SeriesRegistryEntry> value) {
    _manualDraft.seriesEntries = value;
  }

  Map<String, String?> get _manualCustomFieldValues =>
      _manualDraft.customFieldValues;
  set _manualCustomFieldValues(Map<String, String?> value) {
    _manualDraft.customFieldValues = value;
  }

  List<ItemImage> get _manualItemImages => _manualDraft.itemImages;
  set _manualItemImages(List<ItemImage> value) {
    _manualDraft.itemImages = value;
  }

  LibraryCoverScanResult? get _coverScanPrefill =>
      _manualDraft.coverScanPrefill;
  set _coverScanPrefill(LibraryCoverScanResult? value) {
    _manualDraft.coverScanPrefill = value;
  }

  String? get _selectedManualSeriesId => _manualDraft.selectedSeriesId;
  set _selectedManualSeriesId(String? value) {
    _manualDraft.selectedSeriesId = value;
  }

  @override
  void initState() {
    super.initState();
    registerLibraryAddBuilders();
    _manualDraft = LibraryAddManualDraft(
      customFieldValues: widget.customFieldValues,
      itemImages: widget.itemImages,
    );
    _selectionState = LibraryAddSelectionState();
    _searchState = LibraryAddSearchState();
    _manualDraft.syncKindSpecificFactoryValues(widget.type.workspace.kind);
    final defaultFilters = widget.type.addChrome.defaultVideoKindFilters
        .map(_canonicalVideoSearchKind)
        .toSet();
    _videoKindFilters = defaultFilters.isEmpty
        ? {
            _canonicalVideoSearchKind(widget.type.workspace.kind.apiValue),
          }
        : defaultFilters;
    _searchController = _LibraryAddSearchController(this);
    _selectionController = _LibraryAddSelectionController(this);
    _previewController = _LibraryAddPreviewController(this);
    _controller = _LibraryAddController(
      search: _searchController,
      selection: _selectionController,
      preview: _previewController,
    );
    if (_isMovieDesktopChrome) {
      _resultsPaneWidth = 720;
    }
    _selectedProvider = widget.type.defaultSupportedMetadataProvider;
    _conditionOptions = widget.type.conditions;
    _gradeOptions = widget.type.grades;
    _loadAvailableLocations();
    _loadPickListOptions();
    _loadPrefillDefaults();
    _queryController.text = widget.initialQuery?.trim() ?? '';
    _barcodeController.text = widget.initialBarcode?.trim() ?? '';
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
      _manualDraft.dispose();
      _manualDraft.syncKindSpecificFactoryValues(widget.type.workspace.kind);
    }
  }

  @override
  void dispose() {
    _autocompleteTimer?.cancel();
    _queryController.dispose();
    _barcodeController.dispose();
    _titleController.dispose();
    _numberController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _variantController.dispose();
    _physicalFormatLabelController.dispose();
    _coverController.dispose();
    _backCoverController.dispose();
    _creatorsController.dispose();
    _charactersController.dispose();
    _linksController.dispose();
    _editionTitleController.dispose();
    _releaseDateController.dispose();
    _pageCountController.dispose();
    _imprintController.dispose();
    _seriesGroupController.dispose();
    _countryController.dispose();
    _languageController.dispose();
    _ageRatingController.dispose();
    _genresEditController.dispose();
    _synopsisController.dispose();
    _tagsController.dispose();
    _personalNotesController.dispose();
    _rawOrSlabbedController.dispose();
    _gradingCompanyController.dispose();
    _graderNotesController.dispose();
    _signedByController.dispose();
    _labelTypeController.dispose();
    _certificationNumberController.dispose();
    _coverPriceController.dispose();
    _priceController.dispose();
    _purchaseDateController.dispose();
    _purchaseStoreController.dispose();
    _sellPriceController.dispose();
    _soldDateController.dispose();
    _ownerLabelController.dispose();
    _searchSeriesController.dispose();
    _searchNumberController.dispose();
    _searchPublisherController.dispose();
    _searchYearController.dispose();
    _manualDraft.dispose();
    super.dispose();
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
        _controller.search.dismissSuggestions();
        _controller.search.search();
      },
      onQueryChanged: _controller.search.onQueryChanged,
      suggestions: _suggestions,
      showSuggestions: _showSuggestions,
      onSelectSuggestion: _controller.search.selectSuggestion,
      onDismissSuggestions: _controller.search.dismissSuggestions,
      canScanCover: widget.type.capabilities.canScanCover,
      isScanningCover: _isScanningCover,
      onScanCover: _controller.search.scanCover,
      onLookupBarcode: _controller.search.lookupBarcode,
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
    final movieDesktopWidth =
        _isMovieDesktopChrome ? 1540.0 : _defaultDialogWidth;
    final movieDesktopHeight =
        _isMovieDesktopChrome ? 920.0 : _defaultDialogHeight;
    return LibraryAddShell(
      accent: accent,
      width: _dialogWidth ?? movieDesktopWidth,
      height: _dialogHeight ?? movieDesktopHeight,
      minWidth: _minDialogWidth,
      maxWidth: _maxDialogWidth,
      minHeight: _minDialogHeight,
      maxHeight: _maxDialogHeight,
      onResizeWidth: (delta) => setState(() {
        _dialogWidth = ((_dialogWidth ?? movieDesktopWidth) + delta)
            .clamp(_minDialogWidth, _maxDialogWidth);
      }),
      onResizeHeight: (delta) => setState(() {
        _dialogHeight = ((_dialogHeight ?? movieDesktopHeight) + delta)
            .clamp(_minDialogHeight, _maxDialogHeight);
      }),
      header: const SizedBox.shrink(),
      body: Column(
              children: [
                widget.headerBuilder?.call(context, headerRequest) ??
                    LibraryAddRegistry.headerBuilderFor(
                            widget.type.workspace.kind)
                        ?.call(context, headerRequest) ??
                    AccentDialogHeader(
                      title: 'Add ${headerRequest.type.pluralLabel}',
                      accent: headerRequest.accent,
                      icon: headerRequest.type.workspace.icon,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                widget.modeBarBuilder?.call(context, modeBarRequest) ??
                    LibraryAddRegistry.modeBarBuilderFor(
                            widget.type.workspace.kind)
                        ?.call(context, modeBarRequest) ??
                    _LibraryAddModeBar(
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
                  _BarcodePrefillBanner(
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
                        selectedProviderCandidateId:
                            _selectedProviderCandidateId,
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
                        onSelectResult: _controller.selection.selectCoreResult,
                        onSelectProviderCandidate:
                            _controller.selection.selectProviderCandidate,
                        onToggleResultCheck: (id) => setState(() {
                          if (!_checkedResultIds.remove(id)) {
                            _checkedResultIds.add(id);
                          }
                        }),
                        onToggleProviderCheck: (id) => setState(() {
                          if (!_checkedProviderIds.remove(id)) {
                            _checkedProviderIds.add(id);
                          }
                        }),
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
                        onHideComicVariantResultsChanged: (value) =>
                            setState(() {
                          _hideComicVariantResults = value;
                          _pruneSelectionsForVisibility(
                            visibleResults: _visibleCoreResults(),
                            visibleProviderResults: _visibleProviderResults(),
                          );
                        }),
                        onCompactComicIssuesChanged: (value) =>
                            setState(() => _compactComicIssues = value),
                        onSearchCore: _controller.search.search,
                      );
                      final searchPane = widget.searchPaneBuilder
                              ?.call(context, searchPaneRequest) ??
                          LibraryAddRegistry.searchBuilderFor(
                                  widget.type.workspace.kind)
                              ?.call(context, searchPaneRequest) ??
                          _SearchPane(
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
                            selectedProvider:
                                searchPaneRequest.selectedProvider,
                            searchedProvider:
                                searchPaneRequest.searchedProvider,
                            selectedResultId:
                                searchPaneRequest.selectedResultId,
                            selectedProviderCandidateId:
                                searchPaneRequest.selectedProviderCandidateId,
                            checkedResultIds:
                                searchPaneRequest.checkedResultIds,
                            checkedProviderIds:
                                searchPaneRequest.checkedProviderIds,
                            ownedCatalogItemIds:
                                searchPaneRequest.ownedCatalogItemIds,
                            providerQueryText:
                                searchPaneRequest.providerQueryText,
                            providerSeriesText:
                                searchPaneRequest.providerSeriesText,
                            providerNumberText:
                                searchPaneRequest.providerNumberText,
                            providerPublisherText:
                                searchPaneRequest.providerPublisherText,
                            providerYearText:
                                searchPaneRequest.providerYearText,
                            isWideLayout: searchPaneRequest.isWideLayout,
                            showCoreResults: searchPaneRequest.showCoreResults,
                            showProviderResults:
                                searchPaneRequest.showProviderResults,
                            showMediaResults:
                                searchPaneRequest.showMediaResults,
                            showSeasonResults:
                                searchPaneRequest.showSeasonResults,
                            showReleaseResults:
                                searchPaneRequest.showReleaseResults,
                            hideComicOwnedResults:
                                searchPaneRequest.hideComicOwnedResults,
                            hideComicVariantResults:
                                searchPaneRequest.hideComicVariantResults,
                            compactComicIssues:
                                searchPaneRequest.compactComicIssues,
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
                            onHideComicOwnedResultsChanged: searchPaneRequest
                                .onHideComicOwnedResultsChanged,
                            onHideComicVariantResultsChanged: searchPaneRequest
                                .onHideComicVariantResultsChanged,
                            onCompactComicIssuesChanged:
                                searchPaneRequest.onCompactComicIssuesChanged,
                            onSearchCore: searchPaneRequest.onSearchCore,
                          );
                      final searchPaneWithSourceToggles =
                          (_results.isNotEmpty || _providerResults.isNotEmpty)
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _SearchSourceToggles(
                                      type: widget.type,
                                      showCoreResults: _showCoreResults,
                                      showProviderResults: _showProviderResults,
                                      onShowCoreResultsChanged: (value) =>
                                          setState(() {
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
                                      onShowMediaResultsChanged: (value) =>
                                          setState(() {
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
                                      onShowSeasonResultsChanged: (value) =>
                                          setState(() {
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
                      final previewPane = _LibraryAddPreviewPane(
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
                            : _providerPreviews[
                                selectedCandidate.localCatalogId],
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
                        selectedBundleReleaseDetail:
                            _selectedBundleReleaseDetail,
                        selectedEditionId: _selectedReferenceEditionId,
                        selectedVariantId: _selectedReferenceVariantId,
                        isLoadingBundleReleases: selectedResult != null &&
                            _pendingBundleReleaseItemIds
                                .contains(selectedResult.id),
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
                      _manualKindSpecific =
                          _manualDraft.buildKindSpecificMap(kindSpecificMap);

                      final manualRequest = LibraryAddManualPaneRequest(
                        type: widget.type,
                        accent: accent,
                        titleController: _titleController,
                        numberController: _numberController,
                        publisherController: _publisherController,
                        yearController: _yearController,
                        barcodeController: _barcodeController,
                        variantController: _variantController,
                        physicalFormatLabelController:
                            _physicalFormatLabelController,
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
                        onAddWishlist: () =>
                            _addManual(LibraryAddTarget.wishlist),
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
                        onManagePhysicalFormats: () =>
                            _manageSingleValuePickList(
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
                        onCustomFieldValuesChanged: (m) => setState(
                            () => _manualCustomFieldValues = Map.of(m)),
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
                      final manualPane = widget.manualPaneBuilder
                              ?.call(context, manualRequest) ??
                          LibraryAddRegistry.manualBuilderFor(
                                  widget.type.workspace.kind)
                              ?.call(context, manualRequest) ??
                          _ManualPane(request: manualRequest);
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
                          _LibraryAddPaneResizeDivider(
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
                      final addItems = checkedItems.isNotEmpty
                          ? checkedItems
                          : [if (selectedResult != null) selectedResult];
                      final addCount = addItems.length;
                      final selectedEditionSelection = selectedResult == null
                          ? null
                          : _selectedEditionSelectionForItem(selectedResult);
                      final requiresBundleSelection =
                          _addTarget != LibraryAddTarget.track &&
                              _referenceType ==
                                  LibraryAddReferenceType.bundleRelease;
                      final requiresEditionSelection =
                          _addTarget != LibraryAddTarget.track &&
                              _referenceType == LibraryAddReferenceType.edition;
                      final canAddBundleSelection = !requiresBundleSelection ||
                          (addCount == 1 &&
                              selectedResult != null &&
                              _selectedBundleReleaseId != null);
                      final canAddEditionSelection =
                          !requiresEditionSelection ||
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
                                    selectedCandidate == null) ||
                                !canAddBundleSelection ||
                                !canAddEditionSelection
                            ? null
                            : () async {
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
                                        ? const <String,
                                            LibraryAddEditionSelection>{}
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
                                  await _controller.preview.addProviderCandidate(
                                    candidate,
                                    _addTarget,
                                  );
                                }
                              },
                        onQueueIngest: selectedCandidate == null
                            ? null
                            : () => _controller.preview.queueProviderIngest(
                                  selectedCandidate,
                                ),
                        onPropose: selectedCandidate == null
                            ? null
                            : () => _controller.preview.proposeCandidate(
                                  selectedCandidate,
                                ),
                      );
                      return widget.bottomBarBuilder
                              ?.call(context, bottomBarRequest) ??
                          LibraryAddRegistry.bottomBarBuilderFor(
                                  widget.type.workspace.kind)
                              ?.call(context, bottomBarRequest) ??
                          _LibraryAddBottomBar(
                            type: bottomBarRequest.type,
                            isMovieDesktopChrome:
                                bottomBarRequest.isMovieDesktopChrome,
                            conditions: bottomBarRequest.conditions,
                            grades: bottomBarRequest.grades,
                            defaultTags: bottomBarRequest.defaultTags,
                            accent: bottomBarRequest.accent,
                            selectedItem: bottomBarRequest.selectedItem,
                            selectedCandidate:
                                bottomBarRequest.selectedCandidate,
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
                            defaultPurchaseDate:
                                bottomBarRequest.defaultPurchaseDate,
                            onAddTargetChanged:
                                bottomBarRequest.onAddTargetChanged,
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

}
