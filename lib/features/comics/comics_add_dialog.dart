import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
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
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color _kClzToolbar = kClzToolbar;
const Color _kClzPanel = kClzPanel;
const Color _kClzAccent = kClzAccent;
final ThemeData _kClzAddComicDialogTheme = kClzAddComicDialogTheme;

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
  final _collapsedAddSeries = <String>{};
  final _barcodeBatch = <BarcodeLookupEntry>[];
  final _barcodeHistory = <String>[];
  bool _searchedServer = false;
  bool _isSearchingServer = false;
  bool _isSubmitting = false;
  bool _includeVariants = true;
  bool _hideInShelf = true;
  bool _showAdvancedFilters = false;
  LibraryAddMode _mode = LibraryAddMode.search;
  LibraryAddTarget _addTarget = LibraryAddTarget.owned;
  String? _defaultCondition = 'Near Mint';
  String? _defaultGrade = 'Ungraded';
  DateTime? _defaultPurchaseDate;
  String? _error;

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
    final selectedCandidate = providerState.selectedCandidate;
    final selectedProviderLabel =
        _metadataProviderLabel(providerState.provider);
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
                  onModeChanged: (value) => setState(() => _mode = value),
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
                                includeVariants: _includeVariants,
                                hideInShelf: _hideInShelf,
                                searchedServer: _searchedServer,
                                searchedProvider: providerState.searched,
                                isSearchingServer: _isSearchingServer,
                                isSearchingProvider: providerState.isSearching,
                                metadataProviders: comicsLibraryConfig
                                    .supportedMetadataProviders,
                                selectedProvider: providerState.provider,
                                providerLabel: _metadataProviderLabel,
                                onIncludeVariantsChanged: (value) =>
                                    setState(() => _includeVariants = value),
                                onHideInShelfChanged: (value) =>
                                    setState(() => _hideInShelf = value),
                                onProviderChanged: _changeMetadataProvider,
                                onSelectServer: (id) => setState(() {
                                  _selectedServerId = id;
                                  _providerState =
                                      _providerState.clearSelection();
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
                                  _providerState = _providerState.select(id);
                                  _selectedServerId = null;
                                }),
                                onSearchProvider: _searchProvider,
                                onSearchPullListRow: _searchPullListRow,
                              ),
                            ),
                            Expanded(
                              child: AddComicPreviewPane(
                                item: selectedItem,
                                candidate: selectedCandidate,
                                selectedProviderLabel: selectedProviderLabel,
                                selectedIsOwned: selectedIsOwned,
                                selectedIsWishlisted: selectedIsWishlisted,
                                searchedServer: _searchedServer,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            SizedBox(
                              width: 320,
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
                                includeVariants: _includeVariants,
                                hideInShelf: _hideInShelf,
                                searchedServer: _searchedServer,
                                searchedProvider: providerState.searched,
                                isSearchingServer: _isSearchingServer,
                                isSearchingProvider: providerState.isSearching,
                                metadataProviders: comicsLibraryConfig
                                    .supportedMetadataProviders,
                                selectedProvider: providerState.provider,
                                providerLabel: _metadataProviderLabel,
                                onIncludeVariantsChanged: (value) =>
                                    setState(() => _includeVariants = value),
                                onHideInShelfChanged: (value) =>
                                    setState(() => _hideInShelf = value),
                                onProviderChanged: _changeMetadataProvider,
                                onSelectServer: (id) => setState(() {
                                  _selectedServerId = id;
                                  _providerState =
                                      _providerState.clearSelection();
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
                                  _providerState = _providerState.select(id);
                                  _selectedServerId = null;
                                }),
                                onSearchProvider: _searchProvider,
                                onSearchPullListRow: _searchPullListRow,
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              child: AddComicPreviewPane(
                                item: selectedItem,
                                candidate: selectedCandidate,
                                selectedProviderLabel: selectedProviderLabel,
                                selectedIsOwned: selectedIsOwned,
                                selectedIsWishlisted: selectedIsWishlisted,
                                searchedServer: _searchedServer,
                              ),
                            ),
                          ],
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
                  onPropose: selectedCandidate == null
                      ? null
                      : () => _proposeCandidate(selectedCandidate),
                ),
              ],
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
    var query = _controller.text.trim();
    final series = _seriesController.text.trim();
    final issueNumber = _issueController.text.trim();
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
    setState(() {
      _isSearchingServer = true;
      _searchedServer = true;
      _serverResults = const [];
      _selectedServerId = null;
      _providerState = _providerState.clearResults();
      _checkedServerIds.clear();
      _collapsedAddSeries.clear();
      _error = null;
    });
    try {
      final items = await searchAndCacheLibraryMetadata(
        api: ref.read(apiClientProvider),
        type: comicsLibraryConfig,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        input: input,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _serverResults = items;
        _selectedServerId = items.isEmpty ? null : items.first.id;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Server metadata search failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSearchingServer = false);
      }
    }
  }

  Future<void> _searchPullListRow(PullListCandidate row) async {
    setState(() {
      _mode = LibraryAddMode.search;
      _controller.clear();
      _seriesController.text = row.series;
      _issueController.text = row.issue;
      _publisherController.text = row.publisher ?? '';
      _showAdvancedFilters = true;
    });
    await _searchServer();
  }

  Future<void> _searchProvider() async {
    final query = _providerQuery;
    if (query.isEmpty) {
      return;
    }
    final provider = _providerState.provider;
    setState(() {
      _providerState = _providerState.startSearch();
      _error = null;
    });
    try {
      final results = await searchLibraryProviderCandidates(
        ref.read(apiClientProvider),
        comicsLibraryConfig,
        provider: provider,
        query: query,
      );
      if (!mounted || _providerState.provider != provider) {
        return;
      }
      setState(() => _providerState = _providerState.withResults(results));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _providerState = _providerState.finishSearch();
        _error = '${_metadataProviderLabel(provider)} search failed: $error';
      });
    }
  }

  String get _providerQuery {
    return [
      _controller.text.trim(),
      _seriesController.text.trim(),
      _issueController.text.trim(),
      _publisherController.text.trim(),
      _yearController.text.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
  }

  void _changeMetadataProvider(String provider) {
    setState(() {
      _providerState = _providerState.changeProvider(provider);
      _error = null;
    });
  }

  String _metadataProviderLabel(String provider) {
    return comicsLibraryConfig.metadataProviderLabel(provider);
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
        type: comicsLibraryConfig,
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
      );
      if (!mounted) {
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
    } finally {
      if (mounted) {
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
      _serverResults = const [];
      _selectedServerId = null;
      _error = null;
    });
  }

  void _toggleServerCheck(String id) {
    setState(() {
      _selectedServerId = id;
      _providerState = _providerState.clearSelection();
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
        }
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

  Future<void> _proposeCandidate(ProviderCandidate candidate) async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await createAndRecordLibraryMetadataProposal(
        api: ref.read(apiClientProvider),
        type: comicsLibraryConfig,
        provider: candidate.provider,
        providerItemId: candidate.providerItemId,
        query: _providerQuery,
        title: candidate.title,
        summary: candidate.summary,
        imageUrl: candidate.imageUrl,
        source: 'Add Comics provider result',
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metadata proposal sent for review')),
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
      _mode = LibraryAddMode.search;
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
        type: comicsLibraryConfig,
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
    return ColoredBox(
      color: _kClzToolbar,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 4, 7, 7),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                        LibraryAddModeTab(
                          key: const ValueKey('add-comics-search-tab'),
                          icon: Icons.menu_book,
                          label: 'Search',
                          selected: mode == LibraryAddMode.search,
                          onTap: () => onModeChanged(LibraryAddMode.search),
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
                TextButton.icon(
                  onPressed: onAddManual,
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('Manual'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: onProposeManual,
                  icon: const Icon(Icons.outbox, size: 18),
                  label: const Text('Propose'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: onScanBarcode,
                  icon: const Icon(Icons.barcode_reader, size: 18),
                  label: const Text('Scan'),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.menu, size: 28),
              ],
            ),
            const SizedBox(height: 7),
            switch (mode) {
              LibraryAddMode.search => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: TextField(
                              controller: queryController,
                              onSubmitted: (_) => onSearch(),
                              decoration: const InputDecoration(
                                hintText:
                                    'Search title, series, issue, publisher...',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilterChip(
                          selected: showAdvancedFilters,
                          onSelected: onAdvancedChanged,
                          avatar: const Icon(Icons.tune, size: 18),
                          label: const Text('Filters'),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: isSearching ? null : onSearch,
                          child: isSearching
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Search Collectarr Core'),
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
                            height: 34,
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

class _AdvancedSearchFilters extends StatelessWidget {
  const _AdvancedSearchFilters({
    required this.seriesController,
    required this.issueController,
    required this.publisherController,
    required this.yearController,
    required this.barcodeController,
    required this.onSubmitted,
  });

  final TextEditingController seriesController;
  final TextEditingController issueController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
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
          onSubmitted: onSubmitted,
        ),
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

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.width,
    required this.controller,
    required this.label,
    required this.onSubmitted,
    this.keyboardType,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final VoidCallback onSubmitted;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 38,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFF4A4A4A),
          border: const OutlineInputBorder(),
          labelText: label,
        ),
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
