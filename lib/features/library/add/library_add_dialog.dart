import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/library/add/compact_controls.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/add/library_add_mode_tab.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/providers/volumes_provider.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

part 'library_add_mode_bar.dart';
part 'library_add_search_pane.dart';
part 'library_add_preview_pane.dart';
part 'library_add_bottom_bar.dart';
part 'library_add_manual_pane.dart';

class LibraryAddDialog extends ConsumerStatefulWidget {
  const LibraryAddDialog({
    super.key,
    required this.type,
    this.accent,
    this.initialQuery,
    this.initialBarcode,
    this.autoLookupInitialBarcode = true,
  });

  final LibraryTypeConfig type;
  final Color? accent;
  final String? initialQuery;
  final String? initialBarcode;
  final bool autoLookupInitialBarcode;

  @override
  ConsumerState<LibraryAddDialog> createState() => _LibraryAddDialogState();
}

class _LibraryAddDialogState extends ConsumerState<LibraryAddDialog> {
  final _queryController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _variantController = TextEditingController();
  final _coverController = TextEditingController();
  final _storageBoxController = TextEditingController();
  final _uuid = const Uuid();

  // Advanced search fields
  final _searchSeriesController = TextEditingController();
  final _searchNumberController = TextEditingController();
  final _searchPublisherController = TextEditingController();
  final _searchYearController = TextEditingController();
  bool _showAdvancedSearch = false;

  List<CatalogItem> _results = const [];
  List<ProviderCandidate> _providerResults = const [];
  final _queuedProviderIngests = <String, _QueuedProviderIngest>{};
  final _checkedResultIds = <String>{};
  final _checkedProviderIds = <String>{};
  String? _error;
  late String _selectedProvider;
  bool _searchedProvider = false;
  bool _isSearching = false;
  bool _isSearchingProvider = false;
  bool _isQueueingIngest = false;
  bool _isAdding = false;
  _LibraryAddDialogMode _mode = _LibraryAddDialogMode.search;
  LibraryAddTarget _addTarget = LibraryAddTarget.owned;
  String? _selectedResultId;
  String? _selectedProviderCandidateId;
  AdminProviderPreview? _candidatePreview;
  bool _isFetchingPreview = false;
  String? _lastPreviewCandidateId;
  String? _physicalFormatId;
  String _defaultCondition = 'Near Mint';
  String _defaultGrade = 'Ungraded';
  DateTime? _defaultPurchaseDate;
  DateTime? _lastProviderSearchAt;
  String? _lastProviderSearchSignature;
  int _coreSearchGeneration = 0;
  double _resultsPaneWidth = 390;
  static const _providerSearchDebounce = Duration(milliseconds: 450);
  static const _coreSearchTimeout = Duration(seconds: 35);
  static const _minResultsPaneWidth = 280.0;
  static const _maxResultsPaneWidth = 520.0;
  static const _minPreviewPaneWidth = 420.0;
  double? _dialogWidth;
  double? _dialogHeight;
  static const _minDialogWidth = 640.0;
  static const _maxDialogWidth = 1400.0;
  static const _minDialogHeight = 480.0;
  static const _maxDialogHeight = 1000.0;

  @override
  void initState() {
    super.initState();
    _selectedProvider = widget.type.defaultSupportedMetadataProvider;
    _queryController.text = widget.initialQuery?.trim() ?? '';
    _barcodeController.text = widget.initialBarcode?.trim() ?? '';
    _titleController.text = _queryController.text;
    if (_barcodeController.text.isNotEmpty && widget.autoLookupInitialBarcode) {
      _mode = _LibraryAddDialogMode.barcode;
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookupBarcode());
    } else if (_barcodeController.text.isNotEmpty) {
      _mode = _LibraryAddDialogMode.barcode;
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _barcodeController.dispose();
    _titleController.dispose();
    _numberController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _variantController.dispose();
    _coverController.dispose();
    _storageBoxController.dispose();
    _searchSeriesController.dispose();
    _searchNumberController.dispose();
    _searchPublisherController.dispose();
    _searchYearController.dispose();
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
    final accent = widget.accent ?? LibraryAccentScope.accentOf(context, fallback: kClzAccent);
    final selectedResult = _selectedResult;
    final selectedCandidate = _selectedProviderCandidate;
    final selectedProviderLabel = selectedCandidate == null
        ? widget.type.metadataProviderLabel(selectedProvider)
        : widget.type.metadataProviderLabel(selectedCandidate.provider);
    final selectedQueuedIngest = selectedCandidate == null
        ? null
        : _queuedProviderIngests[selectedCandidate.localCatalogId];
    return Theme(
      data: _libraryAddDialogTheme(accent),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 720 ? 10 : 32,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (_dialogWidth ?? 1040).clamp(_minDialogWidth, _maxDialogWidth),
            maxHeight: (_dialogHeight ?? 780).clamp(_minDialogHeight, _maxDialogHeight),
          ),
          child: _ResizableDialogShell(
            accent: accent,
            onResizeWidth: (delta) => setState(() {
              _dialogWidth = ((_dialogWidth ?? 1040) + delta)
                  .clamp(_minDialogWidth, _maxDialogWidth);
            }),
            onResizeHeight: (delta) => setState(() {
              _dialogHeight = ((_dialogHeight ?? 780) + delta)
                  .clamp(_minDialogHeight, _maxDialogHeight);
            }),
            child: Column(
              children: [
                _DialogHeader(type: widget.type, accent: accent),
                _LibraryAddModeBar(
                  type: widget.type,
                  accent: accent,
                  mode: _mode,
                  queryController: _queryController,
                  barcodeController: _barcodeController,
                  isSearching: _isSearching,
                  isSearchingProvider: _isSearchingProvider,
                  onModeChanged: (mode) => setState(() => _mode = mode),
                  onSearch: _search,
                  onLookupBarcode: _lookupBarcode,
                  onManual: () =>
                      setState(() => _mode = _LibraryAddDialogMode.manual),
                  showAdvanced: _showAdvancedSearch,
                  onToggleAdvanced: () => setState(
                      () => _showAdvancedSearch = !_showAdvancedSearch),
                  seriesController: _searchSeriesController,
                  numberController: _searchNumberController,
                  publisherController: _searchPublisherController,
                  yearController: _searchYearController,
                ),
                if (_barcodeController.text.trim().isNotEmpty)
                  _BarcodePrefillBanner(
                    type: widget.type,
                    barcode: _barcodeController.text.trim(),
                  ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final searchPane = _SearchPane(
                        type: widget.type,
                        isBusy: isBusy,
                        error: _error,
                        accent: accent,
                        results: _results,
                        providerResults: _providerResults,
                        queuedProviderIngests: _queuedProviderIngests,
                        selectedProvider: selectedProvider,
                        searchedProvider: _searchedProvider,
                        selectedResultId: _selectedResultId,
                        selectedProviderCandidateId:
                            _selectedProviderCandidateId,
                        checkedResultIds: _checkedResultIds,
                        checkedProviderIds: _checkedProviderIds,
                        onSelectResult: (id) => setState(() {
                          _selectedResultId = id;
                          _selectedProviderCandidateId = null;
                        }),
                        onSelectProviderCandidate: (id) {
                          setState(() {
                            _selectedProviderCandidateId = id;
                            _selectedResultId = null;
                          });
                          final candidate = _providerResults
                              .where((c) => c.localCatalogId == id)
                              .firstOrNull;
                          if (candidate != null) {
                            _fetchCandidatePreview(candidate);
                          }
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
                        onSearchCore: _search,
                      );
                      final previewPane = _LibraryAddPreviewPane(
                        type: widget.type,
                        accent: accent,
                        item: selectedResult,
                        candidate: selectedCandidate,
                        candidatePreview: _candidatePreview,
                        isFetchingPreview: _isFetchingPreview,
                        providerLabel: selectedProviderLabel,
                        searched: _results.isNotEmpty || _searchedProvider,
                      );
                      final manualPane = _ManualPane(
                        type: widget.type,
                        titleController: _titleController,
                        numberController: _numberController,
                        publisherController: _publisherController,
                        yearController: _yearController,
                        barcodeController: _barcodeController,
                        variantController: _variantController,
                        coverController: _coverController,
                        physicalFormats: physicalFormats,
                        physicalFormatId: _physicalFormatId,
                        onPhysicalFormatChanged: _setPhysicalFormat,
                        isAdding: _isAdding,
                        onAddOwned: () => _addManual(LibraryAddTarget.owned),
                        onAddWishlist: () =>
                            _addManual(LibraryAddTarget.wishlist),
                      );
                      if (_mode == _LibraryAddDialogMode.manual) {
                        return manualPane;
                      }
                      if (constraints.maxWidth < 720) {
                        final searchHeight =
                            constraints.maxHeight > 400 ? 300.0 : constraints.maxHeight * 0.5;
                        return Column(
                          children: [
                            SizedBox(height: searchHeight, child: searchPane),
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
                            child: searchPane,
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
                if (_mode != _LibraryAddDialogMode.manual)
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
                      return _LibraryAddBottomBar(
                        type: widget.type,
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
                        defaultStorageBoxController: _storageBoxController,
                        defaultPurchaseDate: _defaultPurchaseDate,
                        onAddTargetChanged: (value) =>
                            setState(() => _addTarget = value),
                        onDefaultConditionChanged: (value) =>
                            setState(() => _defaultCondition = value),
                        onDefaultGradeChanged: (value) =>
                            setState(() => _defaultGrade = value),
                        onDefaultPurchaseDateChanged: (value) =>
                            setState(() => _defaultPurchaseDate = value),
                        onAdd: addItems.isEmpty && selectedCandidate == null
                            ? null
                            : () {
                                if (addItems.isNotEmpty) {
                                  _addItems(addItems, _addTarget);
                                  return;
                                }
                                final candidate = selectedCandidate;
                                if (candidate != null) {
                                  _addProviderCandidate(
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
    final query = _queryController.text.trim();
    if (query.isEmpty &&
        _searchSeriesController.text.trim().isEmpty &&
        _searchNumberController.text.trim().isEmpty &&
        _searchPublisherController.text.trim().isEmpty &&
        _searchYearController.text.trim().isEmpty) {
      setState(() => _error = 'Enter a title, creator, series, or keyword.');
      return;
    }
    final searchGeneration = ++_coreSearchGeneration;
    setState(() {
      _isSearching = true;
      _error = null;
      _providerResults = const [];
      _searchedProvider = false;
    });
    final series = _searchSeriesController.text.trim();
    final issueNumber = _searchNumberController.text.trim();
    final publisher = _searchPublisherController.text.trim();
    final yearText = _searchYearController.text.trim();
    final year = yearText.isNotEmpty ? int.tryParse(yearText) : null;
    try {
      final api = ref.read(apiClientProvider);
      final items = await searchAndCacheLibraryMetadata(
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
      ).timeout(_coreSearchTimeout);
      final shouldSearchProvider =
          widget.type.supportedMetadataProviders.isNotEmpty;
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() {
          _results = items;
          _selectedResultId = items.isEmpty ? null : items.first.id;
          _selectedProviderCandidateId = null;
        });
      }
      if (mounted &&
          searchGeneration == _coreSearchGeneration &&
          shouldSearchProvider) {
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
      _searchedProvider = false;
    });
    try {
      final api = ref.read(apiClientProvider);
      final results = await lookupAndCacheLibraryBarcodes(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        barcodes: [barcode],
      ).timeout(_coreSearchTimeout);
      final found = [
        for (final result in results)
          if (result.item != null) result.item!,
      ];
      if (mounted && searchGeneration == _coreSearchGeneration) {
        setState(() {
          _results = found;
          _selectedResultId = found.isEmpty ? null : found.first.id;
          _selectedProviderCandidateId = null;
          _error =
              found.isEmpty &&
                      widget.type.supportedMetadataProviders.isEmpty
                  ? 'No item found for barcode $barcode.'
                  : null;
        });
      }
      if (mounted &&
          searchGeneration == _coreSearchGeneration &&
          widget.type.supportedMetadataProviders.isNotEmpty) {
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
    final year = int.tryParse(_yearController.text.trim());
    final item = CatalogItem(
      id: 'local-${widget.type.workspace.kind}-${_uuid.v4()}',
      kind: widget.type.workspace.kind,
      title: title,
      itemNumber: _emptyToNull(_numberController.text),
      editionTitle: _emptyToNull(_variantController.text),
      physicalFormat: _physicalFormatId,
      physicalFormatLabel: _physicalFormatForId(_physicalFormatId)?.label,
      publisher: _emptyToNull(_publisherController.text),
      releaseYear: year,
      barcode: _emptyToNull(_barcodeController.text),
      variant: _emptyToNull(_variantController.text),
      coverImageUrl: _emptyToNull(_coverController.text),
    );
    await _addItems([item], target);
  }

  void _setPhysicalFormat(String? value) {
    final format = _physicalFormatForId(value);
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
      formats: physicalMediaFormatsForKind(
        ref.read(mediaCatalogProvider).maybeWhen(
              data: (value) => value,
              orElse: () => fallbackMediaCatalog,
            ),
        widget.type.workspace.kind,
      ),
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
    if (_isSearchingProvider ||
        (!bypassDebounce && _shouldDebounceProviderSearch(provider, query))) {
      return;
    }
    setState(() {
      _isSearchingProvider = true;
      _searchedProvider = true;
      _providerResults = const [];
      _selectedProviderCandidateId = null;
      _error = null;
    });
    try {
      final results = await searchLibraryProviderCandidates(
        ref.read(apiClientProvider),
        widget.type,
        provider: provider,
        query: query,
        series: _searchSeriesController.text.trim().isNotEmpty
            ? _searchSeriesController.text.trim()
            : null,
        issueNumber: _searchNumberController.text.trim().isNotEmpty
            ? _searchNumberController.text.trim()
            : null,
        year: _searchYearController.text.trim().isNotEmpty
            ? int.tryParse(_searchYearController.text.trim())
            : null,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _providerResults = results;
        if (_selectedResultId == null && _selectedProviderCandidateId == null) {
          _selectedProviderCandidateId =
              results.isEmpty ? null : results.first.localCatalogId;
        }
      });
    } catch (error) {
      if (mounted) {
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

  bool _shouldDebounceProviderSearch(String provider, String query) {
    final now = DateTime.now();
    final signature = '$provider|${query.trim().toLowerCase()}';
    final lastAt = _lastProviderSearchAt;
    final shouldSkip = _lastProviderSearchSignature == signature &&
        lastAt != null &&
        now.difference(lastAt) < _providerSearchDebounce;
    _lastProviderSearchSignature = signature;
    _lastProviderSearchAt = now;
    return shouldSkip;
  }

  Future<void> _fetchCandidatePreview(ProviderCandidate candidate) async {
    final candidateId = candidate.localCatalogId;
    if (_lastPreviewCandidateId == candidateId) return;
    _lastPreviewCandidateId = candidateId;
    setState(() {
      _isFetchingPreview = true;
      _candidatePreview = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final preview = await api.providerPreview(
        provider: candidate.provider,
        providerItemId: candidate.providerItemId,
      );
      if (mounted && _lastPreviewCandidateId == candidateId) {
        setState(() => _candidatePreview = preview);
      }
    } catch (_) {
      // Silently fail — candidate basic fields still shown.
    } finally {
      if (mounted && _lastPreviewCandidateId == candidateId) {
        setState(() => _isFetchingPreview = false);
      }
    }
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
      _error = '$action needs a fresh metadata sign-in. '
          'Open Settings and sign in again.';
    });
    return true;
  }

  Future<void> _addProviderCandidate(
    ProviderCandidate candidate,
    LibraryAddTarget target,
  ) async {
    final isAdmin = ref.read(authControllerProvider).isAdmin;
    if (!isAdmin || candidate.isStub) {
      await _addItems([candidate.placeholderCatalogItem()], target);
      return;
    }
    try {
      // Preview: fetch + normalize without creating in core DB.
      final preview = await ref.read(apiClientProvider).adminProviderPreview(
            provider: candidate.provider,
            providerItemId: candidate.providerItemId,
          );
      if (!mounted) return;

      final previewItem = _catalogItemFromPreview(preview);
      final catalog = ref.read(mediaCatalogProvider).maybeWhen(
        data: (value) => value,
        orElse: () => fallbackMediaCatalog,
      );

      // Open edit dialog so the user can review / modify all fields.
      final result = await showDialog<LibraryEditSelection>(
        context: context,
        builder: (context) => LibraryEditDialog(
          type: widget.type,
          item: previewItem,
          ownedItem: null, // catalog-only tabs
          accent: LibraryAccentScope.accentOf(context),
          physicalFormats: physicalMediaFormatsForKind(
            catalog,
            widget.type.workspace.kind,
          ),
        ),
      );
      if (result == null || !mounted) return;

      // Ingest: create item in core DB.
      final ingest = await ref.read(apiClientProvider).adminProviderIngest(
            provider: candidate.provider,
            providerItemId: candidate.providerItemId,
          );

      // Apply user corrections if any fields differ from the ingested item.
      final edited = result.catalogItem;
      final ingested = _catalogItemFromIngestResult(ingest.item);
      if (mounted) {
        await _applyIngestCorrections(
          kind: ingested.kind,
          itemId: ingest.itemId,
          preview: previewItem,
          edited: edited,
        );
      }

      // Use the ingested item as base but overlay the user's edits.
      final finalItem = CatalogItem(
        id: ingested.id,
        kind: ingested.kind,
        title: edited.title,
        itemNumber: edited.itemNumber,
        synopsis: edited.synopsis,
        coverImageUrl: edited.coverImageUrl ?? ingested.coverImageUrl,
        thumbnailImageUrl:
            edited.thumbnailImageUrl ?? ingested.thumbnailImageUrl,
        editionTitle: edited.editionTitle,
        physicalFormat: edited.physicalFormat,
        physicalFormatLabel: edited.physicalFormatLabel,
        publisher: edited.publisher,
        releaseDate: edited.releaseDate,
        releaseYear: edited.releaseYear,
        barcode: edited.barcode,
        variant: edited.variant,
        seriesTitle: ingested.seriesTitle,
        volumeName: ingested.volumeName,
        volumeStartYear: ingested.volumeStartYear,
        imprint: edited.imprint,
        seriesGroup: edited.seriesGroup,
      );
      await _addItems([finalItem], target);
    } catch (error) {
      if (mounted &&
          await _clearRejectedMetadataSession(error, 'Provider ingest')) {
        return;
      }
      if (mounted) {
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Provider ingest failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)}',
        );
      }
    }
  }

  CatalogItem _catalogItemFromPreview(AdminProviderPreview preview) {
    return CatalogItem(
      id: 'preview:${preview.provider}:${preview.providerItemId}',
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
      releaseYear: preview.releaseDate?.year ?? preview.volumeStartYear,
      barcode: preview.barcode,
      variant: preview.variantName,
      seriesTitle: preview.seriesTitle,
      volumeName: preview.volumeName,
      volumeStartYear: preview.volumeStartYear,
      imprint: preview.imprint,
      seriesGroup: preview.seriesGroup,
      pageCount: preview.pageCount,
      country: preview.country,
      language: preview.language,
      ageRating: preview.ageRating,
      subtitle: preview.subtitle,
      coverPriceCents: preview.coverPriceCents,
      currency: preview.currency,
      trackCount: preview.trackCount,
    );
  }

  /// Sends a PATCH correction for any fields the user changed from the preview.
  Future<void> _applyIngestCorrections({
    required String kind,
    required String itemId,
    required CatalogItem preview,
    required CatalogItem edited,
  }) async {
    final corrections = <String, dynamic>{};
    if (edited.title != preview.title) corrections['title'] = edited.title;
    if (edited.itemNumber != preview.itemNumber) {
      corrections['item_number'] = edited.itemNumber;
    }
    if (edited.synopsis != preview.synopsis) {
      corrections['synopsis'] = edited.synopsis;
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
    if (edited.physicalFormat != preview.physicalFormat) {
      corrections['physical_format'] = edited.physicalFormat;
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
          itemNumber: corrections['item_number'] as String?,
          synopsis: corrections['synopsis'] as String?,
          publisher: corrections['publisher'] as String?,
          releaseDate: edited.releaseDate,
          barcode: corrections['barcode'] as String?,
          variantName: corrections['variant_name'] as String?,
          physicalFormat: corrections['physical_format'] as String?,
          coverImageUrl: corrections['cover_image_url'] as String?,
          thumbnailImageUrl: corrections['thumbnail_image_url'] as String?,
        );
  }

  CatalogItem _catalogItemFromIngestResult(AdminMetadataItem item) {
    final primaryEdition = item.primaryEdition;
    final primaryVariant = item.primaryVariant;
    final releaseDate = primaryEdition?.releaseDate;
    return CatalogItem(
      id: item.id,
      kind: item.kind,
      title: item.title,
      itemNumber: item.itemNumber,
      synopsis: item.synopsis,
      coverImageUrl: primaryVariant?.coverImageUrl ?? item.displayCoverUrl,
      thumbnailImageUrl:
          primaryVariant?.thumbnailImageUrl ?? item.displayCoverUrl,
      editionTitle: primaryEdition?.title,
      physicalFormat: primaryEdition?.physicalFormat,
      physicalFormatLabel: primaryEdition?.physicalFormatLabel,
      publisher: primaryEdition?.publisher ?? item.publisher,
      releaseDate: releaseDate,
      releaseYear: releaseDate?.year ?? item.volumeStartYear,
      barcode: primaryVariant?.barcode ?? item.barcode,
      variant: primaryVariant?.name,
      seriesTitle: item.seriesTitle,
      volumeName: item.volumeName,
      volumeStartYear: item.volumeStartYear,
    );
  }

  Future<void> _proposeCandidate(ProviderCandidate candidate) async {
    if (_isAdding) {
      return;
    }
    setState(() {
      _isAdding = true;
      _error = null;
    });
    try {
      await createAndRecordLibraryMetadataProposal(
        api: ref.read(apiClientProvider),
        type: widget.type,
        provider: candidate.provider,
        providerItemId: candidate.providerItemId,
        query: _providerQuery,
        title: candidate.title,
        summary: candidate.summary,
        imageUrl: candidate.imageUrl,
        source: 'Add ${widget.type.pluralLabel} provider result',
      );
      if (!mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${widget.type.singularLabel} metadata proposal sent for review',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        if (await _clearRejectedMetadataSession(
          error,
          'Metadata proposal',
        )) {
          return;
        }
        setState(() => _error = 'Metadata proposal failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Future<void> _queueProviderIngest(ProviderCandidate candidate) async {
    if (_isQueueingIngest ||
        _queuedProviderIngests.containsKey(candidate.localCatalogId)) {
      return;
    }
    setState(() {
      _isQueueingIngest = true;
      _error = null;
    });
    try {
      final job =
          await ref.read(apiClientProvider).adminCreateProviderIngestJob(
                provider: candidate.provider,
                providerItemId: candidate.providerItemId,
              );
      if (!mounted) {
        return;
      }
      setState(() {
        _queuedProviderIngests[candidate.localCatalogId] =
            _QueuedProviderIngest(id: job.id, status: job.status);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Queued ${candidate.title} ingest job ${job.id} (${job.status}).',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        if (await _clearRejectedMetadataSession(
          error,
          'Core ingest queue',
        )) {
          return;
        }
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Core ingest queue failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)} Admin access is required to queue canonical ingest jobs.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isQueueingIngest = false);
      }
    }
  }

  String get _activeProvider {
    final providers = widget.type.supportedMetadataProviders;
    for (final provider in providers) {
      if (provider.id == _selectedProvider) {
        return provider.id;
      }
    }
    return widget.type.defaultSupportedMetadataProvider;
  }

  CatalogItem? get _selectedResult {
    final id = _selectedResultId;
    if (id == null) {
      return null;
    }
    for (final item in _results) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
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
    final seen = <String>{};
    return [
      _queryController.text,
      _titleController.text,
      _numberController.text,
      _publisherController.text,
      _yearController.text,
      _barcodeController.text,
    ].map((part) => part.trim()).where((part) {
      if (part.isEmpty) {
        return false;
      }
      return seen.add(part.toLowerCase());
    }).join(' ');
  }

  Future<void> _addItems(
    List<CatalogItem> items,
    LibraryAddTarget target,
  ) async {
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
        defaults: LibraryAddDefaults(
          condition: _defaultCondition,
          grade: _defaultGrade,
          purchaseDate: _defaultPurchaseDate,
          storageBox: _storageBoxController.text,
        ),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
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

class _QueuedProviderIngest {
  const _QueuedProviderIngest({
    required this.id,
    required this.status,
  });

  final String id;
  final String status;

  String get shortId {
    final trimmed = id.trim();
    if (trimmed.length <= 8) {
      return trimmed;
    }
    return trimmed.substring(0, 8);
  }

  String get statusLabel {
    final trimmed = status.trim();
    if (trimmed.isEmpty) {
      return 'Queued';
    }
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }
}

enum _LibraryAddDialogMode { search, barcode, manual }

const double _kLibraryAddControlHeight = 34;
const double _kLibraryAddModeControlHeight = 36;
const BorderSide _kLibraryAddBorder = BorderSide(color: kClzDivider);

ButtonStyle _libraryAddFilledButtonStyle([Color accent = kClzAccent]) {
  return libraryAddFilledButtonStyle(accent);
}

ButtonStyle _libraryAddOutlinedButtonStyle([Color accent = kClzAccent]) {
  return OutlinedButton.styleFrom(
    foregroundColor: accent,
    side: BorderSide(color: accent.withValues(alpha: 0.78)),
    minimumSize: const Size(0, _kLibraryAddControlHeight),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w800),
  );
}

Color _foregroundForAccent(Color accent) {
  return Colors.white;
}

ThemeData _libraryAddDialogTheme(Color accent) {
  return libraryAddDialogTheme(accent);
}
