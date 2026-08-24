import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/detail/folder_assignment_dialog.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/details/library_detail_section_builder.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryDetailPage extends ConsumerStatefulWidget {
  const LibraryDetailPage({
    super.key,
    required this.type,
    required this.item,
    required this.ownedItem,
    required this.accent,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
    this.onFilterByValue,
  });

  final LibraryTypeConfig type;
  final LibraryProjectionRuntime item;
  final OwnedItem? ownedItem;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final void Function(OwnedItem? ownedItem)? onEdit;
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
    _selectedOwnedItemId = widget.ownedItem?.id;
  }

  @override
  void didUpdateWidget(covariant LibraryDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.node.id != oldWidget.item.node.id) {
      _selectedOwnedItemId = widget.ownedItem?.id;
      _selectNewestOwnedItem = false;
      return;
    }
    if (widget.ownedItem?.id != oldWidget.ownedItem?.id &&
        widget.ownedItem != null &&
        _selectedOwnedItemId == null) {
      _selectedOwnedItemId = widget.ownedItem!.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownedCopies = ref.watch(collectionProvider).maybeWhen(
          data: (items) {
            final matches = items
                .where((item) =>
                    !item.isDeleted &&
                    item.itemId == widget.item.source.catalogItem?.id)
                .toList(growable: false)
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            return matches;
          },
          orElse: () => widget.ownedItem == null
              ? const <OwnedItem>[]
              : <OwnedItem>[widget.ownedItem!],
        );
    final ownedResolution = resolveActiveOwnedItem(
      ownedCopies,
      fallback: widget.ownedItem,
      selectedOwnedItemId: _selectedOwnedItemId,
      selectNewest: _selectNewestOwnedItem,
    );
    final activeOwnedItem = ownedResolution.ownedItem;
    final trackingEntries = ref.watch(trackingEntriesByCatalogItemProvider)[
            widget.item.source.catalogItem?.id] ??
        const <TrackingEntry>[];
    final activeTrackingEntry = resolveActiveTrackingEntry(
      trackingEntries,
      activeOwnedItem,
    );
    final isOwned = ownedCopies.isNotEmpty ||
        activeOwnedItem != null ||
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
                activeOwnedItem: activeOwnedItem,
                ownedCopies: ownedCopies,
                selectedOwnedItemId: activeOwnedItem?.id,
                accent: widget.accent,
                onSelectOwnedItem: ownedCopies.length < 2
                    ? null
                    : (value) => setState(() {
                          _selectedOwnedItemId = value;
                          _selectNewestOwnedItem = false;
                        }),
                onEdit: widget.onEdit == null
                    ? null
                    : () => widget.onEdit!(activeOwnedItem),
                onToggleOwned: isOwned
                    ? activeOwnedItem == null
                        ? widget.onRemoveOwned
                        : () => _removeOwnedCopy(activeOwnedItem)
                    : widget.onAddOwned,
                onAddCopy: isOwned
                    ? () => _addOwnedCopy(
                          widget.item,
                          ownedItem: activeOwnedItem,
                        )
                    : null,
                onToggleWishlist: widget.item.source.isWishlisted
                    ? widget.onRemoveWishlist
                    : widget.onAddWishlist,
                onSearchOnEbay: () => _searchOnEbay(widget.item),
                onAssignFolders: activeOwnedItem == null
                    ? null
                    : () {
                        final db = ref.read(localDatabaseProvider);
                        showFolderAssignmentDialog(
                          context: context,
                          db: db,
                          ownedItemId: activeOwnedItem.id,
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
                  ownedItem: activeOwnedItem,
                  ownedCopies: ownedCopies,
                  accent: widget.accent,
                  isOwned: isOwned,
                ),
                sections: buildLibraryDetailSectionSpecs(
                  context: context,
                  type: widget.type,
                  item: widget.item,
                  accent: widget.accent,
                  ownedItem: activeOwnedItem,
                  trackingEntry: activeTrackingEntry,
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

  Future<void> _searchOnEbay(LibraryProjectionRuntime item) async {
    final dto = item.dto;
    final query =
        dto.itemNumber != null ? '${dto.title} #${dto.itemNumber}' : dto.title;
    await launchEbaySearch(query);
  }

  Future<void> _addOwnedCopy(
    LibraryProjectionRuntime item, {
    OwnedItem? ownedItem,
  }) async {
    final anchor = resolveLibraryMutationAnchor(
      item: item,
      ownedItem: ownedItem,
    );
    await ref.read(collectionCommandCoordinatorProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: CatalogEntityRef(
              kind: widget.type.workspace.kind.apiValue,
              entityType: CatalogEntityType.work,
              id: item.node.titleItemId,
            ),
            common: OwnedItemCommonDraft(
              editionId: anchor.editionId,
              variantId: anchor.variantId,
              bundleReleaseId: anchor.bundleReleaseId,
            ),
            details: defaultDetailsDraftForKind(widget.type.workspace.kind),
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

  Future<void> _removeOwnedCopy(OwnedItem item) async {
    await ref.read(ownedItemMutationsProvider).removeItem(item);
    if (!mounted) {
      return;
    }
    setState(() {
      if (_selectedOwnedItemId == item.id) {
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

  final LibraryTypeConfig type;
  final LibraryProjectionRuntime item;
  final OwnedItem? activeOwnedItem;
  final List<OwnedItem> ownedCopies;
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
                        value: ownedCopies[index].id,
                        label: ownedCopies[index].id == selectedOwnedItemId
                            ? 'Viewing ${buildOwnedCopyLabel(ownedCopies[index], item.source.catalogItem?.toCatalogItem().editions ?? const [], index)}'
                            : buildOwnedCopyLabel(
                                ownedCopies[index],
                                item.source.catalogItem
                                        ?.toCatalogItem()
                                        .editions ??
                                    const [],
                                index,
                              ),
                        icon: ownedCopies[index].id == selectedOwnedItemId
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                  ],
                  onSelected: (value) => onSelectOwnedItem?.call(value),
                ),
              ],
              if (item.dto.barcode?.trim().isNotEmpty == true) ...[
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
