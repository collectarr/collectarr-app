import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_codec.dart';
import 'package:collectarr_app/features/collection/csv/import_export/import_export_wizard.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/ui/error_card.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/data/catalog_item_v1_workspace_repository.dart';
import 'package:collectarr_app/features/library/state/catalog_item_v1_providers.dart';
import 'package:collectarr_app/features/library/v1/catalog_item_v1_kind_identities.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/imports/framework/import_review_panel.dart';
import 'package:dio/dio.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'collection_page_import.dart';
part 'collection_page_shelf.dart';

enum _ShelfFilter { all, owned, wishlist, overdue, notes }

class CollectionPage extends ConsumerStatefulWidget {
  const CollectionPage({
    super.key,
    this.showOverdueOnly = false,
  });

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
    final shelf = ref.watch(shelfProvider);
    final catalogItemsV1 = ref.watch(catalogItemV1AllWorkspacesProvider);
    final overdueOwnedRefs =
        ref.watch(overdueLoanOwnedItemIdsProvider).maybeWhen(
              data: (value) => value,
              orElse: () => const <OwnedItemRef>{},
            );
    final legacyState = shelf.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final entries = legacyState == null
        ? const <LibraryWorkspaceSource>[]
        : _filteredEntries(legacyState.entries, overdueOwnedRefs);
    final catalogRows = _filteredCatalogItemRows(
      catalogItemsV1.maybeWhen(
        data: (rows) => rows,
        orElse: () => const <CatalogItemV1WorkspaceItem>[],
      ),
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
            tooltip: 'Import…',
            onPressed: shelf.maybeWhen(
              data: (state) => () => _showImportExportWizard(
                    state.entries,
                    initialIndex: 1,
                  ),
              orElse: () => null,
            ),
            icon: const Icon(Icons.upload_file),
          ),
          IconButton(
            tooltip: 'Export…',
            onPressed: shelf.maybeWhen(
              data: (state) => () => _showImportExportWizard(
                    state.entries,
                    initialIndex: 0,
                  ),
              orElse: () => null,
            ),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ShelfHeader(
              state: legacyState,
              filter: filter,
              overdueCount: overdueOwnedRefs.length,
              onFilterChanged: (value) => setState(() => filter = value),
            ),
          ),
          if (legacyState == null && shelf.isLoading)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (shelf.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AppErrorCard(message: shelf.error.toString()),
              ),
            ),
          if (catalogRows.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Catalog Item copies',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              sliver: SliverList.separated(
                itemCount: catalogRows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _CatalogItemV1ShelfRow(
                  item: catalogRows[index],
                  onOpen: () => context.go(
                    Uri(
                      path: '/libraries',
                      queryParameters: {
                        'kind': catalogRows[index].reference.kind.apiValue,
                      },
                    ).toString(),
                  ),
                ),
              ),
            ),
          ],
          if (catalogItemsV1.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AppErrorCard(
                  message:
                      'Could not load Catalog Item copies: ${catalogItemsV1.error}',
                ),
              ),
            ),
          if (entries.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              sliver: SliverList.separated(
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _LibraryWorkspaceSourceRow(
                  entry: entries[index],
                  onRemoveOwned: () => _removeOwned(entries[index]),
                  onRemoveWishlist: () => _removeWishlist(entries[index]),
                ),
              ),
            ),
          if (entries.isEmpty &&
              catalogRows.isEmpty &&
              legacyState != null &&
              !catalogItemsV1.isLoading &&
              !catalogItemsV1.hasError)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyShelf(),
            ),
          if (entries.isEmpty &&
              catalogRows.isEmpty &&
              (shelf.isLoading || catalogItemsV1.isLoading))
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  List<LibraryWorkspaceSource> _filteredEntries(
    List<LibraryWorkspaceSource> entries,
    Set<OwnedItemRef> overdueOwnedRefs,
  ) {
    return switch (filter) {
      _ShelfFilter.all => entries,
      _ShelfFilter.owned =>
        entries.where((entry) => entry.isOwned).toList(growable: false),
      _ShelfFilter.wishlist =>
        entries.where((entry) => entry.isWishlisted).toList(growable: false),
      _ShelfFilter.overdue => entries.where((entry) {
          final ref = entry.ownedSummary?.ref;
          return ref != null && overdueOwnedRefs.contains(ref);
        }).toList(growable: false),
      _ShelfFilter.notes =>
        entries.where((entry) => entry.hasNotes).toList(growable: false),
    };
  }

  List<CatalogItemV1WorkspaceItem> _filteredCatalogItemRows(
    List<CatalogItemV1WorkspaceItem> rows,
  ) =>
      switch (filter) {
        _ShelfFilter.all => rows,
        _ShelfFilter.owned => [
            for (final row in rows)
              if (row.copies
                  .any((copy) => copy.status != OwnedCopyStatusV1.sold))
                row,
          ],
        _ShelfFilter.notes => [
            for (final row in rows)
              if (row.copies
                  .any((copy) => copy.notes?.trim().isNotEmpty == true))
                row,
          ],
        _ShelfFilter.wishlist || _ShelfFilter.overdue => const [],
      };

  Future<void> _removeOwned(LibraryWorkspaceSource entry) async {
    final ownedRef = entry.ownedSummary?.ref;
    if (ownedRef == null) {
      return;
    }
    await ref.read(ownedItemMutationsProvider).removeItem(ownedRef);
    ref.invalidate(shelfProvider);
  }

  Future<void> _removeWishlist(LibraryWorkspaceSource entry) async {
    final catalogRef = entry.catalogRef;
    if (!entry.isWishlisted || catalogRef == null) {
      return;
    }
    await ref
        .read(wishlistMutationsProvider)
        .removeFromWishlist(catalogRef: catalogRef);
    ref.invalidate(shelfProvider);
  }

  Future<void> _showImportExportWizard(
    List<LibraryWorkspaceSource> entries, {
    required int initialIndex,
  }) async {
    final db = ref.read(localDatabaseProvider);
    final cfRepo = CustomFieldRepository(db);
    final cfDefs = await cfRepo.listDefinitions();
    final cfValues = await cfRepo.listAllValues();
    if (!mounted) {
      return;
    }
    final imported = await showDialog<int>(
      context: context,
      builder: (context) => ImportExportWizardDialog(
        entries: entries,
        profiles: collectionCsvKindProfiles,
        initialIndex: initialIndex,
        customFieldDefinitions: cfDefs,
        customFieldValuesByItem: cfValues,
        additionalExports: libraryExportPreviewArtifacts(entries),
      ),
    );
    if (!mounted || imported == null) {
      return;
    }
    ref.invalidate(shelfProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported $imported rows into your collection')),
    );
  }
}
