import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
import 'package:collectarr_app/features/library/generic/library_projection.dart';
import 'package:collectarr_app/features/library/generic/library_sidebar.dart';
import 'package:collectarr_app/features/library/generic/library_workspace.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_alpha_jump_bar.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_ctrl_scroll_zoom.dart';
import 'package:collectarr_app/features/library/workspace/library_pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/library_resizable_pane.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class LibraryBody extends StatelessWidget {
  const LibraryBody({
    super.key,
    required this.type,
    required this.adapter,
    required this.projection,
    required this.viewState,
    required this.selectedId,
    required this.selectedBucket,
    required this.groupMode,
    this.groupLoading = false,
    required this.accent,
    required this.hasActiveFilter,
    required this.onAdd,
    required this.onClearFilters,
    required this.selectionEnabled,
    required this.selectedItemIds,
    required this.onSelectItem,
    this.onBoxSelectionChanged,
    required this.onBucketChanged,
    required this.onGroupModeChanged,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onColumnReordered,
    required this.onCoverSizeChanged,
    required this.onSidebarWidthChanged,
    required this.onDetailsWidthChanged,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEditItem,
    this.onItemContextMenu,
    this.onFilterByValue,
    this.selectedLetter,
    this.availableLetters = const {},
    this.onLetterSelected,
    this.db,
  });

  final LibraryTypeConfig type;
  final LibraryMediaAdapter adapter;
  final LibraryProjection projection;
  final LibraryWorkspaceViewState viewState;
  final String? selectedId;
  final String? selectedBucket;
  final LibraryGroupMode groupMode;
  final bool groupLoading;
  final Color accent;
  final bool hasActiveFilter;
  final VoidCallback onAdd;
  final VoidCallback onClearFilters;
  final bool selectionEnabled;
  final Set<String> selectedItemIds;
  final ValueChanged<String> onSelectItem;
  final ValueChanged<Set<String>>? onBoxSelectionChanged;
  final ValueChanged<String?> onBucketChanged;
  final ValueChanged<LibraryGroupMode> onGroupModeChanged;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final void Function(
          LibraryTableColumn column, LibraryTableColumn? beforeColumn)
      onColumnReordered;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<double> onSidebarWidthChanged;
  final ValueChanged<double> onDetailsWidthChanged;
  final ValueChanged<LibraryProjectionItem> onAddOwned;
  final ValueChanged<LibraryProjectionItem> onRemoveOwned;
  final ValueChanged<LibraryProjectionItem> onAddWishlist;
  final ValueChanged<LibraryProjectionItem> onRemoveWishlist;
  final ValueChanged<LibraryProjectionItem> onEditItem;
  final LibraryItemContextMenuCallback? onItemContextMenu;
  final ValueChanged<String>? onFilterByValue;
  final String? selectedLetter;
  final Set<String> availableLetters;
  final ValueChanged<String?>? onLetterSelected;
  final LocalDatabase? db;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final selected = projection.selectedItem;
        final compact = constraints.maxWidth < 860;
        final showSidebar = constraints.maxWidth >= 640;
        final detailsLayout =
            compact && viewState.detailsLayout == LibraryDetailsLayout.right
                ? LibraryDetailsLayout.bottom
                : viewState.detailsLayout;
        final maxSidebarWidth = maxLibraryPaneWidthForViewport(
          viewportWidth: constraints.maxWidth,
          preferredMaxWidth: kLibrarySidebarMaxWidth,
          viewportFraction: compact ? 0.4 : 0.34,
        );
        final sidebarWidth = clampLibraryPaneWidth(
          viewState.sidebarWidth,
          minWidth: kLibrarySidebarMinWidth,
          maxWidth: maxSidebarWidth,
        );
        final maxDetailsWidth = maxLibraryPaneWidthForViewport(
          viewportWidth: constraints.maxWidth,
          preferredMaxWidth: kLibraryDetailsMaxWidth,
          viewportFraction: 0.38,
        );
        final letterFilteredItems = selectedLetter == null
            ? projection.filteredItems
            : projection.filteredItems
                .where((item) => LibraryAlphaJumpBar.matchesLetter(
                      item.entry.title,
                      selectedLetter!,
                    ))
                .toList();
        final workspace = LibraryCtrlScrollZoom(
          coverSize: viewState.coverSize,
          minCoverSize: adapter.viewProfile.minCoverSize,
          maxCoverSize: adapter.viewProfile.maxCoverSize,
          onCoverSizeChanged: onCoverSizeChanged,
          child: LibraryWorkspace(
            type: type,
            adapter: adapter,
            items: letterFilteredItems,
            viewState: viewState,
            selectedId: selectedId,
            selectionEnabled: selectionEnabled,
            selectedIds: selectedItemIds,
            groupMode: groupMode,
            selectedBucket: selectedBucket,
            accent: accent,
            hasActiveFilter: hasActiveFilter,
            onAdd: onAdd,
            onClearFilters: onClearFilters,
            onSelectItem: onSelectItem,
            onBoxSelectionChanged: onBoxSelectionChanged,
            onSortChanged: onSortChanged,
            onColumnWidthChanged: onColumnWidthChanged,
            onColumnReordered: onColumnReordered,
            onItemContextMenu: onItemContextMenu,
          ),
        );
        final details = LibraryInspector(
          type: type,
          entry: selected?.entry,
          ownedItem: selected?.source.ownedItem,
          accent: accent,
          onAddOwned: selected == null ? null : () => onAddOwned(selected),
          onRemoveOwned: selected?.source.ownedItem == null
              ? null
              : () => onRemoveOwned(selected!),
          onAddWishlist:
              selected == null ? null : () => onAddWishlist(selected),
          onRemoveWishlist: selected?.source.isWishlisted != true
              ? null
              : () => onRemoveWishlist(selected!),
          onEdit: selected == null ? null : () => onEditItem(selected),
          onFilterByValue: onFilterByValue,
          db: db,
        );

        final workspaceContent = Column(
          children: [
            if (!showSidebar && projection.buckets.length > 1)
              LibraryCompactBucketBar(
                type: type,
                accent: accent,
                buckets: projection.buckets,
                selectedBucket: selectedBucket ?? genericAllBucketLabel(type),
                onSelected: (bucket) => onBucketChanged(
                  bucket == genericAllBucketLabel(type) ? null : bucket,
                ),
              ),
            if (onLetterSelected != null)
              LibraryAlphaJumpBar(
                availableLetters: availableLetters,
                selectedLetter: selectedLetter,
                accent: accent,
                onLetterSelected: onLetterSelected!,
              ),
            Expanded(child: workspace),
          ],
        );

        return ColoredBox(
          color: kClzCanvas,
          child: Row(
            children: [
              if (showSidebar) ...[
                SizedBox(
                  width: sidebarWidth,
                  child: LibrarySidebar(
                    type: type,
                    accent: accent,
                    buckets: projection.buckets,
                    groupMode: groupMode,
                    groupLoading: groupLoading,
                    selectedBucket:
                        selectedBucket ?? genericAllBucketLabel(type),
                    onSelected: (bucket) => onBucketChanged(
                      bucket == genericAllBucketLabel(type) ? null : bucket,
                    ),
                    onGroupModeChanged: onGroupModeChanged,
                    onClearFilter: selectedBucket == null
                        ? null
                        : () => onBucketChanged(null),
                  ),
                ),
                LibraryResizableDivider(
                  onDragDelta: (delta) => onSidebarWidthChanged(
                    clampLibraryPaneWidth(
                      sidebarWidth + delta,
                      minWidth: kLibrarySidebarMinWidth,
                      maxWidth: maxSidebarWidth,
                    ),
                  ),
                ),
              ],
              Expanded(
                child: LibraryDetailsAwareLayout(
                  content: workspaceContent,
                  detailsLayout: detailsLayout,
                  inspector: details,
                  rightWidth: viewState.detailsWidth,
                  maxRightWidth: maxDetailsWidth,
                  onRightWidthChanged: onDetailsWidthChanged,
                  bottomHeight: compact ? 220 : 250,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
