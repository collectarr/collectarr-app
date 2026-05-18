import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_mode_tab.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/physical_media_formats.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class LibraryAddDialog extends ConsumerStatefulWidget {
  const LibraryAddDialog({
    super.key,
    required this.type,
    this.initialQuery,
    this.initialBarcode,
    this.autoLookupInitialBarcode = true,
  });

  final LibraryTypeConfig type;
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
  final _uuid = const Uuid();

  List<CatalogItem> _results = const [];
  List<ProviderCandidate> _providerResults = const [];
  final _queuedProviderIngests = <String, _QueuedProviderIngest>{};
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
  String? _physicalFormatId;
  DateTime? _lastProviderSearchAt;
  String? _lastProviderSearchSignature;
  int _coreSearchGeneration = 0;
  static const _providerSearchDebounce = Duration(milliseconds: 450);
  static const _coreSearchTimeout = Duration(seconds: 35);

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
    final accent = libraryAccentForKind(widget.type.workspace.kind);
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
          constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 780),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: kClzPanel,
              border: Border.all(color: kClzDivider),
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
                        onSelectResult: (id) => setState(() {
                          _selectedResultId = id;
                          _selectedProviderCandidateId = null;
                        }),
                        onSelectProviderCandidate: (id) => setState(() {
                          _selectedProviderCandidateId = id;
                          _selectedResultId = null;
                        }),
                        onSearchCore: _search,
                      );
                      final previewPane = _LibraryAddPreviewPane(
                        type: widget.type,
                        accent: accent,
                        item: selectedResult,
                        candidate: selectedCandidate,
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
                        return Column(
                          children: [
                            SizedBox(height: 300, child: searchPane),
                            Expanded(child: previewPane),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(width: 390, child: searchPane),
                          const _LibraryAddPaneResizeDivider(),
                          Expanded(child: previewPane),
                        ],
                      );
                    },
                  ),
                ),
                if (_mode != _LibraryAddDialogMode.manual)
                  _LibraryAddBottomBar(
                    type: widget.type,
                    accent: accent,
                    selectedItem: selectedResult,
                    selectedCandidate: selectedCandidate,
                    selectedQueuedIngest: selectedQueuedIngest,
                    providerLabel: selectedProviderLabel,
                    addTarget: _addTarget,
                    isAdding: _isAdding,
                    isQueueingIngest: _isQueueingIngest,
                    onAddTargetChanged: (value) =>
                        setState(() => _addTarget = value),
                    onAdd: selectedResult == null && selectedCandidate == null
                        ? null
                        : () {
                            final item = selectedResult;
                            final candidate = selectedCandidate;
                            if (item != null) {
                              _addItems([item], _addTarget);
                              return;
                            }
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
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
    try {
      final api = ref.read(apiClientProvider);
      final items = await searchAndCacheLibraryMetadata(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        input: LibraryMetadataSearchInput(query: query, limit: 20),
      ).timeout(_coreSearchTimeout);
      final shouldSearchProvider =
          items.isEmpty && widget.type.supportedMetadataProviders.isNotEmpty;
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
              found.isEmpty && widget.type.supportedMetadataProviders.isEmpty
                  ? 'No item found for barcode $barcode.'
                  : null;
        });
      }
      if (mounted &&
          searchGeneration == _coreSearchGeneration &&
          found.isEmpty &&
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
        query: query,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _results = const [];
        _selectedResultId = null;
        _providerResults = results;
        _selectedProviderCandidateId =
            results.isEmpty ? null : results.first.localCatalogId;
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
  ) {
    return _addItems([candidate.placeholderCatalogItem()], target);
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
  return FilledButton.styleFrom(
    backgroundColor: accent,
    foregroundColor: _foregroundForAccent(accent),
    minimumSize: const Size(0, _kLibraryAddControlHeight),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
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
  return ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
      ? Colors.white
      : const Color(0xFF101010);
}

ThemeData _libraryAddDialogTheme(Color accent) {
  final base = kClzAddComicDialogTheme;
  final scheme = base.colorScheme.copyWith(
    primary: accent,
    secondary: accent,
  );
  return base.copyWith(
    colorScheme: scheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: _foregroundForAccent(accent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        visualDensity: VisualDensity.compact,
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accent),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
  );
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.type, required this.accent});

  final LibraryTypeConfig type;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A4A4A), Color(0xFF1B1B1B)],
        ),
        border: Border(bottom: BorderSide(color: accent)),
      ),
      child: Row(
        children: [
          Icon(type.workspace.icon, size: 18, color: accent),
          const SizedBox(width: 8),
          Text(
            'Add ${type.pluralLabel} from Collectarr Core',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close, size: 18),
            style: IconButton.styleFrom(
              minimumSize: const Size(30, 30),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodePrefillBanner extends StatelessWidget {
  const _BarcodePrefillBanner({
    required this.type,
    required this.barcode,
  });

  final LibraryTypeConfig type;
  final String barcode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF253744),
        border: Border(bottom: _kLibraryAddBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            const Icon(Icons.qr_code_2, size: 18, color: kClzAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Barcode $barcode is prefilled for ${type.pluralLabel.toLowerCase()}. Search Core or add it manually with the same code.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryAddModeBar extends StatelessWidget {
  const _LibraryAddModeBar({
    required this.type,
    required this.accent,
    required this.mode,
    required this.queryController,
    required this.barcodeController,
    required this.isSearching,
    required this.isSearchingProvider,
    required this.onModeChanged,
    required this.onSearch,
    required this.onLookupBarcode,
    required this.onManual,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final _LibraryAddDialogMode mode;
  final TextEditingController queryController;
  final TextEditingController barcodeController;
  final bool isSearching;
  final bool isSearchingProvider;
  final ValueChanged<_LibraryAddDialogMode> onModeChanged;
  final VoidCallback onSearch;
  final VoidCallback onLookupBarcode;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final isBusy = isSearching || isSearchingProvider;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kClzToolbar,
        border: Border(bottom: BorderSide(color: Color(0xFF111111))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 5, 7, 7),
        child: Column(
          children: [
            _LibraryAddModeTabStrip(
              type: type,
              accent: accent,
              mode: mode,
              onModeChanged: onModeChanged,
              onManual: onManual,
              onScan: () => onModeChanged(_LibraryAddDialogMode.barcode),
            ),
            const SizedBox(height: 7),
            switch (mode) {
              _LibraryAddDialogMode.search => Row(
                  children: [
                    Expanded(
                      child: _LibraryAddModeTextField(
                        fieldKey: const ValueKey('library-add-query-field'),
                        controller: queryController,
                        label: 'Search Collectarr Core',
                        hintText: _searchHint,
                        onSubmitted: onSearch,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _LibraryAddModeButton(
                      label: _searchButtonLabel,
                      icon: Icons.search,
                      accent: accent,
                      isBusy: isSearching,
                      onPressed: isBusy ? null : onSearch,
                    ),
                  ],
                ),
              _LibraryAddDialogMode.barcode => Row(
                  children: [
                    Expanded(
                      child: _LibraryAddModeTextField(
                        fieldKey: const ValueKey('library-add-barcode-field'),
                        controller: barcodeController,
                        label: 'Barcode / UPC / ISBN',
                        hintText: 'Scan or enter barcode / UPC / ISBN...',
                        keyboardType: TextInputType.number,
                        onSubmitted: onLookupBarcode,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _LibraryAddModeButton(
                      label: 'Lookup barcode',
                      icon: Icons.manage_search,
                      accent: accent,
                      isBusy: isSearching,
                      onPressed: isBusy ? null : onLookupBarcode,
                    ),
                  ],
                ),
              _LibraryAddDialogMode.manual => Row(
                  children: [
                    Icon(Icons.edit_note, size: 18, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fill the manual draft panel, then add it to collection or wishlist.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kClzTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _LibraryAddModeButton(
                      label: 'Manual draft',
                      icon: Icons.edit_note,
                      accent: accent,
                      outlined: true,
                      onPressed: onManual,
                    ),
                  ],
                ),
            },
          ],
        ),
      ),
    );
  }

  String get _searchHint {
    final label = type.singularLabel.toLowerCase();
    if (type.workspace.kind == 'comic' || type.workspace.kind == 'manga') {
      return 'Enter series title...';
    }
    return 'Enter $label title...';
  }

  String get _searchButtonLabel {
    if (type.workspace.kind == 'comic' || type.workspace.kind == 'manga') {
      return 'Search Series';
    }
    return 'Search ${type.pluralLabel}';
  }
}

class _LibraryAddModeTabStrip extends StatelessWidget {
  const _LibraryAddModeTabStrip({
    required this.type,
    required this.accent,
    required this.mode,
    required this.onModeChanged,
    required this.onManual,
    required this.onScan,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final _LibraryAddDialogMode mode;
  final ValueChanged<_LibraryAddDialogMode> onModeChanged;
  final VoidCallback onManual;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF272A2C),
        border: Border.all(color: accent.withValues(alpha: 0.72)),
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
                    icon: type.workspace.icon,
                    label: 'Search',
                    accent: accent,
                    selected: mode == _LibraryAddDialogMode.search,
                    onTap: () => onModeChanged(_LibraryAddDialogMode.search),
                  ),
                  LibraryAddModeTab(
                    icon: Icons.qr_code_2,
                    label: 'Barcode',
                    accent: accent,
                    selected: mode == _LibraryAddDialogMode.barcode,
                    onTap: () => onModeChanged(_LibraryAddDialogMode.barcode),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _LibraryAddModeActionButton(
            icon: Icons.edit_note,
            label: 'Manual',
            accent: accent,
            onPressed: onManual,
          ),
          _LibraryAddModeActionButton(
            icon: Icons.barcode_reader,
            label: 'Scan',
            accent: accent,
            onPressed: onScan,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.menu, size: 26, color: Color(0xFFEDEDED)),
        ],
      ),
    );
  }
}

class _LibraryAddModeActionButton extends StatelessWidget {
  const _LibraryAddModeActionButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color accent;
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
          foregroundColor: accent,
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

class _LibraryAddModeTextField extends StatelessWidget {
  const _LibraryAddModeTextField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.onSubmitted,
    this.keyboardType,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String hintText;
  final VoidCallback onSubmitted;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kLibraryAddModeControlHeight,
      child: _LibraryAddModeFieldFrame(
        child: TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
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
            semanticCounterText: label,
            hintText: hintText,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

class _LibraryAddModeFieldFrame extends StatelessWidget {
  const _LibraryAddModeFieldFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kLibraryAddModeControlHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
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

class _LibraryAddModeButton extends StatelessWidget {
  const _LibraryAddModeButton({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onPressed,
    this.isBusy = false,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback? onPressed;
  final bool isBusy;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = isBusy
        ? const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 7),
              Text(label),
            ],
          );
    final style = outlined
        ? _libraryAddOutlinedButtonStyle(accent)
        : _libraryAddFilledButtonStyle(accent);
    return SizedBox(
      height: _kLibraryAddModeControlHeight,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: style,
              child: child,
            )
          : FilledButton(
              onPressed: onPressed,
              style: style,
              child: child,
            ),
    );
  }
}

class _SearchPane extends StatelessWidget {
  const _SearchPane({
    required this.type,
    required this.isBusy,
    required this.error,
    required this.accent,
    required this.results,
    required this.providerResults,
    required this.queuedProviderIngests,
    required this.selectedProvider,
    required this.searchedProvider,
    required this.selectedResultId,
    required this.selectedProviderCandidateId,
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
    required this.onSearchCore,
  });

  final LibraryTypeConfig type;
  final bool isBusy;
  final String? error;
  final Color accent;
  final List<CatalogItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final String selectedProvider;
  final bool searchedProvider;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;
  final VoidCallback onSearchCore;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF1D2022),
        border: Border(right: BorderSide(color: kClzDivider)),
      ),
      child: _SearchResultsList(
        type: type,
        accent: accent,
        selectedProvider: selectedProvider,
        isBusy: isBusy,
        error: error,
        searchedProvider: searchedProvider,
        results: results,
        providerResults: providerResults,
        queuedProviderIngests: queuedProviderIngests,
        selectedResultId: selectedResultId,
        selectedProviderCandidateId: selectedProviderCandidateId,
        onSearchCore: onSearchCore,
        onSelectResult: onSelectResult,
        onSelectProviderCandidate: onSelectProviderCandidate,
      ),
    );
  }
}

class _SearchPaneNoticeStack extends StatelessWidget {
  const _SearchPaneNoticeStack({
    required this.error,
    required this.queuedProviderIngests,
    required this.isBusy,
    required this.onSearchCore,
  });

  final String? error;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final bool isBusy;
  final VoidCallback onSearchCore;

  @override
  Widget build(BuildContext context) {
    if (error == null && queuedProviderIngests.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (queuedProviderIngests.isNotEmpty)
          _QueuedIngestNotice(
            count: queuedProviderIngests.length,
            onSearchCore: isBusy ? null : onSearchCore,
          ),
        if (error != null)
          Padding(
            padding: EdgeInsets.only(
              top: queuedProviderIngests.isNotEmpty ? 6 : 0,
            ),
            child: _ErrorBanner(error!),
          ),
        const Divider(height: 1, thickness: 1, color: kClzDivider),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF4A2630),
        border: Border.all(color: const Color(0xFF9D5D69)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 18,
              color: Color(0xFFFFB4C0),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFFFFD9DF),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueuedIngestNotice extends StatelessWidget {
  const _QueuedIngestNotice({
    required this.count,
    required this.onSearchCore,
  });

  final int count;
  final VoidCallback? onSearchCore;

  @override
  Widget build(BuildContext context) {
    final jobLabel = count == 1 ? 'job' : 'jobs';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF183246),
        border: Border.all(color: kClzAccent.withValues(alpha: 0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          children: [
            const Icon(Icons.playlist_add_check, size: 18, color: kClzAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$count Core ingest $jobLabel queued. Run or retry them in Admin, then search Core again.',
                style: const TextStyle(
                  color: kClzTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onSearchCore,
              style: _libraryAddOutlinedButtonStyle(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Search Core again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.type,
    required this.accent,
    required this.selectedProvider,
    required this.isBusy,
    required this.error,
    required this.searchedProvider,
    required this.results,
    required this.providerResults,
    required this.queuedProviderIngests,
    required this.selectedResultId,
    required this.selectedProviderCandidateId,
    required this.onSearchCore,
    required this.onSelectResult,
    required this.onSelectProviderCandidate,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final String selectedProvider;
  final bool isBusy;
  final String? error;
  final bool searchedProvider;
  final List<CatalogItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final String? selectedResultId;
  final String? selectedProviderCandidateId;
  final VoidCallback onSearchCore;
  final ValueChanged<String> onSelectResult;
  final ValueChanged<String> onSelectProviderCandidate;

  @override
  Widget build(BuildContext context) {
    final notice = _SearchPaneNoticeStack(
      error: error,
      queuedProviderIngests: queuedProviderIngests,
      isBusy: isBusy,
      onSearchCore: onSearchCore,
    );
    if (isBusy && results.isEmpty && providerResults.isEmpty) {
      return _SearchSkeletonList(notice: notice);
    }
    if (results.isEmpty && providerResults.isEmpty) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          notice,
          SizedBox(
            height: 280,
            child: _NoSearchResults(
              type: type,
              selectedProvider: selectedProvider,
              searchedProvider: searchedProvider,
            ),
          ),
        ],
      );
    }
    final fallbackProviderLabel = _fallbackProviderLabel();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        notice,
        if (results.isNotEmpty) ...[
          const _ResultSectionHeader(label: 'Collectarr Core'),
          ..._withDividers(
            context,
            [
              for (final item in results)
                _SearchResultTile(
                  item: item,
                  accent: accent,
                  selected: item.id == selectedResultId,
                  onSelect: () => onSelectResult(item.id),
                ),
            ],
          ),
        ],
        if (providerResults.isNotEmpty) ...[
          if (fallbackProviderLabel != null)
            _ProviderFallbackNotice(
              requestedProvider: type.metadataProviderLabel(selectedProvider),
              fallbackProvider: fallbackProviderLabel,
            ),
          _ResultSectionHeader(
            label: '${type.metadataProviderLabel(selectedProvider)} candidates',
          ),
          ..._withDividers(
            context,
            [
              for (final candidate in providerResults)
                _ProviderCandidateTile(
                  candidate: candidate,
                  accent: accent,
                  providerLabel: type.metadataProviderLabel(candidate.provider),
                  queuedIngest: queuedProviderIngests[candidate.localCatalogId],
                  selected:
                      candidate.localCatalogId == selectedProviderCandidateId,
                  onSelect: () =>
                      onSelectProviderCandidate(candidate.localCatalogId),
                ),
            ],
          ),
        ],
      ],
    );
  }

  String? _fallbackProviderLabel() {
    for (final item in providerResults) {
      if (item.provider != selectedProvider) {
        return type.metadataProviderLabel(item.provider);
      }
    }
    return null;
  }

  List<Widget> _withDividers(BuildContext context, List<Widget> tiles) {
    const divider = Divider(height: 1, thickness: 1, color: kClzDivider);
    final separated = <Widget>[];
    for (var index = 0; index < tiles.length; index++) {
      if (index > 0) {
        separated.add(divider);
      }
      separated.add(tiles[index]);
    }
    return separated;
  }
}

class _SearchSkeletonList extends StatelessWidget {
  const _SearchSkeletonList({required this.notice});

  final Widget notice;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        notice,
        const Padding(
          padding: EdgeInsets.all(8),
          child: _ResultSectionHeader(label: 'Searching'),
        ),
        for (var index = 0; index < 6; index++) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: index.isEven ? kClzTableEvenRow : kClzTableOddRow,
                border: Border.all(color: kClzTableBottomBorder),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    _SkeletonBox(width: 42, height: 56),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(width: 220, height: 13),
                          SizedBox(height: 8),
                          _SkeletonBox(width: 320, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF313B42),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _ProviderFallbackNotice extends StatelessWidget {
  const _ProviderFallbackNotice({
    required this.requestedProvider,
    required this.fallbackProvider,
  });

  final String requestedProvider;
  final String fallbackProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF3F3A1A),
        border: Border(bottom: _kLibraryAddBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz, size: 18, color: kClzYellow),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$requestedProvider unavailable, $fallbackProvider fallback used.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSectionHeader extends StatelessWidget {
  const _ResultSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: kClzPanelRaised,
        border: Border(bottom: _kLibraryAddBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: kClzTextMuted,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.item,
    required this.accent,
    required this.selected,
    required this.onSelect,
  });

  final CatalogItem item;
  final Color accent;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (item.publisher != null) item.publisher,
      if (item.releaseYear != null) item.releaseYear.toString(),
      if (item.physicalFormatLabel != null) item.physicalFormatLabel,
      if (item.variant != null) item.variant,
      if (item.barcode != null) item.barcode,
    ].whereType<String>().join(' | ');
    return InkWell(
      onTap: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(accent.withValues(alpha: 0.46), kClzSelection)
              : kClzTableEvenRow,
          border: Border(
            left: BorderSide(
              color: selected ? accent : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                height: 56,
                child: LibraryCoverImage(
                  title: item.title,
                  itemNumber: item.itemNumber,
                  imageUrl: item.displayCoverUrl,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemNumber == null
                          ? item.title
                          : '${item.title} #${item.itemNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kClzTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    LibraryAddResultBadge(item.kind),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderCandidateTile extends StatelessWidget {
  const _ProviderCandidateTile({
    required this.candidate,
    required this.accent,
    required this.providerLabel,
    required this.queuedIngest,
    required this.selected,
    required this.onSelect,
  });

  final ProviderCandidate candidate;
  final Color accent;
  final String providerLabel;
  final _QueuedProviderIngest? queuedIngest;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      providerLabel,
      if (candidate.isStub) 'Stub result',
      candidate.summary,
      candidate.providerItemId,
    ].whereType<String>().join(' | ');
    return InkWell(
      onTap: onSelect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(accent.withValues(alpha: 0.46), kClzSelection)
              : kClzTableEvenRow,
          border: Border(
            left: BorderSide(
              color: selected ? accent : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                height: 56,
                child: LibraryCoverImage(
                  title: candidate.title,
                  imageUrl: candidate.imageUrl,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kClzTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        LibraryAddResultBadge(providerLabel),
                        if (candidate.isStub)
                          const LibraryAddResultBadge('stub'),
                        if (queuedIngest != null)
                          LibraryAddResultBadge(
                            '${queuedIngest!.statusLabel} ${queuedIngest!.shortId}',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                color: selected ? accent : kClzTextMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryAddPaneResizeDivider extends StatelessWidget {
  const _LibraryAddPaneResizeDivider();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: SizedBox(
        width: 10,
        child: Center(
          child: Container(width: 2, color: kClzDivider),
        ),
      ),
    );
  }
}

class _LibraryAddPreviewPane extends StatelessWidget {
  const _LibraryAddPreviewPane({
    required this.type,
    required this.accent,
    required this.item,
    required this.candidate,
    required this.providerLabel,
    required this.searched,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final CatalogItem? item;
  final ProviderCandidate? candidate;
  final String providerLabel;
  final bool searched;

  @override
  Widget build(BuildContext context) {
    final selectedItem = item;
    final selectedCandidate = candidate;
    if (selectedItem == null && selectedCandidate == null) {
      return ColoredBox(
        color: const Color(0xFF060606),
        child: Center(
          child: Text(
            searched
                ? 'Select a result or search $providerLabel.'
                : 'Search Collectarr Core to preview metadata.',
          ),
        ),
      );
    }
    final title = selectedItem?.title ?? selectedCandidate!.title;
    final itemNumber = selectedItem?.itemNumber;
    final synopsis = selectedItem?.synopsis ?? selectedCandidate?.summary;
    final coverUrl =
        selectedItem?.displayCoverUrl ?? selectedCandidate?.imageUrl;
    final rows = selectedItem == null
        ? [
            ('Provider', selectedCandidate?.provider),
            ('Provider ID', selectedCandidate?.providerItemId),
            ('Kind', selectedCandidate?.kind),
          ]
        : [
            ('Catalog ID', selectedItem.id),
            ('Kind', selectedItem.kind),
            ('Publisher', selectedItem.publisher),
            ('Year', selectedItem.releaseYear?.toString()),
            ('Barcode', selectedItem.barcode),
            ('Edition', selectedItem.displayEditionLabel),
          ];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF020202),
            Color.alphaBlend(accent.withValues(alpha: 0.22), kClzCanvas),
            const Color(0xFF050505),
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
                        itemNumber == null ? title : '$title #$itemNumber',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedItem == null
                            ? '$providerLabel candidate'
                            : 'Collectarr Core metadata',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                LibraryAddResultBadge(
                  selectedItem == null ? providerLabel : type.singularLabel,
                ),
              ],
            ),
            Divider(height: 22, color: accent.withValues(alpha: 0.42)),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Text('Plot', style: TextStyle(color: accent)),
                        const SizedBox(height: 6),
                        Text(synopsis ?? 'No metadata summary available yet.'),
                        const SizedBox(height: 22),
                        Text('Details', style: TextStyle(color: accent)),
                        const SizedBox(height: 8),
                        for (final row in rows)
                          if (row.$2 != null && row.$2!.trim().isNotEmpty)
                            _LibraryAddPreviewMetadataRow(
                              label: row.$1,
                              value: row.$2!,
                            ),
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
                        child: LibraryCoverImage(
                          title: title,
                          itemNumber: itemNumber,
                          imageUrl: coverUrl,
                        ),
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

class _LibraryAddPreviewMetadataRow extends StatelessWidget {
  const _LibraryAddPreviewMetadataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: kClzTextMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryAddBottomBar extends StatelessWidget {
  const _LibraryAddBottomBar({
    required this.type,
    required this.accent,
    required this.selectedItem,
    required this.selectedCandidate,
    required this.selectedQueuedIngest,
    required this.providerLabel,
    required this.addTarget,
    required this.isAdding,
    required this.isQueueingIngest,
    required this.onAddTargetChanged,
    required this.onAdd,
    required this.onQueueIngest,
    required this.onPropose,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final CatalogItem? selectedItem;
  final ProviderCandidate? selectedCandidate;
  final _QueuedProviderIngest? selectedQueuedIngest;
  final String providerLabel;
  final LibraryAddTarget addTarget;
  final bool isAdding;
  final bool isQueueingIngest;
  final ValueChanged<LibraryAddTarget> onAddTargetChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onQueueIngest;
  final VoidCallback? onPropose;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedItem != null || selectedCandidate != null;
    final addLabel = hasSelection
        ? LibraryAddCopy.addToTargetLabel(
            count: 1,
            type: type,
            target: addTarget,
          )
        : 'Select a ${type.singularLabel.toLowerCase()} to add';
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kClzToolbar,
        border: Border(top: BorderSide(color: kClzDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                LibraryAddResultBadge(
                    hasSelection ? '1 selected' : '0 selected'),
                _LibraryAddTargetMenu(
                  value: addTarget,
                  enabled: !isAdding,
                  accent: accent,
                  onChanged: onAddTargetChanged,
                ),
                if (selectedCandidate != null) ...[
                  LibraryAddResultBadge(providerLabel),
                  _LibraryAddBottomActionButton(
                    tooltip: selectedQueuedIngest == null
                        ? 'Queue Core ingest'
                        : 'Core ingest queued',
                    icon: Icons.playlist_add_check,
                    label: selectedQueuedIngest == null
                        ? 'Queue ingest'
                        : 'Queued ${selectedQueuedIngest!.shortId}',
                    accent: accent,
                    onPressed: selectedQueuedIngest != null || isQueueingIngest
                        ? null
                        : onQueueIngest,
                  ),
                  _LibraryAddBottomActionButton(
                    icon: Icons.outbox_outlined,
                    tooltip: 'Propose metadata to Core',
                    label: 'Propose',
                    accent: accent,
                    onPressed: isAdding || isQueueingIngest ? null : onPropose,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isAdding ? null : onAdd,
                    style: _libraryAddFilledButtonStyle(accent),
                    child: isAdding
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(addLabel),
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

class _LibraryAddBottomActionButton extends StatelessWidget {
  const _LibraryAddBottomActionButton({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.accent,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: _libraryAddOutlinedButtonStyle(accent),
        icon: Icon(icon, size: 17),
        label: Text(label),
      ),
    );
  }
}

class _LibraryAddTargetMenu extends StatelessWidget {
  const _LibraryAddTargetMenu({
    required this.value,
    required this.enabled,
    required this.accent,
    required this.onChanged,
  });

  final LibraryAddTarget value;
  final bool enabled;
  final Color accent;
  final ValueChanged<LibraryAddTarget> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LibraryAddTarget>(
      initialValue: value,
      enabled: enabled,
      tooltip: 'Add target',
      position: PopupMenuPosition.under,
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: LibraryAddTarget.owned,
          child: Text(LibraryAddTarget.owned.actionLabel),
        ),
        PopupMenuItem(
          value: LibraryAddTarget.wishlist,
          child: Text(LibraryAddTarget.wishlist.actionLabel),
        ),
      ],
      child: _LibraryAddCompactMenuFrame(
        width: 158,
        label: value.actionLabel,
        accent: accent,
        enabled: enabled,
      ),
    );
  }
}

class _LibraryAddCompactMenuFrame extends StatelessWidget {
  const _LibraryAddCompactMenuFrame({
    required this.width,
    required this.label,
    required this.accent,
    this.enabled = true,
  });

  final double width;
  final String label;
  final Color accent;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? accent : const Color(0xFF7B8790);
    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: Container(
        width: width,
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            Colors.black.withValues(alpha: 0.56),
            accent,
          ),
          border: Border.all(color: accent.withValues(alpha: 0.82)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({
    required this.type,
    required this.selectedProvider,
    required this.searchedProvider,
  });

  final LibraryTypeConfig type;
  final String selectedProvider;
  final bool searchedProvider;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.workspace.icon, size: 28, color: kClzAccent),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kClzTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _message {
    if (type.supportedMetadataProviders.isEmpty) {
      return 'No Core providers are configured for this library yet. Add a manual item to keep working locally.';
    }
    if (searchedProvider) {
      return 'No ${type.metadataProviderLabel(selectedProvider)} candidates found. Try a broader query or add a manual item.';
    }
    return 'Search Core, lookup a barcode, search ${type.metadataProviderLabel(selectedProvider)}, or add a manual item if Core is offline.';
  }
}

class _ManualPane extends StatelessWidget {
  const _ManualPane({
    required this.type,
    required this.titleController,
    required this.numberController,
    required this.publisherController,
    required this.yearController,
    required this.barcodeController,
    required this.variantController,
    required this.coverController,
    required this.physicalFormats,
    required this.physicalFormatId,
    required this.onPhysicalFormatChanged,
    required this.isAdding,
    required this.onAddOwned,
    required this.onAddWishlist,
  });

  final LibraryTypeConfig type;
  final TextEditingController titleController;
  final TextEditingController numberController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final TextEditingController variantController;
  final TextEditingController coverController;
  final List<PhysicalMediaFormat> physicalFormats;
  final String? physicalFormatId;
  final ValueChanged<String?> onPhysicalFormatChanged;
  final bool isAdding;
  final VoidCallback onAddOwned;
  final VoidCallback onAddWishlist;

  @override
  Widget build(BuildContext context) {
    final labels = libraryMediaFieldLabels(type);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kClzPanelRaised,
        border: Border(left: _kLibraryAddBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: kClzCanvas,
                  border: Border.all(color: kClzDivider),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    _ManualSectionHeader(
                      icon: type.workspace.icon,
                      label: 'Manual ${type.singularLabel}',
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: numberController,
                            decoration:
                                InputDecoration(labelText: labels.number),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: yearController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Year'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: publisherController,
                      decoration: InputDecoration(
                        labelText: labels.publisher,
                        prefixIcon: const Icon(Icons.business_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: variantController,
                      decoration: InputDecoration(
                        labelText: labels.variant,
                        prefixIcon:
                            const Icon(Icons.auto_awesome_motion_outlined),
                      ),
                    ),
                    if (physicalFormats.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: physicalFormatId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Physical format',
                          prefixIcon: Icon(Icons.album_outlined),
                        ),
                        dropdownColor: kClzPanelRaised,
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('No specific format'),
                          ),
                          for (final format in physicalFormats)
                            DropdownMenuItem<String>(
                              value: format.id,
                              child: Text(format.label),
                            ),
                        ],
                        onChanged: onPhysicalFormatChanged,
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextField(
                      controller: barcodeController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: labels.barcode,
                        prefixIcon: const Icon(Icons.qr_code_2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: coverController,
                      decoration: const InputDecoration(
                        labelText: 'Cover image URL',
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: kClzToolbar,
                border: Border.all(color: kClzDivider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        LibraryAddResultBadge('manual'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Create a local ${type.singularLabel.toLowerCase()} draft',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kClzTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isAdding ? null : onAddWishlist,
                            style: _libraryAddOutlinedButtonStyle(),
                            icon: const Icon(Icons.star_outline, size: 18),
                            label: Text(
                              LibraryAddCopy.addToTargetLabel(
                                count: 1,
                                type: type,
                                target: LibraryAddTarget.wishlist,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: isAdding ? null : onAddOwned,
                            style: _libraryAddFilledButtonStyle(),
                            icon: isAdding
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 18,
                                  ),
                            label: Text(
                              LibraryAddCopy.addToTargetLabel(
                                count: 1,
                                type: type,
                                target: LibraryAddTarget.owned,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualSectionHeader extends StatelessWidget {
  const _ManualSectionHeader({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kClzAccent),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
