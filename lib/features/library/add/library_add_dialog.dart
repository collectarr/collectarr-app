import 'dart:async';

import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_contracts.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_form_options_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_manual_draft.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_session_state.dart';
import 'package:collectarr_app/features/library/add/layout/library_add_dialog_layout.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_bottom_bar.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_mode_bar.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_preview_pane.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_search_pane.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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

  final LibraryKindModule type;
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
  static const _formOptionsController = LibraryAddFormOptionsController();

  late final TextEditingController _queryController;
  late final TextEditingController _barcodeController;

  List<StorageLocation> _availableLocations = const [];
  List<String> _conditionOptions = const [];
  List<String> _gradeOptions = const [];
  List<String> _tagOptions = const [];

  double? _dialogWidth;
  double? _dialogHeight;

  double _resultsPaneWidth = 500;

  double _clampedResultsPaneWidth(double totalWidth) {
    return LibraryAddDialogLayout.clampResultsPaneWidth(
      totalWidth: totalWidth,
      requestedWidth: _resultsPaneWidth,
    );
  }

  void _resizeResultsPane(double delta, double totalWidth) {
    setState(() {
      _resultsPaneWidth = LibraryAddDialogLayout.clampResultsPaneWidth(
        totalWidth: totalWidth,
        requestedWidth: _clampedResultsPaneWidth(totalWidth) + delta,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.type.uiPolicy.wideDialog) {
      _resultsPaneWidth = 720;
    }
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    _barcodeController =
        TextEditingController(text: widget.initialBarcode ?? '');

    _manualDraft = LibraryAddManualDraft(
      customFieldValues: widget.customFieldValues,
      itemImages: widget.itemImages,
      kindDraft: widget.type.add.createManualDraft(),
    );
    _manualDraft.titleController.text = _queryController.text;

    _controller = LibraryAddSessionController(
      kind: widget.type.kind,
      type: widget.type,
      ownedMutations: ref.read(ownedItemMutationsProvider),
      wishlistMutations: ref.read(wishlistMutationsProvider),
      trackingMutations: ref.read(trackingMutationsProvider),
      api: ref.read(apiClientProvider),
      catalog: LibraryCatalogRepository(ref.read(localDatabaseProvider)),
      providerRegistry: ref.read(providerRegistryProvider).value ??
          buildDefaultProviderRegistry(),
      coverScanService: widget.coverScanService,
      onAuthSessionExpired: (error, action) => ref
          .read(authControllerProvider.notifier)
          .clearSessionIfRejected(error),
    );

    _controller.addListener(_onControllerStateChanged);

    final editCap = widget.type.edit;
    _conditionOptions = editCap.conditions;
    _gradeOptions = editCap.grades;
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
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant LibraryAddDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type.kind != widget.type.kind) {
      _manualDraft.dispose();
      _manualDraft = LibraryAddManualDraft(
        customFieldValues: widget.customFieldValues,
        itemImages: widget.itemImages,
        kindDraft: widget.type.add.createManualDraft(),
      );
    }
  }

  Future<void> _loadAvailableLocations() async {
    final locations = await _formOptionsController.loadLocations(
      ref.read(localDatabaseProvider),
    );
    if (!mounted) return;
    setState(() {
      _availableLocations = locations;
    });
  }

  Future<void> _loadPrefillDefaults() async {
    final defaults = await PrefillDefaults.load();
    if (!mounted) return;
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
    final options = await _formOptionsController.loadPickLists(
      database: ref.read(localDatabaseProvider),
      type: widget.type,
      selectedCondition: state.defaultCondition,
      selectedGrade: state.defaultGrade,
      selectedTags: state.defaultTags,
    );
    if (!mounted) return;
    setState(() {
      _conditionOptions = options.conditions;
      _gradeOptions = options.grades;
      _tagOptions = options.tags;
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
      visibleProviderResults: () => _controller.state.visibleProviderResults(
        widget.type.add.resultPolicy,
      ),
      currentPhysicalFormats: () => const [],
      showEditDialog: (ctx, req) =>
          showLibraryEditDialog(context: ctx, request: req),
    );
  }

  @override
  void dispose() {
    _manualDraft.dispose();
    _queryController.dispose();
    _barcodeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  LibraryAddManualPaneRequest _buildManualPaneRequest(
    LibraryAddSessionState state,
    Color accent,
  ) {
    return LibraryAddManualPaneRequest(
      kind: widget.type.kind,
      accent: accent,
      type: widget.type,
      commonDraft: state.commonDraft,
      kindDraft: state.manualDraft,
      manualDraft: _manualDraft.kindDraft,
      onCommonDraftChanged: (common) =>
          _controller.updateCommonDraft((_) => common),
      onKindDraftChanged: (draft) => _controller.updateKindDraft((_) => draft),
      titleController: _manualDraft.titleController,
      tagsController: _manualDraft.tagsController,
      personalNotesController: _manualDraft.personalNotesController,
      coverPriceController: _manualDraft.coverPriceController,
      priceController: _manualDraft.priceController,
      purchaseDateController: _manualDraft.purchaseDateController,
      purchaseStoreController: _manualDraft.purchaseStoreController,
      sellPriceController: _manualDraft.sellPriceController,
      soldDateController: _manualDraft.soldDateController,
      ownerLabelController: _manualDraft.ownerLabelController,
      linksController: _manualDraft.linksController,
      isAdding: state.isAdding || state.submitState.isLoading,
      defaultCondition: state.defaultCondition,
      defaultGrade: state.defaultGrade,
      defaultLocationLabel:
          locationPathForId(_availableLocations, state.defaultLocationId),
      defaultPurchaseDate: state.defaultPurchaseDate,
      defaultTags: state.defaultTags,
      onAddOwned: () => _controller.submitCurrentSelection(context: context),
      onAddWishlist: () {
        _controller.setTarget(LibraryAddTarget.wishlist);
        _controller.submitCurrentSelection(context: context);
      },
      onAddTrack: () {
        _controller.setTarget(LibraryAddTarget.track);
        _controller.submitCurrentSelection(context: context);
      },
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
                    createdAt: e.createdAt ?? DateTime.now().toUtc(),
                  ))
              .toList();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent ??
        LibraryAccentScope.accentOf(context,
            fallback: widget.type.identity.accent);
    final state = _controller.state;
    final ownedByCatalogId = ref.watch(collectionByCatalogItemProvider);
    final isWideLayout = widget.type.uiPolicy.wideDialog;
    final resultPolicy = widget.type.add.resultPolicy;
    final visibleCore = state.visibleCoreResults(
      resultPolicy,
      isOwnedCatalogItem: (id) => ownedByCatalogId.containsKey(id),
    );
    final visibleProvider = state.visibleProviderResults(resultPolicy);
    final selectedCandidate = state.selectedCandidate;
    final selectedItem = state.selectedItem;

    final addCapability = widget.type.add;
    final searchContext = LibraryAddSearchContext(
      query: state.search.query,
      barcode: state.search.barcode,
      advancedFilters: state.search.advancedFilters,
    );

    final headerRequest = LibraryAddHeaderRequest(
      type: widget.type,
      accent: accent,
      onClose: () => Navigator.of(context).pop(),
    );

    LibraryAddModeBarRequest buildModeBarRequest(
      List<LibraryAddAdvancedFilterField<String>> advancedFilterDescriptors,
    ) {
      return LibraryAddModeBarRequest(
        type: widget.type,
        accent: accent,
        isWideLayout: isWideLayout,
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
          _controller.updateQuery(_queryController.text);
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
        canScanCover: widget.type.add.chrome.canScanCover,
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
        advancedFilterState: state.search.advancedFilters,
        onAdvancedFilterChanged: _controller.updateAdvancedFilter,
        advancedFilterDescriptors: advancedFilterDescriptors,
        kindSpecificPaneBuilder: addCapability.search.kindSpecificPaneBuilder,
      );
    }

    final descriptorRequest = buildModeBarRequest(const []);
    final modeBarRequest = buildModeBarRequest(
      addCapability.search.advancedFilterDescriptorsBuilder(descriptorRequest),
    );

    final palette = appPalette(context);
    final dialogTheme = buildLibraryAddDialogTheme(accent, palette);

    return LibraryDialogScaffold(
      accent: accent,
      themeData: dialogTheme,
      width: _dialogWidth ?? LibraryAddDialogLayout.defaultDialogWidth,
      height: _dialogHeight ?? LibraryAddDialogLayout.defaultDialogHeight,
      minWidth: LibraryAddDialogLayout.minDialogWidth,
      maxWidth: LibraryAddDialogLayout.maxDialogWidth,
      minHeight: LibraryAddDialogLayout.minDialogHeight,
      maxHeight: LibraryAddDialogLayout.maxDialogHeight,
      onResizeWidth: (delta) => setState(() {
        _dialogWidth = LibraryAddDialogLayout.clampDialogWidth(
          (_dialogWidth ?? LibraryAddDialogLayout.defaultDialogWidth) + delta,
        );
      }),
      onResizeHeight: (delta) => setState(() {
        _dialogHeight = LibraryAddDialogLayout.clampDialogHeight(
          (_dialogHeight ?? LibraryAddDialogLayout.defaultDialogHeight) + delta,
        );
      }),
      header: widget.headerBuilder?.call(context, headerRequest) ??
          addCapability.headerBuilder?.call(context, headerRequest) ??
          AccentDialogHeader(
            title: 'Add ${widget.type.identity.pluralLabel}',
            accent: accent,
            icon: widget.type.identity.icon,
            onClose: () => Navigator.of(context).pop(),
          ),
      contextBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.initialBarcode != null &&
              widget.initialBarcode!.trim().isNotEmpty &&
              state.mode == LibraryAddDialogMode.barcode)
            LibraryAddBarcodePrefillBanner(
              type: widget.type,
              barcode: widget.initialBarcode!.trim(),
            ),
          Builder(
            builder: (scopedContext) =>
                widget.modeBarBuilder?.call(scopedContext, modeBarRequest) ??
                addCapability.modeBarBuilder
                    ?.call(scopedContext, modeBarRequest) ??
                LibraryAddModeBar(
                  type: widget.type,
                  accent: accent,
                  isWideLayout: isWideLayout,
                  mode: state.mode,
                  queryController: _queryController,
                  barcodeController: _barcodeController,
                  isSearching: state.search.isBusy,
                  isSearchingProvider: state.search.isSearchingProvider,
                  onModeChanged: (mode) {
                    if (mode == LibraryAddDialogMode.manual) {
                      _manualDraft.titleController.text = _queryController.text;
                    }
                    _controller.setMode(mode);
                  },
                  onSearch: () {
                    _controller.dismissSuggestions();
                    _controller.updateQuery(_queryController.text);
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
                  canScanCover: widget.type.add.chrome.canScanCover,
                  isScanningCover: state.search.isScanningCover,
                  onScanCover: () => _controller.scanCover(scopedContext),
                  onLookupBarcode: () => _controller.lookupBarcode(
                    barcode: _barcodeController.text,
                  ),
                  onManual: () {
                    _manualDraft.titleController.text = _queryController.text;
                    _controller.setMode(LibraryAddDialogMode.manual);
                  },
                  showAdvanced: state.search.showAdvancedSearch,
                  onToggleAdvanced: _controller.toggleAdvancedSearch,
                  advancedFilterState: state.search.advancedFilters,
                  onAdvancedFilterChanged: _controller.updateAdvancedFilter,
                  advancedFilterDescriptors:
                      modeBarRequest.advancedFilterDescriptors,
                  kindSpecificPaneBuilder:
                      modeBarRequest.kindSpecificPaneBuilder,
                ),
          ),
          if (state.search.error != null)
            Material(
              color: palette.panel,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.search.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: switch (state.mode) {
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
                queuedProviderIngests: state.preview.queuedProviderIngests,
                selectedProvider: state.search.selectedProvider,
                searchedProvider: state.search.searchedProvider,
                selectedResultId: state.selection.selectedResultId,
                selectedProviderCandidateId:
                    state.selection.selectedProviderCandidateId,
                checkedResultIds: state.selection.checkedResultIds,
                checkedProviderIds: state.selection.checkedProviderIds,
                ownedCatalogItemIds: ownedByCatalogId.keys.toSet(),
                coreMatchSummary: (item) =>
                    addCapability.search.coreMatchSummary(item, searchContext),
                providerMatchSummary: (candidate) => addCapability.search
                    .providerMatchSummary(candidate, searchContext),
                resultPolicy: resultPolicy,
                resultPolicyState: state.selection.resultPolicyState,
                onResultPolicyOptionChanged: _controller.setResultPolicyOption,
                isWideLayout: constraints.maxWidth >= 720,
                showCoreResults: state.selection.showCoreResults,
                showProviderResults: state.selection.showProviderResults,
                onSelectResult: _controller.selectResult,
                onSelectProviderCandidate: _controller.selectProviderCandidate,
                onToggleResultCheck: _controller.toggleCheckedResult,
                onToggleProviderCheck: _controller.toggleCheckedProvider,
                onShowCoreResultsChanged: _controller.setShowCoreResults,
                onShowProviderResultsChanged:
                    _controller.setShowProviderResults,
                onSearchCore: _controller.executeSearch,
              );

              final searchPaneWidget = widget.searchPaneBuilder
                      ?.call(context, searchPaneRequest) ??
                  addCapability.searchPaneBuilder
                      ?.call(context, searchPaneRequest) ??
                  LibraryAddSearchPane(
                    type: searchPaneRequest.type,
                    isBusy: searchPaneRequest.isBusy,
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
                    ownedCatalogItemIds: searchPaneRequest.ownedCatalogItemIds,
                    coreMatchSummary: searchPaneRequest.coreMatchSummary,
                    providerMatchSummary:
                        searchPaneRequest.providerMatchSummary,
                    isWideLayout: searchPaneRequest.isWideLayout,
                    resultPolicy: searchPaneRequest.resultPolicy,
                    resultPolicyState: searchPaneRequest.resultPolicyState,
                    onResultPolicyOptionChanged:
                        searchPaneRequest.onResultPolicyOptionChanged,
                    showCoreResults: searchPaneRequest.showCoreResults,
                    showProviderResults: searchPaneRequest.showProviderResults,
                    onSelectResult: searchPaneRequest.onSelectResult,
                    onSelectProviderCandidate:
                        searchPaneRequest.onSelectProviderCandidate,
                    onToggleResultCheck: searchPaneRequest.onToggleResultCheck,
                    onToggleProviderCheck:
                        searchPaneRequest.onToggleProviderCheck,
                    onShowCoreResultsChanged:
                        searchPaneRequest.onShowCoreResultsChanged,
                    onShowProviderResultsChanged:
                        searchPaneRequest.onShowProviderResultsChanged,
                    onSearchCore: searchPaneRequest.onSearchCore,
                  );

              final previewPaneWidget = LibraryAddPreviewPane(
                type: widget.type,
                accent: accent,
                isWideLayout: isWideLayout,
                previewPaneBuilder: widget.previewPaneBuilder ??
                    addCapability.previewPaneBuilder,
                item: selectedItem,
                candidate: selectedCandidate,
                candidatePreview: selectedCandidate == null
                    ? null
                    : state.preview
                        .providerPreviews[selectedCandidate.localCatalogId],
                isFetchingPreview: (selectedCandidate != null &&
                        state.preview.pendingProviderPreviewIds
                            .contains(selectedCandidate.localCatalogId)) ||
                    (selectedItem != null &&
                        state.preview.pendingHydratedResultIds
                            .contains(selectedItem.id)),
                providerLabel: widget.type.metadata.providerLabel(
                  state.search.selectedProvider,
                ),
                searched: state.search.results.isNotEmpty ||
                    state.search.searchedProvider,
                addTarget: state.target,
                referenceType: state.selection.referenceType,
                availableBundleReleases: selectedItem == null
                    ? const <BundleReleaseSummary>[]
                    : state.preview.bundleReleasesByItemId[selectedItem.id] ??
                        const <BundleReleaseSummary>[],
                selectedBundleReleaseId:
                    state.selection.selectedBundleReleaseId,
                selectedBundleReleaseDetail:
                    state.selection.selectedBundleReleaseId == null
                        ? null
                        : state.preview.bundleReleaseDetailsById[
                            state.selection.selectedBundleReleaseId],
                selectedEditionId: state.selection.selectedReferenceEditionId,
                selectedVariantId: state.selection.selectedReferenceVariantId,
                isLoadingBundleReleases: selectedItem != null &&
                    state.preview.pendingBundleReleaseItemIds
                        .contains(selectedItem.id),
                isLoadingBundleReleaseDetail:
                    state.selection.selectedBundleReleaseId != null &&
                        state.preview.pendingBundleReleaseDetailIds
                            .contains(state.selection.selectedBundleReleaseId),
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
        LibraryAddDialogMode.manual => widget.manualPaneBuilder?.call(
              context,
              _buildManualPaneRequest(state, accent),
            ) ??
            addCapability.buildManualPane(
              context,
              _buildManualPaneRequest(state, accent),
            ),
      },
      footer: () {
        final bottomBarRequest = LibraryAddBottomBarRequest(
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
              ? widget.type.metadata
                  .providerLabel(state.search.selectedProvider)
              : widget.type.metadata.providerLabel(selectedCandidate.provider),
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
        );
        return widget.bottomBarBuilder?.call(context, bottomBarRequest) ??
            addCapability.bottomBarBuilder?.call(context, bottomBarRequest) ??
            LibraryAddBottomBar(
              type: widget.type,
              isWideLayout: isWideLayout,
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
                  ? widget.type.metadata.providerLabel(
                      state.search.selectedProvider,
                    )
                  : widget.type.metadata.providerLabel(
                      selectedCandidate.provider,
                    ),
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
            );
      }(),
    );
  }
}
