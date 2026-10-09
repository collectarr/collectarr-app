import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
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

class LibraryDetailPage extends ConsumerStatefulWidget {
  const LibraryDetailPage({
    super.key,
    required this.type,
    required this.item,
    required this.libraryEntrySummary,
    required this.accent,
    required this.onAddEntry,
    required this.onRemoveEntry,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
    this.onFilterByValue,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final LibraryEntrySummary? libraryEntrySummary;
  final Color accent;
  final VoidCallback? onAddEntry;
  final VoidCallback? onRemoveEntry;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final void Function(LibraryEntrySummary? libraryEntry)? onEdit;
  final ValueChanged<String>? onFilterByValue;

  @override
  ConsumerState<LibraryDetailPage> createState() => _LibraryDetailPageState();
}

class _LibraryDetailPageState extends ConsumerState<LibraryDetailPage> {
  @override
  Widget build(BuildContext context) {
    final activeLibraryEntrySummary = widget.libraryEntrySummary;
    final activeTrackingSummary = resolveActiveTrackingSummary(
      libraryTrackingSummariesForItem(
        widget.item,
        ref.watch(trackingSummariesByLibraryEntryRefProvider),
        libraryEntry: activeLibraryEntrySummary,
      ),
      activeLibraryEntrySummary,
    );
    final isEntry =
        activeLibraryEntrySummary != null || widget.item.source.isEntry;
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
                activeLibraryEntry: activeLibraryEntrySummary,
                accent: widget.accent,
                onEdit: widget.onEdit == null
                    ? null
                    : () => widget.onEdit!(activeLibraryEntrySummary),
                onToggleEntry: isEntry
                    ? activeLibraryEntrySummary == null
                        ? widget.onRemoveEntry
                        : () => _removeLibraryEntry(activeLibraryEntrySummary)
                    : widget.onAddEntry,
                onToggleWishlist: widget.item.source.isWishlisted
                    ? widget.onRemoveWishlist
                    : widget.onAddWishlist,
                onSearchOnEbay: () => _searchOnEbay(widget.item),
                onAssignFolders: activeLibraryEntrySummary == null
                    ? null
                    : () {
                        final db = ref.read(localDatabaseProvider);
                        showFolderAssignmentDialog(
                          context: context,
                          db: db,
                          libraryEntryRef: activeLibraryEntrySummary.ref,
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
                  libraryEntry: activeLibraryEntrySummary,
                  accent: widget.accent,
                  isEntry: isEntry,
                ),
                sections: buildLibraryDetailSectionSpecs(
                  context: context,
                  type: widget.type,
                  item: widget.item,
                  accent: widget.accent,
                  libraryEntrySummary: activeLibraryEntrySummary,
                  trackingSummary: activeTrackingSummary,
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

  Future<void> _removeLibraryEntry(LibraryEntrySummary item) async {
    await ref.read(libraryEntryMutationsProvider).removeItem(item.ref);
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}

class _LibraryDetailToolbar extends StatelessWidget {
  const _LibraryDetailToolbar({
    required this.type,
    required this.item,
    required this.activeLibraryEntry,
    required this.accent,
    required this.onEdit,
    required this.onToggleEntry,
    required this.onToggleWishlist,
    required this.onSearchOnEbay,
    required this.onAssignFolders,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final LibraryEntrySummary? activeLibraryEntry;
  final Color accent;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleEntry;
  final VoidCallback? onToggleWishlist;
  final VoidCallback onSearchOnEbay;
  final VoidCallback? onAssignFolders;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final isEntry = activeLibraryEntry != null || item.source.isEntry;
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
                label: isEntry ? 'Remove' : 'Collect',
                icon: isEntry
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                onPressed: onToggleEntry,
                tone: LibraryDenseButtonTone.subtle,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              ),
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
