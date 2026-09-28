import 'package:collectarr_app/features/collection/csv/import_export/import_export_wizard.dart';
import 'package:collectarr_app/features/library/data/catalog_item_v1_workspace_repository.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:collectarr_app/features/library/csv/catalog_item_v1_csv_exporter.dart';
import 'package:collectarr_app/features/library/state/catalog_item_v1_providers.dart';
import 'package:collectarr_app/features/library/v1/catalog_item_v1_kind_identities.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/ui/error_card.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'collection_page_shelf.dart';

enum _ShelfFilter { all, owned, wishlist, overdue, notes }

class CollectionPage extends ConsumerStatefulWidget {
  const CollectionPage({super.key, this.showOverdueOnly = false});

  final bool showOverdueOnly;

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> {
  late _ShelfFilter filter;

  @override
  void initState() {
    super.initState();
    filter = widget.showOverdueOnly ? _ShelfFilter.overdue : _ShelfFilter.all;
  }

  @override
  Widget build(BuildContext context) {
    final catalogItems = ref.watch(catalogItemV1AllWorkspacesProvider);
    final rows = catalogItems.maybeWhen(
      data: (items) => _filteredRows(items),
      orElse: () => const <CatalogItemV1WorkspaceItem>[],
    );
    final allRows = catalogItems.maybeWhen(
      data: (items) => items,
      orElse: () => const <CatalogItemV1WorkspaceItem>[],
    );
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
            tooltip: 'Import Catalog Item v1 CSV',
            onPressed: catalogItems.isLoading
                ? null
                : () => _showImportExportWizard(initialIndex: 1),
            icon: const Icon(Icons.upload_file),
          ),
          IconButton(
            tooltip: 'Export Catalog Item v1 CSV',
            onPressed: catalogItems.isLoading
                ? null
                : () => _showImportExportWizard(initialIndex: 0),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ShelfHeader(
              rows: allRows,
              filter: filter,
              onFilterChanged: (value) => setState(() => filter = value),
            ),
          ),
          if (catalogItems.isLoading)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (catalogItems.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AppErrorCard(
                  message:
                      'Could not load Catalog Item Shelf: ${catalogItems.error}',
                ),
              ),
            ),
          if (rows.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              sliver: SliverList.separated(
                itemCount: rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _CatalogItemV1ShelfRow(
                  item: rows[index],
                  onOpen: () => context.go(
                    Uri(
                      path: '/libraries',
                      queryParameters: {
                        'kind': rows[index].reference.kind.apiValue,
                      },
                    ).toString(),
                  ),
                  onToggleWishlist: () => _toggleWishlist(rows[index]),
                  onRemoveOwned: () => _removeOwned(rows[index]),
                ),
              ),
            ),
          if (!catalogItems.isLoading && !catalogItems.hasError && rows.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyShelf(),
            ),
        ],
      ),
    );
  }

  List<CatalogItemV1WorkspaceItem> _filteredRows(
    List<CatalogItemV1WorkspaceItem> rows,
  ) {
    final now = DateTime.now();
    return rows.where((row) {
      switch (filter) {
        case _ShelfFilter.all:
          return true;
        case _ShelfFilter.owned:
          return row.copies.any(_isOwned);
        case _ShelfFilter.wishlist:
          return row.wishlist != null;
        case _ShelfFilter.overdue:
          return row.copies.any((copy) => _isOverdue(copy, now));
        case _ShelfFilter.notes:
          return row.copies
                  .any((copy) => copy.notes?.trim().isNotEmpty == true) ||
              row.wishlist?.notes?.trim().isNotEmpty == true;
      }
    }).toList(growable: false);
  }

  bool _isOwned(OwnedCopyV1 copy) => copy.status != OwnedCopyStatusV1.sold;

  bool _isOverdue(OwnedCopyV1 copy, DateTime now) {
    final dueDate = copy.loanDueDate;
    if (copy.status != OwnedCopyStatusV1.loaned || dueDate?.day == null) {
      return false;
    }
    final due = DateTime(dueDate!.year!, dueDate.month!, dueDate.day!);
    final today = DateTime(now.year, now.month, now.day);
    return due.isBefore(today);
  }

  Future<void> _toggleWishlist(CatalogItemV1WorkspaceItem row) async {
    final repository = ref.read(catalogItemWishlistV1RepositoryProvider);
    final existing = row.wishlist;
    if (existing == null) {
      await repository.add(row.reference);
    } else {
      await repository.markDeleted(existing, DateTime.now().toUtc());
    }
    ref.invalidate(catalogItemV1AllWorkspacesProvider);
    ref.invalidate(catalogItemV1WorkspaceByKindProvider(row.reference.kind));
  }

  Future<void> _removeOwned(CatalogItemV1WorkspaceItem row) async {
    final repository = ref.read(ownedCopyV1RepositoryProvider);
    final active = row.copies.where(_isOwned).toList(growable: false);
    for (final copy in active) {
      await repository.markDeleted(copy.ref, DateTime.now().toUtc());
    }
    ref.invalidate(catalogItemV1AllWorkspacesProvider);
    ref.invalidate(catalogItemV1WorkspaceByKindProvider(row.reference.kind));
  }

  Future<void> _showImportExportWizard({required int initialIndex}) async {
    final rows = await ref.read(catalogItemV1AllWorkspacesProvider.future);
    if (!mounted) return;
    final exported = const CatalogItemV1CsvExporter().export(rows);
    final imported = await showDialog<int>(
      context: context,
      builder: (context) => ImportExportWizardDialog(
        initialIndex: initialIndex,
        additionalExports: [exported],
      ),
    );
    if (!mounted || imported == null) return;
    ref.invalidate(catalogItemV1AllWorkspacesProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported $imported rows into your collection')),
    );
  }
}
