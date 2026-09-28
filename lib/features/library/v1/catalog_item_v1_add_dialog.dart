part of 'catalog_item_v1_workspace_page.dart';

Future<bool?> showCatalogItemV1AddDialog({
  required BuildContext context,
  required CatalogMediaKind kind,
  required String singularLabel,
  required Color accent,
  bool? canEditCatalog,
  String? initialQuery,
  String? initialIdentifier,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final canEdit =
      canEditCatalog ?? container.read(authControllerProvider).canEditCatalog;
  final added = await showDialog<bool>(
    context: context,
    builder: (context) => _CatalogItemV1AddDialog(
      kind: kind,
      singularLabel: singularLabel,
      accent: accent,
      canEditCatalog: canEdit,
      initialQuery: initialQuery,
      initialIdentifier: initialIdentifier,
    ),
  );
  if (added == true) {
    container
        .read(catalogItemV1WorkspaceRepositoryProvider)
        .clearCatalogCache();
    container.invalidate(catalogItemV1WorkspaceByKindProvider(kind));
  }
  return added;
}

final class _CatalogItemV1AddDialog extends ConsumerStatefulWidget {
  const _CatalogItemV1AddDialog({
    required this.kind,
    required this.singularLabel,
    required this.accent,
    required this.canEditCatalog,
    this.initialQuery,
    this.initialIdentifier,
  });

  final CatalogMediaKind kind;
  final String singularLabel;
  final Color accent;
  final bool canEditCatalog;
  final String? initialQuery;
  final String? initialIdentifier;

  @override
  ConsumerState<_CatalogItemV1AddDialog> createState() =>
      _CatalogItemV1AddDialogState();
}

final class _CatalogItemV1AddDialogState
    extends ConsumerState<_CatalogItemV1AddDialog> {
  final _queryController = TextEditingController();
  final _titleController = TextEditingController();
  final _sortTitleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _releaseYearController = TextEditingController();
  final _releaseMonthController = TextEditingController();
  final _releaseDayController = TextEditingController();
  List<CatalogItemSummaryV1Dto> _results = const [];
  CatalogItemSummaryV1Dto? _selected;
  CatalogItemV1Dto? _selectedDetails;
  bool _loadingSelectedDetails = false;
  String? _selectedDetailsError;
  late OwnedCopyV1FormDraft _copyDraft =
      OwnedCopyV1FormDraft.empty(widget.kind);
  bool _manual = false;
  bool _busy = false;
  bool _searchIdentifierOnly = false;
  String? _error;
  Map<String, dynamic> _kindDetails = {};

  @override
  void initState() {
    super.initState();
    final initialIdentifier = widget.initialIdentifier?.trim();
    final hasInitialIdentifier =
        initialIdentifier != null && initialIdentifier.isNotEmpty;
    _queryController.text =
        hasInitialIdentifier ? initialIdentifier : widget.initialQuery ?? '';
    _searchIdentifierOnly = hasInitialIdentifier;
    if (_searchIdentifierOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _search();
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _titleController.dispose();
    _sortTitleController.dispose();
    _subtitleController.dispose();
    _releaseYearController.dispose();
    _releaseMonthController.dispose();
    _releaseDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Add ${widget.singularLabel}'),
        content: SizedBox(
          width: 620,
          height: 500,
          child: Column(
            children: [
              SegmentedButton<bool>(
                segments: [
                  const ButtonSegment(
                    value: false,
                    label: Text('Search Core'),
                  ),
                  if (widget.canEditCatalog)
                    const ButtonSegment(
                      value: true,
                      label: Text('Create manually'),
                    ),
                ],
                selected: {_manual},
                onSelectionChanged: (values) => setState(() {
                  _manual = values.single;
                  _error = null;
                  _results = const [];
                  _selected = null;
                  _selectedDetails = null;
                  _loadingSelectedDetails = false;
                  _selectedDetailsError = null;
                }),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    if (_manual) ...[
                      _CatalogItemCommonFields(
                        titleController: _titleController,
                        sortTitleController: _sortTitleController,
                        subtitleController: _subtitleController,
                        releaseYearController: _releaseYearController,
                        releaseMonthController: _releaseMonthController,
                        releaseDayController: _releaseDayController,
                      ),
                      _CatalogItemV1KindFields(
                        kind: widget.kind,
                        values: _kindDetails,
                        onChanged: (values) => setState(() {
                          _kindDetails = values;
                        }),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _queryController,
                              autofocus: true,
                              enabled: !_busy,
                              decoration: const InputDecoration(
                                labelText: 'Title or identifier',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (_) => setState(() {
                                _searchIdentifierOnly = false;
                                _results = const [];
                                _selected = null;
                                _selectedDetails = null;
                                _loadingSelectedDetails = false;
                                _selectedDetailsError = null;
                                _error = null;
                              }),
                              onSubmitted: (_) => _search(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Scan barcode',
                            onPressed: _busy ? null : _scanBarcode,
                            icon: const Icon(Icons.qr_code_scanner),
                          ),
                          FilledButton(
                            onPressed: _busy ? null : _search,
                            child: const Text('Search'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_results.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('Search the shared catalog.'),
                          ),
                        )
                      else
                        for (final result in _results)
                          ListTile(
                            selected: _selected?.id == result.id,
                            title: Text(result.title),
                            subtitle: Text(
                              [
                                result.artist,
                                if (result.releaseDate?.year != null)
                                  result.releaseDate!.year.toString(),
                                result.format,
                                result.country,
                                result.label,
                                result.barcode,
                              ].whereType<String>().join(' Â· '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: _selected?.id == result.id
                                ? Icon(Icons.check_circle, color: widget.accent)
                                : null,
                            onTap: () => _selectSearchResult(result),
                          ),
                    ],
                    if (_selected != null) ...[
                      const SizedBox(height: 8),
                      _SelectedCatalogItemDetails(
                        summary: _selected!,
                        details: _selectedDetails,
                        loading: _loadingSelectedDetails,
                        error: _selectedDetailsError,
                        accent: widget.accent,
                      ),
                    ],
                    const Divider(height: 24),
                    OwnedCopyV1Form(
                      key: const ValueKey('add-owned-copy-form'),
                      initial: _copyDraft,
                      showQuantity: true,
                      showAdvanced: true,
                      onChanged: (draft) => setState(() {
                        _copyDraft = draft;
                      }),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
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
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: Text(_manual ? 'Create and add copy' : 'Add to collection'),
          ),
        ],
      );

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;
    final identifierOnly =
        _searchIdentifierOnly || RegExp(r'^\d{8,14}$').hasMatch(query);
    setState(() {
      _busy = true;
      _error = null;
      _selected = null;
      _selectedDetails = null;
      _loadingSelectedDetails = false;
      _selectedDetailsError = null;
    });
    try {
      final results =
          await ref.read(libraryCatalogItemV1AddServiceProvider).search(
                kind: widget.kind,
                query: identifierOnly ? null : query,
                identifier: identifierOnly ? query : null,
              );
      if (!mounted) return;
      setState(() => _results = results);
    } catch (error) {
      if (mounted) setState(() => _error = 'Catalog search failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _scanBarcode() async {
    final scanned = await showModalBottomSheet<ScannedCode>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const BarcodeScanSheet(
        title: 'Search by barcode',
        description:
            'Scan or enter an identifier to search the shared catalog.',
        manualLabel: 'Barcode / ISBN / identifier',
        submitLabel: 'Search catalog',
      ),
    );
    if (!mounted || scanned == null) return;
    _queryController.text = scanned.value;
    _searchIdentifierOnly = true;
    await _search();
  }

  Future<void> _selectSearchResult(CatalogItemSummaryV1Dto result) async {
    setState(() {
      _selected = result;
      _selectedDetails = null;
      _selectedDetailsError = null;
      _loadingSelectedDetails = true;
      _error = null;
    });
    try {
      final details = await ref
          .read(libraryCatalogItemV1AddServiceProvider)
          .get(result.reference);
      if (!mounted || _selected?.id != result.id) return;
      ref.read(catalogItemV1WorkspaceRepositoryProvider).remember(details);
      setState(() => _selectedDetails = details);
    } catch (error) {
      if (!mounted || _selected?.id != result.id) return;
      setState(() => _selectedDetailsError = error.toString());
    } finally {
      if (mounted && _selected?.id == result.id) {
        setState(() => _loadingSelectedDetails = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_copyDraft.validationError != null) {
      setState(() => _error = _copyDraft.validationError);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final service = ref.read(libraryCatalogItemV1AddServiceProvider);
      CatalogItemRef reference;
      if (_manual) {
        final title = _titleController.text.trim();
        if (title.isEmpty) throw const FormatException('Title is required.');
        final releaseDate = _parseCatalogPartialDate(
          _releaseYearController.text,
          _releaseMonthController.text,
          _releaseDayController.text,
        );
        final details = <String, dynamic>{
          'kind': widget.kind.apiValue,
          'title': title,
          'sort_title': _nullableText(_sortTitleController.text),
          'subtitle': _nullableText(_subtitleController.text),
          if (releaseDate != null) 'release_date': releaseDate.toJson(),
          ..._kindDetails,
        };
        final typedDetails = catalogItemWriteDetailsFromJson(details);
        final matchesById = <String, CatalogItemSummaryV1Dto>{};
        for (final identifier in _catalogIdentitySearchValues(details)) {
          final matches = await service.search(
            kind: widget.kind,
            identifier: identifier,
            limit: 50,
          );
          for (final match in matches) {
            matchesById.putIfAbsent(match.id, () => match);
          }
        }
        if (matchesById.isNotEmpty) {
          final matches = matchesById.values.toList(growable: false);
          setState(() {
            _manual = false;
            _results = matches;
            _selected = null;
            _selectedDetails = null;
            _selectedDetailsError = null;
            _error = matches.length == 1
                ? 'This identifier already exists in the catalog. Review the item below before adding a copy.'
                : 'These identifiers match existing catalog items. Select the correct item below before adding a copy.';
          });
          if (matches.length == 1) {
            await _selectSearchResult(matches.single);
          }
          return;
        }
        final created = await service.create(
          CatalogItemWriteV1Dto(details: typedDetails),
        );
        ref.read(catalogItemV1WorkspaceRepositoryProvider).remember(created);
        reference = created.reference;
      } else {
        final selected = _selected;
        if (selected == null) {
          throw const FormatException('Select a Catalog Item first.');
        }
        reference = selected.reference;
      }

      await service.addCopies(
        item: reference,
        quantity: _copyDraft.quantity,
        status: _copyDraft.status,
        startingIndex: _copyDraft.indexNumber,
        locationId: _copyDraft.locationId,
        owner: _copyDraft.owner,
        isDigital: _copyDraft.isDigital,
        condition: _copyDraft.condition,
        purchaseDate: _copyDraft.purchaseDate,
        purchasePrice: _copyDraft.purchasePrice,
        purchaseStore: _copyDraft.purchaseStore,
        currentValue: _copyDraft.currentValue,
        soldAt: _copyDraft.soldAt,
        soldTo: _copyDraft.soldTo,
        salePrice: _copyDraft.salePrice,
        rating: _copyDraft.rating,
        notes: _copyDraft.notes,
        tags: _copyDraft.tags,
        personalImages: _copyDraft.personalImages,
        customFields: _copyDraft.customFields,
        kindDetails: _copyDraft.kindDetails,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = _catalogWriteError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
