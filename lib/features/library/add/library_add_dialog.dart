import 'dart:async';

import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_contracts.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_manual_draft.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_controller.dart';
import 'package:collectarr_app/features/library/add/library_add_registry.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/comic_add_search_options_scope.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/models/movie_add_chrome_scope.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_bottom_bar.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_mode_bar.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_preview_pane.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_search_pane.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_shell.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/series/series_registry_dialog.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

export 'controllers/library_add_dialog_requests.dart';
export 'controllers/library_add_manual_draft.dart';
export 'library_add_ranking.dart';
export 'panes/library_add_preview_pane.dart';

String buildPreviewCatalogItemId({
  required String kind,
  required String provider,
  required String providerItemId,
}) {
  final previewKey = '$kind:$provider:$providerItemId';
  return 'preview-$kind-${const Uuid().v5(Namespace.url.value, previewKey)}';
}

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
  late final LibraryAddSessionController _controller;
  late final LibraryAddManualDraft _manualDraft;

  late final TextEditingController _queryController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _searchSeriesController;
  late final TextEditingController _searchNumberController;
  late final TextEditingController _searchPublisherController;
  late final TextEditingController _searchYearController;

  List<StorageLocation> _availableLocations = const [];
  List<String> _conditionOptions = const [];
  List<String> _gradeOptions = const [];
  List<String> _tagOptions = const [];

  double? _dialogWidth;
  double? _dialogHeight;
  static const _defaultDialogWidth = 1320.0;
  static const _defaultDialogHeight = 860.0;
  static const _minDialogWidth = 760.0;
  static const _maxDialogWidth = 1800.0;
  static const _minDialogHeight = 560.0;
  static const _maxDialogHeight = 1200.0;

  double _resultsPaneWidth = 500;

  double _clampedResultsPaneWidth(double totalWidth) {
    final minResultsWidth = 320.0;
    final minPreviewWidth = 320.0;
    final maxResultsWidth = (totalWidth - minPreviewWidth).clamp(
      minResultsWidth,
      totalWidth,
    );
    return _resultsPaneWidth.clamp(minResultsWidth, maxResultsWidth);
  }

  void _resizeResultsPane(double delta, double totalWidth) {
    setState(() {
      _resultsPaneWidth = _clampedResultsPaneWidth(totalWidth) + delta;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.type.capabilities.wideDialog) {
      _resultsPaneWidth = 720;
    }
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    _barcodeController =
        TextEditingController(text: widget.initialBarcode ?? '');
    _searchSeriesController = TextEditingController();
    _searchNumberController = TextEditingController();
    _searchPublisherController = TextEditingController();
    _searchYearController = TextEditingController();

    _manualDraft = LibraryAddManualDraft(
      customFieldValues: widget.customFieldValues,
      itemImages: widget.itemImages,
    );
    _manualDraft.syncKindSpecificFactoryValues(widget.type.workspace.kind);
    _manualDraft.titleController.text = _queryController.text;

    _controller = LibraryAddSessionController(
      kind: widget.type.workspace.kind,
      type: widget.type,
      ownedMutations: ref.read(ownedItemMutationsProvider),
      wishlistMutations: ref.read(wishlistMutationsProvider),
      trackingMutations: ref.read(trackingMutationsProvider),
      api: ref.read(apiClientProvider),
      catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
      providerRegistry: ref.read(providerRegistryProvider).value ??
          buildDefaultProviderRegistry(),
      coverScanService: widget.coverScanService,
      onAuthSessionExpired: (error, action) => ref
          .read(authControllerProvider.notifier)
          .clearSessionIfRejected(error),
    );

    _controller.addListener(_onControllerStateChanged);

    _conditionOptions = widget.type.conditions;
    _gradeOptions = widget.type.grades;
    _loadAvailableLocations();
    _loadPickListOptions();
    _loadPrefillDefaults();

    if (widget.initialBarcode != null &&
        widget.initialBarcode!.isNotEmpty &&
        widget.autoLookupInitialBarcode) {
      _controller.setMode(LibraryAddDialogMode.barcode);
      _controller.updateBarcode(widget.initialBarcode!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.lookupBarcode(barcode: widget.initialBarcode!);
      });
    } else if (widget.initialBarcode != null &&
        widget.initialBarcode!.isNotEmpty) {
      _controller.setMode(LibraryAddDialogMode.barcode);
      _controller.updateBarcode(widget.initialBarcode!);
    } else if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.updateQuery(widget.initialQuery!);
    }
  }

  void _onControllerStateChanged() {
    if (!mounted) return;
    final state = _controller.state;
    if (_queryController.text != state.search.query) {
      _queryController.value = TextEditingValue(
        text: state.search.query,
        selection: TextSelection.collapsed(offset: state.search.query.length),
      );
    }
    if (_barcodeController.text != state.search.barcode) {
      _barcodeController.value = TextEditingValue(
        text: state.search.barcode,
        selection: TextSelection.collapsed(offset: state.search.barcode.length),
      );
    }
    if (_searchSeriesController.text != state.search.series) {
      _searchSeriesController.text = state.search.series;
    }
    if (_searchNumberController.text != state.search.number) {
      _searchNumberController.text = state.search.number;
    }
    if (_searchPublisherController.text != state.search.publisher) {
      _searchPublisherController.text = state.search.publisher;
    }
    if (_searchYearController.text != state.search.year) {
      _searchYearController.text = state.search.year;
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant LibraryAddDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type.workspace.kind != widget.type.workspace.kind) {
      _manualDraft.disposeKindSpecificFactoryValues();
      _manualDraft.syncKindSpecificFactoryValues(widget.type.workspace.kind);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    _controller.dispose();
    _queryController.dispose();
    _barcodeController.dispose();
    _searchSeriesController.dispose();
    _searchNumberController.dispose();
    _searchPublisherController.dispose();
    _searchYearController.dispose();
    _manualDraft.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableLocations() async {
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) return;
    setState(() {
      _availableLocations = locations;
    });
  }

  Future<void> _loadPrefillDefaults() async {
    final defaults = await PrefillDefaults.load();
    if (!mounted) return;
    if (defaults.condition?.trim().isNotEmpty == true) {
      _controller.setDefaultCondition(defaults.condition!.trim());
    }
    if (defaults.grade?.trim().isNotEmpty == true) {
      _controller.setDefaultGrade(defaults.grade!.trim());
    }
    if (defaults.readStatus != null) {
      _controller.setDefaultReadStatus(defaults.readStatus);
    }
    if (defaults.tags != null) {
      _controller.setDefaultTags(defaults.tags);
    }
    if (defaults.locationId != null) {
      _controller.setDefaultLocationId(defaults.locationId);
    }
    await _loadPickListOptions();
  }

  Future<void> _loadPickListOptions() async {
    final state = _controller.state;
    final options = await loadConditionGradePickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      builtInConditions: widget.type.conditions,
      builtInGrades: widget.type.grades,
      selectedCondition: state.defaultCondition,
      selectedGrade: state.defaultGrade,
    );
    final tagOptions = await loadTagPickListOptions(
      ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTags: splitPickListValues(state.defaultTags),
    );
    final db = ref.read(localDatabaseProvider);
    final vocabularyResults = await Future.wait<dynamic>([
      loadSingleValuePickListOptions(
        db,
        listName: kPublisherPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _manualDraft.publisherController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kImprintPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _manualDraft.imprintController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kSeriesGroupPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedValue: _manualDraft.seriesGroupController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: kPhysicalFormatPickListName,
        mediaKind: widget.type.workspace.kind.apiValue,
        builtInValues: [
          for (final format in _currentPhysicalFormats()) format.label,
        ],
        selectedValue: _manualDraft.physicalFormatLabelController.text,
      ),
      SeriesRegistryRepository(db).searchEntries(
        mediaKind: widget.type.workspace.kind.apiValue,
        selectedTitle: _manualDraft.titleController.text,
        selectedSeriesId: _manualDraft.selectedSeriesId,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _conditionOptions = options.conditions;
      _gradeOptions = options.grades;
      _tagOptions = tagOptions;
      _manualDraft.publisherOptions =
          List<String>.from(vocabularyResults[0] as List<String>);
      _manualDraft.imprintOptions =
          List<String>.from(vocabularyResults[1] as List<String>);
      _manualDraft.seriesGroupOptions =
          List<String>.from(vocabularyResults[2] as List<String>);
      _manualDraft.physicalFormatOptions =
          List<String>.from(vocabularyResults[3] as List<String>);
      _manualDraft.seriesEntries = List<SeriesRegistryEntry>.from(
        vocabularyResults[4] as List<SeriesRegistryEntry>,
      );
    });
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
    if (!mounted) return;
    await _loadPickListOptions();
  }

  Future<void> _openManualSeriesPicker() async {
    final selected = await showSeriesPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      mediaKind: widget.type.workspace.kind.apiValue,
      selectedTitle: _manualDraft.titleController.text,
      selectedSeriesId: _manualDraft.selectedSeriesId,
    );
    if (!mounted || selected == null) return;
    setState(() {
      _manualDraft.selectedSeriesId = selected.coreSeriesId;
      _manualDraft.titleController.value = TextEditingValue(
        text: selected.title,
        selection: TextSelection.collapsed(offset: selected.title.length),
      );
    });
    await _loadPickListOptions();
  }

  void _setManualSeries(String? value) {
    final normalized = (value ?? '').trim();
    final match =
        _manualDraft.seriesEntries.cast<SeriesRegistryEntry?>().firstWhere(
              (entry) =>
                  entry != null &&
                  entry.title.trim().toLowerCase() == normalized.toLowerCase(),
              orElse: () => null,
            );
    setState(() {
      _manualDraft.selectedSeriesId = match?.coreSeriesId;
    });
  }

  Future<void> _showDefaultTagsEditor() async {
    final controller =
        TextEditingController(text: _controller.state.defaultTags ?? '');
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (dialogCtx) => AccentAlertDialog(
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
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(
                joinPickListValues(splitPickListValues(controller.text)) ?? '',
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      );
      if (!mounted || result == null) return;
      _controller.setDefaultTags(result.isEmpty ? null : result);
    } finally {
      controller.dispose();
    }
  }

  Future<void> _pickDefaultLocation() async {
    final result = await showLocationPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      currentLocationId: _controller.state.defaultLocationId,
    );
    if (result == null) return;
    final locations =
        await LocationRepository(ref.read(localDatabaseProvider)).getAll();
    if (!mounted) return;
    setState(() {
      _availableLocations = locations;
    });
    _controller.setDefaultLocationId(result.isEmpty ? null : result);
  }

  Future<void> _proposeCandidate(ProviderCandidate candidate) async {
    await _controller.proposalFlowService.proposeCandidate(
      context: context,
      api: ref.read(apiClientProvider),
      type: widget.type,
      candidate: candidate,
      providerActionService: _controller.providerActionService,
      orchestrationService: _controller.providerOrchestrationService,
      mounted: mounted,
      isAdding: _controller.state.isAdding,
      rebuild: (fn) {
        if (mounted) setState(fn);
      },
      setIsAdding: (bool value) {
        _controller.state = _controller.state.copyWith(isAdding: value);
      },
      setError: (String? message) {
        _controller.state = _controller.state.copyWith(
          search: _controller.state.search.copyWith(error: message),
        );
      },
      visibleProviderResults: () =>
          _controller.state.visibleProviderResults(widget.type),
      currentPhysicalFormats: _currentPhysicalFormats,
      showEditDialog: (ctx, req) =>
          showLibraryEditDialog(context: ctx, request: req),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent ??
        LibraryAccentScope.accentOf(context,
            fallback: widget.type.workspace.accent);
    final state = _controller.state;
    final ownedByCatalogId = ref.watch(collectionByCatalogItemProvider);
    final isMovieDesktopChrome = widget.type.capabilities.wideDialog;
    final visibleCore = state.visibleCoreResults(
      widget.type,
      isOwnedCatalogItem: (id) => ownedByCatalogId.containsKey(id),
    );
    final visibleProvider = state.visibleProviderResults(widget.type);
    final selectedCandidate = state.selectedCandidate;
    final selectedItem = state.selectedItem;

    final kind = widget.type.workspace.kind;
    final headerBuilder =
        widget.headerBuilder ?? LibraryAddRegistry.headerBuilderFor(kind);
    final modeBarBuilder =
        widget.modeBarBuilder ?? LibraryAddRegistry.modeBarBuilderFor(kind);
    final searchPaneBuilder =
        widget.searchPaneBuilder ?? LibraryAddRegistry.searchBuilderFor(kind);
    final manualPaneBuilder =
        widget.manualPaneBuilder ?? LibraryAddRegistry.manualBuilderFor(kind);
    final previewPaneBuilder =
        widget.previewPaneBuilder ?? LibraryAddRegistry.previewBuilderFor(kind);
    final bottomBarBuilder =
        widget.bottomBarBuilder ?? LibraryAddRegistry.bottomBarBuilderFor(kind);

    final headerRequest = LibraryAddHeaderRequest(
      type: widget.type,
      accent: accent,
      onClose: () => Navigator.of(context).pop(),
    );

    final modeBarRequest = LibraryAddModeBarRequest(
      type: widget.type,
      accent: accent,
      isMovieDesktopChrome: isMovieDesktopChrome,
      mode: state.mode,
      queryController: _queryController,
      barcodeController: _barcodeController,
      isSearching: state.search.isSearching,
      isSearchingProvider: state.search.isSearchingProvider,
      onModeChanged: (mode) {
        if (mode == LibraryAddDialogMode.manual) {
          _manualDraft.titleController.text = _queryController.text;
        }
        _controller.setMode(mode);
      },
      onSearch: () {
        _controller.dismissSuggestions();
        final series = _searchSeriesController.text;
        final number = _searchNumberController.text;
        final publisher = _searchPublisherController.text;
        final year = _searchYearController.text;
        final query = _queryController.text;
        _controller.updateSearchSeries(series);
        _controller.updateSearchNumber(number);
        _controller.updateSearchPublisher(publisher);
        _controller.updateSearchYear(year);
        _controller.updateQuery(query);
        _controller.executeSearch();
      },
      onQueryChanged: _controller.updateQuery,
      suggestions: state.search.suggestions,
      showSuggestions: state.search.showSuggestions,
      onSelectSuggestion: (item) {
        _queryController.text = item.title;
        _controller.selectSuggestion(item);
      },
      onDismissSuggestions: _controller.dismissSuggestions,
      canScanCover: widget.type.capabilities.canScanCover,
      isScanningCover: state.search.isScanningCover,
      onScanCover: () => _controller.scanCover(context),
      onLookupBarcode: () => _controller.lookupBarcode(
        barcode: _barcodeController.text,
      ),
      onManual: () {
        _manualDraft.titleController.text = _queryController.text;
        _controller.setMode(LibraryAddDialogMode.manual);
      },
      showAdvanced: state.search.showAdvancedSearch,
      onToggleAdvanced: _controller.toggleAdvancedSearch,
      seriesController: _searchSeriesController,
      numberController: _searchNumberController,
      publisherController: _searchPublisherController,
      yearController: _searchYearController,
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
          headerBuilder?.call(context, headerRequest) ??
              AccentDialogHeader(
                title: 'Add ${widget.type.pluralLabel}',
                accent: accent,
                icon: widget.type.workspace.icon,
                onClose: () => Navigator.of(context).pop(),
              ),
          MovieAddChromeScope(
            isWideChrome: isMovieDesktopChrome,
            videoKindFilters: state.search.videoKindFilters,
            showVideoKindFilters:
                widget.type.addChrome.videoKindFilterOptions.isNotEmpty,
            onVideoKindFilterChanged: (k, checked) {
              _controller.setVideoKindFilter(k, checked);
            },
            child: Builder(
              builder: (scopedContext) =>
                  modeBarBuilder?.call(scopedContext, modeBarRequest) ??
                  LibraryAddModeBar(
                    type: modeBarRequest.type,
                    accent: modeBarRequest.accent,
                    isMovieDesktopChrome: isMovieDesktopChrome,
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
                    videoKindFilters:
                        widget.type.addChrome.videoKindFilterOptions.isNotEmpty
                            ? state.search.videoKindFilters
                            : null,
                    onVideoKindFilterChanged:
                        widget.type.addChrome.videoKindFilterOptions.isNotEmpty
                            ? (k, checked) =>
                                _controller.setVideoKindFilter(k, checked)
                            : null,
                  ),
            ),
          ),
          if (_barcodeController.text.trim().isNotEmpty)
            LibraryAddBarcodePrefillBanner(
              type: widget.type,
              barcode: _barcodeController.text.trim(),
            ),
          Expanded(
            child: switch (state.mode) {
              LibraryAddDialogMode.search ||
              LibraryAddDialogMode.barcode =>
                LayoutBuilder(
                  builder: (context, constraints) {
                    final searchPaneRequest = LibraryAddSearchPaneRequest(
                      type: widget.type,
                      isBusy: state.search.isBusy,
                      error: state.search.error,
                      accent: accent,
                      results: visibleCore,
                      providerResults: visibleProvider,
                      queuedProviderIngests:
                          state.preview.queuedProviderIngests,
                      selectedProvider: state.search.selectedProvider,
                      searchedProvider: state.search.searchedProvider,
                      selectedResultId: state.selection.selectedResultId,
                      selectedProviderCandidateId:
                          state.selection.selectedProviderCandidateId,
                      checkedResultIds: state.selection.checkedResultIds,
                      checkedProviderIds: state.selection.checkedProviderIds,
                      ownedCatalogItemIds: ownedByCatalogId.keys.toSet(),
                      providerQueryText: _queryController.text,
                      providerSeriesText: _searchSeriesController.text,
                      providerNumberText: _searchNumberController.text,
                      providerPublisherText: _searchPublisherController.text,
                      providerYearText: _searchYearController.text,
                      isWideLayout: constraints.maxWidth >= 720,
                      showCoreResults: state.selection.showCoreResults,
                      showProviderResults: state.selection.showProviderResults,
                      showMediaResults: state.selection.showMediaResults,
                      showSeasonResults: state.selection.showSeasonResults,
                      showReleaseResults: state.selection.showReleaseResults,
                      onSelectResult: _controller.selectResult,
                      onSelectProviderCandidate:
                          _controller.selectProviderCandidate,
                      onToggleResultCheck: _controller.toggleCheckedResult,
                      onToggleProviderCheck: _controller.toggleCheckedProvider,
                      onShowCoreResultsChanged: _controller.setShowCoreResults,
                      onShowProviderResultsChanged:
                          _controller.setShowProviderResults,
                      onShowMediaResultsChanged:
                          _controller.setShowMediaResults,
                      onShowSeasonResultsChanged:
                          _controller.setShowSeasonResults,
                      onShowReleaseResultsChanged:
                          _controller.setShowReleaseResults,
                      onSearchCore: _controller.executeSearch,
                    );

                    final searchPaneWidget = ComicAddSearchOptionsScope(
                      hideOwnedResults: state.selection.hideComicOwnedResults,
                      hideVariantResults:
                          state.selection.hideComicVariantResults,
                      compactIssues: state.selection.compactComicIssues,
                      onHideOwnedResultsChanged:
                          _controller.setHideComicOwnedResults,
                      onHideVariantResultsChanged:
                          _controller.setHideComicVariantResults,
                      onCompactIssuesChanged: _controller.setCompactComicIssues,
                      child: searchPaneBuilder?.call(
                              context, searchPaneRequest) ??
                          LibraryAddSearchPane(
                            type: searchPaneRequest.type,
                            isBusy: searchPaneRequest.isBusy,
                            isMovieDesktopChrome: isMovieDesktopChrome,
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
                                state.selection.hideComicOwnedResults,
                            hideComicVariantResults:
                                state.selection.hideComicVariantResults,
                            compactComicIssues:
                                state.selection.compactComicIssues,
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
                                _controller.setHideComicOwnedResults,
                            onHideComicVariantResultsChanged:
                                _controller.setHideComicVariantResults,
                            onCompactComicIssuesChanged:
                                _controller.setCompactComicIssues,
                            onSearchCore: searchPaneRequest.onSearchCore,
                          ),
                    );

                    final previewPaneWidget = LibraryAddPreviewPane(
                      type: widget.type,
                      accent: accent,
                      isMovieDesktopChrome: isMovieDesktopChrome,
                      previewPaneBuilder: previewPaneBuilder,
                      item: selectedItem,
                      candidate: selectedCandidate,
                      candidatePreview: selectedCandidate == null
                          ? null
                          : state.preview.providerPreviews[
                              selectedCandidate.localCatalogId],
                      isFetchingPreview: (selectedCandidate != null &&
                              state.preview.pendingProviderPreviewIds.contains(
                                  selectedCandidate.localCatalogId)) ||
                          (selectedItem != null &&
                              state.preview.pendingHydratedResultIds
                                  .contains(selectedItem.id)),
                      providerLabel: widget.type
                          .metadataProviderLabel(state.search.selectedProvider),
                      searched: state.search.results.isNotEmpty ||
                          state.search.searchedProvider,
                      addTarget: state.target,
                      referenceType: state.selection.referenceType,
                      availableBundleReleases: selectedItem == null
                          ? const <BundleReleaseSummary>[]
                          : state.preview
                                  .bundleReleasesByItemId[selectedItem.id] ??
                              const <BundleReleaseSummary>[],
                      selectedBundleReleaseId:
                          state.selection.selectedBundleReleaseId,
                      selectedBundleReleaseDetail:
                          state.selection.selectedBundleReleaseId == null
                              ? null
                              : state.preview.bundleReleaseDetailsById[
                                  state.selection.selectedBundleReleaseId],
                      selectedEditionId:
                          state.selection.selectedReferenceEditionId,
                      selectedVariantId:
                          state.selection.selectedReferenceVariantId,
                      isLoadingBundleReleases: selectedItem != null &&
                          state.preview.pendingBundleReleaseItemIds
                              .contains(selectedItem.id),
                      isLoadingBundleReleaseDetail:
                          state.selection.selectedBundleReleaseId != null &&
                              state.preview.pendingBundleReleaseDetailIds
                                  .contains(
                                      state.selection.selectedBundleReleaseId),
                      onReferenceTypeChanged: (value) =>
                          _controller.setReferenceType(value),
                      onEditionSelected: (editionId) =>
                          _controller.selectReferenceEdition(editionId),
                      onVariantSelected: (variantId) =>
                          _controller.selectReferenceVariant(variantId),
                      onBundleReleaseSelected: (bundleReleaseId) =>
                          _controller.selectBundleRelease(bundleReleaseId),
                    );

                    if (constraints.maxWidth < 720) {
                      final searchHeight = constraints.maxHeight > 400
                          ? 300.0
                          : constraints.maxHeight * 0.5;
                      return Column(
                        children: [
                          SizedBox(
                            height: searchHeight,
                            child: searchPaneWidget,
                          ),
                          Expanded(child: previewPaneWidget),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: _clampedResultsPaneWidth(constraints.maxWidth),
                          child: searchPaneWidget,
                        ),
                        LibraryAddPaneResizeDivider(
                          onDragDelta: (delta) => _resizeResultsPane(
                            delta,
                            constraints.maxWidth,
                          ),
                        ),
                        Expanded(child: previewPaneWidget),
                      ],
                    );
                  },
                ),
              LibraryAddDialogMode.manual => manualPaneBuilder?.call(
                    context,
                    LibraryAddManualPaneRequest(
                      kind: widget.type.workspace.kind,
                      accent: accent,
                      type: widget.type,
                      commonDraft: state.commonDraft,
                      kindDraft: state.manualDraft,
                      onCommonDraftChanged: (common) =>
                          _controller.updateCommonDraft((_) => common),
                      onKindDraftChanged: (draft) =>
                          _controller.updateKindDraft((_) => draft),
                      titleController: _manualDraft.titleController,
                      numberController: _manualDraft.numberController,
                      publisherController: _manualDraft.publisherController,
                      yearController: _manualDraft.yearController,
                      barcodeController: _barcodeController,
                      variantController: _manualDraft.variantController,
                      physicalFormatLabelController:
                          _manualDraft.physicalFormatLabelController,
                      coverController: _manualDraft.coverController,
                      backCoverController: _manualDraft.backCoverController,
                      creatorsController: _manualDraft.creatorsController,
                      charactersController: _manualDraft.charactersController,
                      physicalFormats: _currentPhysicalFormats(),
                      physicalFormatId: state.physicalFormatId,
                      onPhysicalFormatChanged: _controller.setPhysicalFormatId,
                      onPhysicalFormatLabelChanged: (label) {
                        _manualDraft.physicalFormatLabelController.text =
                            label ?? '';
                      },
                      isAdding: state.isAdding || state.submitState.isLoading,
                      defaultCondition: state.defaultCondition,
                      defaultGrade: state.defaultGrade,
                      defaultLocationLabel: locationPathForId(
                          _availableLocations, state.defaultLocationId),
                      defaultPurchaseDate: state.defaultPurchaseDate,
                      defaultTags: state.defaultTags,
                      onAddOwned: () =>
                          _controller.submitCurrentSelection(context: context),
                      onAddWishlist: () {
                        _controller.setTarget(LibraryAddTarget.wishlist);
                        _controller.submitCurrentSelection(context: context);
                      },
                      onAddTrack: () {
                        _controller.setTarget(LibraryAddTarget.track);
                        _controller.submitCurrentSelection(context: context);
                      },
                      editionTitleController:
                          _manualDraft.editionTitleController,
                      releaseDateController: _manualDraft.releaseDateController,
                      pageCountController: _manualDraft.pageCountController,
                      imprintController: _manualDraft.imprintController,
                      seriesGroupController: _manualDraft.seriesGroupController,
                      countryController: _manualDraft.countryController,
                      languageController: _manualDraft.languageController,
                      ageRatingController: _manualDraft.ageRatingController,
                      genresEditController: _manualDraft.genresEditController,
                      synopsisController: _manualDraft.synopsisController,
                      tagsController: _manualDraft.tagsController,
                      publisherOptions: _manualDraft.publisherOptions,
                      imprintOptions: _manualDraft.imprintOptions,
                      seriesGroupOptions: _manualDraft.seriesGroupOptions,
                      physicalFormatOptions: _manualDraft.physicalFormatOptions,
                      seriesEntries: _manualDraft.seriesEntries,
                      onManagePublishers: () => _manageSingleValuePickList(
                        listName: kPublisherPickListName,
                        label: 'Publisher',
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
                        label: 'Format',
                      ),
                      onManageSeries: _openManualSeriesPicker,
                      onSeriesChanged: _setManualSeries,
                      customFieldDefinitions: widget.customFieldDefinitions,
                      customFieldValues: _manualDraft.customFieldValues,
                      onCustomFieldValuesChanged: (vals) {
                        setState(() {
                          _manualDraft.customFieldValues = vals;
                        });
                      },
                      itemImages: _manualDraft.itemImages,
                      onItemImagesChanged: (imgs) {
                        setState(() {
                          _manualDraft.itemImages = imgs
                              .where((e) => !e.deleted && e.imageData != null)
                              .map((e) => ItemImage(
                                    id: e.id,
                                    ownedItemId: 'draft',
                                    imageData: e.imageData!,
                                    imageType: e.imageType,
                                    caption: e.caption,
                                    sortOrder: e.sortOrder,
                                    createdAt:
                                        e.createdAt ?? DateTime.now().toUtc(),
                                  ))
                              .toList();
                        });
                      },
                    ),
                  ) ??
                  buildDefaultManualPane(
                    context,
                    LibraryAddManualPaneRequest(
                      kind: widget.type.workspace.kind,
                      accent: accent,
                      type: widget.type,
                      commonDraft: state.commonDraft,
                      kindDraft: state.manualDraft,
                      onCommonDraftChanged: (common) =>
                          _controller.updateCommonDraft((_) => common),
                      onKindDraftChanged: (draft) =>
                          _controller.updateKindDraft((_) => draft),
                      titleController: _manualDraft.titleController,
                      numberController: _manualDraft.numberController,
                      publisherController: _manualDraft.publisherController,
                      yearController: _manualDraft.yearController,
                      barcodeController: _barcodeController,
                      variantController: _manualDraft.variantController,
                      physicalFormatLabelController:
                          _manualDraft.physicalFormatLabelController,
                      coverController: _manualDraft.coverController,
                      backCoverController: _manualDraft.backCoverController,
                      creatorsController: _manualDraft.creatorsController,
                      charactersController: _manualDraft.charactersController,
                      physicalFormats: _currentPhysicalFormats(),
                      physicalFormatId: state.physicalFormatId,
                      onPhysicalFormatChanged: _controller.setPhysicalFormatId,
                      onPhysicalFormatLabelChanged: (label) {
                        _manualDraft.physicalFormatLabelController.text =
                            label ?? '';
                      },
                      isAdding: state.isAdding || state.submitState.isLoading,
                      defaultCondition: state.defaultCondition,
                      defaultGrade: state.defaultGrade,
                      defaultLocationLabel: locationPathForId(
                          _availableLocations, state.defaultLocationId),
                      defaultPurchaseDate: state.defaultPurchaseDate,
                      defaultTags: state.defaultTags,
                      onAddOwned: () =>
                          _controller.submitCurrentSelection(context: context),
                      onAddWishlist: () {
                        _controller.setTarget(LibraryAddTarget.wishlist);
                        _controller.submitCurrentSelection(context: context);
                      },
                      onAddTrack: () {
                        _controller.setTarget(LibraryAddTarget.track);
                        _controller.submitCurrentSelection(context: context);
                      },
                      editionTitleController:
                          _manualDraft.editionTitleController,
                      releaseDateController: _manualDraft.releaseDateController,
                      pageCountController: _manualDraft.pageCountController,
                      imprintController: _manualDraft.imprintController,
                      seriesGroupController: _manualDraft.seriesGroupController,
                      countryController: _manualDraft.countryController,
                      languageController: _manualDraft.languageController,
                      ageRatingController: _manualDraft.ageRatingController,
                      genresEditController: _manualDraft.genresEditController,
                      synopsisController: _manualDraft.synopsisController,
                      tagsController: _manualDraft.tagsController,
                      publisherOptions: _manualDraft.publisherOptions,
                      imprintOptions: _manualDraft.imprintOptions,
                      seriesGroupOptions: _manualDraft.seriesGroupOptions,
                      physicalFormatOptions: _manualDraft.physicalFormatOptions,
                      seriesEntries: _manualDraft.seriesEntries,
                      onManagePublishers: () => _manageSingleValuePickList(
                        listName: kPublisherPickListName,
                        label: 'Publisher',
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
                        label: 'Format',
                      ),
                      onManageSeries: _openManualSeriesPicker,
                      onSeriesChanged: _setManualSeries,
                      customFieldDefinitions: widget.customFieldDefinitions,
                      customFieldValues: _manualDraft.customFieldValues,
                      onCustomFieldValuesChanged: (vals) {
                        setState(() {
                          _manualDraft.customFieldValues = vals;
                        });
                      },
                      itemImages: _manualDraft.itemImages,
                      onItemImagesChanged: (imgs) {
                        setState(() {
                          _manualDraft.itemImages = imgs
                              .where((e) => !e.deleted && e.imageData != null)
                              .map((e) => ItemImage(
                                    id: e.id,
                                    ownedItemId: 'draft',
                                    imageData: e.imageData!,
                                    imageType: e.imageType,
                                    caption: e.caption,
                                    sortOrder: e.sortOrder,
                                    createdAt:
                                        e.createdAt ?? DateTime.now().toUtc(),
                                  ))
                              .toList();
                        });
                      },
                    ),
                  ),
            },
          ),
        ],
      ),
      footer: bottomBarBuilder?.call(
            context,
            LibraryAddBottomBarRequest(
              type: widget.type,
              conditions: _conditionOptions,
              grades: _gradeOptions,
              defaultTags: state.defaultTags,
              accent: accent,
              selectedItem: selectedItem,
              selectedCandidate: selectedCandidate,
              selectedQueuedIngest: selectedCandidate != null
                  ? state.preview
                      .queuedProviderIngests[selectedCandidate.localCatalogId]
                  : null,
              providerLabel: selectedCandidate == null
                  ? widget.type
                      .metadataProviderLabel(state.search.selectedProvider)
                  : widget.type
                      .metadataProviderLabel(selectedCandidate.provider),
              addTarget: state.target,
              addCount: state.selection.checkedResultIds.length > 1
                  ? state.selection.checkedResultIds.length
                  : 1,
              isAdding: state.isAdding || state.submitState.isLoading,
              isQueueingIngest: state.preview.isQueueingIngest,
              isAdmin: ref.watch(authControllerProvider).isAdmin,
              defaultCondition: state.defaultCondition,
              defaultGrade: state.defaultGrade,
              defaultLocationLabel: locationPathForId(
                  _availableLocations, state.defaultLocationId),
              defaultPurchaseDate: state.defaultPurchaseDate,
              onAddTargetChanged: _controller.setTarget,
              onDefaultConditionChanged: _controller.setDefaultCondition,
              onDefaultGradeChanged: _controller.setDefaultGrade,
              onEditDefaultTagsPressed: _showDefaultTagsEditor,
              onDefaultLocationPressed: _pickDefaultLocation,
              onDefaultPurchaseDateChanged: _controller.setDefaultPurchaseDate,
              onAdd: () async {
                final navigator = Navigator.of(context);
                final success = await _controller.submitCurrentSelection(
                  context: context,
                  isAdmin: ref.read(authControllerProvider).isAdmin,
                );
                if (success && mounted) {
                  navigator.pop(true);
                }
              },
              onQueueIngest: selectedCandidate != null
                  ? () => _controller.queueProviderIngest(
                        selectedCandidate,
                        context: context,
                      )
                  : null,
              onPropose: selectedCandidate != null
                  ? () => _proposeCandidate(selectedCandidate)
                  : null,
            ),
          ) ??
          LibraryAddBottomBar(
            type: widget.type,
            isMovieDesktopChrome: isMovieDesktopChrome,
            conditions: _conditionOptions,
            grades: _gradeOptions,
            defaultTags: state.defaultTags,
            accent: accent,
            selectedItem: selectedItem,
            selectedCandidate: selectedCandidate,
            selectedQueuedIngest: selectedCandidate != null
                ? state.preview
                    .queuedProviderIngests[selectedCandidate.localCatalogId]
                : null,
            providerLabel: selectedCandidate == null
                ? widget.type
                    .metadataProviderLabel(state.search.selectedProvider)
                : widget.type.metadataProviderLabel(selectedCandidate.provider),
            addTarget: state.target,
            addCount: state.selection.checkedResultIds.length > 1
                ? state.selection.checkedResultIds.length
                : 1,
            isAdding: state.isAdding || state.submitState.isLoading,
            isQueueingIngest: state.preview.isQueueingIngest,
            isAdmin: ref.watch(authControllerProvider).isAdmin,
            defaultCondition: state.defaultCondition,
            defaultGrade: state.defaultGrade,
            defaultLocationLabel:
                locationPathForId(_availableLocations, state.defaultLocationId),
            defaultPurchaseDate: state.defaultPurchaseDate,
            onAddTargetChanged: _controller.setTarget,
            onDefaultConditionChanged: _controller.setDefaultCondition,
            onDefaultGradeChanged: _controller.setDefaultGrade,
            onEditDefaultTagsPressed: _showDefaultTagsEditor,
            onDefaultLocationPressed: _pickDefaultLocation,
            onDefaultPurchaseDateChanged: _controller.setDefaultPurchaseDate,
            onAdd: () async {
              final navigator = Navigator.of(context);
              final success = await _controller.submitCurrentSelection(
                context: context,
                isAdmin: ref.read(authControllerProvider).isAdmin,
              );
              if (success && mounted) {
                navigator.pop(true);
              }
            },
            onQueueIngest: selectedCandidate != null
                ? () => _controller.queueProviderIngest(
                      selectedCandidate,
                      context: context,
                    )
                : null,
            onPropose: selectedCandidate != null
                ? () => _proposeCandidate(selectedCandidate)
                : null,
          ),
    );
  }
}
