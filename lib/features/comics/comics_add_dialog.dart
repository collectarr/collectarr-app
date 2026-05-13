import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_add_images.dart';
import 'package:collectarr_app/features/comics/comics_barcode_lookup.dart';
import 'package:collectarr_app/features/comics/comics_add_bottom_bar.dart';
import 'package:collectarr_app/features/comics/comics_add_preview_pane.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/comics_manual_metadata_dialogs.dart';
import 'package:collectarr_app/features/library/add/library_add_mode.dart';
import 'package:collectarr_app/features/library/add/library_add_mode_tab.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color _kClzToolbar = kClzToolbar;
const Color _kClzPanel = kClzPanel;
const Color _kClzAccent = kClzAccent;
const Color _kClzSelection = kClzSelection;
const Color _kClzYellow = kClzYellow;
const Color _kClzDivider = kClzDivider;
final ThemeData _kClzAddComicDialogTheme = kClzAddComicDialogTheme;

int _compareIssueNumbers(String? left, String? right) {
  final leftNumber = _issueNumberSortValue(left);
  final rightNumber = _issueNumberSortValue(right);
  if (leftNumber != null && rightNumber != null) {
    final numeric = leftNumber.compareTo(rightNumber);
    if (numeric != 0) {
      return numeric;
    }
  }
  if (leftNumber != null) {
    return -1;
  }
  if (rightNumber != null) {
    return 1;
  }
  return _compareNullableStrings(left, right);
}

double? _issueNumberSortValue(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final match = RegExp(r'^\s*(\d+(?:\.\d+)?)').firstMatch(value);
  return match == null ? null : double.tryParse(match.group(1)!);
}

int _compareNullableStrings(String? left, String? right) {
  final leftValue = left?.toLowerCase() ?? '';
  final rightValue = right?.toLowerCase() ?? '';
  if (leftValue.isEmpty && rightValue.isNotEmpty) {
    return 1;
  }
  if (leftValue.isNotEmpty && rightValue.isEmpty) {
    return -1;
  }
  return leftValue.compareTo(rightValue);
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

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
  var _providerResults = const <ProviderCandidate>[];
  String? _selectedServerId;
  String? _selectedProviderId;
  final _checkedServerIds = <String>{};
  final _collapsedAddSeries = <String>{};
  final _barcodeBatch = <BarcodeLookupEntry>[];
  final _barcodeHistory = <String>[];
  bool _searchedServer = false;
  bool _searchedProvider = false;
  bool _isSearchingServer = false;
  bool _isSearchingProvider = false;
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
    final selectedCandidate = _selectedProviderCandidate;
    final pullListRows = _pullListCandidates(shelf);
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
                              child: _AddComicResultPane(
                                mode: _mode,
                                serverResults: _serverResults,
                                providerResults: _providerResults,
                                pullListRows: pullListRows,
                                ownedItemIds: ownedItemIds,
                                wishlistItemIds: wishlistItemIds,
                                selectedServerId: _selectedServerId,
                                selectedProviderId: _selectedProviderId,
                                checkedServerIds: _checkedServerIds,
                                includeVariants: _includeVariants,
                                hideInShelf: _hideInShelf,
                                searchedServer: _searchedServer,
                                searchedProvider: _searchedProvider,
                                isSearchingServer: _isSearchingServer,
                                isSearchingProvider: _isSearchingProvider,
                                onIncludeVariantsChanged: (value) =>
                                    setState(() => _includeVariants = value),
                                onHideInShelfChanged: (value) =>
                                    setState(() => _hideInShelf = value),
                                onSelectServer: (id) => setState(() {
                                  _selectedServerId = id;
                                  _selectedProviderId = null;
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
                                  _selectedProviderId = id;
                                  _selectedServerId = null;
                                }),
                                onSearchProvider: _searchComicVine,
                                onSearchPullListRow: _searchPullListRow,
                              ),
                            ),
                            Expanded(
                              child: AddComicPreviewPane(
                                item: selectedItem,
                                candidate: selectedCandidate,
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
                              child: _AddComicResultPane(
                                mode: _mode,
                                serverResults: _serverResults,
                                providerResults: _providerResults,
                                pullListRows: pullListRows,
                                ownedItemIds: ownedItemIds,
                                wishlistItemIds: wishlistItemIds,
                                selectedServerId: _selectedServerId,
                                selectedProviderId: _selectedProviderId,
                                checkedServerIds: _checkedServerIds,
                                includeVariants: _includeVariants,
                                hideInShelf: _hideInShelf,
                                searchedServer: _searchedServer,
                                searchedProvider: _searchedProvider,
                                isSearchingServer: _isSearchingServer,
                                isSearchingProvider: _isSearchingProvider,
                                onIncludeVariantsChanged: (value) =>
                                    setState(() => _includeVariants = value),
                                onHideInShelfChanged: (value) =>
                                    setState(() => _hideInShelf = value),
                                onSelectServer: (id) => setState(() {
                                  _selectedServerId = id;
                                  _selectedProviderId = null;
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
                                  _selectedProviderId = id;
                                  _selectedServerId = null;
                                }),
                                onSearchProvider: _searchComicVine,
                                onSearchPullListRow: _searchPullListRow,
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              child: AddComicPreviewPane(
                                item: selectedItem,
                                candidate: selectedCandidate,
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
                            wishlist: _addTarget == LibraryAddTarget.wishlist,
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

  ProviderCandidate? get _selectedProviderCandidate {
    final id = _selectedProviderId;
    if (id == null) {
      return null;
    }
    for (final item in _providerResults) {
      if (item.providerItemId == id) {
        return item;
      }
    }
    return null;
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
    if (query.isEmpty &&
        series.isEmpty &&
        issueNumber.isEmpty &&
        publisher.isEmpty &&
        barcode.isEmpty &&
        year == null) {
      return;
    }
    setState(() {
      _isSearchingServer = true;
      _searchedServer = true;
      _searchedProvider = false;
      _serverResults = const [];
      _providerResults = const [];
      _selectedServerId = null;
      _selectedProviderId = null;
      _checkedServerIds.clear();
      _collapsedAddSeries.clear();
      _error = null;
    });
    try {
      final rows = await ref.read(apiClientProvider).searchMetadata(
            libraryMetadataSearchQuery(
              comicsLibraryConfig,
              query: query,
              series: series,
              issueNumber: issueNumber,
              publisher: publisher,
              year: year,
              barcode: barcode,
              limit: 50,
            ),
          );
      final items = rows.map(CatalogItem.fromJson).toList(growable: false);
      await CatalogCacheRepository(ref.read(localDatabaseProvider))
          .upsertAll(items);
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

  Future<void> _searchPullListRow(_PullListCandidate row) async {
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

  Future<void> _searchComicVine() async {
    final query = _providerQuery;
    if (query.isEmpty) {
      return;
    }
    setState(() {
      _isSearchingProvider = true;
      _searchedProvider = true;
      _providerResults = const [];
      _selectedProviderId = null;
      _error = null;
    });
    try {
      final rows = await ref.read(apiClientProvider).searchProvider(
            provider: comicsLibraryConfig.defaultMetadataProvider,
            query: query,
          );
      final results =
          rows.map(ProviderCandidate.fromJson).toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _providerResults = results;
        _selectedProviderId =
            results.isEmpty ? null : results.first.providerItemId;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'ComicVine search failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSearchingProvider = false);
      }
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
        _searchedProvider = false;
        _providerResults = const [];
        _selectedProviderId = null;
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
      final found = <CatalogItem>[];
      for (final code in normalizedCodes) {
        try {
          final result = await ref.read(apiClientProvider).lookupBarcode(
                code,
                kind: comicsLibraryConfig.workspace.kind,
              );
          final item = CatalogItem.fromJson(result);
          found.add(item);
          if (!mounted) {
            return;
          }
          _updateBarcodeBatchEntry(
            code,
            BarcodeLookupEntry.found(code: code, item: item),
          );
        } catch (_) {
          if (!mounted) {
            return;
          }
          _updateBarcodeBatchEntry(
            code,
            BarcodeLookupEntry.missing(code),
          );
        }
      }
      if (found.isNotEmpty) {
        await CatalogCacheRepository(ref.read(localDatabaseProvider))
            .upsertAll(found);
      }
      if (!mounted) {
        return;
      }
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
      _selectedProviderId = null;
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
        _selectedProviderId = null;
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
          _selectedProviderId = null;
        }
      }
    });
  }

  Future<void> _addServerComics(
    List<CatalogItem> items, {
    required bool wishlist,
  }) async {
    setState(() => _isSubmitting = true);
    await CatalogCacheRepository(ref.read(localDatabaseProvider))
        .upsertAll(items);
    final mutations = ref.read(collectionMutationsProvider);
    for (final item in items) {
      if (wishlist) {
        await mutations.addToWishlist(item.id);
      } else {
        await mutations.addItem(
          item.id,
          condition: _defaultCondition,
          grade: _defaultGrade,
          purchaseDate: _defaultPurchaseDate,
          storageBox: _defaultStorageBoxController.text.trim().isEmpty
              ? null
              : _defaultStorageBoxController.text.trim(),
        );
      }
    }
    ref.invalidate(shelfProvider);
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    Navigator.of(context).pop();
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
      await ref.read(apiClientProvider).createMetadataProposal(
            provider: candidate.provider,
            providerItemId: candidate.providerItemId,
            query: _providerQuery,
            title: candidate.title,
            summary: candidate.summary,
            imageUrl: candidate.imageUrl,
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
      _selectedProviderId = null;
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
      await ref.read(apiClientProvider).createMetadataProposal(
            provider: comicsLibraryConfig.defaultMetadataProvider,
            query: proposal.title,
            title: proposal.title,
            summary: proposal.notes,
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
                              onLookupAll: onLookupBarcodeBatch,
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

class _AddComicResultPane extends StatelessWidget {
  const _AddComicResultPane({
    required this.mode,
    required this.serverResults,
    required this.providerResults,
    required this.pullListRows,
    required this.ownedItemIds,
    required this.wishlistItemIds,
    required this.selectedServerId,
    required this.selectedProviderId,
    required this.checkedServerIds,
    required this.includeVariants,
    required this.hideInShelf,
    required this.searchedServer,
    required this.searchedProvider,
    required this.isSearchingServer,
    required this.isSearchingProvider,
    required this.onIncludeVariantsChanged,
    required this.onHideInShelfChanged,
    required this.onSelectServer,
    required this.onToggleServerCheck,
    required this.collapsedSeries,
    required this.onToggleSeriesCollapsed,
    required this.onToggleSeriesCheck,
    required this.onCheckAllVisible,
    required this.onClearServerChecks,
    required this.onSelectProvider,
    required this.onSearchProvider,
    required this.onSearchPullListRow,
  });

  final LibraryAddMode mode;
  final List<CatalogItem> serverResults;
  final List<ProviderCandidate> providerResults;
  final List<_PullListCandidate> pullListRows;
  final Set<String> ownedItemIds;
  final Set<String> wishlistItemIds;
  final String? selectedServerId;
  final String? selectedProviderId;
  final Set<String> checkedServerIds;
  final bool includeVariants;
  final bool hideInShelf;
  final bool searchedServer;
  final bool searchedProvider;
  final bool isSearchingServer;
  final bool isSearchingProvider;
  final ValueChanged<bool> onIncludeVariantsChanged;
  final ValueChanged<bool> onHideInShelfChanged;
  final ValueChanged<String> onSelectServer;
  final ValueChanged<String> onToggleServerCheck;
  final Set<String> collapsedSeries;
  final ValueChanged<String> onToggleSeriesCollapsed;
  final ValueChanged<Iterable<CatalogItem>> onToggleSeriesCheck;
  final ValueChanged<Iterable<CatalogItem>> onCheckAllVisible;
  final VoidCallback onClearServerChecks;
  final ValueChanged<String> onSelectProvider;
  final VoidCallback onSearchProvider;
  final ValueChanged<_PullListCandidate> onSearchPullListRow;

  @override
  Widget build(BuildContext context) {
    if (mode == LibraryAddMode.pullList) {
      return _PullListResultsPane(
        rows: pullListRows,
        onSearchRow: onSearchPullListRow,
      );
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF1D2022),
        border: Border(right: BorderSide(color: _kClzDivider)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TinyCheckbox(
                    value: includeVariants,
                    label: 'Variants',
                    onChanged: onIncludeVariantsChanged,
                  ),
                  const SizedBox(width: 10),
                  _TinyCheckbox(
                    value: hideInShelf,
                    label: 'Hide in shelf',
                    onChanged: onHideInShelfChanged,
                  ),
                  const SizedBox(width: 10),
                  const Text('Issues:'),
                  const SizedBox(width: 4),
                  const _IssueSortButton(label: 'III', selected: true),
                  const _IssueSortButton(label: 'Asc'),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A))),
            ),
            child: const Text(
              'Collectarr Core results',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
          Expanded(
            child: _buildResults(),
          ),
          if (serverResults.isEmpty && searchedServer)
            Padding(
              padding: const EdgeInsets.all(8),
              child: OutlinedButton.icon(
                onPressed: isSearchingProvider ? null : onSearchProvider,
                icon: const Icon(Icons.manage_search),
                label: Text(
                  searchedProvider
                      ? 'Search ComicVine again'
                      : 'Search ComicVine',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (isSearchingServer || isSearchingProvider) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!searchedServer) {
      return const Center(
        child: Text(
          'Search Collectarr Core to add comics to your local collection.',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (serverResults.isNotEmpty) {
      final visibleResults = hideInShelf
          ? serverResults
              .where((item) =>
                  !ownedItemIds.contains(item.id) &&
                  !wishlistItemIds.contains(item.id))
              .toList(growable: false)
          : serverResults;
      if (visibleResults.isEmpty) {
        return const Center(
          child: Text(
            'All matching comics are already in your local shelf.',
            textAlign: TextAlign.center,
          ),
        );
      }
      final addable = visibleResults
          .where((item) =>
              !ownedItemIds.contains(item.id) &&
              !wishlistItemIds.contains(item.id))
          .toList(growable: false);
      final groupedResults = _groupAddResultsBySeries(visibleResults);
      return Column(
        children: [
          _AddResultsSummaryBar(
            visibleCount: visibleResults.length,
            addableCount: addable.length,
            selectedCount: checkedServerIds.length,
            seriesCount: groupedResults.length,
            onSelectAll:
                addable.isEmpty ? null : () => onCheckAllVisible(addable),
            onClear: checkedServerIds.isEmpty ? null : onClearServerChecks,
          ),
          Expanded(
            child: ListView(
              children: [
                for (final group in groupedResults.entries) ...[
                  Builder(
                    builder: (context) {
                      final groupAddable = group.value
                          .where((item) =>
                              !ownedItemIds.contains(item.id) &&
                              !wishlistItemIds.contains(item.id))
                          .toList(growable: false);
                      final selectedInGroup = group.value
                          .where((item) => checkedServerIds.contains(item.id))
                          .length;
                      final collapsed = collapsedSeries.contains(group.key);
                      return _AddSeriesHeader(
                        title: group.key,
                        subtitle: _addSeriesSubtitle(group.value),
                        count: group.value.length,
                        selectableCount: groupAddable.length,
                        selectedCount: selectedInGroup,
                        isCollapsed: collapsed,
                        canCheck: groupAddable.isNotEmpty,
                        onToggleCollapsed: () =>
                            onToggleSeriesCollapsed(group.key),
                        onToggleCheck: groupAddable.isEmpty
                            ? null
                            : () => onToggleSeriesCheck(groupAddable),
                      );
                    },
                  ),
                  if (!collapsedSeries.contains(group.key))
                    for (final item in group.value)
                      _AddResultRow(
                        selected: item.id == selectedServerId,
                        checked: checkedServerIds.contains(item.id),
                        checkDisabled: ownedItemIds.contains(item.id) ||
                            wishlistItemIds.contains(item.id),
                        cover: SizedBox(
                          width: 38,
                          height: 56,
                          child: AddComicCoverImage(item: item),
                        ),
                        title: item.itemNumber == null
                            ? item.title
                            : '#${item.itemNumber}',
                        subtitle: _addResultSubtitle(item),
                        badges: [
                          ..._addResultBadges(item),
                          if (ownedItemIds.contains(item.id)) 'Owned',
                          if (wishlistItemIds.contains(item.id)) 'Wishlist',
                        ],
                        trailing: _addResultTrailing(item),
                        onTap: () => onSelectServer(item.id),
                        onToggleCheck: ownedItemIds.contains(item.id) ||
                                wishlistItemIds.contains(item.id)
                            ? null
                            : () => onToggleServerCheck(item.id),
                      ),
                ],
              ],
            ),
          ),
        ],
      );
    }
    if (providerResults.isNotEmpty) {
      return ListView.builder(
        itemCount: providerResults.length,
        itemBuilder: (context, index) {
          final item = providerResults[index];
          return _AddResultRow(
            selected: item.providerItemId == selectedProviderId,
            checked: false,
            checkDisabled: true,
            cover: SizedBox(
              width: 42,
              height: 62,
              child: ProviderCandidateImage(candidate: item),
            ),
            title: item.title,
            subtitle: item.summary ?? 'ComicVine candidate',
            badges: const ['ComicVine'],
            trailing: 'propose',
            onTap: () => onSelectProvider(item.providerItemId),
            onToggleCheck: null,
          );
        },
      );
    }
    return const Center(
      child: Text(
        'No Collectarr Core matches yet. Try ComicVine to propose metadata.',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _PullListResultsPane extends StatelessWidget {
  const _PullListResultsPane({
    required this.rows,
    required this.onSearchRow,
  });

  final List<_PullListCandidate> rows;
  final ValueChanged<_PullListCandidate> onSearchRow;

  @override
  Widget build(BuildContext context) {
    final visibleRows = rows.isEmpty ? _pullListPlaceholderRows : rows;
    return ColoredBox(
      color: const Color(0xFF2E2E2E),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: const BoxDecoration(
              color: Color(0xFF252525),
              border: Border(bottom: BorderSide(color: Color(0xFF444444))),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFF18B7EB), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Local Pull List',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                LibraryAddResultBadge(
                  rows.isEmpty
                      ? 'needs local shelf'
                      : '${rows.length} suggestion${rows.length == 1 ? '' : 's'}',
                ),
              ],
            ),
          ),
          const _PullListPreviewHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: visibleRows.length,
              itemBuilder: (context, index) {
                final row = visibleRows[index];
                return _PullListPreviewRow(
                  row: row,
                  onSearch: rows.isEmpty ? null : () => onSearchRow(row),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              rows.isEmpty
                  ? 'Add a few owned or wishlist comics first. Pull List will use local series and wishlist gaps to search Collectarr Core for likely next issues.'
                  : 'Pull List is generated from the local shelf only. Use Search Core on a row to query server metadata for that next issue.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFCCCCCC)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PullListCandidate {
  const _PullListCandidate({
    required this.series,
    required this.issue,
    required this.release,
    required this.status,
    this.publisher,
  });

  final String series;
  final String issue;
  final String release;
  final String status;
  final String? publisher;
}

List<_PullListCandidate> _pullListCandidates(ShelfState? shelf) {
  final entries = shelf?.entries ?? const <ShelfEntry>[];
  final bySeries = <String, List<ShelfEntry>>{};
  for (final entry in entries) {
    final item = entry.catalogItem;
    if (item == null || (!entry.isOwned && !entry.isWishlisted)) {
      continue;
    }
    bySeries.putIfAbsent(item.title, () => []).add(entry);
  }
  final rows = <_PullListCandidate>[];
  for (final group in bySeries.entries) {
    final numbered = [
      for (final entry in group.value)
        if (_issueNumberSortValue(entry.catalogItem?.itemNumber) != null)
          (
            entry: entry,
            number: _issueNumberSortValue(entry.catalogItem?.itemNumber)!,
          ),
    ]..sort((a, b) => a.number.compareTo(b.number));
    if (numbered.isEmpty) {
      continue;
    }
    final last = numbered.last;
    final nextIssue = _formatIssueNumber(last.number + 1);
    final publisher = last.entry.catalogItem?.publisher;
    rows.add(
      _PullListCandidate(
        series: group.key,
        issue: nextIssue,
        release: publisher ?? 'Collectarr Core',
        status: group.value.any((entry) => entry.isWishlisted)
            ? 'wishlist gap'
            : 'next issue',
        publisher: publisher,
      ),
    );
  }
  rows.sort((a, b) => a.series.toLowerCase().compareTo(b.series.toLowerCase()));
  return rows.take(25).toList(growable: false);
}

String _formatIssueNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

const _pullListPlaceholderRows = [
  _PullListCandidate(
    series: 'Watched series',
    issue: 'next',
    release: 'local shelf',
    status: 'waiting',
  ),
  _PullListCandidate(
    series: 'Wishlist gaps',
    issue: 'missing',
    release: 'Collectarr Core',
    status: 'planned',
  ),
  _PullListCandidate(
    series: 'New releases',
    issue: 'weekly',
    release: 'ComicVine',
    status: 'planned',
  ),
];

class _PullListPreviewHeader extends StatelessWidget {
  const _PullListPreviewHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: const Color(0xFF383838),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: const Row(
        children: [
          Expanded(flex: 4, child: Text('Series')),
          Expanded(flex: 2, child: Text('Issue')),
          Expanded(flex: 3, child: Text('Release')),
          Expanded(flex: 3, child: Text('Status')),
          SizedBox(width: 96, child: Text('Action')),
        ],
      ),
    );
  }
}

class _PullListPreviewRow extends StatelessWidget {
  const _PullListPreviewRow({
    required this.row,
    required this.onSearch,
  });

  final _PullListCandidate row;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF3B3B3B))),
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(row.series)),
          Expanded(flex: 2, child: Text('#${row.issue}')),
          Expanded(flex: 3, child: Text(row.release)),
          Expanded(
            flex: 3,
            child: Text(
              row.status,
              style: const TextStyle(color: Color(0xFFBFEFFF)),
            ),
          ),
          SizedBox(
            width: 96,
            child: OutlinedButton(
              onPressed: onSearch,
              child: const Text('Search Core'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddResultsSummaryBar extends StatelessWidget {
  const _AddResultsSummaryBar({
    required this.visibleCount,
    required this.addableCount,
    required this.selectedCount,
    required this.seriesCount,
    required this.onSelectAll,
    required this.onClear,
  });

  final int visibleCount;
  final int addableCount;
  final int selectedCount;
  final int seriesCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: const BoxDecoration(
        color: Color(0xFF252525),
        border: Border(bottom: BorderSide(color: Color(0xFF444444))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  LibraryAddResultBadge(
                    '$visibleCount result${visibleCount == 1 ? '' : 's'}',
                  ),
                  const SizedBox(width: 6),
                  LibraryAddResultBadge(
                    '$seriesCount series',
                  ),
                  const SizedBox(width: 6),
                  LibraryAddResultBadge(
                    '$selectedCount selected',
                  ),
                  if (addableCount != visibleCount) ...[
                    const SizedBox(width: 6),
                    LibraryAddResultBadge(
                      '$addableCount addable',
                    ),
                  ],
                ],
              ),
            ),
          ),
          Wrap(
            spacing: 4,
            children: [
              TextButton(
                onPressed: onSelectAll,
                child: const Text('Select all'),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Map<String, List<CatalogItem>> _groupAddResultsBySeries(
  List<CatalogItem> items,
) {
  final grouped = <String, List<CatalogItem>>{};
  final sortedItems = items.toList(growable: false)
    ..sort((a, b) {
      final series = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (series != 0) {
        return series;
      }
      return _compareIssueNumbers(a.itemNumber, b.itemNumber);
    });
  for (final item in sortedItems) {
    grouped.putIfAbsent(item.title, () => []).add(item);
  }
  return grouped;
}

String _addSeriesSubtitle(List<CatalogItem> items) {
  final issues = items
      .map((item) => item.itemNumber)
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
  final publishers = items
      .map((item) => item.publisher)
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false);
  final publisher = publishers.isEmpty ? null : publishers.first;
  final years = items
      .map((item) => item.releaseYear)
      .whereType<int>()
      .toList(growable: false);
  final range = issues.isEmpty
      ? null
      : issues.length == 1
          ? '#${issues.first}'
          : '#${issues.first} - #${issues.last}';
  final yearRange = years.isEmpty
      ? null
      : years.length == 1 || years.toSet().length == 1
          ? years.first.toString()
          : '${years.reduce((a, b) => a < b ? a : b)}-${years.reduce((a, b) => a > b ? a : b)}';
  return [
    if (range != null) range,
    if (publisher != null) publisher,
    if (yearRange != null) yearRange,
  ].join(' | ');
}

String _addResultSubtitle(CatalogItem item) {
  final parts = [
    if (item.variant != null && item.variant!.isNotEmpty) item.variant,
    if (item.releaseDate != null) _formatDate(item.releaseDate!),
    if (item.publisher != null && item.publisher!.isNotEmpty) item.publisher,
    if (item.barcode != null && item.barcode!.isNotEmpty) item.barcode,
  ].whereType<String>().toList(growable: false);
  if (parts.isNotEmpty) {
    return parts.join('  |  ');
  }
  return item.synopsis ?? 'Metadata in Collectarr Core';
}

List<String> _addResultBadges(CatalogItem item) {
  return [
    if (item.publisher != null && item.publisher!.isNotEmpty) item.publisher!,
    if (item.releaseYear != null) item.releaseYear!.toString(),
  ];
}

String _addResultTrailing(CatalogItem item) {
  if (item.releaseDate != null) {
    return _formatDate(item.releaseDate!);
  }
  if (item.releaseYear != null) {
    return item.releaseYear!.toString();
  }
  return item.itemNumber == null ? '' : '#${item.itemNumber}';
}

class _AddSeriesHeader extends StatelessWidget {
  const _AddSeriesHeader({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.selectableCount,
    required this.selectedCount,
    required this.isCollapsed,
    required this.canCheck,
    required this.onToggleCollapsed,
    required this.onToggleCheck,
  });

  final String title;
  final String subtitle;
  final int count;
  final int selectableCount;
  final int selectedCount;
  final bool isCollapsed;
  final bool canCheck;
  final VoidCallback onToggleCollapsed;
  final VoidCallback? onToggleCheck;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggleCollapsed,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF232323),
          border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A))),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 5, 6, 5),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tooltip: isCollapsed ? 'Expand series' : 'Collapse series',
                  onPressed: onToggleCollapsed,
                  icon: Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_right
                        : Icons.keyboard_arrow_down,
                    size: 18,
                  ),
                ),
              ),
              Checkbox(
                value: selectedCount == 0
                    ? false
                    : selectedCount >= selectableCount
                        ? true
                        : null,
                tristate: true,
                onChanged: canCheck ? (_) => onToggleCheck?.call() : null,
                visualDensity: VisualDensity.compact,
              ),
              const Icon(Icons.folder, size: 15, color: Color(0xFF18B7EB)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFB8B8B8),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (selectedCount > 0) ...[
                LibraryAddResultBadge('$selectedCount selected'),
                const SizedBox(width: 6),
              ],
              LibraryAddResultBadge('$count issue${count == 1 ? '' : 's'}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyCheckbox extends StatelessWidget {
  const _TinyCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            value ? Icons.check_box : Icons.check_box_outline_blank,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _IssueSortButton extends StatelessWidget {
  const _IssueSortButton({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      color: selected ? const Color(0xFF159AC8) : const Color(0xFF555555),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

class _AddResultRow extends StatelessWidget {
  const _AddResultRow({
    required this.selected,
    required this.checked,
    required this.checkDisabled,
    required this.cover,
    required this.title,
    required this.subtitle,
    required this.badges,
    required this.trailing,
    required this.onTap,
    required this.onToggleCheck,
  });

  final bool selected;
  final bool checked;
  final bool checkDisabled;
  final Widget cover;
  final String title;
  final String subtitle;
  final List<String> badges;
  final String trailing;
  final VoidCallback onTap;
  final VoidCallback? onToggleCheck;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: selected ? _kClzSelection : const Color(0xFF242729),
        border: Border(
          left: BorderSide(
            color: selected ? _kClzYellow : Colors.transparent,
            width: 3,
          ),
          bottom: const BorderSide(color: Color(0xFF36393B)),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Row(
            children: [
              Checkbox(
                value: checked,
                onChanged: checkDisabled ? null : (_) => onToggleCheck?.call(),
                visualDensity: VisualDensity.compact,
              ),
              cover,
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFDDDDDD)),
                    ),
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final badge in badges)
                            LibraryAddResultBadge(badge),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing.isNotEmpty)
                Text(trailing,
                    style: const TextStyle(color: Color(0xFFBFEFFF))),
            ],
          ),
        ),
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
