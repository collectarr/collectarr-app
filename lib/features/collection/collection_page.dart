import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/collection/collection_csv.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ShelfFilter { all, owned, wishlist, missingGrade, notes }

class CollectionPage extends ConsumerStatefulWidget {
  const CollectionPage({super.key});

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> {
  _ShelfFilter filter = _ShelfFilter.all;

  @override
  Widget build(BuildContext context) {
    final shelf = ref.watch(shelfProvider);
    final accent = LibraryAccentScope.accentOf(context);
    final animationDuration = LibraryAccentScope.animationDurationOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelf'),
        backgroundColor: libraryAccentChromeFallbackColor(accent),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: LibraryAccentChrome(
          accent: accent,
          animationDuration: animationDuration,
        ),
        actions: [
          IconButton(
            tooltip: 'Import CSV',
            onPressed: _showImportDialog,
            icon: const Icon(Icons.upload_file),
          ),
          IconButton(
            tooltip: 'Export CSV',
            onPressed: shelf.maybeWhen(
              data: (state) => () => _showExportDialog(state.entries),
              orElse: () => null,
            ),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: shelf.when(
        data: (state) {
          final entries = _filteredEntries(state.entries);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ShelfHeader(
                  state: state,
                  filter: filter,
                  onFilterChanged: (value) => setState(() => filter = value),
                ),
              ),
              if (entries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyShelf(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  sliver: SliverList.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _ShelfEntryRow(
                        entry: entries[index],
                        onRemoveOwned: () => _removeOwned(entries[index]),
                        onRemoveWishlist: () => _removeWishlist(entries[index]),
                      );
                    },
                  ),
                ),
            ],
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  List<ShelfEntry> _filteredEntries(List<ShelfEntry> entries) {
    return switch (filter) {
      _ShelfFilter.all => entries,
      _ShelfFilter.owned =>
        entries.where((entry) => entry.isOwned).toList(growable: false),
      _ShelfFilter.wishlist =>
        entries.where((entry) => entry.isWishlisted).toList(growable: false),
      _ShelfFilter.missingGrade =>
        entries.where((entry) => entry.isMissingGrade).toList(growable: false),
      _ShelfFilter.notes =>
        entries.where((entry) => entry.hasNotes).toList(growable: false),
    };
  }

  Future<void> _removeOwned(ShelfEntry entry) async {
    final ownedItem = entry.ownedItem;
    if (ownedItem == null) {
      return;
    }
    await ref.read(collectionMutationsProvider).removeItem(ownedItem);
    ref.invalidate(shelfProvider);
  }

  Future<void> _removeWishlist(ShelfEntry entry) async {
    if (!entry.isWishlisted) {
      return;
    }
    await ref
        .read(collectionMutationsProvider)
        .removeFromWishlist(entry.itemId);
    ref.invalidate(shelfProvider);
  }

  Future<void> _showExportDialog(List<ShelfEntry> entries) async {
    final csv = CollectionCsv();
    final collectarrCsv = csv.exportShelf(entries);
    final clzCsv = csv.exportClzFriendlyShelf(entries);
    final ownedCount = entries.where((entry) => entry.isOwned).length;
    final wishlistCount = entries.where((entry) => entry.isWishlisted).length;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export CSV'),
        content: SizedBox(
          width: 760,
          height: 420,
          child: DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Collectarr'),
                    Tab(text: 'CLZ-friendly'),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PreviewChip('Rows', entries.length),
                    _PreviewChip('Owned', ownedCount),
                    _PreviewChip('Wishlist', wishlistCount),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: [
                      SelectableText(collectarrCsv),
                      SelectableText(clzCsv),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _copyCsvFromDialog(
              context,
              collectarrCsv,
              'Collectarr CSV copied',
            ),
            icon: const Icon(Icons.copy_all),
            label: const Text('Copy Collectarr'),
          ),
          TextButton.icon(
            onPressed: () => _copyCsvFromDialog(
              context,
              clzCsv,
              'CLZ-friendly CSV copied',
            ),
            icon: const Icon(Icons.table_view),
            label: const Text('Copy CLZ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyCsvFromDialog(
    BuildContext dialogContext,
    String data,
    String message,
  ) async {
    final messenger = ScaffoldMessenger.of(dialogContext);
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) {
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showImportDialog() async {
    final imported = await showDialog<int>(
      context: context,
      builder: (context) => const _ImportCsvDialog(),
    );
    if (imported != null && mounted) {
      ref.invalidate(shelfProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $imported CSV rows')),
      );
    }
  }
}

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
    return AlertDialog(
      title: const Text('Import CSV'),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paste Collectarr CSV or CLZ-style CSV. Rows with no item ID are matched locally by barcode, then by series + issue.',
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
      final preview =
          await ref.read(collectionMutationsProvider).previewImportRows(rows);
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
          .read(collectionMutationsProvider)
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
        type: comicsLibraryConfig,
        row: row,
      ),
    );
    if (item == null || !mounted || _preview == null) {
      return;
    }
    await CatalogCacheRepository(ref.read(localDatabaseProvider))
        .upsertAll([item]);
    final resolvedRow = row.copyWith(itemId: item.id);
    setState(() {
      final preview = _preview!;
      _preview = CollectionImportPreview(
        totalRows: preview.totalRows,
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
          comicsLibraryConfig,
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
      await CatalogCacheRepository(ref.read(localDatabaseProvider))
          .upsertAll(resolvedItems);
      if (!mounted) {
        return;
      }
      setState(() {
        _preview = CollectionImportPreview(
          totalRows: preview.totalRows,
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
        setState(() => _error = 'Resolve all failed: $error');
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
        totalRows: preview.totalRows,
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
        totalRows: preview.totalRows,
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
        totalRows: preview.totalRows,
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
        totalRows: preview.totalRows,
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
      final type = ref.read(resolvedLibraryTypeProvider(comicsLibraryConfig));
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
              Text(
                'Existing local items',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              for (final row in preview.conflictRows.take(8))
                _ConflictImportRow(
                  row: row,
                  onUpdate: onUpdateConflict,
                  onWishlist: onWishlistConflict,
                  onSkip: onSkipConflict,
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
              Text(
                'Duplicate CSV rows',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              for (final row in preview.duplicateRows.take(8))
                _DuplicateImportRow(row: row),
              if (preview.duplicateRows.length > 8)
                Text('+${preview.duplicateRows.length - 8} more duplicates'),
            ],
          ],
        ),
      ),
    );
  }
}

class _DuplicateImportRow extends StatelessWidget {
  const _DuplicateImportRow({required this.row});

  final CollectionCsvRow row;

  @override
  Widget build(BuildContext context) {
    final text = [
      row.title ?? 'Catalog item ${row.itemId}',
      if (row.itemNumber != null) '#${row.itemNumber}',
      if (row.publisher != null) row.publisher,
      if (row.barcode != null) row.barcode,
    ].join(' | ');
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(Icons.content_copy, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const Text('Skipped duplicate target'),
        ],
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
    final text = [
      row.title ?? 'Unknown title',
      if (row.itemNumber != null) '#${row.itemNumber}',
      if (row.publisher != null) row.publisher,
      if (row.barcode != null) row.barcode,
    ].join(' | ');
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

class _ConflictImportRow extends StatelessWidget {
  const _ConflictImportRow({
    required this.row,
    required this.onUpdate,
    required this.onWishlist,
    required this.onSkip,
  });

  final CollectionCsvRow row;
  final ValueChanged<CollectionCsvRow> onUpdate;
  final ValueChanged<CollectionCsvRow> onWishlist;
  final ValueChanged<CollectionCsvRow> onSkip;

  @override
  Widget build(BuildContext context) {
    final text = [
      row.title ?? 'Catalog item ${row.itemId}',
      if (row.itemNumber != null) '#${row.itemNumber}',
      if (row.publisher != null) row.publisher,
      if (row.grade != null) 'grade ${row.grade}',
      if (row.condition != null) row.condition,
    ].join(' | ');
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
          FilledButton.tonalIcon(
            onPressed: () => onUpdate(row),
            icon: const Icon(Icons.update, size: 18),
            label: const Text('Update'),
          ),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: () => onWishlist(row),
            icon: const Icon(Icons.bookmark_add_outlined, size: 18),
            label: const Text('Wishlist'),
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

  final LibraryTypeConfig type;
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
    return AlertDialog(
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
                        'Search Core and choose the matching comic.',
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
        (widget.row.barcode == null || widget.row.barcode!.trim().isEmpty)) {
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
        setState(() => _error = 'Core search failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  String _initialQuery(CollectionCsvRow row) {
    final parts = [
      if (row.title?.trim().isNotEmpty ?? false) row.title!.trim(),
      if (row.itemNumber?.trim().isNotEmpty ?? false) '#${row.itemNumber}',
    ];
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }
    return row.barcode?.trim() ?? '';
  }

  String _rowSummary(CollectionCsvRow row) {
    return [
      row.title ?? 'Unknown title',
      if (row.itemNumber != null) 'Issue ${row.itemNumber}',
      if (row.publisher != null) row.publisher,
      if (row.barcode != null) 'Barcode ${row.barcode}',
    ].join(' | ');
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
  late final _issueController =
      TextEditingController(text: widget.row.itemNumber ?? '');
  late final _barcodeController =
      TextEditingController(text: widget.row.barcode ?? '');
  late final _publisherController =
      TextEditingController(text: widget.row.publisher ?? '');
  final _sourceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _issueController.dispose();
    _barcodeController.dispose();
    _publisherController.dispose();
    _sourceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
              label: 'Series / title',
              onChanged: (_) => setState(() {}),
            ),
            _ImportProposalField(
              width: 120,
              controller: _issueController,
              label: 'Issue #',
            ),
            _ImportProposalField(
              width: 220,
              controller: _barcodeController,
              label: 'Barcode / UPC',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            _ImportProposalField(
              width: 220,
              controller: _publisherController,
              label: 'Publisher',
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
                      issueNumber: _issueController.text,
                      barcode: _barcodeController.text,
                      publisher: _publisherController.text,
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
    required this.issueNumber,
    required this.barcode,
    required this.publisher,
    required this.sourceUrl,
    required this.notes,
  });

  final String title;
  final String issueNumber;
  final String barcode;
  final String publisher;
  final String sourceUrl;
  final String notes;

  String get query {
    return [
      title.trim(),
      if (issueNumber.trim().isNotEmpty) '#${issueNumber.trim()}',
      if (barcode.trim().isNotEmpty) barcode.trim(),
    ].where((value) => value.isNotEmpty).join(' ');
  }

  String get summary {
    final lines = [
      'Metadata proposal from CSV import',
      '',
      'Suggested metadata:',
      if (title.trim().isNotEmpty) 'title: ${title.trim()}',
      if (issueNumber.trim().isNotEmpty) 'issue: ${issueNumber.trim()}',
      if (barcode.trim().isNotEmpty) 'barcode: ${barcode.trim()}',
      if (publisher.trim().isNotEmpty) 'publisher: ${publisher.trim()}',
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
  final issue = item.itemNumber;
  if (issue == null || issue.isEmpty) {
    return item.title;
  }
  return '${item.title} #$issue';
}

String _catalogSubtitle(CatalogItem item) {
  return [
    if (item.variant != null) item.variant,
    if (item.publisher != null) item.publisher,
    if (item.releaseYear != null) item.releaseYear.toString(),
    if (item.barcode != null) item.barcode,
  ].join(' | ');
}

Future<List<CatalogItem>> _searchCoreForRow(
  WidgetRef ref,
  LibraryTypeConfig type,
  CollectionCsvRow row, {
  String? queryOverride,
  int limit = 20,
}) async {
  final resolvedType = ref.read(resolvedLibraryTypeProvider(type));
  return searchLibraryMetadata(
    ref.read(apiClientProvider),
    resolvedType,
    query: _searchQueryForRow(row, queryOverride: queryOverride),
    barcode: row.barcode,
    issueNumber: row.itemNumber,
    limit: limit,
  );
}

String? _searchQueryForRow(CollectionCsvRow row, {String? queryOverride}) {
  final override = queryOverride?.trim();
  if (override != null && override.isNotEmpty) {
    return override;
  }
  final title = row.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
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
  final barcode = row.barcode == null
      ? null
      : MetadataSearchQuery.normalizeBarcode(row.barcode!);
  if (barcode != null && barcode.isNotEmpty) {
    final barcodeMatches = results
        .where((item) =>
            item.barcode != null &&
            MetadataSearchQuery.normalizeBarcode(item.barcode!) == barcode)
        .toList(growable: false);
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

class _ShelfHeader extends StatelessWidget {
  const _ShelfHeader({
    required this.state,
    required this.filter,
    required this.onFilterChanged,
  });

  final ShelfState state;
  final _ShelfFilter filter;
  final ValueChanged<_ShelfFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ShelfStatCard(
                icon: Icons.inventory_2_outlined,
                label: 'Owned',
                value: state.ownedCount.toString(),
              ),
              _ShelfStatCard(
                icon: Icons.tag_outlined,
                label: 'Quantity',
                value: state.totalQuantity.toString(),
              ),
              _ShelfStatCard(
                icon: Icons.star_border,
                label: 'Wishlist',
                value: state.wishlistCount.toString(),
              ),
              _ShelfStatCard(
                icon: Icons.key_outlined,
                label: 'Key comics',
                value: state.keyComicCount.toString(),
              ),
              _ShelfStatCard(
                icon: Icons.verified_outlined,
                label: 'Missing grade',
                value: state.missingGradeCount.toString(),
              ),
              _ShelfStatCard(
                icon: Icons.payments_outlined,
                label: 'Paid',
                value: _totalPaidLabel(state),
              ),
              _ShelfStatCard(
                icon: Icons.cloud_off_outlined,
                label: 'Missing metadata',
                value: state.missingMetadataCount.toString(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ShelfDistributionPanel(state: state),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<_ShelfFilter>(
              segments: const [
                ButtonSegment(
                  value: _ShelfFilter.all,
                  icon: Icon(Icons.all_inbox_outlined),
                  label: Text('All', key: ValueKey('shelf-filter-all')),
                ),
                ButtonSegment(
                  value: _ShelfFilter.owned,
                  icon: Icon(Icons.inventory_2_outlined),
                  label: Text('Owned', key: ValueKey('shelf-filter-owned')),
                ),
                ButtonSegment(
                  value: _ShelfFilter.wishlist,
                  icon: Icon(Icons.star_border),
                  label:
                      Text('Wishlist', key: ValueKey('shelf-filter-wishlist')),
                ),
                ButtonSegment(
                  value: _ShelfFilter.missingGrade,
                  icon: Icon(Icons.rule_outlined),
                  label: Text(
                    'Missing grade',
                    key: ValueKey('shelf-filter-missing-grade'),
                  ),
                ),
                ButtonSegment(
                  value: _ShelfFilter.notes,
                  icon: Icon(Icons.notes_outlined),
                  label: Text('Notes', key: ValueKey('shelf-filter-notes')),
                ),
              ],
              selected: {filter},
              onSelectionChanged: (value) => onFilterChanged(value.first),
            ),
          ),
        ],
      ),
    );
  }

  String _totalPaidLabel(ShelfState state) {
    if (state.hasMixedCurrencies) {
      return '${state.pricedCount} priced';
    }
    final cents = state.totalPaidCents;
    if (cents == null || state.primaryCurrency == null) {
      return 'No prices';
    }
    return _formatMoney(cents, state.primaryCurrency!);
  }
}

class _ShelfDistributionPanel extends StatelessWidget {
  const _ShelfDistributionPanel({required this.state});

  final ShelfState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DistributionGroup(title: 'Grades', values: state.gradeCounts),
            _DistributionGroup(
              title: 'Conditions',
              values: state.conditionCounts,
            ),
            _DistributionGroup(
              title: 'Read status',
              values: state.readStatusCounts,
            ),
            _DistributionGroup(
              title: 'Storage boxes',
              values: state.storageBoxCounts,
            ),
            _DistributionGroup(
              title: 'Top series',
              values: state.seriesCounts,
              maxItems: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class _DistributionGroup extends StatelessWidget {
  const _DistributionGroup({
    required this.title,
    required this.values,
    this.maxItems,
  });

  final String title;
  final Map<String, int> values;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final sorted = values.entries.toList(growable: false)
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) {
          return byCount;
        }
        return a.key.toLowerCase().compareTo(b.key.toLowerCase());
      });
    final visible = maxItems == null
        ? sorted
        : sorted.take(maxItems!).toList(growable: false);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (values.isEmpty)
                const Chip(label: Text('None'))
              else
                for (final entry in visible)
                  Chip(label: Text('${entry.key}: ${entry.value}')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShelfStatCard extends StatelessWidget {
  const _ShelfStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 170,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelMedium),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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

class _ShelfEntryRow extends StatelessWidget {
  const _ShelfEntryRow({
    required this.entry,
    required this.onRemoveOwned,
    required this.onRemoveWishlist,
  });

  final ShelfEntry entry;
  final VoidCallback onRemoveOwned;
  final VoidCallback onRemoveWishlist;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final owned = entry.ownedItem;
    final wishlist = entry.wishlistItem;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            _ShelfCover(entry: entry),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (entry.isOwned)
                        _ShelfChip(
                          icon: Icons.inventory_2,
                          label: owned?.condition ?? 'Owned',
                        ),
                      if (entry.isWishlisted)
                        const _ShelfChip(
                          icon: Icons.star,
                          label: 'Wishlist',
                        ),
                      _ShelfChip(
                        icon: Icons.verified_outlined,
                        label: owned?.grade ?? 'Ungraded',
                      ),
                      if (owned?.pricePaidCents != null &&
                          owned?.currency != null)
                        _ShelfChip(
                          icon: Icons.payments_outlined,
                          label: _formatMoney(
                            owned!.pricePaidCents!,
                            owned.currency!,
                          ),
                        ),
                      if (wishlist?.targetPriceCents != null &&
                          wishlist?.currency != null)
                        _ShelfChip(
                          icon: Icons.sell_outlined,
                          label: _formatMoney(
                            wishlist!.targetPriceCents!,
                            wishlist.currency!,
                          ),
                        ),
                    ],
                  ),
                  if (owned?.personalNotes?.trim().isNotEmpty ?? false) ...[
                    const SizedBox(height: 6),
                    Text(
                      owned!.personalNotes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(entry.updatedAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                PopupMenuButton<_ShelfAction>(
                  tooltip: 'Shelf actions',
                  onSelected: (action) {
                    switch (action) {
                      case _ShelfAction.removeOwned:
                        onRemoveOwned();
                        break;
                      case _ShelfAction.removeWishlist:
                        onRemoveWishlist();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (entry.isOwned)
                      const PopupMenuItem(
                        value: _ShelfAction.removeOwned,
                        child: Text('Remove owned'),
                      ),
                    if (entry.isWishlisted)
                      const PopupMenuItem(
                        value: _ShelfAction.removeWishlist,
                        child: Text('Remove wishlist'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _ShelfAction { removeOwned, removeWishlist }

class _ShelfCover extends StatelessWidget {
  const _ShelfCover({required this.entry});

  final ShelfEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = entry.catalogItem?.title ?? 'Item';
    final initials = title
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
    return SizedBox(
      width: 48,
      height: 72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            initials.isEmpty ? '?' : initials,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colorScheme.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}

class _ShelfChip extends StatelessWidget {
  const _ShelfChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyShelf extends StatelessWidget {
  const _EmptyShelf();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No shelf items match this view'));
  }
}

String _formatMoney(int cents, String currency) {
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final fraction = (cents.abs() % 100).toString().padLeft(2, '0');
  return '$currency $sign$whole.$fraction';
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
