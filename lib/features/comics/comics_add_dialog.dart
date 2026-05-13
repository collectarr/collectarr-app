import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/comic_detail.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_controller.dart';
import 'package:collectarr_app/features/comics/comics_inspector.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_mode.dart';
import 'package:collectarr_app/features/library/add/library_add_mode_tab.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color _kClzToolbar = Color(0xFF2B2B2B);
const Color _kClzPanel = Color(0xFF1D1D1D);
const Color _kClzPanelRaised = Color(0xFF2F2F2F);
const Color _kClzCanvas = Color(0xFF141414);
const Color _kClzAccent = Color(0xFF10A8D8);
const Color _kClzSelection = Color(0xFF075F75);
const Color _kClzYellow = Color(0xFFFFD400);
const Color _kClzDivider = Color(0xFF4A4A4A);
final ThemeData _kClzComicsTheme = _buildClzComicsTheme();
final ThemeData _kClzAddComicDialogTheme = _kClzComicsTheme.copyWith(
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF111111),
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: _kClzDivider),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _kClzDivider),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _kClzAccent),
    ),
  ),
);

ThemeData _buildClzComicsTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: _kClzAccent,
    brightness: Brightness.dark,
    surface: _kClzPanel,
  );
  return base.copyWith(
    colorScheme: scheme.copyWith(
      primary: _kClzAccent,
      secondary: _kClzYellow,
      surface: _kClzPanel,
      surfaceContainerLowest: _kClzCanvas,
      surfaceContainerLow: _kClzPanel,
      surfaceContainer: _kClzToolbar,
      surfaceContainerHigh: _kClzPanelRaised,
      surfaceContainerHighest: const Color(0xFF3A3A3A),
      outline: _kClzDivider,
      outlineVariant: const Color(0xFF373737),
    ),
    scaffoldBackgroundColor: _kClzCanvas,
    dividerTheme: const DividerThemeData(
      color: _kClzDivider,
      thickness: 1,
      space: 1,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF343434),
        disabledForegroundColor: const Color(0xFF777777),
        disabledBackgroundColor: const Color(0xFF252525),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _kClzAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        visualDensity: VisualDensity.compact,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: _kClzDivider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        visualDensity: VisualDensity.compact,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF101010),
      isDense: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: _kClzDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _kClzDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _kClzAccent),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: const Color(0xFF343434),
      selectedColor: _kClzSelection,
      labelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: _kClzDivider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _kClzPanel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    return LibraryCoverImage(
      title: item.title,
      itemNumber: item.itemNumber,
      imageUrl: item.displayCoverUrl,
    );
  }
}

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

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class AddComicDialog extends ConsumerStatefulWidget {
  const AddComicDialog({super.key});

  @override
  ConsumerState<AddComicDialog> createState() => AddComicDialogState();
}

enum _BarcodeLookupStatus {
  pending,
  lookingUp,
  found,
  missing;

  String get label => switch (this) {
        _BarcodeLookupStatus.pending => 'Pending',
        _BarcodeLookupStatus.lookingUp => 'Looking up',
        _BarcodeLookupStatus.found => 'Found',
        _BarcodeLookupStatus.missing => 'Not found',
      };

  IconData get icon => switch (this) {
        _BarcodeLookupStatus.pending => Icons.schedule,
        _BarcodeLookupStatus.lookingUp => Icons.sync,
        _BarcodeLookupStatus.found => Icons.check_circle,
        _BarcodeLookupStatus.missing => Icons.error_outline,
      };

  Color get color => switch (this) {
        _BarcodeLookupStatus.pending => const Color(0xFFB8B8B8),
        _BarcodeLookupStatus.lookingUp => const Color(0xFF18B7EB),
        _BarcodeLookupStatus.found => const Color(0xFF59D17D),
        _BarcodeLookupStatus.missing => const Color(0xFFFFC857),
      };
}

class _BarcodeLookupEntry {
  const _BarcodeLookupEntry({
    required this.code,
    required this.status,
    this.item,
    this.error,
  });

  factory _BarcodeLookupEntry.pending(String code) {
    return _BarcodeLookupEntry(
      code: code,
      status: _BarcodeLookupStatus.pending,
    );
  }

  factory _BarcodeLookupEntry.lookingUp(String code) {
    return _BarcodeLookupEntry(
      code: code,
      status: _BarcodeLookupStatus.lookingUp,
    );
  }

  factory _BarcodeLookupEntry.found({
    required String code,
    required CatalogItem item,
  }) {
    return _BarcodeLookupEntry(
      code: code,
      status: _BarcodeLookupStatus.found,
      item: item,
    );
  }

  factory _BarcodeLookupEntry.missing(String code) {
    return _BarcodeLookupEntry(
      code: code,
      status: _BarcodeLookupStatus.missing,
      error: 'No match',
    );
  }

  final String code;
  final _BarcodeLookupStatus status;
  final CatalogItem? item;
  final String? error;

  _BarcodeLookupEntry copyWith({
    _BarcodeLookupStatus? status,
    CatalogItem? item,
    String? error,
  }) {
    return _BarcodeLookupEntry(
      code: code,
      status: status ?? this.status,
      item: item ?? this.item,
      error: error,
    );
  }
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
  final _barcodeBatch = <_BarcodeLookupEntry>[];
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
                              child: _AddComicPreviewPane(
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
                              child: _AddComicPreviewPane(
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
                _AddComicBottomBar(
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
      _barcodeBatch.add(_BarcodeLookupEntry.pending(code));
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
            _barcodeBatch.add(_BarcodeLookupEntry.lookingUp(code));
          } else {
            _barcodeBatch[index] = _barcodeBatch[index].copyWith(
              status: _BarcodeLookupStatus.lookingUp,
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
            _BarcodeLookupEntry.found(code: code, item: item),
          );
        } catch (_) {
          if (!mounted) {
            return;
          }
          _updateBarcodeBatchEntry(
            code,
            _BarcodeLookupEntry.missing(code),
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

  void _updateBarcodeBatchEntry(String code, _BarcodeLookupEntry entry) {
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
      builder: (context) => const _ManualComicDialog(),
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
    final proposal = await showDialog<_ManualProposalDraft>(
      context: context,
      builder: (context) => const _ManualProposalDialog(),
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
  final List<_BarcodeLookupEntry> barcodeBatch;
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
                          const _BarcodeLookupStrip(),
                          if (barcodeHistory.isNotEmpty &&
                              barcodeBatch.isEmpty) ...[
                            const SizedBox(height: 8),
                            _BarcodeHistoryStrip(
                              codes: barcodeHistory,
                              onUse: onUseBarcodeHistory,
                            ),
                          ],
                          if (barcodeBatch.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _BarcodeBatchPanel(
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

class _BarcodeLookupStrip extends StatelessWidget {
  const _BarcodeLookupStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: const Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _AddInfoChip(icon: Icons.radio_button_checked, label: 'Connected'),
          _AddInfoChip(icon: Icons.center_focus_strong, label: 'Camera scan'),
          _AddInfoChip(icon: Icons.keyboard, label: 'Manual UPC/EAN'),
          _AddInfoChip(icon: Icons.cleaning_services, label: 'Auto-normalize'),
        ],
      ),
    );
  }
}

class _BarcodeHistoryStrip extends StatelessWidget {
  const _BarcodeHistoryStrip({
    required this.codes,
    required this.onUse,
  });

  final List<String> codes;
  final ValueChanged<String> onUse;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Recent',
            style: TextStyle(
              color: Color(0xFFB8B8B8),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final code in codes)
                ActionChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(code),
                  avatar: const Icon(Icons.history, size: 16),
                  onPressed: () => onUse(code),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarcodeBatchPanel extends StatelessWidget {
  const _BarcodeBatchPanel({
    required this.entries,
    required this.isLookingUp,
    required this.onLookupAll,
    required this.onRemove,
    required this.onClear,
  });

  final List<_BarcodeLookupEntry> entries;
  final bool isLookingUp;
  final VoidCallback onLookupAll;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final found = entries.where((entry) => entry.item != null).length;
    final missing = entries
        .where((entry) => entry.status == _BarcodeLookupStatus.missing)
        .length;
    return Container(
      constraints: const BoxConstraints(maxHeight: 168),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
            decoration: const BoxDecoration(
              color: Color(0xFF282828),
              border: Border(bottom: BorderSide(color: Color(0xFF444444))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      LibraryAddResultBadge('${entries.length} scanned'),
                      LibraryAddResultBadge('$found found'),
                      if (missing > 0)
                        LibraryAddResultBadge('$missing missing'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: isLookingUp ? null : onLookupAll,
                  child: const Text('Lookup all'),
                ),
                TextButton(
                  onPressed: isLookingUp ? null : onClear,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _BarcodeBatchRow(
                  entry: entry,
                  onRemove: () => onRemove(entry.code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodeBatchRow extends StatelessWidget {
  const _BarcodeBatchRow({required this.entry, required this.onRemove});

  final _BarcodeLookupEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final item = entry.item;
    final label = item == null
        ? entry.status.label
        : item.itemNumber == null
            ? item.title
            : '${item.title} #${item.itemNumber}';
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 4, 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF333333))),
      ),
      child: Row(
        children: [
          Icon(entry.status.icon, size: 16, color: entry.status.color),
          const SizedBox(width: 7),
          SizedBox(
            width: 128,
            child: Text(
              entry.code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFeatures: []),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: item == null ? const Color(0xFFCCCCCC) : Colors.white,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remove barcode',
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 16),
          ),
        ],
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
                          child: _CoverImage(item: item),
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
              child: _ProviderCandidateImage(candidate: item),
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

class _AddComicPreviewPane extends ConsumerWidget {
  const _AddComicPreviewPane({
    required this.item,
    required this.candidate,
    required this.selectedIsOwned,
    required this.selectedIsWishlisted,
    required this.searchedServer,
  });

  final CatalogItem? item;
  final ProviderCandidate? candidate;
  final bool selectedIsOwned;
  final bool selectedIsWishlisted;
  final bool searchedServer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItem = item;
    final selectedCandidate = candidate;
    if (selectedItem == null && selectedCandidate == null) {
      return ColoredBox(
        color: const Color(0xFF060606),
        child: Center(
          child: Text(
            searchedServer
                ? 'Select a result or search ComicVine.'
                : 'Search Collectarr Core to preview metadata.',
          ),
        ),
      );
    }
    final detail = selectedItem == null
        ? null
        : ref.watch(comicDetailProvider(selectedItem.id)).value;
    final title = selectedItem?.title ?? selectedCandidate!.title;
    final issue = selectedItem?.itemNumber;
    final synopsis = selectedItem?.synopsis ?? selectedCandidate?.summary;
    final localStatus = selectedIsOwned
        ? 'In local collection'
        : selectedIsWishlisted
            ? 'In local wishlist'
            : 'Not in local shelf';
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF020202),
            Color(0xFF082531),
            Color(0xFF050505),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF05AEEF),
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selectedItem == null
                            ? 'ComicVine candidate'
                            : 'Collectarr Core metadata',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 9),
                      _AddPreviewChips(
                        labels: [
                          localStatus,
                          if (selectedItem?.publisher != null)
                            selectedItem!.publisher!,
                          if (selectedItem?.releaseYear != null)
                            selectedItem!.releaseYear!.toString(),
                          if (selectedItem?.barcode != null)
                            'UPC ${selectedItem!.barcode}',
                          if (selectedCandidate != null)
                            selectedCandidate.provider,
                        ],
                      ),
                    ],
                  ),
                ),
                if (issue != null)
                  Text(
                    '# $issue',
                    style: const TextStyle(
                      color: Color(0xFF05AEEF),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const Divider(height: 22, color: Color(0x664DBBD5)),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          'Plot',
                          style: TextStyle(color: Color(0xFF05AEEF)),
                        ),
                        const SizedBox(height: 6),
                        Text(synopsis ?? 'No plot metadata available yet.'),
                        const SizedBox(height: 22),
                        const Text(
                          'Details',
                          style: TextStyle(color: Color(0xFF05AEEF)),
                        ),
                        const SizedBox(height: 6),
                        _AddPreviewMetadata(
                          item: selectedItem,
                          candidate: selectedCandidate,
                          detail: detail,
                          localStatus: localStatus,
                        ),
                        if (detail?.creators.isNotEmpty ?? false) ...[
                          const SizedBox(height: 22),
                          const Text(
                            'Creators',
                            style: TextStyle(color: Color(0xFF05AEEF)),
                          ),
                          const SizedBox(height: 6),
                          _AddPreviewChips(
                            labels: [
                              for (final credit in detail!.creators)
                                credit.role == null
                                    ? credit.name
                                    : '${credit.name} - ${credit.role}',
                            ],
                          ),
                        ],
                        if (detail?.characters.isNotEmpty ?? false) ...[
                          const SizedBox(height: 22),
                          const Text(
                            'Characters',
                            style: TextStyle(color: Color(0xFF05AEEF)),
                          ),
                          const SizedBox(height: 6),
                          _AddPreviewChips(
                            labels: [
                              for (final credit in detail!.characters)
                                credit.name,
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0x99FFFFFF)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xCC000000),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: selectedItem == null
                            ? _ProviderCandidateImage(
                                candidate: selectedCandidate!,
                              )
                            : _CoverImage(item: selectedItem),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPreviewMetadata extends StatelessWidget {
  const _AddPreviewMetadata({
    required this.item,
    required this.candidate,
    required this.detail,
    required this.localStatus,
  });

  final CatalogItem? item;
  final ProviderCandidate? candidate;
  final ComicDetail? detail;
  final String localStatus;

  @override
  Widget build(BuildContext context) {
    final selectedItem = item;
    final rows = selectedItem == null
        ? [
            ('Provider', candidate?.provider),
            ('Provider ID', candidate?.providerItemId),
          ]
        : [
            ('Status', localStatus),
            ('Catalog ID', selectedItem.id),
            ('Series', detail?.seriesTitle ?? selectedItem.title),
            ('Issue', selectedItem.itemNumber),
            ('Publisher', detail?.publisher ?? selectedItem.publisher),
            ('Cover Date', _formatOptionalDate(detail?.coverDate)),
            ('Release', _formatOptionalDate(selectedItem.releaseDate)),
            ('Pages', detail?.pageCount?.toString()),
            ('Barcode', detail?.barcode ?? selectedItem.barcode),
            ('Price', _moneyLabel(detail?.coverPriceCents, detail?.currency)),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          if (row.$2 != null && row.$2!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 88,
                    child: Text(
                      row.$1,
                      style: const TextStyle(
                        color: Color(0xFFB8B8B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(child: Text(row.$2!)),
                ],
              ),
            ),
      ],
    );
  }

  String? _formatOptionalDate(DateTime? value) {
    return value == null ? null : _formatDate(value);
  }

  String? _moneyLabel(int? cents, String? currency) {
    if (cents == null) {
      return null;
    }
    final absolute = cents.abs();
    final sign = cents < 0 ? '-' : '';
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '${currency ?? ''} $sign$whole.$fraction'.trim();
  }
}

class _AddPreviewChips extends StatelessWidget {
  const _AddPreviewChips({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final label in labels.take(12))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF242424),
              border: Border.all(color: const Color(0xFF555555)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}

class _AddComicBottomBar extends StatelessWidget {
  const _AddComicBottomBar({
    required this.selectedItem,
    required this.selectedCandidate,
    required this.selectedIsOwned,
    required this.selectedIsWishlisted,
    required this.addTarget,
    required this.addCount,
    required this.isSubmitting,
    required this.defaultCondition,
    required this.defaultGrade,
    required this.defaultStorageBoxController,
    required this.defaultPurchaseDate,
    required this.onAddTargetChanged,
    required this.onDefaultConditionChanged,
    required this.onDefaultGradeChanged,
    required this.onDefaultPurchaseDateChanged,
    required this.onAdd,
    required this.onPropose,
  });

  final CatalogItem? selectedItem;
  final ProviderCandidate? selectedCandidate;
  final bool selectedIsOwned;
  final bool selectedIsWishlisted;
  final LibraryAddTarget addTarget;
  final int addCount;
  final bool isSubmitting;
  final String? defaultCondition;
  final String? defaultGrade;
  final TextEditingController defaultStorageBoxController;
  final DateTime? defaultPurchaseDate;
  final ValueChanged<LibraryAddTarget> onAddTargetChanged;
  final ValueChanged<String?> onDefaultConditionChanged;
  final ValueChanged<String?> onDefaultGradeChanged;
  final ValueChanged<DateTime?> onDefaultPurchaseDateChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onPropose;

  @override
  Widget build(BuildContext context) {
    final isProposal = selectedItem == null && selectedCandidate != null;
    final disabledByLocalStatus = addTarget == LibraryAddTarget.owned
        ? selectedIsOwned
        : selectedIsWishlisted;
    final label = isProposal
        ? 'Propose ComicVine Metadata'
        : disabledByLocalStatus
            ? addTarget == LibraryAddTarget.owned
                ? 'Already in Collection'
                : 'Already in Wishlist'
            : LibraryAddCopy.addToTargetLabel(
                count: addCount,
                type: comicsLibraryConfig,
                target: addTarget,
              );
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _kClzToolbar,
        border: Border(top: BorderSide(color: _kClzDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isProposal && addTarget == LibraryAddTarget.owned) ...[
              _AddOwnedDefaultsBar(
                condition: defaultCondition,
                grade: defaultGrade,
                storageBoxController: defaultStorageBoxController,
                purchaseDate: defaultPurchaseDate,
                onConditionChanged: onDefaultConditionChanged,
                onGradeChanged: onDefaultGradeChanged,
                onPurchaseDateChanged: onDefaultPurchaseDateChanged,
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                if (!isProposal) ...[
                  LibraryAddResultBadge(
                    '$addCount selected',
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 190,
                    height: 40,
                    child: DropdownButtonFormField<LibraryAddTarget>(
                      initialValue: addTarget,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: LibraryAddTarget.owned,
                          child: Text(LibraryAddTarget.owned.actionLabel),
                        ),
                        DropdownMenuItem(
                          value: LibraryAddTarget.wishlist,
                          child: Text(LibraryAddTarget.wishlist.actionLabel),
                        ),
                      ],
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                onAddTargetChanged(value);
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : isProposal
                            ? onPropose
                            : disabledByLocalStatus
                                ? null
                                : onAdd,
                    style: FilledButton.styleFrom(
                      backgroundColor: _kClzAccent,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    child: Text(label),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOwnedDefaultsBar extends StatelessWidget {
  const _AddOwnedDefaultsBar({
    required this.condition,
    required this.grade,
    required this.storageBoxController,
    required this.purchaseDate,
    required this.onConditionChanged,
    required this.onGradeChanged,
    required this.onPurchaseDateChanged,
  });

  final String? condition;
  final String? grade;
  final TextEditingController storageBoxController;
  final DateTime? purchaseDate;
  final ValueChanged<String?> onConditionChanged;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<DateTime?> onPurchaseDateChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Owned defaults',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        _SmallDropdown(
          width: 140,
          value: condition,
          items: ComicInspector.conditions,
          label: 'Condition',
          onChanged: onConditionChanged,
        ),
        _SmallDropdown(
          width: 120,
          value: grade,
          items: ComicInspector.grades,
          label: 'Grade',
          onChanged: onGradeChanged,
        ),
        SizedBox(
          width: 150,
          height: 38,
          child: TextField(
            controller: storageBoxController,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              labelText: 'Storage box',
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: purchaseDate ?? DateTime.now(),
              firstDate: DateTime(1970),
              lastDate: DateTime(2100),
            );
            onPurchaseDateChanged(picked);
          },
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text(
            purchaseDate == null ? 'Purchase date' : _formatDate(purchaseDate!),
          ),
        ),
        if (purchaseDate != null)
          IconButton(
            tooltip: 'Clear purchase date',
            onPressed: () => onPurchaseDateChanged(null),
            icon: const Icon(Icons.clear, size: 18),
          ),
      ],
    );
  }
}

class _SmallDropdown extends StatelessWidget {
  const _SmallDropdown({
    required this.width,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  final double width;
  final String? value;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 38,
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        items: [
          const DropdownMenuItem<String>(value: null, child: Text('None')),
          for (final item in items)
            DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ManualComicDialog extends StatefulWidget {
  const _ManualComicDialog();

  @override
  State<_ManualComicDialog> createState() => _ManualComicDialogState();
}

class _ManualComicDialogState extends State<_ManualComicDialog> {
  final _titleController = TextEditingController();
  final _issueController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _variantController = TextEditingController();
  final _synopsisController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _issueController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _barcodeController.dispose();
    _variantController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add manual comic'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DialogTextField(
                width: 320,
                controller: _titleController,
                label: 'Series / title',
              ),
              _DialogTextField(
                width: 110,
                controller: _issueController,
                label: 'Issue #',
              ),
              _DialogTextField(
                width: 220,
                controller: _publisherController,
                label: 'Publisher',
              ),
              _DialogTextField(
                width: 100,
                controller: _yearController,
                label: 'Year',
                keyboardType: TextInputType.number,
              ),
              _DialogTextField(
                width: 220,
                controller: _barcodeController,
                label: 'Barcode / UPC',
                keyboardType: TextInputType.number,
              ),
              _DialogTextField(
                width: 220,
                controller: _variantController,
                label: 'Variant',
              ),
              _DialogTextField(
                width: 500,
                controller: _synopsisController,
                label: 'Plot / notes',
                maxLines: 4,
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
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              CatalogItem(
                id: 'manual-comic-${DateTime.now().microsecondsSinceEpoch}',
                kind: comicsLibraryConfig.workspace.kind,
                title: title,
                itemNumber: _emptyToNull(_issueController.text),
                synopsis: _emptyToNull(_synopsisController.text),
                publisher: _emptyToNull(_publisherController.text),
                releaseYear: int.tryParse(_yearController.text.trim()),
                barcode: _emptyToNull(_barcodeController.text),
                variant: _emptyToNull(_variantController.text),
              ),
            );
          },
          child: const Text('Add to results'),
        ),
      ],
    );
  }
}

class _ManualProposalDialog extends StatefulWidget {
  const _ManualProposalDialog();

  @override
  State<_ManualProposalDialog> createState() => _ManualProposalDialogState();
}

class _ManualProposalDialogState extends State<_ManualProposalDialog> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Propose manual metadata'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comic title / issue',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Source notes',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              _ManualProposalDraft(
                title: title,
                notes: _emptyToNull(_notesController.text),
              ),
            );
          },
          child: const Text('Send proposal'),
        ),
      ],
    );
  }
}

class _ManualProposalDraft {
  const _ManualProposalDraft({required this.title, required this.notes});

  final String title;
  final String? notes;
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.width,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}

class _ProviderCandidateImage extends StatelessWidget {
  const _ProviderCandidateImage({required this.candidate});

  final ProviderCandidate candidate;

  @override
  Widget build(BuildContext context) {
    return LibraryCoverImage(
      title: candidate.title,
      imageUrl: candidate.imageUrl,
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
