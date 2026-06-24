import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/bundles/bundle_release_contents_section.dart';
import 'package:collectarr_app/features/library/bundles/item_bundle_release_browser_section.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/detail/activity_timeline_section.dart';
import 'package:collectarr_app/features/library/detail/folder_assignment_dialog.dart';
import 'package:collectarr_app/features/library/detail/library_detail_catalog_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_collection_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/detail/metadata_corrections_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_trailers_section.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_shared_sections.dart';
import 'package:collectarr_app/features/library/kinds/video/watch_history_section.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryDetailPage extends ConsumerStatefulWidget {
  const LibraryDetailPage({
    super.key,
    required this.type,
    required this.entry,
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
  final LibraryWorkspaceEntry entry;
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
    if (widget.entry.id != oldWidget.entry.id) {
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
                .where((item) => !item.isDeleted && item.itemId == widget.entry.id)
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
    final trackingEntries =
        ref.watch(trackingEntriesByCatalogItemProvider)[widget.entry.id] ??
            const <TrackingEntry>[];
    final activeTrackingEntry = resolveActiveTrackingEntry(
      trackingEntries,
      activeOwnedItem,
    );
    final activeBundleReleaseId =
        activeOwnedItem?.bundleReleaseId ?? widget.entry.referenceBundleReleaseId;
    final isOwned = ownedCopies.isNotEmpty || activeOwnedItem != null || widget.entry.isOwned;
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
                entry: widget.entry,
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
                          widget.entry,
                          ownedItem: activeOwnedItem,
                        )
                    : null,
                onToggleWishlist: widget.entry.isWishlisted
                    ? widget.onRemoveWishlist
                    : widget.onAddWishlist,
                onSearchOnEbay: () => _searchOnEbay(widget.entry),
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                children: [
                  LibraryDetailHero(
                    type: widget.type,
                    entry: widget.entry,
                    ownedItem: activeOwnedItem,
                    ownedCopies: ownedCopies,
                    accent: widget.accent,
                    isOwned: isOwned,
                  ),
                  const SizedBox(height: 10),
                  if (activeOwnedItem != null || activeTrackingEntry != null) ...[
                    LibraryDetailPersonalSection(
                      entry: widget.entry,
                      ownedItem: activeOwnedItem,
                      ownedCopies: ownedCopies,
                      trackingEntry: activeTrackingEntry,
                      accent: widget.accent,
                    ),
                    ...buildLibraryInspectorEditorSections(
                      type: widget.type,
                      entry: widget.entry,
                      accent: widget.accent,
                      ownedItem: activeOwnedItem,
                      trackingEntry: activeTrackingEntry,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (activeBundleReleaseId != null) ...[
                    BundleReleaseContentsSection(
                      bundleReleaseId: activeBundleReleaseId,
                      accent: widget.accent,
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    ItemBundleReleaseBrowserSection(
                      itemId: widget.entry.titleItemId ?? widget.entry.id,
                      accent: widget.accent,
                    ),
                    const SizedBox(height: 12),
                  ],
                  ...buildLibraryDetailCatalogSections(
                    context: context,
                    type: widget.type,
                    entry: widget.entry,
                    accent: widget.accent,
                    onFilterByValue: widget.onFilterByValue,
                  ),
                  LibraryDetailTrailersSection(
                    trailerUrls: widget.entry.trailerUrls,
                    accent: widget.accent,
                  ),
                  ...buildLibraryInspectorKindSections(
                    context: context,
                    type: widget.type,
                    entry: widget.entry,
                    accent: widget.accent,
                  ),
                  LibraryDetailProvenanceSection(
                    type: widget.type,
                    entry: widget.entry,
                    accent: widget.accent,
                  ),
                  LibraryDetailMetadataHealthSection(
                    type: widget.type,
                    entry: widget.entry,
                    accent: widget.accent,
                  ),
                  LibraryDetailCoverStatusSection(
                    entry: widget.entry,
                    accent: widget.accent,
                  ),
                  WatchHistorySection(
                    itemId: widget.entry.id,
                    accent: widget.accent,
                    labels: sessionHistoryLabelsForKind(
                      widget.type.workspace.kind.apiValue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ActivityTimelineSection(
                    itemId: widget.entry.id,
                    ownedItemIds: ownedCopies.map((c) => c.id).toList(),
                    accent: widget.accent,
                  ),
                  MetadataCorrectionsSection(
                    itemId: widget.entry.id,
                    accent: widget.accent,
                  ),
                  LibraryDetailProviderSection(
                    type: widget.type,
                    accent: widget.accent,
                  ),
                  LibraryDetailLocalSnapshotSection(
                    entry: widget.entry,
                    ownedItem: activeOwnedItem,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchOnEbay(LibraryWorkspaceEntry entry) async {
    final query = entry.itemNumber != null
        ? '${entry.resolvedTitle} #${entry.itemNumber}'
        : entry.resolvedTitle;
    await launchEbaySearch(query);
  }

  Future<void> _addOwnedCopy(
    LibraryWorkspaceEntry entry, {
    OwnedItem? ownedItem,
  }) async {
    final anchor = resolveLibraryMutationAnchor(
      entry: entry,
      ownedItem: ownedItem,
    );
    await ref.read(collectionMutationsProvider).addItem(
          entry.id,
          anchorType: anchor.anchorType,
          editionId: anchor.editionId,
          variantId: anchor.variantId,
          bundleReleaseId: anchor.bundleReleaseId,
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
    await ref.read(collectionMutationsProvider).removeItem(item);
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
    required this.entry,
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
  final LibraryWorkspaceEntry entry;
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
    final isOwned = ownedCopies.isNotEmpty || activeOwnedItem != null || entry.isOwned;

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
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  entries: [
                    for (var index = 0; index < ownedCopies.length; index += 1)
                      LibraryDenseMenuEntry<String>(
                        value: ownedCopies[index].id,
                        label: ownedCopies[index].id == selectedOwnedItemId
                            ? 'Viewing ${buildOwnedCopyLabel(ownedCopies[index], entry.editions, index)}'
                            : buildOwnedCopyLabel(
                                ownedCopies[index],
                                entry.editions,
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
              if (entry.barcode?.trim().isNotEmpty == true) ...[
                const SizedBox(width: 4),
                LibraryDenseButton(
                  label: 'eBay',
                  icon: Icons.storefront_outlined,
                  onPressed: onSearchOnEbay,
                  tone: LibraryDenseButtonTone.subtle,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
                    value: entry.isWishlisted ? 'unwishlist' : 'wishlist',
                    label: entry.isWishlisted ? 'Remove from wishlist' : 'Move to wishlist',
                    icon: entry.isWishlisted ? Icons.star : Icons.star_border,
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
