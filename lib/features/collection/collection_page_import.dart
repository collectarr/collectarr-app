part of 'collection_page.dart';

// CSV import dialog + preview + proposal widgets

class _ImportCsvDialog extends ConsumerStatefulWidget {
  const _ImportCsvDialog();

  @override
  ConsumerState<_ImportCsvDialog> createState() => _ImportCsvDialogState();
}

class _ImportCsvDialogState extends ConsumerState<_ImportCsvDialog> {
  final _controller = TextEditingController();
  final _csv = CollectionCsv();
  CollectionImportPreview? _preview;
  String? _error;
  bool _isWorking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    return AccentAlertDialog(
      title: const Text('Import CSV'),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paste Collectarr CSV or CLZ-style CSV. Rows with no item ID are matched locally by barcode, then by title + item number.',
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                minLines: 9,
                maxLines: 14,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {
                  _preview = null;
                  _error = null;
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: TextStyle(color: Colors.red.shade300)),
              ],
              if (preview != null) ...[
                const SizedBox(height: 12),
                _ImportPreviewPanel(
                  preview: preview,
                  onResolveRow: _resolveRow,
                  onResolveAll: _isWorking ? null : _resolveAllUnresolved,
                  onProposeRow: _isWorking ? null : _proposeRow,
                  onSkipRow: _skipRow,
                  onUpdateConflict: _updateConflict,
                  onWishlistConflict: _wishlistConflict,
                  onSkipConflict: _skipConflict,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isWorking ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        OutlinedButton.icon(
          onPressed: _isWorking ? null : _previewRows,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Preview'),
        ),
        FilledButton.icon(
          onPressed:
              _isWorking || preview?.hasImportableRows != true ? null : _import,
          icon: _isWorking
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: Text(
            preview == null
                ? 'Import'
                : 'Import ${preview.resolvedCount} matched',
          ),
        ),
      ],
    );
  }

  Future<void> _previewRows() async {
    setState(() {
      _isWorking = true;
      _error = null;
    });
    try {
      final rows = _csv.parse(_controller.text);
      final preview = await ref
          .read(collectionImportServiceProvider)
          .previewImportRows(rows);
      if (mounted) {
        setState(() => _preview = preview);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'CSV preview failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  Future<void> _import() async {
    var preview = _preview;
    if (preview == null) {
      await _previewRows();
      preview = _preview;
    }
    if (preview == null || !preview.hasImportableRows) {
      return;
    }
    setState(() => _isWorking = true);
    try {
      final imported = await ref
          .read(collectionImportServiceProvider)
          .importRows(preview.resolvedRows);
      if (mounted) {
        Navigator.of(context).pop(imported);
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  Future<void> _resolveRow(CollectionCsvRow row) async {
    final item = await showDialog<CatalogItem>(
      context: context,
      builder: (context) => _ResolveImportRowDialog(
        type: _runtimeForImportRow(row),
        row: row,
      ),
    );
    if (item == null || !mounted || _preview == null) {
      return;
    }
    await LibraryCatalogRepository(ref.read(localDatabaseProvider))
        .upsertMetadataItems([item]);
    final resolvedRow = row.copyWith(itemId: item.id);
    setState(() {
      final preview = _preview!;
      _preview = CollectionImportPreview(
        resolvedRows: [...preview.resolvedRows, resolvedRow],
        conflictRows: preview.conflictRows,
        unresolvedRows: [
          for (final candidate in preview.unresolvedRows)
            if (!identical(candidate, row)) candidate,
        ],
        skippedRows: preview.skippedRows,
        duplicateRows: preview.duplicateRows,
      );
    });
  }

  Future<void> _resolveAllUnresolved() async {
    final preview = _preview;
    if (preview == null || preview.unresolvedRows.isEmpty) {
      return;
    }
    setState(() {
      _isWorking = true;
      _error = null;
    });
    try {
      final resolvedRows = [...preview.resolvedRows];
      final unresolvedRows = <CollectionCsvRow>[];
      final resolvedItems = <CatalogItem>[];
      for (final row in preview.unresolvedRows) {
        final results = await _searchCoreForRow(
          ref,
          _runtimeForImportRow(row),
          row,
          limit: 5,
        );
        final match = _confidentImportMatch(row, results);
        if (match == null) {
          unresolvedRows.add(row);
          continue;
        }
        resolvedRows.add(row.copyWith(itemId: match.id));
        resolvedItems.add(match);
      }
      await LibraryCatalogRepository(ref.read(localDatabaseProvider))
          .upsertMetadataItems(resolvedItems);
      if (!mounted) {
        return;
      }
      setState(() {
        _preview = CollectionImportPreview(
          resolvedRows: resolvedRows,
          conflictRows: preview.conflictRows,
          unresolvedRows: unresolvedRows,
          skippedRows: preview.skippedRows,
          duplicateRows: preview.duplicateRows,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Resolved ${resolvedItems.length} rows from Collectarr Core',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = _friendlyImportError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  void _skipRow(CollectionCsvRow row) {
    final preview = _preview;
    if (preview == null) {
      return;
    }
    setState(() {
      _preview = CollectionImportPreview(
        resolvedRows: preview.resolvedRows,
        conflictRows: preview.conflictRows,
        unresolvedRows: [
          for (final candidate in preview.unresolvedRows)
            if (!identical(candidate, row)) candidate,
        ],
        skippedRows: [...preview.skippedRows, row],
        duplicateRows: preview.duplicateRows,
      );
    });
  }

  void _updateConflict(CollectionCsvRow row) {
    final preview = _preview;
    if (preview == null) {
      return;
    }
    setState(() {
      _preview = CollectionImportPreview(
        resolvedRows: [...preview.resolvedRows, row],
        conflictRows: [
          for (final candidate in preview.conflictRows)
            if (!identical(candidate, row)) candidate,
        ],
        unresolvedRows: preview.unresolvedRows,
        skippedRows: preview.skippedRows,
        duplicateRows: preview.duplicateRows,
      );
    });
  }

  void _wishlistConflict(CollectionCsvRow row) {
    final preview = _preview;
    if (preview == null) {
      return;
    }
    setState(() {
      _preview = CollectionImportPreview(
        resolvedRows: [
          ...preview.resolvedRows,
          row.copyWith(status: 'wishlist'),
        ],
        conflictRows: [
          for (final candidate in preview.conflictRows)
            if (!identical(candidate, row)) candidate,
        ],
        unresolvedRows: preview.unresolvedRows,
        skippedRows: preview.skippedRows,
        duplicateRows: preview.duplicateRows,
      );
    });
  }

  void _skipConflict(CollectionCsvRow row) {
    final preview = _preview;
    if (preview == null) {
      return;
    }
    setState(() {
      _preview = CollectionImportPreview(
        resolvedRows: preview.resolvedRows,
        conflictRows: [
          for (final candidate in preview.conflictRows)
            if (!identical(candidate, row)) candidate,
        ],
        unresolvedRows: preview.unresolvedRows,
        skippedRows: [...preview.skippedRows, row],
        duplicateRows: preview.duplicateRows,
      );
    });
  }

  Future<void> _proposeRow(CollectionCsvRow row) async {
    final draft = await showDialog<_ImportProposalDraft>(
      context: context,
      builder: (context) => _ImportProposalDialog(row: row),
    );
    if (draft == null || !mounted) {
      return;
    }
    setState(() {
      _isWorking = true;
      _error = null;
    });
    try {
      final type = ref.read(
        resolvedLibraryTypeProvider(
          _runtimeForImportRow(row),
        ),
      );
      final response = await createLibraryMetadataProposal(
        api: ref.read(apiClientProvider),
        type: type,
        query: draft.query,
        title: draft.title.trim().isEmpty ? null : draft.title.trim(),
        summary: draft.summary,
      );
      await recordLibraryMetadataProposalResponse(
        response: response,
        type: type,
        query: draft.query,
        title: draft.title,
        source: 'CSV import',
      );
      if (!mounted) {
        return;
      }
      _skipRow(row);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Metadata proposal sent; row skipped for now'),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Metadata proposal failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }
}

class _ImportPreviewPanel extends StatelessWidget {
  const _ImportPreviewPanel({
    required this.preview,
    required this.onResolveRow,
    required this.onResolveAll,
    required this.onProposeRow,
    required this.onSkipRow,
    required this.onUpdateConflict,
    required this.onWishlistConflict,
    required this.onSkipConflict,
  });

  final CollectionImportPreview preview;
  final ValueChanged<CollectionCsvRow> onResolveRow;
  final VoidCallback? onResolveAll;
  final ValueChanged<CollectionCsvRow>? onProposeRow;
  final ValueChanged<CollectionCsvRow> onSkipRow;
  final ValueChanged<CollectionCsvRow> onUpdateConflict;
  final ValueChanged<CollectionCsvRow> onWishlistConflict;
  final ValueChanged<CollectionCsvRow> onSkipConflict;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PreviewChip('Rows', preview.totalRows),
                _PreviewChip('Matched', preview.resolvedCount),
                _PreviewChip('Conflicts', preview.conflictCount),
                _PreviewChip('Unresolved', preview.unresolvedCount),
                _PreviewChip('Duplicates', preview.duplicateCount),
                _PreviewChip('Skipped', preview.skippedCount),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              preview.reviewCount == 0
                  ? 'Ready to import ${preview.resolvedCount} matched rows.'
                  : 'Ready to import ${preview.resolvedCount} rows. Review ${preview.reviewCount} rows before import.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (preview.conflictRows.isNotEmpty) ...[
              const SizedBox(height: 10),
              ImportReviewPanel(
                title: 'Existing local items',
                emptyLabel: 'No conflicts.',
                items: [
                  for (final row in preview.conflictRows.take(8))
                    ImportReviewItem(
                      title: _importRowTitle(row),
                      description: _importRowDescription(row),
                      severity: ImportReviewSeverity.warning,
                      actions: [
                        ImportReviewAction(
                          label: 'Update',
                          isPrimary: true,
                          onPressed: () => onUpdateConflict(row),
                        ),
                        ImportReviewAction(
                          label: 'Wishlist',
                          onPressed: () => onWishlistConflict(row),
                        ),
                        ImportReviewAction(
                          label: 'Skip',
                          onPressed: () => onSkipConflict(row),
                        ),
                      ],
                    ),
                ],
              ),
              if (preview.conflictRows.length > 8)
                Text('+${preview.conflictRows.length - 8} more conflicts'),
            ],
            if (preview.unresolvedRows.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Unresolved rows',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onResolveAll,
                    icon: const Icon(Icons.auto_fix_high, size: 18),
                    label: const Text('Search all'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              for (final row in preview.unresolvedRows.take(8))
                _UnresolvedImportRow(
                  row: row,
                  onResolve: onResolveRow,
                  onPropose: onProposeRow,
                  onSkip: onSkipRow,
                ),
              if (preview.unresolvedRows.length > 8)
                Text('+${preview.unresolvedRows.length - 8} more unresolved'),
            ],
            if (preview.duplicateRows.isNotEmpty) ...[
              const SizedBox(height: 10),
              ImportReviewPanel(
                title: 'Duplicate CSV rows',
                emptyLabel: 'No duplicates.',
                items: [
                  for (final row in preview.duplicateRows.take(8))
                    ImportReviewItem(
                      title: _importRowTitle(row),
                      description: _importRowDescription(row),
                      severity: ImportReviewSeverity.info,
                    ),
                ],
              ),
              if (preview.duplicateRows.length > 8)
                Text('+${preview.duplicateRows.length - 8} more duplicates'),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnresolvedImportRow extends StatelessWidget {
  const _UnresolvedImportRow({
    required this.row,
    required this.onResolve,
    required this.onPropose,
    required this.onSkip,
  });

  final CollectionCsvRow row;
  final ValueChanged<CollectionCsvRow> onResolve;
  final ValueChanged<CollectionCsvRow>? onPropose;
  final ValueChanged<CollectionCsvRow> onSkip;

  @override
  Widget build(BuildContext context) {
    final text = _importRowDescription(row);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => onResolve(row),
            icon: const Icon(Icons.manage_search, size: 18),
            label: const Text('Search Core'),
          ),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: onPropose == null ? null : () => onPropose!(row),
            icon: const Icon(Icons.outbox, size: 18),
            label: const Text('Propose'),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: () => onSkip(row),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}

class _ResolveImportRowDialog extends ConsumerStatefulWidget {
  const _ResolveImportRowDialog({
    required this.type,
    required this.row,
  });

  final LibraryKindModule type;
  final CollectionCsvRow row;

  @override
  ConsumerState<_ResolveImportRowDialog> createState() =>
      _ResolveImportRowDialogState();
}

class _ResolveImportRowDialogState
    extends ConsumerState<_ResolveImportRowDialog> {
  late final TextEditingController _queryController;
  var _results = const <CatalogItem>[];
  String? _error;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: _initialQuery(widget.row));
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      title: const Text('Resolve CSV row'),
      content: SizedBox(
        width: 760,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_rowSummary(widget.row)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(
                      labelText: 'Search Collectarr Core',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _isSearching ? null : _search,
                  icon: _isSearching
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.manage_search),
                  label: const Text('Search'),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Colors.red.shade300)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: _results.isEmpty
                  ? const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Search Core and choose the matching item.',
                      ),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return ListTile(
                          dense: true,
                          leading: _CatalogThumb(item: item),
                          title: Text(_catalogTitle(item)),
                          subtitle: Text(_catalogSubtitle(item)),
                          trailing: FilledButton(
                            onPressed: () => Navigator.of(context).pop(item),
                            child: const Text('Use'),
                          ),
                        );
                      },
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
      ],
    );
  }

  Future<void> _search() async {
    if (_queryController.text.trim().isEmpty &&
        (_importRowBarcode(widget.row) == null ||
            _importRowBarcode(widget.row)!.trim().isEmpty)) {
      return;
    }
    setState(() {
      _isSearching = true;
      _error = null;
    });
    try {
      final items = await _searchCoreForRow(
        ref,
        widget.type,
        widget.row,
        queryOverride: _queryController.text,
      );
      if (mounted) {
        setState(() => _results = items);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = _friendlyImportError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  String _initialQuery(CollectionCsvRow row) {
    return _importRowSearchQuery(row);
  }

  String _rowSummary(CollectionCsvRow row) {
    return _importRowDescription(row);
  }
}

class _ImportProposalDialog extends StatefulWidget {
  const _ImportProposalDialog({required this.row});

  final CollectionCsvRow row;

  @override
  State<_ImportProposalDialog> createState() => _ImportProposalDialogState();
}

class _ImportProposalDialogState extends State<_ImportProposalDialog> {
  late final _titleController =
      TextEditingController(text: widget.row.title ?? '');
  late final _barcodeController =
      TextEditingController(text: _importRowBarcode(widget.row) ?? '');
  late final _queryController =
      TextEditingController(text: _importRowSearchQuery(widget.row));
  final _sourceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _barcodeController.dispose();
    _queryController.dispose();
    _sourceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      title: const Text('Propose metadata'),
      content: SizedBox(
        width: 560,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ImportProposalField(
              width: 350,
              controller: _titleController,
              label: 'Title',
              onChanged: (_) => setState(() {}),
            ),
            _ImportProposalField(
              width: 540,
              controller: _queryController,
              label: 'Search query',
            ),
            _ImportProposalField(
              width: 220,
              controller: _barcodeController,
              label: 'Identifier / barcode',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            _ImportProposalField(
              width: 540,
              controller: _sourceController,
              label: 'Source URL',
            ),
            _ImportProposalField(
              width: 540,
              controller: _notesController,
              label: 'Notes for admin review',
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: !_hasProposalIdentity
              ? null
              : () => Navigator.of(context).pop(
                    _ImportProposalDraft(
                      title: _titleController.text,
                      searchQuery: _queryController.text,
                      barcode: _barcodeController.text,
                      sourceUrl: _sourceController.text,
                      notes: _notesController.text,
                    ),
                  ),
          icon: const Icon(Icons.outbox),
          label: const Text('Send proposal'),
        ),
      ],
    );
  }

  bool get _hasProposalIdentity {
    return _titleController.text.trim().isNotEmpty ||
        _barcodeController.text.trim().isNotEmpty;
  }
}

class _ImportProposalField extends StatelessWidget {
  const _ImportProposalField({
    required this.width,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  final double width;
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}

class _ImportProposalDraft {
  const _ImportProposalDraft({
    required this.title,
    required this.searchQuery,
    required this.barcode,
    required this.sourceUrl,
    required this.notes,
  });

  final String title;
  final String searchQuery;
  final String barcode;
  final String sourceUrl;
  final String notes;

  String get query {
    return searchQuery.trim().isNotEmpty ? searchQuery.trim() : title.trim();
  }

  String get summary {
    final lines = [
      'Metadata proposal from CSV import',
      '',
      'Suggested metadata:',
      if (title.trim().isNotEmpty) 'title: ${title.trim()}',
      if (barcode.trim().isNotEmpty) 'barcode: ${barcode.trim()}',
      if (sourceUrl.trim().isNotEmpty) 'source: ${sourceUrl.trim()}',
      if (notes.trim().isNotEmpty) ...['', 'Notes:', notes.trim()],
    ];
    return lines.join('\n');
  }
}

class _CatalogThumb extends StatelessWidget {
  const _CatalogThumb({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final url = item.displayCoverUrl;
    if (url == null || url.isEmpty) {
      return const SizedBox.square(
        dimension: 42,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.black26),
          child: Icon(Icons.menu_book),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Image.network(
        url,
        width: 42,
        height: 56,
        fit: BoxFit.cover,
        webHtmlElementStrategy: kIsWeb
            ? WebHtmlElementStrategy.prefer
            : WebHtmlElementStrategy.never,
        errorBuilder: (_, __, ___) => const SizedBox.square(
          dimension: 42,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black26),
            child: Icon(Icons.broken_image),
          ),
        ),
      ),
    );
  }
}

String _catalogTitle(CatalogItem item) {
  return libraryCollectionCsvProjectionForKind(item.mediaKind)
          ?.catalogDisplayTitle(item) ??
      item.title;
}

String _catalogSubtitle(CatalogItem item) {
  return libraryCollectionCsvProjectionForKind(item.mediaKind)
          ?.catalogDisplaySubtitle(item) ??
      '';
}

String _importRowTitle(CollectionCsvRow row) {
  final projection = _importProjection(row);
  final cells = row.kindCatalogCells;
  if (projection != null &&
      cells.length == libraryCollectionCsvCatalogCellCount) {
    return projection.importDisplayTitle(cells);
  }
  final title = row.title?.trim();
  return title == null || title.isEmpty ? 'Catalog item ${row.itemId}' : title;
}

String _importRowDescription(CollectionCsvRow row) {
  final projection = _importProjection(row);
  final cells = row.kindCatalogCells;
  final subtitle =
      projection != null && cells.length == libraryCollectionCsvCatalogCellCount
          ? projection.importDisplaySubtitle(cells)
          : '';
  final barcode = _importRowBarcode(row);
  return [
    _importRowTitle(row),
    if (subtitle.trim().isNotEmpty) subtitle,
    if (barcode != null && barcode.trim().isNotEmpty) 'Identifier $barcode',
  ].join(' | ');
}

String _importRowSearchQuery(CollectionCsvRow row) {
  final projection = _importProjection(row);
  final cells = row.kindCatalogCells;
  final title =
      projection != null && cells.length == libraryCollectionCsvCatalogCellCount
          ? projection.importDisplayTitle(cells)
          : row.title?.trim() ?? '';
  final barcode = _importRowBarcode(row);
  return [
    if (title.trim().isNotEmpty && title != 'Unknown title') title.trim(),
    if (barcode != null && barcode.trim().isNotEmpty) barcode.trim(),
  ].join(' ');
}

String? _importRowBarcode(CollectionCsvRow row) {
  final value = row.kindCatalogCells.elementAtOrNull(10)?.trim();
  return value == null || value.isEmpty ? null : value;
}

LibraryCollectionCsvProjection? _importProjection(CollectionCsvRow row) {
  return libraryCollectionCsvProjectionForKind(
    catalogMediaKindFromValue(row.kind),
  );
}

LibraryKindModule _runtimeForImportRow(CollectionCsvRow row) {
  return libraryKindModuleForKind(
    catalogMediaKindFromValue(row.kind),
  );
}

String _friendlyImportError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return 'Not authenticated — sign in via Settings → Account to search the Collectarr Core catalog.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Cannot reach the metadata server. Check the URL in Settings → Connection.';
    }
  }
  return 'Search failed: $error';
}

Future<List<CatalogItem>> _searchCoreForRow(
  WidgetRef ref,
  LibraryKindModule type,
  CollectionCsvRow row, {
  String? queryOverride,
  int limit = 20,
}) async {
  final resolvedType = ref.read(resolvedLibraryTypeProvider(type));
  return await searchLibraryMetadata(
    ref.read(apiClientProvider),
    resolvedType,
    query: _searchQueryForRow(row, queryOverride: queryOverride),
    barcode: _importRowBarcode(row),
    limit: limit,
  );
}

String? _searchQueryForRow(CollectionCsvRow row, {String? queryOverride}) {
  final override = queryOverride?.trim();
  if (override != null && override.isNotEmpty) {
    return override;
  }
  final query = _importRowSearchQuery(row);
  if (query.isNotEmpty) {
    return query;
  }
  return null;
}

CatalogItem? _confidentImportMatch(
  CollectionCsvRow row,
  List<CatalogItem> results,
) {
  if (results.isEmpty) {
    return null;
  }
  final rawBarcode = _importRowBarcode(row);
  final barcode = rawBarcode == null
      ? null
      : MetadataSearchQuery.normalizeBarcode(rawBarcode);
  if (barcode != null && barcode.isNotEmpty) {
    final barcodeMatches = results.where((item) {
      return libraryCollectionCsvProjectionForKind(item.mediaKind)
              ?.catalogMatchesBarcode(item, barcode) ??
          false;
    }).toList(growable: false);
    if (barcodeMatches.length == 1) {
      return barcodeMatches.single;
    }
  }
  if (results.length == 1) {
    return results.single;
  }
  return null;
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}
