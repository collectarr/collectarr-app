import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/settings/connection_diagnostics.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
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
  String? _error;
  bool _isSearching = false;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
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
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 680),
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
                    isAdding: _isAdding,
                    error: _error,
                    results: _results,
                    onSearch: _search,
                    onLookupBarcode: _lookupBarcode,
                    onAddOwned: (item) =>
                        _addItems([item], LibraryAddTarget.owned),
                    onAddWishlist: (item) =>
                        _addItems([item], LibraryAddTarget.wishlist),
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
                    isAdding: _isAdding,
                    onAddOwned: () => _addManual(LibraryAddTarget.owned),
                    onAddWishlist: () => _addManual(LibraryAddTarget.wishlist),
                  );
                  if (constraints.maxWidth < 720) {
                    return DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(icon: Icon(Icons.search), text: 'Search'),
                              Tab(icon: Icon(Icons.edit), text: 'Manual'),
                            ],
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
    );
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() => _error = 'Enter a title, creator, series, or keyword.');
      return;
    }
    setState(() {
      _isSearching = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final items = await searchAndCacheLibraryMetadata(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        input: LibraryMetadataSearchInput(query: query, limit: 20),
      );
      if (mounted) {
        setState(() => _results = items);
      }
    } catch (error) {
      if (mounted) {
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Core search failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)} Manual add still works.',
        );
      }
    } finally {
      if (mounted) {
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
    setState(() {
      _isSearching = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final results = await lookupAndCacheLibraryBarcodes(
        api: api,
        type: widget.type,
        catalog: CatalogCacheRepository(ref.read(localDatabaseProvider)),
        barcodes: [barcode],
      );
      final found = [
        for (final result in results)
          if (result.item != null) result.item!,
      ];
      if (mounted) {
        setState(() {
          _results = found;
          _error = found.isEmpty ? 'No item found for barcode $barcode.' : null;
        });
      }
    } catch (error) {
      if (mounted) {
        final api = ref.read(apiClientProvider);
        setState(
          () => _error =
              'Barcode lookup failed: ${ConnectionDiagnostics.metadataError(error, api.baseUrl)} Manual add keeps the scanned code.',
        );
      }
    } finally {
      if (mounted) {
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
      publisher: _emptyToNull(_publisherController.text),
      releaseYear: year,
      barcode: _emptyToNull(_barcodeController.text),
      variant: _emptyToNull(_variantController.text),
      coverImageUrl: _emptyToNull(_coverController.text),
    );
    await _addItems([item], target);
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

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.type});

  final LibraryTypeConfig type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Icon(type.workspace.icon),
          const SizedBox(width: 10),
          Text(
            'Add ${type.pluralLabel}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close),
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
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.35),
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.qr_code_2, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Barcode $barcode is prefilled for ${type.pluralLabel.toLowerCase()}. Search Core or add it manually with the same code.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    required this.isAdding,
    required this.error,
    required this.results,
    required this.onSearch,
    required this.onLookupBarcode,
    required this.onAddOwned,
    required this.onAddWishlist,
  });

  final LibraryTypeConfig type;
  final TextEditingController queryController;
  final TextEditingController barcodeController;
  final bool isSearching;
  final bool isAdding;
  final String? error;
  final List<CatalogItem> results;
  final VoidCallback onSearch;
  final VoidCallback onLookupBarcode;
  final ValueChanged<CatalogItem> onAddOwned;
  final ValueChanged<CatalogItem> onAddWishlist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                onPressed: isSearching ? null : onSearch,
                icon: isSearching
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                onPressed: isSearching ? null : onLookupBarcode,
                icon: const Icon(Icons.manage_search),
                label: const Text('Lookup'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _CoreSearchNotice(type: type),
          if (type.supportedMetadataProviders.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final provider in type.supportedMetadataProviders)
                  Chip(
                    avatar: provider.requiresApiKey
                        ? const Icon(Icons.key, size: 14)
                        : null,
                    label: Text(provider.label),
                  ),
              ],
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: results.isEmpty
                ? _NoSearchResults(type: type)
                : ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return _SearchResultTile(
                        item: item,
                        isAdding: isAdding,
                        onAddOwned: () => onAddOwned(item),
                        onAddWishlist: () => onAddWishlist(item),
                      );
                    },
                  ),
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.44),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              hasProviders
                  ? Icons.cloud_queue_outlined
                  : Icons.warning_amber_outlined,
              size: 18,
              color: hasProviders ? colorScheme.primary : colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasProviders
                    ? 'Core search uses the configured metadata server. If it is offline, use the manual panel; local items still sync normally.'
                    : 'No metadata provider is configured for ${type.pluralLabel.toLowerCase()}. Manual add is available.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 42,
        height: 56,
        child: LibraryCoverImage(
          title: item.title,
          itemNumber: item.itemNumber,
          imageUrl: item.displayCoverUrl,
        ),
      ),
      title: Text(item.itemNumber == null
          ? item.title
          : '${item.title} #${item.itemNumber}'),
      subtitle: Text(
        [
          if (item.publisher != null) item.publisher,
          if (item.releaseYear != null) item.releaseYear.toString(),
          if (item.variant != null) item.variant,
          if (item.barcode != null) item.barcode,
        ].whereType<String>().join(' | '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Wrap(
        spacing: 6,
        children: [
          IconButton(
            tooltip: 'Add as owned',
            onPressed: isAdding ? null : onAddOwned,
            icon: const Icon(Icons.inventory_2_outlined),
          ),
          IconButton(
            tooltip: 'Add to wishlist',
            onPressed: isAdding ? null : onAddWishlist,
            icon: const Icon(Icons.star_outline),
          ),
        ],
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({required this.type});

  final LibraryTypeConfig type;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        type.supportedMetadataProviders.isEmpty
            ? 'No Core providers are configured for this library yet. Add a manual item to keep working locally.'
            : 'Search Core, lookup a barcode, or add a manual item if Core is offline.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
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
  final bool isAdding;
  final VoidCallback onAddOwned;
  final VoidCallback onAddWishlist;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Manual ${type.singularLabel}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
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
                    decoration: const InputDecoration(labelText: 'No. / Vol.'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Year'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: publisherController,
              decoration: const InputDecoration(
                labelText: 'Publisher / Studio / Creator',
                prefixIcon: Icon(Icons.business_outlined),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: variantController,
              decoration: const InputDecoration(
                labelText: 'Edition / Variant / Format',
                prefixIcon: Icon(Icons.auto_awesome_motion_outlined),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: barcodeController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Barcode / UPC / ISBN',
                prefixIcon: Icon(Icons.qr_code_2),
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
            const Spacer(),
            OutlinedButton.icon(
              onPressed: isAdding ? null : onAddWishlist,
              icon: const Icon(Icons.star_outline),
              label:
                  Text('Add to ${LibraryAddTarget.wishlist.destinationLabel}'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: isAdding ? null : onAddOwned,
              icon: isAdding
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.inventory_2_outlined),
              label: Text('Add to ${LibraryAddTarget.owned.destinationLabel}'),
            ),
          ],
        ),
      ),
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
