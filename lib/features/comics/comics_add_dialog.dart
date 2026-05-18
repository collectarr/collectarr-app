import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_add_results_pane.dart';
import 'package:collectarr_app/features/comics/comics_barcode_lookup.dart';
import 'package:collectarr_app/features/comics/comics_add_bottom_bar.dart';
import 'package:collectarr_app/features/comics/comics_add_preview_pane.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/comics_manual_metadata_dialogs.dart';
import 'package:collectarr_app/features/comics/comics_provider_search_state.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_mode.dart';
import 'package:collectarr_app/features/library/add/library_add_mode_tab.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

const Color _kClzToolbar = kClzToolbar;
const Color _kClzPanel = kClzPanel;
const Color _kClzAccent = kClzAccent;
final ThemeData _kClzAddComicDialogTheme = kClzAddComicDialogTheme;
final TextInputFormatter _noNewlineFormatter =
    FilteringTextInputFormatter.deny(RegExp(r'[\r\n]'));

class AddComicDialog extends ConsumerStatefulWidget {
  const AddComicDialog({super.key});

  @override
  ConsumerState<AddComicDialog> createState() => AddComicDialogState();
}

class AddComicDialogState extends ConsumerState<AddComicDialog> {
  final _controller = TextEditingController();
  final _seriesController = TextEditingController();
  final _issueController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _defaultStorageBoxController = TextEditingController();
  var _serverResults = const <CatalogItem>[];
  String? _selectedServerId;
  var _providerState = ComicsProviderSearchState.initial(
    comicsLibraryConfig.defaultSupportedMetadataProvider,
  );
  final _checkedServerIds = <String>{};
  final _checkedProviderIds = <String>{};
  final _collapsedAddSeries = <String>{};
  final _barcodeBatch = <BarcodeLookupEntry>[];
  final _barcodeHistory = <String>[];
  bool _searchedServer = false;
  bool _isSearchingServer = false;
  bool _isSubmitting = false;
  bool _includeVariants = true;
  bool _hideInShelf = true;
  bool _issueSortAscending = true;
  bool _showAdvancedFilters = false;
  LibraryAddMode _mode = LibraryAddMode.addSeries;
  LibraryAddTarget _addTarget = LibraryAddTarget.owned;
  String? _defaultCondition = 'Near Mint';
  String? _defaultGrade = 'Ungraded';
  DateTime? _defaultPurchaseDate;
  String? _error;
  DateTime? _lastProviderSearchAt;
  String? _lastProviderSearchSignature;
  int _serverSearchGeneration = 0;
  double _resultsPaneWidth = 340;
  static const _providerSearchDebounce = Duration(milliseconds: 450);
  static const _coreSearchTimeout = Duration(seconds: 35);
  static const _minResultsPaneWidth = 280.0;
  static const _maxResultsPaneWidth = 520.0;
  static const _minPreviewPaneWidth = 420.0;

  @override
  void dispose() {
    _controller.dispose();
    _seriesController.dispose();
    _issueController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _barcodeController.dispose();
    _defaultStorageBoxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final libraryType = ref.watch(
      resolvedLibraryTypeProvider(comicsLibraryConfig),
    );
    _syncDefaultMetadataProvider(libraryType);
    final shelf = ref.watch(shelfProvider).value;
    final ownedItemIds = shelf == null
        ? const <String>{}
        : {
            for (final entry in shelf.entries)
              if (entry.ownedItem != null) entry.itemId,
          };
    final wishlistItemIds = shelf == null
        ? const <String>{}
        : {
            for (final entry in shelf.entries)
              if (entry.wishlistItem != null) entry.itemId,
          };
    final selectedItem = _selectedServerItem;
    final providerState = _providerState;
    final rawSelectedCandidate = providerState.selectedCandidate;
    final selectedCandidate = rawSelectedCandidate != null &&
            _isProviderCandidateVisible(
              rawSelectedCandidate,
              ownedItemIds: ownedItemIds,
              wishlistItemIds: wishlistItemIds,
            )
        ? rawSelectedCandidate
        : null;
    final checkedProviderCandidates = [
      for (final candidate in providerState.results)
        if (_checkedProviderIds.contains(candidate.providerItemId) &&
            _isProviderCandidateVisible(
              candidate,
              ownedItemIds: ownedItemIds,
              wishlistItemIds: wishlistItemIds,
            ))
          candidate,
    ];
    final proposalCandidates = checkedProviderCandidates.isNotEmpty
        ? checkedProviderCandidates
        : [
            if (selectedCandidate != null) selectedCandidate,
          ];
    final selectedProviderLabel =
        _metadataProviderLabel(providerState.provider);
    final selectedCandidateProviderLabel = selectedCandidate == null
        ? selectedProviderLabel
        : _metadataProviderLabel(selectedCandidate.provider);
    final pullListRows = pullListCandidates(shelf);
    final selectedIsOwned =
        selectedItem != null && ownedItemIds.contains(selectedItem.id);
    final selectedIsWishlisted =
        selectedItem != null && wishlistItemIds.contains(selectedItem.id);
    final checkedItems = [
      for (final item in _serverResults)
        if (_checkedServerIds.contains(item.id) &&
            !ownedItemIds.contains(item.id) &&
            !wishlistItemIds.contains(item.id))
          item,
    ];
    final addItems = checkedItems.isNotEmpty
        ? checkedItems
        : [
            if (selectedItem != null &&
                !selectedIsOwned &&
                !selectedIsWishlisted)
              selectedItem,
          ];
    final barcodeAddItems = _barcodeFoundAddItems(
      ownedItemIds: ownedItemIds,
      wishlistItemIds: wishlistItemIds,
    );
    return Theme(
      data: _kClzAddComicDialogTheme,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: width < 720 ? 10 : 32,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 780),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _kClzPanel,
              border: Border.all(color: const Color(0xFF636363)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xCC000000),
                  blurRadius: 22,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Focus(
              autofocus: true,
              onKeyEvent: (node, event) => _handleDialogKeyEvent(
                event,
                ownedItemIds: ownedItemIds,
                wishlistItemIds: wishlistItemIds,
              ),
              child: Column(
                children: [
                  _AddComicTitleBar(onClose: () => Navigator.of(context).pop()),
                  _AddComicModeBar(
                    mode: _mode,
                    queryController: _controller,
                    seriesController: _seriesController,
                    issueController: _issueController,
                    publisherController: _publisherController,
                    yearController: _yearController,
                    barcodeController: _barcodeController,
                    barcodeBatch: _barcodeBatch,
                    barcodeHistory: _barcodeHistory,
                    showAdvancedFilters: _showAdvancedFilters,
                    isSearching: _isSearchingServer,
                    onModeChanged: _changeMode,
                    onAdvancedChanged: (value) =>
                        setState(() => _showAdvancedFilters = value),
                    onSearch: _searchServer,
                    onLookupBarcode: () =>
                        _lookupBarcode(_barcodeController.text.trim()),
                    onLookupBarcodeBatch: _lookupBarcodeBatch,
                    barcodeAddCount: barcodeAddItems.length,
                    barcodeAddLabel: _barcodeAddLabel(barcodeAddItems.length),
                    onAddBarcodeFound: barcodeAddItems.isEmpty
                        ? null
                        : () => _addServerComics(
                              barcodeAddItems,
                              target: _addTarget,
                            ),
                    onRemoveBarcodeBatchEntry: _removeBarcodeBatchEntry,
                    onClearBarcodeBatch: _clearBarcodeBatch,
                    onUseBarcodeHistory: _lookupBarcode,
                    onScanBarcode: _scanBarcode,
                    onAddManual: _addManualComic,
                    onProposeManual: _proposeManualComic,
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                      child: _DialogMessage(
                        icon: Icons.error_outline,
                        text: _error!,
                      ),
                    ),
                  Expanded(
                    child: compact
                        ? Column(
                            children: [
                              SizedBox(
                                height: 300,
                                child: AddComicResultPane(
                                  mode: _mode,
                                  serverResults: _serverResults,
                                  providerResults: providerState.results,
                                  pullListRows: pullListRows,
                                  ownedItemIds: ownedItemIds,
                                  wishlistItemIds: wishlistItemIds,
                                  selectedServerId: _selectedServerId,
                                  selectedProviderId: providerState.selectedId,
                                  checkedServerIds: _checkedServerIds,
                                  checkedProviderIds: _checkedProviderIds,
                                  includeVariants: _includeVariants,
                                  hideInShelf: _hideInShelf,
                                  issueSortAscending: _issueSortAscending,
                                  searchedServer: _searchedServer,
                                  searchedProvider: providerState.searched,
                                  isSearchingServer: _isSearchingServer,
                                  isSearchingProvider:
                                      providerState.isSearching,
                                  selectedProvider: providerState.provider,
                                  providerLabel: _metadataProviderLabel,
                                  onIncludeVariantsChanged: (value) =>
                                      setState(() => _includeVariants = value),
                                  onHideInShelfChanged: (value) =>
                                      setState(() => _hideInShelf = value),
                                  onIssueSortAscendingChanged: (value) =>
                                      setState(
                                          () => _issueSortAscending = value),
                                  onSelectServer: (id) => setState(() {
                                    _selectedServerId = id;
                                    _providerState =
                                        _providerState.clearSelection();
                                    _checkedProviderIds.clear();
                                  }),
                                  onToggleServerCheck: _toggleServerCheck,
                                  collapsedSeries: _collapsedAddSeries,
                                  onToggleSeriesCollapsed:
                                      _toggleAddSeriesCollapsed,
                                  onToggleSeriesCheck: _toggleAddSeriesCheck,
                                  onCheckAllVisible: _checkServerItems,
                                  onClearServerChecks: () =>
                                      setState(_checkedServerIds.clear),
                                  onSelectProvider: (id) => setState(() {
                                    _selectProviderCandidate(id);
                                  }),
                                  onToggleProviderCheck: _toggleProviderCheck,
                                  onToggleProviderCandidatesCheck:
                                      _toggleProviderCandidatesCheck,
                                  onSearchPullListRow: _searchPullListRow,
                                ),
                              ),
                              Expanded(
                                child: AddComicPreviewPane(
                                  item: selectedItem,
                                  candidate: selectedCandidate,
                                  selectedProviderLabel:
                                      selectedCandidateProviderLabel,
                                  selectedIsOwned: selectedIsOwned,
                                  selectedIsWishlisted: selectedIsWishlisted,
                                  searchedServer: _searchedServer,
                                ),
                              ),
                            ],
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final paneWidth = _clampedResultsPaneWidth(
                                constraints.maxWidth,
                              );
                              return Row(
                                children: [
                                  SizedBox(
                                    width: paneWidth,
                                    child: AddComicResultPane(
                                      mode: _mode,
                                      serverResults: _serverResults,
                                      providerResults: providerState.results,
                                      pullListRows: pullListRows,
                                      ownedItemIds: ownedItemIds,
                                      wishlistItemIds: wishlistItemIds,
                                      selectedServerId: _selectedServerId,
                                      selectedProviderId:
                                          providerState.selectedId,
                                      checkedServerIds: _checkedServerIds,
                                      checkedProviderIds: _checkedProviderIds,
                                      includeVariants: _includeVariants,
                                      hideInShelf: _hideInShelf,
                                      issueSortAscending: _issueSortAscending,
                                      searchedServer: _searchedServer,
                                      searchedProvider: providerState.searched,
                                      isSearchingServer: _isSearchingServer,
                                      isSearchingProvider:
                                          providerState.isSearching,
                                      selectedProvider: providerState.provider,
                                      providerLabel: _metadataProviderLabel,
                                      onIncludeVariantsChanged: (value) =>
                                          setState(
                                              () => _includeVariants = value),
                                      onHideInShelfChanged: (value) =>
                                          setState(() => _hideInShelf = value),
                                      onIssueSortAscendingChanged: (value) =>
                                          setState(() =>
                                              _issueSortAscending = value),
                                      onSelectServer: (id) => setState(() {
                                        _selectedServerId = id;
                                        _providerState =
                                            _providerState.clearSelection();
                                        _checkedProviderIds.clear();
                                      }),
                                      onToggleServerCheck: _toggleServerCheck,
                                      collapsedSeries: _collapsedAddSeries,
                                      onToggleSeriesCollapsed:
                                          _toggleAddSeriesCollapsed,
                                      onToggleSeriesCheck:
                                          _toggleAddSeriesCheck,
                                      onCheckAllVisible: _checkServerItems,
                                      onClearServerChecks: () =>
                                          setState(_checkedServerIds.clear),
                                      onSelectProvider: (id) => setState(() {
                                        _selectProviderCandidate(id);
                                      }),
                                      onToggleProviderCheck:
                                          _toggleProviderCheck,
                                      onToggleProviderCandidatesCheck:
                                          _toggleProviderCandidatesCheck,
                                      onSearchPullListRow: _searchPullListRow,
                                    ),
                                  ),
                                  _AddComicPaneResizeHandle(
                                    onDragDelta: (delta) => _resizeResultsPane(
                                      delta,
                                      constraints.maxWidth,
                                    ),
                                  ),
                                  Expanded(
                                    child: AddComicPreviewPane(
                                      item: selectedItem,
                                      candidate: selectedCandidate,
                                      selectedProviderLabel:
                                          selectedCandidateProviderLabel,
                                      selectedIsOwned: selectedIsOwned,
                                      selectedIsWishlisted:
                                          selectedIsWishlisted,
                                      searchedServer: _searchedServer,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  AddComicBottomBar(
                    selectedItem: selectedItem,
                    selectedCandidate: selectedCandidate,
                    selectedIsOwned: selectedIsOwned,
                    selectedIsWishlisted: selectedIsWishlisted,
                    proposalProviderLabel: selectedCandidate == null
                        ? selectedProviderLabel
                        : _metadataProviderLabel(selectedCandidate.provider),
                    proposalCount: proposalCandidates.length,
                    addTarget: _addTarget,
                    addCount: addItems.length,
                    isSubmitting: _isSubmitting,
                    defaultCondition: _defaultCondition,
                    defaultGrade: _defaultGrade,
                    defaultStorageBoxController: _defaultStorageBoxController,
                    defaultPurchaseDate: _defaultPurchaseDate,
                    onAddTargetChanged: (value) =>
                        setState(() => _addTarget = value),
                    onDefaultConditionChanged: (value) =>
                        setState(() => _defaultCondition = value),
                    onDefaultGradeChanged: (value) =>
                        setState(() => _defaultGrade = value),
                    onDefaultPurchaseDateChanged: (value) =>
                        setState(() => _defaultPurchaseDate = value),
                    onAdd: addItems.isEmpty
                        ? null
                        : () => _addServerComics(
                              addItems,
                              target: _addTarget,
                            ),
                    onPropose: proposalCandidates.isEmpty
                        ? null
                        : () => _proposeCandidates(proposalCandidates),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  CatalogItem? get _selectedServerItem {
    final id = _selectedServerId;
    if (id == null) {
      return null;
    }
    for (final item in _serverResults) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  LibraryTypeConfig get _libraryType {
    return ref.read(resolvedLibraryTypeProvider(comicsLibraryConfig));
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

  void _syncDefaultMetadataProvider(LibraryTypeConfig libraryType) {
    final providerIds = {
      for (final provider in libraryType.supportedMetadataProviders)
        provider.id,
    };
    final defaultProvider = libraryType.defaultSupportedMetadataProvider;
    final providerIsUnsupported =
        !providerIds.contains(_providerState.provider);
    final shouldUseCatalogDefault = _providerState.provider != defaultProvider;
    if (!providerIsUnsupported && !shouldUseCatalogDefault) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _providerState = _providerState.changeProvider(defaultProvider);
      });
    });
  }

  bool _isProviderCandidateVisible(
    ProviderCandidate candidate, {
    required Set<String> ownedItemIds,
    required Set<String> wishlistItemIds,
  }) {
    if (!_includeVariants && candidate.isVariant) {
      return false;
    }
    if (_hideInShelf &&
        (ownedItemIds.contains(candidate.localCatalogId) ||
            wishlistItemIds.contains(candidate.localCatalogId))) {
      return false;
    }
    return true;
  }

  bool _isServerItemVisible(
    CatalogItem item, {
    required Set<String> ownedItemIds,
    required Set<String> wishlistItemIds,
  }) {
    if (!_includeVariants && _looksLikeComicVariant(item.variant)) {
      return false;
    }
    if (_hideInShelf &&
        (ownedItemIds.contains(item.id) || wishlistItemIds.contains(item.id))) {
      return false;
    }
    return true;
  }

  bool _looksLikeComicVariant(String? value) {
    final text = value?.trim().toLowerCase();
    if (text == null || text.isEmpty) {
      return false;
    }
    if (text == 'cover a' ||
        text == 'regular cover' ||
        text == 'standard cover' ||
        text == 'standard edition') {
      return false;
    }
    return text.contains('variant') ||
        text.contains('virgin') ||
        text.contains('foil') ||
        text.contains('exclusive') ||
        text.contains('incentive') ||
        text.contains('ratio') ||
        text.contains('second printing') ||
        text.contains('third printing');
  }

  bool get _keyboardShortcutShouldYieldToInput {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) {
      return false;
    }
    return context.widget is EditableText ||
        context.findAncestorWidgetOfExactType<EditableText>() != null ||
        context is Element && _containsEditableText(context);
  }

  bool _containsEditableText(Element root) {
    var found = false;
    void visit(Element element) {
      if (found) {
        return;
      }
      if (element.widget is EditableText) {
        found = true;
        return;
      }
      element.visitChildren(visit);
    }

    root.visitChildren(visit);
    return found;
  }

  KeyEventResult _handleDialogKeyEvent(
    KeyEvent event, {
    required Set<String> ownedItemIds,
    required Set<String> wishlistItemIds,
  }) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (_keyboardShortcutShouldYieldToInput) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _searchServer();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveResultSelection(
        1,
        ownedItemIds: ownedItemIds,
        wishlistItemIds: wishlistItemIds,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveResultSelection(
        -1,
        ownedItemIds: ownedItemIds,
        wishlistItemIds: wishlistItemIds,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.space) {
      _toggleFocusedResultSelection();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _moveResultSelection(
    int delta, {
    required Set<String> ownedItemIds,
    required Set<String> wishlistItemIds,
  }) {
    if (_keyboardShortcutShouldYieldToInput) {
      return;
    }
    final visibleServerIds = [
      for (final item in _serverResults)
        if (_isServerItemVisible(
          item,
          ownedItemIds: ownedItemIds,
          wishlistItemIds: wishlistItemIds,
        ))
          item.id,
    ];
    if (visibleServerIds.isNotEmpty) {
      final currentIndex = _selectedServerId == null
          ? -1
          : visibleServerIds.indexOf(_selectedServerId!);
      final nextIndex = _wrappedResultIndex(
        currentIndex: currentIndex,
        delta: delta,
        length: visibleServerIds.length,
      );
      setState(() {
        _selectedServerId = visibleServerIds[nextIndex];
        _providerState = _providerState.clearSelection();
        _checkedProviderIds.clear();
      });
      return;
    }

    final visibleProviderIds = [
      for (final candidate in _providerState.results)
        if (_isProviderCandidateVisible(
          candidate,
          ownedItemIds: ownedItemIds,
          wishlistItemIds: wishlistItemIds,
        ))
          candidate.providerItemId,
    ];
    if (visibleProviderIds.isEmpty) {
      return;
    }
    final currentIndex = _providerState.selectedId == null
        ? -1
        : visibleProviderIds.indexOf(_providerState.selectedId!);
    final nextIndex = _wrappedResultIndex(
      currentIndex: currentIndex,
      delta: delta,
      length: visibleProviderIds.length,
    );
    setState(() => _selectProviderCandidate(visibleProviderIds[nextIndex]));
  }

  int _wrappedResultIndex({
    required int currentIndex,
    required int delta,
    required int length,
  }) {
    if (length <= 1) {
      return 0;
    }
    final start = currentIndex < 0 ? (delta > 0 ? -1 : 0) : currentIndex;
    return (start + delta) % length;
  }

  void _toggleFocusedResultSelection() {
    if (_keyboardShortcutShouldYieldToInput) {
      return;
    }
    final selectedServerId = _selectedServerId;
    if (selectedServerId != null) {
      _toggleServerCheck(selectedServerId);
      return;
    }
    final selectedProviderId = _providerState.selectedId;
    if (selectedProviderId != null) {
      _toggleProviderCheck(selectedProviderId);
    }
  }

  List<CatalogItem> _barcodeFoundAddItems({
    required Set<String> ownedItemIds,
    required Set<String> wishlistItemIds,
  }) {
    final seen = <String>{};
    return [
      for (final entry in _barcodeBatch)
        if (entry.item != null &&
            !ownedItemIds.contains(entry.item!.id) &&
            !wishlistItemIds.contains(entry.item!.id) &&
            seen.add(entry.item!.id))
          entry.item!,
    ];
  }

  String _barcodeAddLabel(int count) {
    final verb = _addTarget == LibraryAddTarget.wishlist ? 'Save' : 'Add';
    return count == 1 ? '$verb found' : '$verb $count found';
  }

  Future<void> _searchServer() async {
    final searchFields = _searchFieldsForMode();
    var query = searchFields.query;
    final series = searchFields.series;
    final issueNumber = searchFields.issueNumber;
    if (_mode == LibraryAddMode.addIssue && issueNumber.trim().isEmpty) {
      setState(() {
        _error = 'Issue number is required for Add Issue.';
        _searchedServer = false;
        _serverResults = const [];
        _providerState = _providerState.clearResults();
      });
      return;
    }
    final publisher = _publisherController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    var barcode = _barcodeController.text.trim();
    if (barcode.isEmpty && _looksLikeBarcode(query)) {
      barcode = query;
      _barcodeController.text = query;
      query = '';
    }
    final input = LibraryMetadataSearchInput(
      query: query,
      series: series,
      issueNumber: issueNumber,
      publisher: publisher,
      year: year,
      barcode: barcode,
      limit: 50,
    );
    if (input.isEmpty) {
      return;
    }
    final searchGeneration = ++_serverSearchGeneration;
    setState(() {
      _isSearchingServer = true;
      _searchedServer = true;
      _serverResults = const [];
      _selectedServerId = null;
      _providerState = _providerState.clearResults();
      _checkedServerIds.clear();
      _checkedProviderIds.clear();
      _collapsedAddSeries.clear();
      _error = null;
    });
    try {
      final items = await searchAndCacheLibraryMetadata(
        api: ref.read(apiClientProvider),
        type: _libraryType,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        input: input,
      ).timeout(_coreSearchTimeout);
      if (!mounted || searchGeneration != _serverSearchGeneration) {
        return;
      }
      final shouldSearchProvider = items.isEmpty;
      setState(() {
        _serverResults = items;
        _selectedServerId = items.isEmpty ? null : items.first.id;
        if (shouldSearchProvider) {
          _isSearchingServer = false;
        }
      });
      if (shouldSearchProvider) {
        await _searchProvider(bypassDebounce: true);
      }
    } catch (error) {
      if (!mounted || searchGeneration != _serverSearchGeneration) {
        return;
      }
      if (await _clearRejectedMetadataSession(error, 'Core search')) {
        return;
      }
      final api = ref.read(apiClientProvider);
      final detail = ConnectionDiagnostics.metadataError(error, api.baseUrl);
      setState(
        () => _error = 'Core search failed: $detail '
            'Try a provider search or add the item manually.',
      );
    } finally {
      if (mounted && searchGeneration == _serverSearchGeneration) {
        setState(() => _isSearchingServer = false);
      }
    }
  }

  Future<void> _searchPullListRow(PullListCandidate row) async {
    setState(() {
      _mode = LibraryAddMode.addIssue;
      _controller.clear();
      _seriesController.text = row.series;
      _issueController.text = row.issue;
      _publisherController.text = row.publisher ?? '';
      _showAdvancedFilters = true;
    });
    await _searchServer();
  }

  Future<void> _searchProvider({
    String? queryOverride,
    bool bypassDebounce = false,
  }) async {
    final query = queryOverride?.trim().isNotEmpty == true
        ? queryOverride!.trim()
        : _providerQuery;
    if (query.isEmpty) {
      return;
    }
    final provider = _providerState.provider;
    if (_providerState.isSearching ||
        (!bypassDebounce && _shouldDebounceProviderSearch(provider, query))) {
      return;
    }
    setState(() {
      _providerState = _providerState.startSearch();
      _error = null;
    });
    try {
      final results = await searchLibraryProviderCandidates(
        ref.read(apiClientProvider),
        _libraryType,
        query: query,
      );
      if (!mounted) {
        return;
      }
      setState(() => _providerState = _providerState.withResults(results));
    } catch (error) {
      if (!mounted) {
        return;
      }
      if (await _clearRejectedMetadataSession(error, 'Provider search')) {
        return;
      }
      setState(() {
        final api = ref.read(apiClientProvider);
        _providerState = _providerState.finishSearch();
        _error = 'Provider search failed: '
            '${ConnectionDiagnostics.metadataError(error, api.baseUrl)}';
      });
    }
  }

  String get _providerQuery {
    final searchFields = _searchFieldsForMode();
    return [
      searchFields.query,
      searchFields.series,
      searchFields.issueNumber,
      _publisherController.text.trim(),
      _yearController.text.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
  }

  _ComicsSearchFields _searchFieldsForMode() {
    final query = _controller.text.trim();
    final series = _seriesController.text.trim();
    final issue = _issueController.text.trim();
    return switch (_mode) {
      LibraryAddMode.addSeries => _ComicsSearchFields(query: query),
      LibraryAddMode.addIssue => _ComicsSearchFields(
          query: '',
          series: series.isNotEmpty ? series : query,
          issueNumber: issue,
        ),
      LibraryAddMode.barcode ||
      LibraryAddMode.pullList =>
        _ComicsSearchFields(query: query, series: series, issueNumber: issue),
    };
  }

  void _changeMode(LibraryAddMode mode) {
    if (mode == _mode) {
      return;
    }
    if (mode == LibraryAddMode.addIssue &&
        _seriesController.text.trim().isEmpty &&
        _controller.text.trim().isNotEmpty) {
      _seriesController.text = _controller.text.trim();
    }
    if (mode == LibraryAddMode.addSeries &&
        _controller.text.trim().isEmpty &&
        _seriesController.text.trim().isNotEmpty) {
      _controller.text = _seriesController.text.trim();
    }
    setState(() => _mode = mode);
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
      _isSearchingServer = false;
      _providerState = _providerState.finishSearch();
      _error = '$action needs a fresh metadata sign-in. '
          'Open Settings and sign in again.';
    });
    return true;
  }

  String _metadataProviderLabel(String provider) {
    return _libraryType.metadataProviderLabel(provider);
  }

  bool _looksLikeBarcode(String value) {
    final trimmed = value.trim();
    final normalized = MetadataSearchQuery.normalizeBarcode(value);
    return normalized.length >= 8 &&
        RegExp(r'^[0-9Xx\-\s]+$').hasMatch(trimmed);
  }

  Future<void> _scanBarcode() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const BarcodeScanSheet(),
    );
    if (code == null || !mounted) {
      return;
    }
    _barcodeController.text = code;
    await _lookupBarcode(code);
  }

  Future<void> _lookupBarcode(String code) async {
    final normalized = MetadataSearchQuery.normalizeBarcode(code);
    if (normalized.isEmpty) {
      return;
    }
    final added = _ensureBarcodeBatchEntry(normalized);
    if (!added) {
      setState(() => _error = 'Barcode already scanned: $normalized');
      return;
    }
    _recordBarcodeHistory(normalized);
    setState(_barcodeController.clear);
    await _lookupBarcodeBatch(codes: [normalized]);
  }

  bool _ensureBarcodeBatchEntry(String code) {
    if (_barcodeBatch.any((entry) => entry.code == code)) {
      return false;
    }
    setState(() {
      _barcodeBatch.add(BarcodeLookupEntry.pending(code));
    });
    return true;
  }

  void _recordBarcodeHistory(String code) {
    setState(() {
      _barcodeHistory
        ..remove(code)
        ..insert(0, code);
      if (_barcodeHistory.length > 8) {
        _barcodeHistory.removeRange(8, _barcodeHistory.length);
      }
    });
  }

  Future<void> _lookupBarcodeBatch({Iterable<String>? codes}) async {
    final normalizedCodes = (codes ?? _barcodeBatch.map((entry) => entry.code))
        .map(MetadataSearchQuery.normalizeBarcode)
        .where((code) => code.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedCodes.isEmpty) {
      return;
    }
    final searchGeneration = ++_serverSearchGeneration;
    try {
      setState(() {
        _isSearchingServer = true;
        _searchedServer = true;
        _providerState = _providerState.clearResults();
        _error = null;
        for (final code in normalizedCodes) {
          final index = _barcodeBatch.indexWhere((entry) => entry.code == code);
          if (index == -1) {
            _barcodeBatch.add(BarcodeLookupEntry.lookingUp(code));
          } else {
            _barcodeBatch[index] = _barcodeBatch[index].copyWith(
              status: BarcodeLookupStatus.lookingUp,
              error: null,
            );
          }
        }
      });
      final results = await lookupAndCacheLibraryBarcodes(
        api: ref.read(apiClientProvider),
        type: _libraryType,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        barcodes: normalizedCodes,
        onResult: (result) {
          if (!mounted) {
            return;
          }
          _updateBarcodeBatchEntry(
            result.barcode,
            result.found
                ? BarcodeLookupEntry.found(
                    code: result.barcode,
                    item: result.item!,
                  )
                : BarcodeLookupEntry.missing(result.barcode),
          );
        },
      ).timeout(_coreSearchTimeout);
      if (!mounted || searchGeneration != _serverSearchGeneration) {
        return;
      }
      final found = results
          .map((result) => result.item)
          .whereType<CatalogItem>()
          .toList(growable: false);
      setState(() {
        final merged = <String, CatalogItem>{
          for (final item in _serverResults) item.id: item,
          for (final item in found) item.id: item,
        };
        _serverResults = merged.values.toList(growable: false);
        if (found.isNotEmpty) {
          _selectedServerId = found.first.id;
          _checkedServerIds.addAll(found.map((item) => item.id));
        }
        if (found.isEmpty) {
          _error = 'No Collectarr Core comics found for selected barcodes';
        }
      });
    } catch (error) {
      if (!mounted || searchGeneration != _serverSearchGeneration) {
        return;
      }
      if (await _clearRejectedMetadataSession(error, 'Barcode lookup')) {
        return;
      }
      setState(() {
        final detail = ConnectionDiagnostics.metadataError(
          error,
          ref.read(apiClientProvider).baseUrl,
        );
        for (final code in normalizedCodes) {
          final index = _barcodeBatch.indexWhere((entry) => entry.code == code);
          if (index != -1 &&
              _barcodeBatch[index].status == BarcodeLookupStatus.lookingUp) {
            _barcodeBatch[index] = _barcodeBatch[index].copyWith(
              status: BarcodeLookupStatus.missing,
              error: detail,
            );
          }
        }
        _error = 'Barcode lookup failed: $detail';
      });
    } finally {
      if (mounted && searchGeneration == _serverSearchGeneration) {
        setState(() => _isSearchingServer = false);
      }
    }
  }

  void _updateBarcodeBatchEntry(String code, BarcodeLookupEntry entry) {
    setState(() {
      final index = _barcodeBatch.indexWhere((row) => row.code == code);
      if (index == -1) {
        _barcodeBatch.add(entry);
      } else {
        _barcodeBatch[index] = entry;
      }
    });
  }

  void _removeBarcodeBatchEntry(String code) {
    setState(() {
      final removedIds = _barcodeBatch
          .where((entry) => entry.code == code)
          .map((entry) => entry.item?.id)
          .whereType<String>()
          .toSet();
      _barcodeBatch.removeWhere((entry) => entry.code == code);
      final remainingIds = _barcodeBatch
          .map((entry) => entry.item?.id)
          .whereType<String>()
          .toSet();
      _serverResults = _serverResults
          .where((item) =>
              !removedIds.contains(item.id) || remainingIds.contains(item.id))
          .toList(growable: false);
      _checkedServerIds.removeAll(removedIds.difference(remainingIds));
    });
  }

  void _clearBarcodeBatch() {
    setState(() {
      _barcodeBatch.clear();
      _barcodeController.clear();
      _checkedServerIds.clear();
      _checkedProviderIds.clear();
      _serverResults = const [];
      _selectedServerId = null;
      _error = null;
    });
  }

  void _toggleServerCheck(String id) {
    setState(() {
      _selectedServerId = id;
      _providerState = _providerState.clearSelection();
      _checkedProviderIds.clear();
      if (_checkedServerIds.contains(id)) {
        _checkedServerIds.remove(id);
      } else {
        _checkedServerIds.add(id);
      }
    });
  }

  void _checkServerItems(Iterable<CatalogItem> items) {
    setState(() {
      _checkedServerIds
        ..clear()
        ..addAll(items.map((item) => item.id));
      if (items.isNotEmpty) {
        _selectedServerId = items.first.id;
        _providerState = _providerState.clearSelection();
        _checkedProviderIds.clear();
      }
    });
  }

  void _toggleAddSeriesCollapsed(String seriesTitle) {
    setState(() {
      if (_collapsedAddSeries.contains(seriesTitle)) {
        _collapsedAddSeries.remove(seriesTitle);
      } else {
        _collapsedAddSeries.add(seriesTitle);
      }
    });
  }

  void _toggleAddSeriesCheck(Iterable<CatalogItem> items) {
    final addable = items
        .where((item) => !_checkedServerIds.contains(item.id))
        .map((item) => item.id)
        .toList(growable: false);
    setState(() {
      if (addable.isEmpty) {
        _checkedServerIds.removeAll(items.map((item) => item.id));
      } else {
        _checkedServerIds.addAll(addable);
        if (items.isNotEmpty) {
          _selectedServerId = items.first.id;
          _providerState = _providerState.clearSelection();
          _checkedProviderIds.clear();
        }
      }
    });
  }

  void _selectProviderCandidate(String id) {
    _providerState = _providerState.select(id);
    _selectedServerId = null;
    _checkedServerIds.clear();
  }

  void _toggleProviderCheck(String id) {
    setState(() {
      _selectProviderCandidate(id);
      if (_checkedProviderIds.contains(id)) {
        _checkedProviderIds.remove(id);
      } else {
        _checkedProviderIds.add(id);
      }
    });
  }

  void _toggleProviderCandidatesCheck(Iterable<ProviderCandidate> candidates) {
    final ids = [
      for (final candidate in candidates) candidate.providerItemId,
    ];
    if (ids.isEmpty) {
      return;
    }
    final allChecked = ids.every(_checkedProviderIds.contains);
    setState(() {
      _selectedServerId = null;
      _checkedServerIds.clear();
      _providerState = _providerState.select(ids.first);
      if (allChecked) {
        _checkedProviderIds.removeAll(ids);
      } else {
        _checkedProviderIds.addAll(ids);
      }
    });
  }

  Future<void> _addServerComics(
    List<CatalogItem> items, {
    required LibraryAddTarget target,
  }) async {
    setState(() => _isSubmitting = true);
    await addLibraryItemsToTarget(
      catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
      mutations: ref.read(collectionMutationsProvider),
      items: items,
      target: target,
      defaults: LibraryAddDefaults(
        condition: _defaultCondition,
        grade: _defaultGrade,
        purchaseDate: _defaultPurchaseDate,
        storageBox: _defaultStorageBoxController.text,
      ),
    );
    ref.invalidate(shelfProvider);
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    Navigator.of(context).pop();
    final wishlist = target == LibraryAddTarget.wishlist;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wishlist
              ? 'Saved ${items.length} comic${items.length == 1 ? '' : 's'} to local wishlist'
              : 'Added ${items.length} comic${items.length == 1 ? '' : 's'} to local collection',
        ),
      ),
    );
  }

  Future<void> _proposeCandidates(List<ProviderCandidate> candidates) async {
    if (candidates.isEmpty) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      for (final candidate in candidates) {
        await createAndRecordLibraryMetadataProposal(
          api: ref.read(apiClientProvider),
          type: _libraryType,
          provider: candidate.provider,
          providerItemId: candidate.providerItemId,
          query: _providerQuery,
          title: candidate.title,
          summary: candidate.summary,
          imageUrl: candidate.imageUrl,
          source: 'Add Comics provider result',
        );
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            candidates.length == 1
                ? 'Metadata proposal sent for review'
                : '${candidates.length} metadata proposals sent for review',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Metadata proposal failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _addManualComic() async {
    final item = await showDialog<CatalogItem>(
      context: context,
      builder: (context) => const ManualComicDialog(),
    );
    if (item == null || !mounted) {
      return;
    }
    await CatalogCacheRepository(ref.read(localDatabaseProvider))
        .upsertAll([item]);
    setState(() {
      _mode = LibraryAddMode.addIssue;
      _searchedServer = true;
      _serverResults = [
        item,
        ..._serverResults.where((row) => row.id != item.id)
      ];
      _selectedServerId = item.id;
      _providerState = _providerState.clearSelection();
      _checkedServerIds
        ..clear()
        ..add(item.id);
      _error = null;
    });
  }

  Future<void> _proposeManualComic() async {
    final proposal = await showDialog<ManualProposalDraft>(
      context: context,
      builder: (context) => const ManualProposalDialog(),
    );
    if (proposal == null || !mounted) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await createAndRecordLibraryMetadataProposal(
        api: ref.read(apiClientProvider),
        type: _libraryType,
        provider: _providerState.provider,
        query: proposal.title,
        title: proposal.title,
        summary: proposal.notes,
        source: 'Add Comics manual proposal',
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Manual metadata proposal sent for review')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Manual metadata proposal failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _AddComicTitleBar extends StatelessWidget {
  const _AddComicTitleBar({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A4A4A), Color(0xFF1B1B1B)],
        ),
        border: Border(bottom: BorderSide(color: _kClzAccent)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.public, color: Color(0xFF03A9DE), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Add Comics from Collectarr Core',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}

class _AddComicPaneResizeHandle extends StatelessWidget {
  const _AddComicPaneResizeHandle({required this.onDragDelta});

  final ValueChanged<double> onDragDelta;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDragDelta(details.delta.dx),
        child: Tooltip(
          message: 'Resize results pane',
          child: SizedBox(
            width: 10,
            child: Center(
              child: Container(
                width: 2,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComicsSearchFields {
  const _ComicsSearchFields({
    this.query = '',
    this.series = '',
    this.issueNumber = '',
  });

  final String query;
  final String series;
  final String issueNumber;
}

const double _kAddComicModeControlHeight = 36;

class _AddComicModeBar extends StatelessWidget {
  const _AddComicModeBar({
    required this.mode,
    required this.queryController,
    required this.seriesController,
    required this.issueController,
    required this.publisherController,
    required this.yearController,
    required this.barcodeController,
    required this.barcodeBatch,
    required this.barcodeHistory,
    required this.showAdvancedFilters,
    required this.isSearching,
    required this.onModeChanged,
    required this.onAdvancedChanged,
    required this.onSearch,
    required this.onLookupBarcode,
    required this.onLookupBarcodeBatch,
    required this.barcodeAddCount,
    required this.barcodeAddLabel,
    required this.onAddBarcodeFound,
    required this.onRemoveBarcodeBatchEntry,
    required this.onClearBarcodeBatch,
    required this.onUseBarcodeHistory,
    required this.onScanBarcode,
    required this.onAddManual,
    required this.onProposeManual,
  });

  final LibraryAddMode mode;
  final TextEditingController queryController;
  final TextEditingController seriesController;
  final TextEditingController issueController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final List<BarcodeLookupEntry> barcodeBatch;
  final List<String> barcodeHistory;
  final bool showAdvancedFilters;
  final bool isSearching;
  final ValueChanged<LibraryAddMode> onModeChanged;
  final ValueChanged<bool> onAdvancedChanged;
  final VoidCallback onSearch;
  final VoidCallback onLookupBarcode;
  final VoidCallback onLookupBarcodeBatch;
  final int barcodeAddCount;
  final String barcodeAddLabel;
  final VoidCallback? onAddBarcodeFound;
  final ValueChanged<String> onRemoveBarcodeBatchEntry;
  final VoidCallback onClearBarcodeBatch;
  final ValueChanged<String> onUseBarcodeHistory;
  final VoidCallback onScanBarcode;
  final VoidCallback onAddManual;
  final VoidCallback onProposeManual;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _kClzToolbar,
        border: Border(bottom: BorderSide(color: Color(0xFF111111))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 5, 7, 7),
        child: Column(
          children: [
            _AddModeTabStrip(
              mode: mode,
              onModeChanged: onModeChanged,
              onAddManual: onAddManual,
              onProposeManual: onProposeManual,
              onScanBarcode: onScanBarcode,
            ),
            const SizedBox(height: 7),
            switch (mode) {
              LibraryAddMode.addSeries => Row(
                  children: [
                    Expanded(
                      child: _PrimarySearchField(
                        controller: queryController,
                        hintText: 'Enter series title...',
                        onSubmitted: onSearch,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _FilterField(
                      width: 92,
                      controller: yearController,
                      label: 'Year',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      onSubmitted: onSearch,
                    ),
                    const SizedBox(width: 10),
                    _ModeSearchButton(
                      label: 'Search Series',
                      isSearching: isSearching,
                      onPressed: onSearch,
                    ),
                  ],
                ),
              LibraryAddMode.addIssue => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _PrimarySearchField(
                            controller: seriesController,
                            hintText: 'Enter series title...',
                            onSubmitted: onSearch,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _FilterField(
                          width: 96,
                          controller: issueController,
                          label: 'Issue',
                          textAlign: TextAlign.center,
                          onSubmitted: onSearch,
                        ),
                        const SizedBox(width: 10),
                        FilterChip(
                          selected: showAdvancedFilters,
                          onSelected: onAdvancedChanged,
                          avatar: const Icon(Icons.tune, size: 18),
                          label: const Text('Filters'),
                        ),
                        const SizedBox(width: 10),
                        _ModeSearchButton(
                          label: 'Search Issue',
                          isSearching: isSearching,
                          onPressed: onSearch,
                        ),
                      ],
                    ),
                    if (showAdvancedFilters) ...[
                      const SizedBox(height: 8),
                      _AdvancedSearchFilters(
                        seriesController: seriesController,
                        issueController: issueController,
                        publisherController: publisherController,
                        yearController: yearController,
                        barcodeController: barcodeController,
                        onSubmitted: onSearch,
                        includeSeriesAndIssue: false,
                      ),
                    ],
                  ],
                ),
              LibraryAddMode.barcode => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: _kAddComicModeControlHeight,
                            child: TextField(
                              controller: barcodeController,
                              keyboardType: TextInputType.number,
                              onSubmitted: (_) => onLookupBarcode(),
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Color(0xFF4A4A4A),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.qr_code_2),
                                hintText: 'Scan or enter barcode / UPC...',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const BarcodeLookupStrip(),
                          if (barcodeHistory.isNotEmpty &&
                              barcodeBatch.isEmpty) ...[
                            const SizedBox(height: 8),
                            BarcodeHistoryStrip(
                              codes: barcodeHistory,
                              onUse: onUseBarcodeHistory,
                            ),
                          ],
                          if (barcodeBatch.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            BarcodeBatchPanel(
                              entries: barcodeBatch,
                              isLookingUp: isSearching,
                              addableCount: barcodeAddCount,
                              addFoundLabel: barcodeAddLabel,
                              onLookupAll: onLookupBarcodeBatch,
                              onAddFound: onAddBarcodeFound,
                              onRemove: onRemoveBarcodeBatchEntry,
                              onClear: onClearBarcodeBatch,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: isSearching ? null : onScanBarcode,
                      icon: const Icon(Icons.barcode_reader, size: 18),
                      label: const Text('Scan barcode'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: isSearching ? null : onLookupBarcode,
                      child: isSearching
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Lookup barcode'),
                    ),
                  ],
                ),
              LibraryAddMode.pullList => const _PullListModePanel(),
            },
          ],
        ),
      ),
    );
  }
}

class _AddModeTabStrip extends StatelessWidget {
  const _AddModeTabStrip({
    required this.mode,
    required this.onModeChanged,
    required this.onAddManual,
    required this.onProposeManual,
    required this.onScanBarcode,
  });

  final LibraryAddMode mode;
  final ValueChanged<LibraryAddMode> onModeChanged;
  final VoidCallback onAddManual;
  final VoidCallback onProposeManual;
  final VoidCallback onScanBarcode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF272A2C),
        border: Border.all(color: const Color(0xFF4D555A)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          const Text(
            'Search by',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFFEDEDED),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  LibraryAddModeTab(
                    key: const ValueKey('add-comics-series-tab'),
                    icon: Icons.library_books,
                    label: 'Add Series',
                    selected: mode == LibraryAddMode.addSeries,
                    onTap: () => onModeChanged(LibraryAddMode.addSeries),
                  ),
                  LibraryAddModeTab(
                    key: const ValueKey('add-comics-issue-tab'),
                    icon: Icons.menu_book,
                    label: 'Add Issue',
                    selected: mode == LibraryAddMode.addIssue,
                    onTap: () => onModeChanged(LibraryAddMode.addIssue),
                  ),
                  LibraryAddModeTab(
                    key: const ValueKey('add-comics-barcode-tab'),
                    icon: Icons.qr_code_2,
                    label: 'Barcode',
                    selected: mode == LibraryAddMode.barcode,
                    onTap: () => onModeChanged(LibraryAddMode.barcode),
                  ),
                  LibraryAddModeTab(
                    key: const ValueKey('add-comics-pull-list-tab'),
                    icon: Icons.star,
                    label: 'Pull List',
                    selected: mode == LibraryAddMode.pullList,
                    onTap: () => onModeChanged(LibraryAddMode.pullList),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ModeActionButton(
            icon: Icons.edit_note,
            label: 'Manual',
            onPressed: onAddManual,
          ),
          _ModeActionButton(
            icon: Icons.outbox,
            label: 'Propose',
            onPressed: onProposeManual,
          ),
          _ModeActionButton(
            icon: Icons.barcode_reader,
            label: 'Scan',
            onPressed: onScanBarcode,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.menu, size: 26, color: Color(0xFFEDEDED)),
        ],
      ),
    );
  }
}

class _ModeActionButton extends StatelessWidget {
  const _ModeActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: kClzAccent,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          minimumSize: const Size(0, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _AdvancedSearchFilters extends StatelessWidget {
  const _AdvancedSearchFilters({
    required this.seriesController,
    required this.issueController,
    required this.publisherController,
    required this.yearController,
    required this.barcodeController,
    required this.onSubmitted,
    this.includeSeriesAndIssue = true,
  });

  final TextEditingController seriesController;
  final TextEditingController issueController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final VoidCallback onSubmitted;
  final bool includeSeriesAndIssue;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (includeSeriesAndIssue) ...[
          _FilterField(
            width: 210,
            controller: seriesController,
            label: 'Series',
            onSubmitted: onSubmitted,
          ),
          _FilterField(
            width: 92,
            controller: issueController,
            label: 'Issue #',
            textAlign: TextAlign.center,
            onSubmitted: onSubmitted,
          ),
        ],
        _FilterField(
          width: 150,
          controller: publisherController,
          label: 'Publisher',
          onSubmitted: onSubmitted,
        ),
        _FilterField(
          width: 92,
          controller: yearController,
          label: 'Year',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          onSubmitted: onSubmitted,
        ),
        _FilterField(
          width: 210,
          controller: barcodeController,
          label: 'Barcode / UPC',
          keyboardType: TextInputType.number,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

class _PrimarySearchField extends StatelessWidget {
  const _PrimarySearchField({
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kAddComicModeControlHeight,
      child: _ModeFieldFrame(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.text,
          inputFormatters: [_noNewlineFormatter],
          expands: true,
          minLines: null,
          maxLines: null,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          onSubmitted: (_) => onSubmitted(),
          style: const TextStyle(
            color: Color(0xFFEDEDED),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            isDense: true,
            isCollapsed: true,
            filled: false,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9EA9B0)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.width,
    required this.controller,
    required this.label,
    required this.onSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final VoidCallback onSubmitted;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: _kAddComicModeControlHeight,
      child: _ModeFieldFrame(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          inputFormatters: [...?inputFormatters, _noNewlineFormatter],
          expands: true,
          minLines: null,
          maxLines: null,
          textInputAction: TextInputAction.search,
          textAlign: textAlign,
          textAlignVertical: TextAlignVertical.center,
          onSubmitted: (_) => onSubmitted(),
          style: const TextStyle(
            color: Color(0xFFEDEDED),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            isDense: true,
            isCollapsed: true,
            filled: false,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            hintText: label,
            hintStyle: const TextStyle(color: Color(0xFF9EA9B0)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

class _ModeFieldFrame extends StatelessWidget {
  const _ModeFieldFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kAddComicModeControlHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.all(color: const Color(0xFF50565A)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: child,
    );
  }
}

class _ModeSearchButton extends StatelessWidget {
  const _ModeSearchButton({
    required this.label,
    required this.isSearching,
    required this.onPressed,
  });

  final String label;
  final bool isSearching;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kAddComicModeControlHeight,
      child: FilledButton(
        onPressed: isSearching ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, _kAddComicModeControlHeight),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: isSearching
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

class _PullListModePanel extends StatelessWidget {
  const _PullListModePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: const Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _AddInfoChip(icon: Icons.event_available, label: 'Upcoming issues'),
          _AddInfoChip(icon: Icons.bookmark_added, label: 'Watched series'),
          _AddInfoChip(icon: Icons.sync, label: 'Provider feeds'),
          _AddInfoChip(icon: Icons.lock_person, label: 'Local preferences'),
        ],
      ),
    );
  }
}

class _AddInfoChip extends StatelessWidget {
  const _AddInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        border: Border.all(color: const Color(0xFF555555)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF18B7EB)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _DialogMessage extends StatelessWidget {
  const _DialogMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
