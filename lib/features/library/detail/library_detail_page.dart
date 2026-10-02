import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/detail/folder_assignment_dialog.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/details/library_detail_section_builder.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';

final activeOwnedCopiesByCatalogItemProvider = FutureProvider.autoDispose
    .family<List<CollectionItemSummary>, (CatalogMediaKind, String)>(
  (ref, params) async {
    final (kind, catalogItemId) = params;
    final database = ref.watch(localDatabaseProvider);
    final reader = libraryCollectionItemSummaryReadersByKind[kind];
    if (reader == null) return const [];
    final items = await reader(database);
    return items
        .where((i) => i.catalogRef?.id == catalogItemId)
        .toList(growable: false)
      ..sort(
        (a, b) => (b.updatedAt ?? DateTime(0)).compareTo(
          a.updatedAt ?? DateTime(0),
        ),
      );
  },
);

class LibraryDetailPage extends ConsumerStatefulWidget {
  const LibraryDetailPage({
    super.key,
    required this.type,
    required this.item,
    required this.collectionItemSummary,
    this.ownedCopies,
    required this.accent,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
    this.onFilterByValue,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final CollectionItemSummary? collectionItemSummary;
  final List<CollectionItemSummary>? ownedCopies;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final void Function(CollectionItemSummary? collectionItem)? onEdit;
  final ValueChanged<String>? onFilterByValue;

  @override
  ConsumerState<LibraryDetailPage> createState() => _LibraryDetailPageState();
}

class _LibraryDetailPageState extends ConsumerState<LibraryDetailPage> {
  CollectionItemRef? _selectedCollectionItemRef;
  bool _selectNewestCollectionItem = false;

  @override
  void initState() {
    super.initState();
    _selectedCollectionItemRef = widget.collectionItemSummary?.ref;
  }

  @override
  void didUpdateWidget(covariant LibraryDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.node.id != oldWidget.item.node.id) {
      _selectedCollectionItemRef = widget.collectionItemSummary?.ref;
      _selectNewestCollectionItem = false;
      return;
    }
    if (widget.collectionItemSummary?.ref != oldWidget.collectionItemSummary?.ref &&
        widget.collectionItemSummary != null &&
        _selectedCollectionItemRef == null) {
      _selectedCollectionItemRef = widget.collectionItemSummary!.ref;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogItemId = widget.item.source.catalogRef?.rootId ??
        widget.item.source.catalogRef?.id;
    final loadedCopies = catalogItemId == null
        ? null
        : ref
            .watch(
              activeOwnedCopiesByCatalogItemProvider(
                (widget.type.kind, catalogItemId),
              ),
            )
            .asData
            ?.value;

    final ownedCopies = widget.ownedCopies == null
        ? (loadedCopies != null && loadedCopies.isNotEmpty
            ? loadedCopies
            : (widget.collectionItemSummary == null
                ? const <CollectionItemSummary>[]
                : <CollectionItemSummary>[widget.collectionItemSummary!]))
        : widget.ownedCopies!;
    final ownedResolution = resolveActiveCollectionItemSummary(
      ownedCopies,
      fallback: widget.collectionItemSummary,
      selectedCollectionItemRef: _selectedCollectionItemRef,
      selectNewest: _selectNewestCollectionItem,
    );
    final activeCollectionItemSummary = ownedResolution.collectionItem;
    final activeTrackingSummary = resolveActiveTrackingSummary(
      libraryTrackingSummariesForItem(
        widget.type,
        widget.item,
        ref.watch(trackingSummariesByCatalogRefProvider),
        collectionItem: activeCollectionItemSummary,
      ),
      activeCollectionItemSummary,
    );
    final isOwned = ownedCopies.isNotEmpty ||
        activeCollectionItemSummary != null ||
        widget.item.source.isOwned;
    final palette = appPalette(context);
    return Theme(
      data: buildLibraryTheme(palette: palette),
      child: Scaffold(
        backgroundColor: palette.canvas,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: _LibraryDetailToolbar(
                type: widget.type,
                item: widget.item,
                activeCollectionItem: activeCollectionItemSummary,
                ownedCopies: ownedCopies,
                selectedCollectionItemRef: activeCollectionItemSummary?.ref,
                accent: widget.accent,
                onSelectCollectionItem: ownedCopies.length < 2
                    ? null
                    : (value) => setState(() {
                          _selectedCollectionItemRef = value;
                          _selectNewestCollectionItem = false;
                        }),
                onEdit: widget.onEdit == null
                    ? null
                    : () => widget.onEdit!(activeCollectionItemSummary),
                onToggleOwned: isOwned
                    ? activeCollectionItemSummary == null
                        ? widget.onRemoveOwned
                        : () => _removeCollectionItem(activeCollectionItemSummary)
                    : widget.onAddOwned,
                onAddCopy: isOwned && widget.onAddOwned != null
                    ? () => _addCollectionItem(
                          widget.item,
                        )
                    : null,
                onToggleWishlist: widget.item.source.isWishlisted
                    ? widget.onRemoveWishlist
                    : widget.onAddWishlist,
                onSearchOnEbay: () => _searchOnEbay(widget.item),
                onAssignFolders: activeCollectionItemSummary == null
                    ? null
                    : () {
                        final db = ref.read(localDatabaseProvider);
                        showFolderAssignmentDialog(
                          context: context,
                          db: db,
                          collectionItemRef: activeCollectionItemSummary.ref,
                        );
                      },
              ),
            ),
            Expanded(
              child: LibraryDetailPanelScaffold(
                accent: widget.accent,
                variant: LibraryDetailPanelVariant.fullPage,
                hero: LibraryDetailHero(
                  type: widget.type,
                  item: widget.item,
                  collectionItem: activeCollectionItemSummary,
                  ownedCopies: ownedCopies,
                  accent: widget.accent,
                  isOwned: isOwned,
                ),
                sections: buildLibraryDetailSectionSpecs(
                  context: context,
                  type: widget.type,
                  item: widget.item,
                  accent: widget.accent,
                  collectionItemSummary: activeCollectionItemSummary,
                  trackingSummary: activeTrackingSummary,
                  ownedCopies: ownedCopies,
                  onFilterByValue: widget.onFilterByValue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchOnEbay(LibraryProjectionView item) async {
    final dto = item.dto;
    final itemNumber = libraryCardPresentationForEntry(item).itemNumber;
    final query = itemNumber != null
        ? '${dto.primaryLabel} #$itemNumber'
        : dto.primaryLabel;
    await launchEbaySearch(query);
  }

  Future<void> _addCollectionItem(
    LibraryProjectionView item,
  ) async {
    if (!libraryOwnershipForKind(widget.type.kind).canCreateCopyAt(item.node)) {
      return;
    }
    final catalogRef = item.source.catalogRef;
    if (catalogRef == null) {
      return;
    }
    final catalogItem = await CatalogSnapshotRepository(
      ref.read(localDatabaseProvider),
    ).findCandidateByRef(catalogRef.rootScope);
    if (catalogItem == null) {
      return;
    }
    await ref.read(collectionCommandCoordinatorProvider).addCollectionItem(
          libraryAddForKind(widget.type.kind).buildCommand(
            catalogItem,
            const LibraryAddCommonDraft(),
            libraryAddForKind(widget.type.kind).createInitialDraft(),
          ),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedCollectionItemRef = null;
      _selectNewestCollectionItem = true;
    });
  }

  Future<void> _removeCollectionItem(CollectionItemSummary item) async {
    await ref.read(collectionItemMutationsProvider).removeItem(item.ref);
    if (!mounted) {
      return;
    }
    setState(() {
      if (_selectedCollectionItemRef == item.ref) {
        _selectedCollectionItemRef = null;
      }
      _selectNewestCollectionItem = false;
    });
  }
}

class _LibraryDetailToolbar extends StatelessWidget {
  const _LibraryDetailToolbar({
    required this.type,
    required this.item,
    required this.activeCollectionItem,
    required this.ownedCopies,
    required this.selectedCollectionItemRef,
    required this.accent,
    required this.onSelectCollectionItem,
    required this.onEdit,
    required this.onToggleOwned,
    required this.onAddCopy,
    required this.onToggleWishlist,
    required this.onSearchOnEbay,
    required this.onAssignFolders,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final CollectionItemSummary? activeCollectionItem;
  final List<CollectionItemSummary> ownedCopies;
  final CollectionItemRef? selectedCollectionItemRef;
  final Color accent;
  final ValueChanged<CollectionItemRef?>? onSelectCollectionItem;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleOwned;
  final VoidCallback? onAddCopy;
  final VoidCallback? onToggleWishlist;
  final VoidCallback onSearchOnEbay;
  final VoidCallback? onAssignFolders;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final hasCopyMenu = ownedCopies.length > 1 && onSelectCollectionItem != null;
    final isOwned = ownedCopies.isNotEmpty ||
        activeCollectionItem != null ||
        item.source.isOwned;
    final identifierCode = libraryCardPresentationForEntry(item).identifierCode;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          bottom: BorderSide(
            color: palette.divider,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 3),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (Navigator.of(context).canPop())
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: LibraryDenseIconButton(
                    tooltip: 'Back',
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.of(context).pop(),
                    tone: LibraryDenseButtonTone.subtle,
                  ),
                ),
              LibraryDenseButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                onPressed: onEdit,
                tone: LibraryDenseButtonTone.subtle,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              ),
              const SizedBox(width: 4),
              LibraryDenseButton(
                label: isOwned ? 'Remove' : 'Collect',
                icon: isOwned
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                onPressed: onToggleOwned,
                tone: LibraryDenseButtonTone.subtle,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              ),
              if (hasCopyMenu) ...[
                const SizedBox(width: 4),
                LibraryDenseMenuButton<CollectionItemRef>(
                  key: const ValueKey('detail-toolbar-copy-menu'),
                  label: 'Copy',
                  icon: Icons.copy_all_outlined,
                  tone: LibraryDenseButtonTone.subtle,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  entries: [
                    for (var index = 0; index < ownedCopies.length; index += 1)
                      LibraryDenseMenuEntry<CollectionItemRef>(
                        value: ownedCopies[index].ref,
                        label: ownedCopies[index].ref == selectedCollectionItemRef
                            ? 'Viewing ${buildCollectionItemSummaryLabel(ownedCopies[index], index)}'
                            : buildCollectionItemSummaryLabel(
                                ownedCopies[index],
                                index,
                              ),
                        icon: ownedCopies[index].ref == selectedCollectionItemRef
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                  ],
                  onSelected: (value) => onSelectCollectionItem?.call(value),
                ),
              ],
              if (identifierCode?.trim().isNotEmpty == true) ...[
                const SizedBox(width: 4),
                LibraryDenseButton(
                  label: 'eBay',
                  icon: Icons.storefront_outlined,
                  onPressed: onSearchOnEbay,
                  tone: LibraryDenseButtonTone.subtle,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                ),
              ],
              const SizedBox(width: 4),
              LibraryDenseMenuButton<String>(
                key: const ValueKey('detail-toolbar-more-menu'),
                label: 'More',
                icon: Icons.more_vert,
                tone: LibraryDenseButtonTone.subtle,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                entries: [
                  if (isOwned && onAddCopy != null)
                    const LibraryDenseMenuEntry<String>(
                      value: 'add-copy',
                      label: 'Add copy',
                      icon: Icons.copy_outlined,
                    ),
                  LibraryDenseMenuEntry<String>(
                    value: item.source.isWishlisted ? 'unwishlist' : 'wishlist',
                    label: item.source.isWishlisted
                        ? 'Remove from wishlist'
                        : 'Move to wishlist',
                    icon: item.source.isWishlisted
                        ? Icons.star
                        : Icons.star_border,
                  ),
                  if (onAssignFolders != null)
                    const LibraryDenseMenuEntry<String>(
                      value: 'folders',
                      label: 'Assign to folders',
                      icon: Icons.folder_outlined,
                    ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'add-copy':
                      onAddCopy?.call();
                    case 'wishlist':
                    case 'unwishlist':
                      onToggleWishlist?.call();
                    case 'folders':
                      onAssignFolders?.call();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
