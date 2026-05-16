import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/library/metadata/provider_status_provider.dart';
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
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookupBarcode());
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
    final providerStatuses =
        ref.watch(metadataProviderStatusesProvider).maybeWhen(
              data: (value) => value,
              orElse: () => const <String, AdminProviderStatus>{},
            );
    final selectedProvider = _activeProvider;
    return Theme(
      data: kClzAddComicDialogTheme,
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
                _DialogHeader(type: widget.type),
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
                        queryController: _queryController,
                        barcodeController: _barcodeController,
                        isSearching: _isSearching,
                        isSearchingProvider: _isSearchingProvider,
                        isQueueingIngest: _isQueueingIngest,
                        isAdding: _isAdding,
                        error: _error,
                        results: _results,
                        providerResults: _providerResults,
                        queuedProviderIngests: _queuedProviderIngests,
                        selectedProvider: selectedProvider,
                        providerStatuses: providerStatuses,
                        searchedProvider: _searchedProvider,
                        onSearch: _search,
                        onSearchProvider: _searchProvider,
                        onLookupBarcode: _lookupBarcode,
                        onAddOwned: (item) =>
                            _addItems([item], LibraryAddTarget.owned),
                        onAddWishlist: (item) =>
                            _addItems([item], LibraryAddTarget.wishlist),
                        onAddProviderOwned: (candidate) =>
                            _addProviderCandidate(
                          candidate,
                          LibraryAddTarget.owned,
                        ),
                        onAddProviderWishlist: (candidate) =>
                            _addProviderCandidate(
                          candidate,
                          LibraryAddTarget.wishlist,
                        ),
                        onQueueProviderIngest: _queueProviderIngest,
                        onProposeProvider: _proposeCandidate,
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
                      if (constraints.maxWidth < 720) {
                        return DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              const ColoredBox(
                                color: kClzToolbar,
                                child: TabBar(
                                  tabs: [
                                    Tab(
                                      icon: Icon(Icons.search),
                                      text: 'Search',
                                    ),
                                    Tab(icon: Icon(Icons.edit), text: 'Manual'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [searchPane, manualPane],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: searchPane),
                          const VerticalDivider(width: 1),
                          Expanded(flex: 2, child: manualPane),
                        ],
                      );
                    },
                  ),
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
        setState(() => _results = items);
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
      setState(() => _providerResults = results);
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

const double _kLibraryAddControlHeight = 34;
const BorderSide _kLibraryAddBorder = BorderSide(color: kClzDivider);

ButtonStyle _libraryAddFilledButtonStyle() {
  return FilledButton.styleFrom(
    minimumSize: const Size(0, _kLibraryAddControlHeight),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _libraryAddOutlinedButtonStyle() {
  return OutlinedButton.styleFrom(
    minimumSize: const Size(0, _kLibraryAddControlHeight),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w800),
  );
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.type});

  final LibraryTypeConfig type;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: kClzPanelRaised,
        border: Border(bottom: BorderSide(color: kClzAccent)),
      ),
      child: Row(
        children: [
          Icon(type.workspace.icon, size: 18, color: kClzAccent),
          const SizedBox(width: 8),
          Text(
            'Add ${type.pluralLabel}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Collectarr Core',
            style: TextStyle(
              color: kClzTextMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
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

class _SearchPane extends StatelessWidget {
  const _SearchPane({
    required this.type,
    required this.queryController,
    required this.barcodeController,
    required this.isSearching,
    required this.isSearchingProvider,
    required this.isQueueingIngest,
    required this.isAdding,
    required this.error,
    required this.results,
    required this.providerResults,
    required this.queuedProviderIngests,
    required this.selectedProvider,
    required this.providerStatuses,
    required this.searchedProvider,
    required this.onSearch,
    required this.onSearchProvider,
    required this.onLookupBarcode,
    required this.onAddOwned,
    required this.onAddWishlist,
    required this.onAddProviderOwned,
    required this.onAddProviderWishlist,
    required this.onQueueProviderIngest,
    required this.onProposeProvider,
  });

  final LibraryTypeConfig type;
  final TextEditingController queryController;
  final TextEditingController barcodeController;
  final bool isSearching;
  final bool isSearchingProvider;
  final bool isQueueingIngest;
  final bool isAdding;
  final String? error;
  final List<CatalogItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final String selectedProvider;
  final Map<String, AdminProviderStatus> providerStatuses;
  final bool searchedProvider;
  final VoidCallback onSearch;
  final VoidCallback onSearchProvider;
  final VoidCallback onLookupBarcode;
  final ValueChanged<CatalogItem> onAddOwned;
  final ValueChanged<CatalogItem> onAddWishlist;
  final ValueChanged<ProviderCandidate> onAddProviderOwned;
  final ValueChanged<ProviderCandidate> onAddProviderWishlist;
  final ValueChanged<ProviderCandidate> onQueueProviderIngest;
  final ValueChanged<ProviderCandidate> onProposeProvider;

  @override
  Widget build(BuildContext context) {
    final providers = type.supportedMetadataProviders;
    final selectedProviderOption = _selectedProviderOption(providers);
    final isBusy = isSearching || isSearchingProvider;
    return ColoredBox(
      color: kClzPanel,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                        Expanded(
                          child: TextField(
                            controller: queryController,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              labelText: 'Search Collectarr Core',
                              prefixIcon: Icon(type.workspace.icon),
                            ),
                            onSubmitted: (_) => onSearch(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: isBusy ? null : onSearch,
                          style: _libraryAddFilledButtonStyle(),
                          icon: isSearching
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search, size: 18),
                          label: const Text('Search Core'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: barcodeController,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              labelText: 'Barcode / UPC / ISBN',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            onSubmitted: (_) => onLookupBarcode(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: isBusy ? null : onLookupBarcode,
                          style: _libraryAddOutlinedButtonStyle(),
                          icon: const Icon(Icons.manage_search, size: 18),
                          label: const Text('Lookup'),
                        ),
                        if (providers.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: isBusy ? null : onSearchProvider,
                            style: _libraryAddOutlinedButtonStyle(),
                            icon: isSearchingProvider
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.travel_explore, size: 18),
                            label: const Text('Search providers'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _CoreSearchNotice(type: type),
            if (providers.isNotEmpty) ...[
              const SizedBox(height: 8),
              _ProviderRoutingNotice(
                type: type,
                selectedProvider: selectedProvider,
              ),
              if (selectedProviderOption != null) ...[
                const SizedBox(height: 8),
                _ProviderSearchNotice(
                  provider: selectedProviderOption,
                  status: providerStatuses[selectedProviderOption.id],
                ),
              ],
              if (queuedProviderIngests.isNotEmpty) ...[
                const SizedBox(height: 8),
                _QueuedIngestNotice(
                  count: queuedProviderIngests.length,
                  onSearchCore: isBusy ? null : onSearch,
                ),
              ],
            ],
            if (error != null) ...[
              const SizedBox(height: 8),
              _ErrorBanner(error!),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: kClzCanvas,
                  border: Border.all(color: kClzDivider),
                ),
                child: _SearchResultsList(
                  type: type,
                  selectedProvider: selectedProvider,
                  isBusy: isBusy,
                  isAdding: isAdding,
                  isQueueingIngest: isQueueingIngest,
                  searchedProvider: searchedProvider,
                  results: results,
                  providerResults: providerResults,
                  queuedProviderIngests: queuedProviderIngests,
                  onAddOwned: onAddOwned,
                  onAddWishlist: onAddWishlist,
                  onAddProviderOwned: onAddProviderOwned,
                  onAddProviderWishlist: onAddProviderWishlist,
                  onQueueProviderIngest: onQueueProviderIngest,
                  onProposeProvider: onProposeProvider,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LibraryMetadataProviderOption? _selectedProviderOption(
    List<LibraryMetadataProviderOption> providers,
  ) {
    for (final provider in providers) {
      if (provider.id == selectedProvider) {
        return provider;
      }
    }
    return providers.isEmpty ? null : providers.first;
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

class _CoreSearchNotice extends StatelessWidget {
  const _CoreSearchNotice({required this.type});

  final LibraryTypeConfig type;

  @override
  Widget build(BuildContext context) {
    final hasProviders = type.supportedMetadataProviders.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        border: Border.all(color: kClzDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              hasProviders
                  ? Icons.cloud_queue_outlined
                  : Icons.warning_amber_outlined,
              size: 18,
              color: hasProviders ? kClzAccent : const Color(0xFFFFB4C0),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasProviders
                    ? 'Core search uses the configured metadata server. If it is offline, use the manual panel; local items still sync normally.'
                    : 'No metadata provider is configured for ${type.pluralLabel.toLowerCase()}. Manual add is available.',
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
}

class _ProviderRoutingNotice extends StatelessWidget {
  const _ProviderRoutingNotice({
    required this.type,
    required this.selectedProvider,
  });

  final LibraryTypeConfig type;
  final String selectedProvider;

  @override
  Widget build(BuildContext context) {
    final providerLabel = type.metadataProviderLabel(selectedProvider);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF222C33),
        border: Border.all(color: kClzDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          children: [
            const Icon(Icons.alt_route, size: 18, color: kClzAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Core chooses the provider. Default route: $providerLabel, with server-side fallback when available.',
                maxLines: 2,
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
      ),
    );
  }
}

class _ProviderSearchNotice extends StatelessWidget {
  const _ProviderSearchNotice({
    required this.provider,
    required this.status,
  });

  final LibraryMetadataProviderOption provider;
  final AdminProviderStatus? status;

  @override
  Widget build(BuildContext context) {
    final policy = provider.usagePolicy;
    final chips = <Widget>[
      if (status != null && !status!.isConfigured)
        const _ProviderNoticeChip(
          icon: Icons.warning_amber_outlined,
          label: 'Stub / needs credentials',
        )
      else if (status != null && status!.isConfigured)
        const _ProviderNoticeChip(
          icon: Icons.check_circle_outline,
          label: 'Live provider',
        )
      else if (provider.requiresApiKey)
        const _ProviderNoticeChip(
          icon: Icons.warning_amber_outlined,
          label: 'May be stub until configured',
        ),
      if (status != null && !status!.supportsIngest)
        const _ProviderNoticeChip(
          icon: Icons.search,
          label: 'Search-only',
        ),
      if (provider.requiresApiKey)
        const _ProviderNoticeChip(
          icon: Icons.key,
          label: 'Requires API key',
        ),
      if (policy?.requiresAttribution ?? false)
        const _ProviderNoticeChip(
          icon: Icons.link,
          label: 'Attribution required',
        ),
      if (policy?.nonCommercialOnly ?? false)
        const _ProviderNoticeChip(
          icon: Icons.volunteer_activism_outlined,
          label: 'Non-commercial',
        ),
    ];
    final message = status?.message.trim();
    final kindLabel = status == null || status!.effectiveKinds.isEmpty
        ? null
        : 'Kinds: ${status!.effectiveKinds.join(', ')}';
    if ((provider.description == null || provider.description!.isEmpty) &&
        chips.isEmpty &&
        policy == null &&
        (message == null || message.isEmpty) &&
        kindLabel == null) {
      return const SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF222C33),
        border: Border.all(color: kClzDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.description != null &&
                provider.description!.isNotEmpty)
              Text(
                provider.description!,
                style: const TextStyle(
                  color: kClzTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: chips),
            ],
            if (message != null && message.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                message,
                style: const TextStyle(color: kClzTextMuted, fontSize: 12),
              ),
            ],
            if (kindLabel != null) ...[
              const SizedBox(height: 6),
              Text(
                kindLabel,
                style: const TextStyle(color: kClzTextMuted, fontSize: 12),
              ),
            ],
            if (policy?.summary != null && policy!.summary.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                policy.summary,
                style: const TextStyle(color: kClzTextMuted, fontSize: 12),
              ),
            ],
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

class _ProviderNoticeChip extends StatelessWidget {
  const _ProviderNoticeChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 14),
      label: Text(label),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.type,
    required this.selectedProvider,
    required this.isBusy,
    required this.isAdding,
    required this.isQueueingIngest,
    required this.searchedProvider,
    required this.results,
    required this.providerResults,
    required this.queuedProviderIngests,
    required this.onAddOwned,
    required this.onAddWishlist,
    required this.onAddProviderOwned,
    required this.onAddProviderWishlist,
    required this.onQueueProviderIngest,
    required this.onProposeProvider,
  });

  final LibraryTypeConfig type;
  final String selectedProvider;
  final bool isBusy;
  final bool isAdding;
  final bool isQueueingIngest;
  final bool searchedProvider;
  final List<CatalogItem> results;
  final List<ProviderCandidate> providerResults;
  final Map<String, _QueuedProviderIngest> queuedProviderIngests;
  final ValueChanged<CatalogItem> onAddOwned;
  final ValueChanged<CatalogItem> onAddWishlist;
  final ValueChanged<ProviderCandidate> onAddProviderOwned;
  final ValueChanged<ProviderCandidate> onAddProviderWishlist;
  final ValueChanged<ProviderCandidate> onQueueProviderIngest;
  final ValueChanged<ProviderCandidate> onProposeProvider;

  @override
  Widget build(BuildContext context) {
    if (isBusy && results.isEmpty && providerResults.isEmpty) {
      return const _SearchSkeletonList();
    }
    if (results.isEmpty && providerResults.isEmpty) {
      return _NoSearchResults(
        type: type,
        selectedProvider: selectedProvider,
        searchedProvider: searchedProvider,
      );
    }
    final fallbackProviderLabel = _fallbackProviderLabel();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (results.isNotEmpty) ...[
          const _ResultSectionHeader(label: 'Collectarr Core'),
          ..._withDividers(
            context,
            [
              for (final item in results)
                _SearchResultTile(
                  item: item,
                  isAdding: isAdding,
                  onAddOwned: () => onAddOwned(item),
                  onAddWishlist: () => onAddWishlist(item),
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
                  providerLabel: type.metadataProviderLabel(candidate.provider),
                  isAdding: isAdding,
                  isQueueingIngest: isQueueingIngest,
                  queuedIngest: queuedProviderIngests[candidate.localCatalogId],
                  onAddOwned: () => onAddProviderOwned(candidate),
                  onAddWishlist: () => onAddProviderWishlist(candidate),
                  onQueueIngest: () => onQueueProviderIngest(candidate),
                  onPropose: () => onProposeProvider(candidate),
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
  const _SearchSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        const _ResultSectionHeader(label: 'Searching'),
        for (var index = 0; index < 6; index++) ...[
          const SizedBox(height: 8),
          DecoratedBox(
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
        ],
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
    required this.isAdding,
    required this.onAddOwned,
    required this.onAddWishlist,
  });

  final CatalogItem item;
  final bool isAdding;
  final VoidCallback onAddOwned;
  final VoidCallback onAddWishlist;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (item.publisher != null) item.publisher,
      if (item.releaseYear != null) item.releaseYear.toString(),
      if (item.physicalFormatLabel != null) item.physicalFormatLabel,
      if (item.variant != null) item.variant,
      if (item.barcode != null) item.barcode,
    ].whereType<String>().join(' | ');
    return ColoredBox(
      color: kClzTableEvenRow,
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
            const SizedBox(width: 8),
            Wrap(
              spacing: 4,
              children: [
                _CompactTileIconButton(
                  tooltip: 'Add as owned',
                  onPressed: isAdding ? null : onAddOwned,
                  icon: Icons.inventory_2_outlined,
                ),
                _CompactTileIconButton(
                  tooltip: 'Add to wishlist',
                  onPressed: isAdding ? null : onAddWishlist,
                  icon: Icons.star_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactTileIconButton extends StatelessWidget {
  const _CompactTileIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        minimumSize: const Size.square(30),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _ProviderCandidateTile extends StatelessWidget {
  const _ProviderCandidateTile({
    required this.candidate,
    required this.providerLabel,
    required this.isAdding,
    required this.isQueueingIngest,
    required this.queuedIngest,
    required this.onAddOwned,
    required this.onAddWishlist,
    required this.onQueueIngest,
    required this.onPropose,
  });

  final ProviderCandidate candidate;
  final String providerLabel;
  final bool isAdding;
  final bool isQueueingIngest;
  final _QueuedProviderIngest? queuedIngest;
  final VoidCallback onAddOwned;
  final VoidCallback onAddWishlist;
  final VoidCallback onQueueIngest;
  final VoidCallback onPropose;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      providerLabel,
      if (candidate.isStub) 'Stub result',
      candidate.summary,
      candidate.providerItemId,
    ].whereType<String>().join(' | ');
    return ColoredBox(
      color: kClzTableEvenRow,
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
                      if (candidate.isStub) const LibraryAddResultBadge('stub'),
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  _CompactTileIconButton(
                    tooltip: 'Add provider draft as owned',
                    onPressed: isAdding ? null : onAddOwned,
                    icon: Icons.inventory_2_outlined,
                  ),
                  _CompactTileIconButton(
                    tooltip: 'Add provider draft to wishlist',
                    onPressed: isAdding ? null : onAddWishlist,
                    icon: Icons.star_outline,
                  ),
                  if (queuedIngest == null)
                    _CompactTileIconButton(
                      tooltip: 'Queue Core ingest',
                      onPressed:
                          isAdding || isQueueingIngest ? null : onQueueIngest,
                      icon: Icons.playlist_add_check,
                    ),
                  _CompactTileIconButton(
                    tooltip: 'Propose metadata to Core',
                    onPressed: isAdding || isQueueingIngest ? null : onPropose,
                    icon: Icons.outbox_outlined,
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
