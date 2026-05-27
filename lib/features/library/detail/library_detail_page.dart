import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/bundles/bundle_release_contents_section.dart';
import 'package:collectarr_app/features/library/bundles/item_bundle_release_browser_section.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/detail/activity_timeline_section.dart';
import 'package:collectarr_app/features/library/detail/folder_assignment_dialog.dart';
import 'package:collectarr_app/features/library/detail/library_detail_actions.dart';
import 'package:collectarr_app/features/library/detail/library_detail_catalog_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_collection_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/detail/library_detail_trailers_section.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/kinds/shared/metadata_corrections_section.dart';
import 'package:collectarr_app/features/library/kinds/shared/watch_history_section.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Theme(
      data: buildLibraryTheme(palette: appPalette(context)),
      child: Scaffold(
        backgroundColor: appPalette(context).canvas,
        appBar: AppBar(
          backgroundColor: widget.accent,
          foregroundColor: Colors.white,
          title: Text(widget.entry.resolvedTitle),
          actions: [
            IconButton(
              tooltip: 'Edit metadata and collection fields',
              onPressed: widget.onEdit == null
                  ? null
                  : () => widget.onEdit!(activeOwnedItem),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Search on eBay',
              onPressed: () => _searchOnEbay(widget.entry),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
            if (activeOwnedItem != null)
              IconButton(
                tooltip: 'Assign to folders',
                onPressed: () {
                  final db = ref.read(localDatabaseProvider);
                  showFolderAssignmentDialog(
                    context: context,
                    db: db,
                    ownedItemId: activeOwnedItem.id,
                  );
                },
                icon: const Icon(Icons.folder_outlined),
              ),
            IconButton(
              tooltip: widget.entry.isWishlisted
                  ? 'Remove from wishlist'
                  : 'Move to wishlist',
              onPressed: widget.entry.isWishlisted
                  ? widget.onRemoveWishlist
                  : widget.onAddWishlist,
              icon: Icon(
                widget.entry.isWishlisted ? Icons.star : Icons.star_border,
              ),
            ),
            if (isOwned)
              IconButton(
                tooltip: 'Add another copy',
                onPressed: () => _addOwnedCopy(
                  widget.entry,
                  ownedItem: activeOwnedItem,
                ),
                icon: const Icon(Icons.copy_all_outlined),
              ),
            IconButton(
              tooltip: isOwned
                  ? 'Remove selected copy'
                  : 'Add to collection',
              onPressed: isOwned
                  ? activeOwnedItem == null
                      ? widget.onRemoveOwned
                      : () => _removeOwnedCopy(activeOwnedItem)
                  : widget.onAddOwned,
              icon: Icon(
                isOwned
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LibraryDetailHero(
              type: widget.type,
              entry: widget.entry,
              ownedItem: activeOwnedItem,
              accent: widget.accent,
              isOwned: isOwned,
            ),
            const SizedBox(height: 12),
            LibraryDetailActionStrip(
              type: widget.type,
              entry: widget.entry,
              activeOwnedItem: activeOwnedItem,
              ownedCopies: ownedCopies,
              selectedOwnedItemId: activeOwnedItem?.id,
              onSelectOwnedItem: ownedCopies.length < 2
                  ? null
                  : (value) => setState(() {
                    _selectedOwnedItemId = value;
                    _selectNewestOwnedItem = false;
                  }),
              onAddOwned: isOwned
                  ? () => _addOwnedCopy(
                        widget.entry,
                        ownedItem: activeOwnedItem,
                      )
                  : widget.onAddOwned,
              onRemoveOwned: activeOwnedItem == null
                  ? widget.onRemoveOwned
                  : () => _removeOwnedCopy(activeOwnedItem),
              onAddWishlist: widget.onAddWishlist,
              onRemoveWishlist: widget.onRemoveWishlist,
              onEdit: widget.onEdit == null
                  ? null
                  : () => widget.onEdit!(activeOwnedItem),
            ),
            const SizedBox(height: 16),
            LibraryDetailStatsBar(
              entry: widget.entry,
              ownedItem: activeOwnedItem,
              ownedCopies: ownedCopies,
            ),
            const SizedBox(height: 16),
            if (activeBundleReleaseId != null) ...[
              BundleReleaseContentsSection(
                bundleReleaseId: activeBundleReleaseId,
                accent: widget.accent,
              ),
              const SizedBox(height: 16),
            ] else ...[
              ItemBundleReleaseBrowserSection(
                itemId: widget.entry.titleItemId ?? widget.entry.id,
                accent: widget.accent,
              ),
              const SizedBox(height: 16),
            ],
            LibraryDetailMetadataSection(
              type: widget.type,
              entry: widget.entry,
              accent: widget.accent,
              onFilterByValue: widget.onFilterByValue,
            ),
            LibraryDetailContextSection(
              type: widget.type,
              entry: widget.entry,
              accent: widget.accent,
              onFilterByValue: widget.onFilterByValue,
            ),
            LibraryDetailCreditsSection(
              type: widget.type,
              entry: widget.entry,
              accent: widget.accent,
              onFilterByValue: widget.onFilterByValue,
            ),
            LibraryDetailTrailersSection(
              trailerUrls: widget.entry.trailerUrls,
              accent: widget.accent,
            ),
            ...widget.type.presentation.builder.buildInspectorSections(
              context: context,
              entry: widget.entry,
              accent: widget.accent,
            ),
            LibraryDetailProvenanceSection(
              type: widget.type,
              entry: widget.entry,
              accent: widget.accent,
            ),
            LibraryDetailMetadataHealthSection(
              entry: widget.entry,
              accent: widget.accent,
            ),
            LibraryDetailCoverStatusSection(
              entry: widget.entry,
              accent: widget.accent,
            ),
            LibraryDetailPersonalSection(
              entry: widget.entry,
              ownedItem: activeOwnedItem,
              trackingEntry: activeTrackingEntry,
              accent: widget.accent,
            ),
            if (activeOwnedItem != null)
              InspectorPersonalDetailsEditor(
                ownedItem: activeOwnedItem,
                accent: widget.accent,
              ),
            if (activeTrackingEntry != null)
              InspectorTrackingDetailsEditor(
                itemId: widget.entry.id,
                trackingEntry: activeTrackingEntry,
                profile: widget.type.trackingProfile,
                editions: widget.entry.editions,
                accent: widget.accent,
              ),
            WatchHistorySection(
              itemId: widget.entry.id,
              accent: widget.accent,
            ),
            const SizedBox(height: 16),
            ActivityTimelineSection(
              itemId: widget.entry.id,
              ownedItemIds: ownedCopies.map((c) => c.id).toList(),
              accent: widget.accent,
            ),
            MetadataCorrectionsSection(
              itemId: widget.entry.id,
              accent: widget.accent,
            ),
            LibraryDetailProviderSection(type: widget.type, accent: widget.accent),
            LibraryDetailLocalSnapshotSection(
              entry: widget.entry,
              ownedItem: activeOwnedItem,
            ),
          ],
        ),
      ),
    );
  }

  void _searchOnEbay(LibraryWorkspaceEntry entry) {
    final query = entry.itemNumber != null
        ? '${entry.resolvedTitle} #${entry.itemNumber}'
        : entry.resolvedTitle;
    final encoded = Uri.encodeComponent(query);
    final url = Uri.parse('https://www.ebay.com/sch/i.html?_nkw=$encoded');
    launchUrl(url, mode: LaunchMode.externalApplication);
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
