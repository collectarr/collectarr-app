import 'package:collectarr_app/features/library/kinds/registry/library_kind_capabilities.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/detail/folder_assignment_dialog.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/details/library_detail_section_builder.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';

final activeOwnedCopiesByCatalogItemProvider = FutureProvider.autoDispose
    .family<List<OwnedItemSummary>, (CatalogMediaKind, String)>(
  (ref, params) async {
    final (kind, catalogItemId) = params;
    final database = ref.watch(localDatabaseProvider);
    final reader = collectarrOwnedItemSummaryReaders[kind];
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
    required this.ownedSummary,
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
  final OwnedItemSummary? ownedSummary;
  final List<OwnedItemSummary>? ownedCopies;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final void Function(OwnedItemSummary? ownedItem)? onEdit;
  final ValueChanged<String>? onFilterByValue;

  @override
  ConsumerState<LibraryDetailPage> createState() => _LibraryDetailPageState();
}

class _LibraryDetailPageState extends ConsumerState<LibraryDetailPage> {
  String? _selectedOwnedItemId;
  bool _selectNewestOwnedItem = false;

  @override
  void initState() {
    super.initState();
    _selectedOwnedItemId = widget.ownedSummary?.ref.id.value;
  }

  @override
  void didUpdateWidget(covariant LibraryDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.node.id != oldWidget.item.node.id) {
      _selectedOwnedItemId = widget.ownedSummary?.ref.id.value;
      _selectNewestOwnedItem = false;
      return;
    }
    if (widget.ownedSummary?.ref.id.value !=
            oldWidget.ownedSummary?.ref.id.value &&
        widget.ownedSummary != null &&
        _selectedOwnedItemId == null) {
      _selectedOwnedItemId = widget.ownedSummary!.ref.id.value;
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
            : (widget.ownedSummary == null
                ? const <OwnedItemSummary>[]
                : <OwnedItemSummary>[widget.ownedSummary!]))
        : widget.ownedCopies!;
    final ownedResolution = resolveActiveOwnedSummary(
      ownedCopies,
      fallback: widget.ownedSummary,
      selectedOwnedItemId: _selectedOwnedItemId,
      selectNewest: _selectNewestOwnedItem,
    );
    final activeOwnedSummary = ownedResolution.ownedItem;
    final trackingLifecycles = switch (widget.item.source.catalogRef) {
      final catalogRef? =>
        ref.watch(trackingPersistenceEntriesByCatalogRefProvider)[catalogRef] ??
            const <TrackingLifecycle>[],
      _ => const <TrackingLifecycle>[],
    };
    final activeTrackingLifecycle = resolveActiveTrackingLifecycle(
      trackingLifecycles,
      activeOwnedSummary,
    );
    final isOwned = ownedCopies.isNotEmpty ||
        activeOwnedSummary != null ||
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
                activeOwnedItem: activeOwnedSummary,
                ownedCopies: ownedCopies,
                selectedOwnedItemId: activeOwnedSummary?.ref.id.value,
                accent: widget.accent,
                onSelectOwnedItem: ownedCopies.length < 2
                    ? null
                    : (value) => setState(() {
                          _selectedOwnedItemId = value;
                          _selectNewestOwnedItem = false;
                        }),
                onEdit: widget.onEdit == null
                    ? null
                    : () => widget.onEdit!(activeOwnedSummary),
                onToggleOwned: isOwned
                    ? activeOwnedSummary == null
                        ? widget.onRemoveOwned
                        : () => _removeOwnedCopy(activeOwnedSummary)
                    : widget.onAddOwned,
                onAddCopy: isOwned
                    ? () => _addOwnedCopy(
                          widget.item,
                          ownedItem: activeOwnedSummary,
                        )
                    : null,
                onToggleWishlist: widget.item.source.isWishlisted
                    ? widget.onRemoveWishlist
                    : widget.onAddWishlist,
                onSearchOnEbay: () => _searchOnEbay(widget.item),
                onAssignFolders: activeOwnedSummary == null
                    ? null
                    : () {
                        final db = ref.read(localDatabaseProvider);
                        showFolderAssignmentDialog(
                          context: context,
                          db: db,
                          ownedRef: activeOwnedSummary.ref,
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
                  ownedItem: activeOwnedSummary,
                  ownedCopies: ownedCopies,
                  accent: widget.accent,
                  isOwned: isOwned,
                ),
                sections: buildLibraryDetailSectionSpecs(
                  context: context,
                  type: widget.type,
                  item: widget.item,
                  accent: widget.accent,
                  ownedSummary: activeOwnedSummary,
                  trackingLifecycle: activeTrackingLifecycle,
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
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final query = adapter?.itemNumber != null
        ? '${dto.title} #${adapter!.itemNumber}'
        : dto.title;
    await launchEbaySearch(query);
  }

  Future<void> _addOwnedCopy(
    LibraryProjectionView item, {
    OwnedItemSummary? ownedItem,
  }) async {
    final targetRef = resolveLibraryMutationTargetFromSummary(
      item: item,
      ownedItem: ownedItem,
    );
    final catalogItem = item.source.catalogTransport;
    if (catalogItem == null) {
      return;
    }
    await ref.read(collectionCommandCoordinatorProvider).addOwnedItem(
          widget.type.add.buildCommand(
            catalogItem,
            const LibraryAddCommonDraft(),
            widget.type.add.createInitialDraft(),
            targetRef: catalogRefForLibrarySelection(
              catalogItem.catalogRef,
              editionId: catalogRefEditionId(targetRef),
              variantId: catalogRefVariantId(targetRef),
              bundleReleaseId: catalogRefBundleReleaseId(targetRef),
            ),
          ),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedOwnedItemId = null;
      _selectNewestOwnedItem = true;
    });
  }

  Future<void> _removeOwnedCopy(OwnedItemSummary item) async {
    await ref.read(ownedItemMutationsProvider).removeItem(item.ref);
    if (!mounted) {
      return;
    }
    setState(() {
      if (_selectedOwnedItemId == item.ref.id.value) {
        _selectedOwnedItemId = null;
      }
      _selectNewestOwnedItem = false;
    });
  }
}

class _LibraryDetailToolbar extends StatelessWidget {
  const _LibraryDetailToolbar({
    required this.type,
    required this.item,
    required this.activeOwnedItem,
    required this.ownedCopies,
    required this.selectedOwnedItemId,
    required this.accent,
    required this.onSelectOwnedItem,
    required this.onEdit,
    required this.onToggleOwned,
    required this.onAddCopy,
    required this.onToggleWishlist,
    required this.onSearchOnEbay,
    required this.onAssignFolders,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final OwnedItemSummary? activeOwnedItem;
  final List<OwnedItemSummary> ownedCopies;
  final String? selectedOwnedItemId;
  final Color accent;
  final ValueChanged<String?>? onSelectOwnedItem;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleOwned;
  final VoidCallback? onAddCopy;
  final VoidCallback? onToggleWishlist;
  final VoidCallback onSearchOnEbay;
  final VoidCallback? onAssignFolders;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final hasCopyMenu = ownedCopies.length > 1 && onSelectOwnedItem != null;
    final isOwned = ownedCopies.isNotEmpty ||
        activeOwnedItem != null ||
        item.source.isOwned;
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;

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
                LibraryDenseMenuButton<String>(
                  key: const ValueKey('detail-toolbar-copy-menu'),
                  label: 'Copy',
                  icon: Icons.copy_all_outlined,
                  tone: LibraryDenseButtonTone.subtle,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  entries: [
                    for (var index = 0; index < ownedCopies.length; index += 1)
                      LibraryDenseMenuEntry<String>(
                        value: ownedCopies[index].ref.id.value,
                        label: ownedCopies[index].ref.id.value ==
                                selectedOwnedItemId
                            ? 'Viewing ${buildOwnedCopySummaryLabel(ownedCopies[index], index)}'
                            : buildOwnedCopySummaryLabel(
                                ownedCopies[index],
                                index,
                              ),
                        icon: ownedCopies[index].ref.id.value ==
                                selectedOwnedItemId
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                  ],
                  onSelected: (value) => onSelectOwnedItem?.call(value),
                ),
              ],
              if (adapter?.identifierCode?.trim().isNotEmpty == true) ...[
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
