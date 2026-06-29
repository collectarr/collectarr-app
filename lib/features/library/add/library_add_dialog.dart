import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/core/utils/image_url.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/add/compact_controls.dart';
import 'package:collectarr_app/features/library/add/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_search_operations.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/library_add_mode_tab.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
export 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/add/provider_add_result_merge.dart';
import 'package:collectarr_app/features/library/config/library_dialog_tokens.dart';
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

part 'library_add_mode_bar.dart';
part 'library_add_search_pane.dart';
part 'library_add_search_comic.dart';
part 'library_add_search_unified.dart';
part 'library_add_preview_pane.dart';
part 'library_add_bottom_bar.dart';
part 'library_add_manual_pane.dart';
part 'library_add_dialog_selection_state.dart';
part 'library_add_provider_ingest.dart';
part 'library_add_dialog_requests.dart';

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

class _LibraryAddDialogState extends ConsumerState<LibraryAddDialog> {
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
  Map<String, dynamic> _manualKindSpecific = {};
  Map<String, dynamic> _manualKindSpecificFactoryValues = {};
  // Controllers created by a kind-specific factory: tracked so we can dispose
  // them safely (dialog disposes dialog-owned controllers separately).
  final Set<TextEditingController> _manualKindSpecificCreatedControllers = {};
  DateTime? _soldAt;
  final _uuid = const Uuid();

  // Advanced search fields
  final _searchSeriesController = TextEditingController();
  final _searchNumberController = TextEditingController();
  final _searchPublisherController = TextEditingController();
  final _searchYearController = TextEditingController();
  bool _showAdvancedSearch = false;

  List<LibraryMetadataItem> _results = const [];
  List<ProviderCandidate> _providerResults = const [];
  final _queuedProviderIngests = <String, LibraryQueuedProviderIngest>{};
  final _checkedResultIds = <String>{};
  final _checkedProviderIds = <String>{};
  String? _error;
  late String _selectedProvider;
  bool _searchedProvider = false;
  bool _isSearching = false;
  bool _isSearchingProvider = false;
  bool _showCoreResults = true;
  bool _showProviderResults = true;
  bool _showMediaResults = true;
  bool _showReleaseResults = true;
  bool _isQueueingIngest = false;
  bool _isAdding = false;
  LibraryAddDialogMode _mode = LibraryAddDialogMode.search;
  LibraryAddTarget _addTarget = LibraryAddTarget.owned;
  LibraryAddReferenceType _referenceType = LibraryAddReferenceType.media;
  String? _selectedResultId;
  String? _selectedProviderCandidateId;
  String? _selectedBundleReleaseId;
  String? _selectedReferenceEditionId;
  String? _selectedReferenceVariantId;
  final _providerPreviews = <String, AdminProviderPreview>{};
  final _hydratedResults = <String, LibraryMetadataItem>{};
  final _bundleReleasesByItemId = <String, List<BundleReleaseSummary>>{};
  final _bundleReleaseDetailsById = <String, BundleReleaseDetail>{};
  String? _physicalFormatId;
  String _defaultCondition = 'Near Mint';
  String _defaultGrade = 'Ungraded';
  DateTime? _defaultPurchaseDate;
  String? _defaultReadStatus;
  String? _defaultTags;
  DateTime? _lastProviderSearchAt;
  String? _lastProviderSearchSignature;
  int _coreSearchGeneration = 0;
  int _providerSearchGeneration = 0;
  final _pendingHydratedResultIds = <String>{};
  final _pendingBundleReleaseItemIds = <String>{};
  final _pendingBundleReleaseDetailIds = <String>{};
  final _pendingProviderPreviewIds = <String>{};
  List<StorageLocation> _availableLocations = const [];
  List<String> _conditionOptions = const [];
  List<String> _gradeOptions = const [];
  List<String> _tagOptions = const [];
  List<String> _publisherOptions = const [];
  List<String> _imprintOptions = const [];
  List<String> _seriesGroupOptions = const [];
  List<String> _physicalFormatOptions = const [];
  List<SeriesRegistryEntry> _manualSeriesEntries = const [];
  String? _defaultLocationId;
  // Manual pane transient state
  late Map<String, String?> _manualCustomFieldValues;
  late List<ItemImage> _manualItemImages;
  LibraryCoverScanResult? _coverScanPrefill;
  bool _isScanningCover = false;
  String? _selectedManualSeriesId;
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

  // ── Autocomplete ──
  Timer? _autocompleteTimer;
  List<LibraryMetadataItem> _suggestions = const [];
  bool _showSuggestions = false;
  static const _autocompleteDebounce = Duration(milliseconds: 350);
  static const _autocompleteLimit = 8;

  /// Video-kind filter for movie library: allows searching across releases and box sets.
  late final Set<String> _videoKindFilters;

  @override
  void initState() {
    super.initState();
    registerLibraryAddBuilders();
    _syncManualKindSpecificFactoryValues();
    final defaultFilters = widget.type.addChrome.defaultVideoKindFilters
        .map(_canonicalVideoSearchKind)
        .toSet();
    _videoKindFilters = defaultFilters.isEmpty
        ? {
            _canonicalVideoSearchKind(widget.type.workspace.kind.apiValue),
          }
        : defaultFilters;
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
    // Manual custom field edits and item images default from widget inputs
    _manualCustomFieldValues = Map.of(widget.customFieldValues
        .asMap()
        .map((k, v) => MapEntry(v.fieldDefinitionId, v.value)));
    _manualItemImages = List.of(widget.itemImages);
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
    _disposeManualKindSpecificControllers();
    super.dispose();
  }

  void _disposeManualKindSpecificControllers() {
    for (final c in _manualKindSpecificCreatedControllers) {
      try {
        c.dispose();
      } catch (_) {}
    }
    _manualKindSpecificCreatedControllers.clear();
    _manualKindSpecificFactoryValues = {};
  }

  void _syncManualKindSpecificFactoryValues() {
    final factory = LibraryAddRegistry.manualKindSpecificFactoryFor(
        widget.type.workspace.kind);
    if (factory == null) {
      if (_manualKindSpecificFactoryValues.isNotEmpty ||
          _manualKindSpecificCreatedControllers.isNotEmpty) {
        _disposeManualKindSpecificControllers();
      }
      return;
    }
    if (_manualKindSpecificFactoryValues.isNotEmpty) {
      return;
    }
    final factoryMap = factory();
    for (final value in factoryMap.values) {
      if (value is TextEditingController) {
        _manualKindSpecificCreatedControllers.add(value);
      }
    }
    _manualKindSpecificFactoryValues = factoryMap;
  }

  Map<String, dynamic> _kindSpecificFactoryValues() {
    return _manualKindSpecificFactoryValues;
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
    final palette = appPalette(context);
    final movieDesktopWidth =
        _isMovieDesktopChrome ? 1540.0 : _defaultDialogWidth;
    final movieDesktopHeight =
        _isMovieDesktopChrome ? 920.0 : _defaultDialogHeight;
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
          _openManualEditor(_addTarget);
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
      onManual: () => _openManualEditor(_addTarget),
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
    return Theme(
      data: buildLibraryAddDialogTheme(accent, palette),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 720 ? 10 : 32,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (_dialogWidth ?? movieDesktopWidth)
                .clamp(_minDialogWidth, _maxDialogWidth),
            maxHeight: (_dialogHeight ?? movieDesktopHeight)
                .clamp(_minDialogHeight, _maxDialogHeight),
          ),
          child: _ResizableDialogShell(
            accent: accent,
            onResizeWidth: (delta) => setState(() {
              _dialogWidth = ((_dialogWidth ?? movieDesktopWidth) + delta)
                  .clamp(_minDialogWidth, _maxDialogWidth);
            }),
            onResizeHeight: (delta) => setState(() {
              _dialogHeight = ((_dialogHeight ?? movieDesktopHeight) + delta)
                  .clamp(_minDialogHeight, _maxDialogHeight);
            }),
            child: Column(
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
                        showCoreResults: _showCoreResults,
                        showProviderResults: _showProviderResults,
                        showMediaResults: _showMediaResults,
                        showReleaseResults: _showReleaseResults,
                        onSelectResult: (id) {
                          _selectCoreResult(id);
                        },
                        onSelectProviderCandidate: (id) {
                          _selectProviderCandidate(id);
                        },
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
                        onShowReleaseResultsChanged: (_) {},
                        onSearchCore: _search,
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
                            showCoreResults: searchPaneRequest.showCoreResults,
                            showProviderResults:
                                searchPaneRequest.showProviderResults,
                            showMediaResults:
                                searchPaneRequest.showMediaResults,
                            showReleaseResults:
                                searchPaneRequest.showReleaseResults,
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
                            onShowReleaseResultsChanged:
                                searchPaneRequest.onShowReleaseResultsChanged,
                            onSearchCore: searchPaneRequest.onSearchCore,
                          );
                      final searchPaneWithSourceToggles =
                          (_results.isNotEmpty || _providerResults.isNotEmpty)
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _SearchSourceToggles(
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
                                      showReleaseResults: _showReleaseResults,
                                      onShowMediaResultsChanged: (value) =>
                                          setState(() {
                                        if (!value && !_showReleaseResults) {
                                          return;
                                        }
                                        _showMediaResults = value;
                                        _pruneSelectionsForVisibility(
                                          visibleResults: _visibleCoreResults(),
                                          visibleProviderResults:
                                              _visibleProviderResults(),
                                        );
                                      }),
                                      onShowReleaseResultsChanged: (value) =>
                                          setState(() {
                                        if (!value && !_showMediaResults) {
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
                                  await _addProviderCandidate(
                                    candidate,
                                    _addTarget,
                                  );
                                }
                              },
                        onQueueIngest: selectedCandidate == null
                            ? null
                            : () => _queueProviderIngest(selectedCandidate),
                        onPropose: selectedCandidate == null
                            ? null
                            : () => _proposeCandidate(selectedCandidate),
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
          ),
        ),
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
        rerankHints: _currentLocalRerankHints(),
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
              ownedItemId: '',
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
      itemId: item.id,
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
      final rerankHints = _currentLocalRerankHints();

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
    if (_providerPreviews.containsKey(candidateId) ||
        _pendingProviderPreviewIds.contains(candidateId)) {
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
      _pendingProviderPreviewIds.add(candidateId);
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
        _providerPreviews[candidateId] = preview;
        _pendingProviderPreviewIds.remove(candidateId);
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
        _pendingProviderPreviewIds.remove(candidateId);
      });
    }
  }

  Future<void> _ensureSelectedResultLoaded(String itemId) async {
    if (_hydratedResults.containsKey(itemId) ||
        _pendingHydratedResultIds.contains(itemId)) {
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
      _pendingHydratedResultIds.add(itemId);
    });
    try {
      final hydrated = await ref.read(apiClientProvider).getMetadataItem(
            kind: selected.kind,
            id: itemId,
          );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      final hydratedItem = LibraryMetadataItem.fromCatalogItem(hydrated);
      final mergedItem = hydratedItem.displayCoverUrl != null
          ? hydratedItem
          : hydratedItem.copyWith(
              coverImageUrl: selected.coverImageUrl,
              thumbnailImageUrl:
                  selected.thumbnailImageUrl ?? selected.coverImageUrl,
            );
      setState(() {
        _hydratedResults[itemId] = mergedItem;
        _pendingHydratedResultIds.remove(itemId);
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
        _pendingHydratedResultIds.remove(itemId);
      });
    }
  }

  Future<void> _ensureBundleReleasesLoaded(String itemId) async {
    if (_bundleReleasesByItemId.containsKey(itemId) ||
        _pendingBundleReleaseItemIds.contains(itemId)) {
      return;
    }
    final searchGeneration = _coreSearchGeneration;
    setState(() {
      _pendingBundleReleaseItemIds.add(itemId);
    });
    try {
      final bundleReleases =
          await ref.read(apiClientProvider).getItemBundleReleases(itemId);
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _bundleReleasesByItemId[itemId] = bundleReleases;
        _pendingBundleReleaseItemIds.remove(itemId);
        if (_selectedResultId == itemId &&
            _referenceType == LibraryAddReferenceType.bundleRelease &&
            _selectedBundleReleaseId == null &&
            bundleReleases.isNotEmpty) {
          _selectedBundleReleaseId = bundleReleases.first.id;
        }
      });
      final bundleReleaseId = _selectedResultId == itemId &&
              _referenceType == LibraryAddReferenceType.bundleRelease
          ? _selectedBundleReleaseId
          : null;
      if (bundleReleaseId != null) {
        await _ensureBundleReleaseDetailLoaded(bundleReleaseId);
      }
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'library_add',
        message: 'Failed to load bundle releases for item $itemId.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _pendingBundleReleaseItemIds.remove(itemId);
      });
    }
  }

  Future<void> _ensureBundleReleaseDetailLoaded(String bundleReleaseId) async {
    if (_bundleReleaseDetailsById.containsKey(bundleReleaseId) ||
        _pendingBundleReleaseDetailIds.contains(bundleReleaseId)) {
      return;
    }
    final searchGeneration = _coreSearchGeneration;
    setState(() {
      _pendingBundleReleaseDetailIds.add(bundleReleaseId);
    });
    try {
      final bundleRelease =
          await ref.read(apiClientProvider).getBundleRelease(bundleReleaseId);
      if (!mounted || searchGeneration != _coreSearchGeneration) {
        return;
      }
      setState(() {
        _bundleReleaseDetailsById[bundleReleaseId] = bundleRelease;
        _pendingBundleReleaseDetailIds.remove(bundleReleaseId);
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
        _pendingBundleReleaseDetailIds.remove(bundleReleaseId);
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
    final uniqueUrls = <String>{
      for (final value in urls)
        if (normalizeNetworkImageUrl(value) case final normalized?) normalized,
    };
    await Future.wait([
      for (final url in uniqueUrls)
        precacheImage(
          CachedNetworkImageProvider(url),
          context,
          onError: (_, __) {},
        ).catchError((_) {}),
    ]);
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

  Future<void> _addProviderCandidate(
    ProviderCandidate candidate,
    LibraryAddTarget target,
  ) =>
      addProviderCandidate(candidate, target);

  Future<void> _proposeCandidate(ProviderCandidate candidate) =>
      proposeCandidate(candidate);

  Future<void> _queueProviderIngest(ProviderCandidate candidate) =>
      queueProviderIngest(candidate);

  String get _activeProvider {
    final providers = widget.type.supportedMetadataProviders;
    for (final provider in providers) {
      if (provider.id == _selectedProvider) {
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
    final hydrated = _hydratedResults[id];
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
    return _bundleReleaseDetailsById[bundleReleaseId];
  }

  LibraryAddEditionSelection? _selectedEditionSelectionForItem(
    LibraryMetadataItem item,
  ) {
    final edition = _previewEditionForItem(item, _selectedReferenceEditionId);
    if (edition == null) {
      return null;
    }
    final variant = _selectedVariantForEdition(
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

  Future<List<LibraryMetadataItem>> _resolveCoreItemsForAdd(
    List<LibraryMetadataItem> items,
  ) async {
    if (items.isEmpty) {
      return const <LibraryMetadataItem>[];
    }
    final api = ref.read(apiClientProvider);
    final resolved = await Future.wait(
      items.map((item) async {
        final hydrated = _hydratedResults[item.id];
        if (hydrated != null) {
          return hydrated;
        }
        if (item.id.startsWith('local-') ||
            item.id.startsWith('preview-') ||
            item.id.startsWith('provider:')) {
          return item;
        }
        try {
          final full = await api.getMetadataItem(kind: item.kind, id: item.id);
          final fullItem = LibraryMetadataItem.fromCatalogItem(full);
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

  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _availableLocations = locations;
    });
  }

  LibraryAddLocalRerankHints _currentLocalRerankHints() {
    return LibraryAddLocalRerankHints(
      query: _queryController.text.trim(),
      series: _searchSeriesController.text.trim(),
      issueNumber: _searchNumberController.text.trim(),
      publisher: _searchPublisherController.text.trim(),
      year: int.tryParse(_searchYearController.text.trim()),
    );
  }

  Future<void> _loadPrefillDefaults() async {
    final defaults = await PrefillDefaults.load();
    if (!mounted) {
      return;
    }
    setState(() {
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
    setState(() {
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
    setState(() {
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
    setState(() {
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
      setState(() {
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
    setState(() {
      _defaultLocationId = result.isEmpty ? null : result;
      _availableLocations = locations;
    });
  }
}
