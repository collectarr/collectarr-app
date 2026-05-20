import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/library/inspector/generic_library_inspector.dart';
import 'package:collectarr_app/features/library/generic/generic_library_projection.dart';
import 'package:collectarr_app/features/library/generic/generic_library_sidebar.dart';
import 'package:collectarr_app/features/library/generic/generic_library_workspace.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_ctrl_scroll_zoom.dart';
import 'package:collectarr_app/features/library/workspace/library_pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/library_resizable_pane.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class GenericLibraryBody extends StatelessWidget {
  const GenericLibraryBody({
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
    required this.onSelectItem,
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
    this.onFilterByValue,
    this.db,
  });

  final LibraryTypeConfig type;
  final LibraryMediaAdapter adapter;
  final GenericLibraryProjection projection;
  final LibraryWorkspaceViewState viewState;
  final String? selectedId;
  final String? selectedBucket;
  final GenericLibraryGroupMode groupMode;
  final bool groupLoading;
  final Color accent;
  final bool hasActiveFilter;
  final VoidCallback onAdd;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onSelectItem;
  final ValueChanged<String?> onBucketChanged;
  final ValueChanged<GenericLibraryGroupMode> onGroupModeChanged;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final void Function(
          LibraryTableColumn column, LibraryTableColumn? beforeColumn)
      onColumnReordered;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<double> onSidebarWidthChanged;
  final ValueChanged<double> onDetailsWidthChanged;
  final ValueChanged<GenericLibraryItem> onAddOwned;
  final ValueChanged<GenericLibraryItem> onRemoveOwned;
  final ValueChanged<GenericLibraryItem> onAddWishlist;
  final ValueChanged<GenericLibraryItem> onRemoveWishlist;
  final ValueChanged<GenericLibraryItem> onEditItem;
  final ValueChanged<String>? onFilterByValue;
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
        final workspace = LibraryCtrlScrollZoom(
          coverSize: viewState.coverSize,
          minCoverSize: adapter.viewProfile.minCoverSize,
          maxCoverSize: adapter.viewProfile.maxCoverSize,
          onCoverSizeChanged: onCoverSizeChanged,
          child: GenericLibraryWorkspace(
            type: type,
            adapter: adapter,
            items: projection.filteredItems,
            viewState: viewState,
            selectedId: selectedId,
            groupMode: groupMode,
            selectedBucket: selectedBucket,
            accent: accent,
            hasActiveFilter: hasActiveFilter,
            onAdd: onAdd,
            onClearFilters: onClearFilters,
            onSelectItem: onSelectItem,
            onSortChanged: onSortChanged,
            onColumnWidthChanged: onColumnWidthChanged,
            onColumnReordered: onColumnReordered,
          ),
        );
        final details = GenericLibraryInspector(
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
              GenericLibraryCompactBucketBar(
                type: type,
                accent: accent,
                buckets: projection.buckets,
                selectedBucket: selectedBucket ?? genericAllBucketLabel(type),
                onSelected: (bucket) => onBucketChanged(
                  bucket == genericAllBucketLabel(type) ? null : bucket,
                ),
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
                  child: GenericLibrarySidebar(
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
