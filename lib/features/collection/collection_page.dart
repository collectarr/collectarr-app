import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv.dart';
import 'package:collectarr_app/features/collection/csv/import_export/import_export_wizard.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/generic/skeleton_grid.dart';
import 'package:collectarr_app/ui/error_card.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/shelf_volumes_provider.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:dio/dio.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'collection_page_import.dart';
part 'collection_page_shelf.dart';

enum _ShelfFilter { all, owned, wishlist, overdue, missingGrade, notes }

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
    final overdueOwnedItemIds = ref.watch(overdueLoanOwnedItemIdsProvider)
        .maybeWhen(data: (value) => value, orElse: () => const <String>{});
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
            tooltip: 'Import collection',
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
            tooltip: 'Export collection',
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
      body: shelf.when(
        data: (state) {
          final entries = _filteredEntries(state.entries, overdueOwnedItemIds);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ShelfHeader(
                  state: state,
                  filter: filter,
                  overdueCount: overdueOwnedItemIds.length,
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
        error: (error, stackTrace) => AppErrorCard(
          message: error.toString(),
        ),
        loading: () => const SkeletonGrid(),
      ),
    );
  }

  List<ShelfEntry> _filteredEntries(
    List<ShelfEntry> entries,
    Set<String> overdueOwnedItemIds,
  ) {
    return switch (filter) {
      _ShelfFilter.all => entries,
      _ShelfFilter.owned =>
        entries.where((entry) => entry.isOwned).toList(growable: false),
      _ShelfFilter.wishlist =>
        entries.where((entry) => entry.isWishlisted).toList(growable: false),
      _ShelfFilter.overdue => entries
          .where((entry) => overdueOwnedItemIds.contains(entry.ownedItem?.id))
          .toList(growable: false),
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

  Future<void> _showImportExportWizard(
    List<ShelfEntry> entries, {
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
        initialIndex: initialIndex,
        customFieldDefinitions: cfDefs,
        customFieldValuesByItem: cfValues,
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

