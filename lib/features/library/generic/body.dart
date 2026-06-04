import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/sidebar.dart';
import 'package:collectarr_app/features/library/generic/workspace.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_alpha_jump_bar.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_ctrl_scroll_zoom.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_resizable_pane.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

LibraryDetailsLayout resolveEffectiveLibraryDetailsLayout({
  required LibraryDetailsLayout preferredLayout,
  required bool compact,
  required bool hasSelection,
  required bool hideWhenSelectionEmpty,
}) {
  if (hideWhenSelectionEmpty && !hasSelection) {
    return LibraryDetailsLayout.hidden;
  }
  if (compact && preferredLayout == LibraryDetailsLayout.right) {
    return LibraryDetailsLayout.bottom;
  }
  return preferredLayout;
}

double resolveLibraryWorkspaceMinWidth({
  required LibraryWorkspaceViewState viewState,
}) {
  return switch (viewState.viewMode) {
    LibraryViewMode.grid ||
    LibraryViewMode.horizontalCards ||
    LibraryViewMode.shelves =>
      (viewState.coverSize + 36)
          .clamp(160.0, kLibraryWorkspaceMinWidth)
          .toDouble(),
    _ => kLibraryWorkspaceMinWidth,
  };
}

double resolveLibrarySidebarMinWidth(
  BuildContext context, {
  required String selectedBucketLabel,
  required int ancestorScopeDepth,
}) {
  final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
          ) ??
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w800);
  final textPainter = TextPainter(
    text: TextSpan(text: selectedBucketLabel, style: labelStyle),
    maxLines: 1,
    textDirection: Directionality.of(context),
  )..layout();
  final leadingInset =
      ancestorScopeDepth == 0 ? 0.0 : 14.0 + ancestorScopeDepth * 12.0;
  final rowWidth = 6.0 + leadingInset + 20.0 + 6.0 + textPainter.width + 8.0;
  return rowWidth
      .clamp(kLibrarySidebarMinWidth, kLibraryPaneStoredMaxWidth)
      .toDouble();
}

class LibraryBody extends StatelessWidget {
  const LibraryBody({
    super.key,
    required this.type,
    required this.adapter,
    required this.projection,
    required this.viewState,
    required this.selectedId,
    required this.selectedAnchorId,
    required this.selectedBucket,
    required this.groupMode,
    this.groupLoading = false,
    required this.accent,
    required this.hasActiveFilter,
    required this.onAdd,
    required this.onClearFilters,
    required this.onEditFilters,
    required this.selectionEnabled,
    required this.selectedItemIds,
    required this.onApplySelection,
    required this.onActivateItem,
    required this.onToggleSelectionItem,
    required this.onOpenItem,
    this.onBoxSelectionChanged,
    required this.onBucketChanged,
    required this.onGroupModeChanged,
    required this.sidebarBreadcrumbs,
    this.sidebarAncestorScopeLabels = const [],
    this.onSidebarNavigateBack,
    this.onSidebarNavigateToBreadcrumb,
    this.onSidebarNavigateToAncestorScope,
    this.searchQuery,
    this.searchTarget = LibrarySearchTarget.all,
    this.activeSmartListName,
    this.quickView,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.seriesCompletionScope = LibrarySeriesCompletionScope.all,
    this.collectionStatusScopeLabel,
    this.linkedMetadataFilterLabel,
    this.sidebarSelectedLetter,
    this.seriesStatusSummary,
    this.filterSelection = LibraryFilterSelection.none,
    this.preferToolbarAlphabet = false,
    this.onCollectionStatusScopeChanged,
    this.onSeriesCompletionScopeChanged,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onColumnReordered,
    required this.onCoverSizeChanged,
    required this.onSidebarWidthChanged,
    required this.onSidebarVisibilityChanged,
    required this.onDetailsLayoutChanged,
    required this.onDetailsWidthChanged,
    required this.onDetailsHeightChanged,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEditItem,
    this.workspaceOverride,
    this.onItemContextMenu,
    this.onFilterByValue,
    this.selectedLetter,
    this.availableLetters = const {},
    this.onLetterSelected,
    this.db,
    this.folderPreset,
    this.pinnedFolderPresets = const [],
    this.onPinnedFolderPresetsChanged,
    this.onManageBuckets,
    this.inspectorContextLabel,
    this.desktopToolbarBand,
  });

  final LibraryTypeConfig type;
  final LibraryMediaAdapter adapter;
  final LibraryProjection projection;
  final LibraryWorkspaceViewState viewState;
  final String? selectedId;
  final String? selectedAnchorId;
  final String? selectedBucket;
  final LibraryGroupMode groupMode;
  final bool groupLoading;
  final Color accent;
  final bool hasActiveFilter;
  final VoidCallback onAdd;
  final VoidCallback onClearFilters;
  final VoidCallback onEditFilters;
  final bool selectionEnabled;
  final Set<String> selectedItemIds;
  final void Function(Set<String> ids, String focusedId) onApplySelection;
  final ValueChanged<String> onActivateItem;
  final ValueChanged<String> onToggleSelectionItem;
  final ValueChanged<LibraryProjectionItem> onOpenItem;
  final ValueChanged<Set<String>>? onBoxSelectionChanged;
  final ValueChanged<String?> onBucketChanged;
  final ValueChanged<LibraryGroupMode> onGroupModeChanged;
  final List<String> sidebarBreadcrumbs;
  final List<String> sidebarAncestorScopeLabels;
  final VoidCallback? onSidebarNavigateBack;
  final ValueChanged<int>? onSidebarNavigateToBreadcrumb;
  final ValueChanged<int>? onSidebarNavigateToAncestorScope;
  final String? searchQuery;
  final LibrarySearchTarget searchTarget;
  final String? activeSmartListName;
  final LibraryQuickView? quickView;
  final LibraryCollectionStatusScope collectionStatusScope;
  final LibrarySeriesCompletionScope seriesCompletionScope;
  final String? collectionStatusScopeLabel;
  final String? linkedMetadataFilterLabel;
  final String? sidebarSelectedLetter;
  final LibrarySeriesStatusSummary? seriesStatusSummary;
  final LibraryFilterSelection filterSelection;
  final bool preferToolbarAlphabet;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final ValueChanged<LibrarySeriesCompletionScope>?
      onSeriesCompletionScopeChanged;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final void Function(
          LibraryTableColumn column, LibraryTableColumn? beforeColumn)
      onColumnReordered;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<double> onSidebarWidthChanged;
  final ValueChanged<bool> onSidebarVisibilityChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<double> onDetailsWidthChanged;
  final ValueChanged<double> onDetailsHeightChanged;
  final ValueChanged<LibraryProjectionItem> onAddOwned;
  final ValueChanged<LibraryProjectionItem> onRemoveOwned;
  final ValueChanged<LibraryProjectionItem> onAddWishlist;
  final ValueChanged<LibraryProjectionItem> onRemoveWishlist;
  final void Function(LibraryProjectionItem item, OwnedItem? ownedItem)
      onEditItem;
  final Widget? workspaceOverride;
  final LibraryItemContextMenuCallback? onItemContextMenu;
  final ValueChanged<String>? onFilterByValue;
  final String? selectedLetter;
  final Set<String> availableLetters;
  final ValueChanged<String?>? onLetterSelected;
  final LocalDatabase? db;
  final LibraryFolderPreset? folderPreset;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedFolderPresetsChanged;
  final VoidCallback? onManageBuckets;
  final String? inspectorContextLabel;
  final Widget? desktopToolbarBand;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final selected = projection.selectedItem;
        final compact = constraints.maxWidth < kAppSpacedBreakpoint;
        final canShowSidebar = constraints.maxWidth >= kAppCompactBreakpoint;
        final showSidebar = canShowSidebar && viewState.isSidebarVisible;
        final workspaceMinWidth = resolveLibraryWorkspaceMinWidth(
          viewState: viewState,
        );
        final resolvedSelectedBucket =
            selectedBucket ?? genericAllBucketLabel(type);
        final sidebarMinWidth = resolveLibrarySidebarMinWidth(
          context,
          selectedBucketLabel: resolvedSelectedBucket,
          ancestorScopeDepth: sidebarAncestorScopeLabels.length,
        );
        final detailsLayout = resolveEffectiveLibraryDetailsLayout(
          preferredLayout: viewState.detailsLayout,
          compact: compact,
          hasSelection: selected != null,
          hideWhenSelectionEmpty:
              adapter.viewProfile.hideDetailsWhenSelectionEmpty,
        );
        final requestedDetailsWidth = clampLibraryPaneWidth(
          viewState.detailsWidth,
          minWidth: kLibraryDetailsMinWidth,
          maxWidth: kLibraryPaneStoredMaxWidth,
        );
        final maxSidebarWidth = resolveLibrarySidebarMaxWidth(
          viewportWidth: constraints.maxWidth,
          workspaceMinWidth: workspaceMinWidth,
          hasRightDetails: detailsLayout == LibraryDetailsLayout.right,
          rightDetailsWidth: requestedDetailsWidth,
          minWidth: sidebarMinWidth,
        );
        final sidebarWidth = clampLibraryPaneWidth(
          viewState.sidebarWidth,
          minWidth: sidebarMinWidth,
          maxWidth: maxSidebarWidth,
        );
        final maxDetailsWidth = resolveLibraryDetailsMaxWidth(
          viewportWidth: constraints.maxWidth,
          workspaceMinWidth: workspaceMinWidth,
          hasSidebar: showSidebar,
          sidebarWidth: sidebarWidth,
        );
        final maxDetailsHeight = resolveLibraryDetailsMaxHeight(
          viewportHeight:
              constraints.maxHeight.isFinite ? constraints.maxHeight : 800,
          workspaceMinHeight: kLibraryWorkspaceMinHeight,
        );
        final letterFilteredItems = selectedLetter == null
            ? projection.filteredItems
            : projection.filteredItems
                .where((item) => LibraryAlphaJumpBar.matchesLetter(
                      item.entry.resolvedTitle,
                      selectedLetter!,
                    ))
                .toList();
        final workspace = workspaceOverride ??
            LibraryCtrlScrollZoom(
              viewMode: viewState.viewMode,
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
                selectedAnchorId: selectedAnchorId,
                onApplySelection: onApplySelection,
                onActivateItem: onActivateItem,
                onToggleSelectionItem: onToggleSelectionItem,
                onOpenItem: onOpenItem,
                onEditItem: (item) => onEditItem(item, item.source.ownedItem),
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
          contextLabel: inspectorContextLabel,
          onAddOwned: selected == null ? null : () => onAddOwned(selected),
          onRemoveOwned: selected?.source.ownedItem == null
              ? null
              : () => onRemoveOwned(selected!),
          onAddWishlist:
              selected == null ? null : () => onAddWishlist(selected),
          onRemoveWishlist: selected?.source.isWishlisted != true
              ? null
              : () => onRemoveWishlist(selected!),
          onEdit: selected == null
              ? null
              : (ownedItem) => onEditItem(selected, ownedItem),
          onDetailsLayoutChanged: onDetailsLayoutChanged,
          onFilterByValue: onFilterByValue,
          searchQuery: searchQuery,
          searchTarget: searchTarget,
          db: db,
        );

        final workspaceContent = Column(
          children: [
            if (!compact && desktopToolbarBand != null) desktopToolbarBand!,
            if (workspaceOverride == null &&
                !showSidebar &&
                !canShowSidebar &&
                projection.buckets.length > 1)
              LibraryCompactBucketBar(
                type: type,
                accent: accent,
                buckets: projection.buckets,
                selectedBucket: selectedBucket ?? genericAllBucketLabel(type),
                onSelected: (bucket) => onBucketChanged(
                  bucket == genericAllBucketLabel(type) ? null : bucket,
                ),
              ),
            if (workspaceOverride == null &&
                onLetterSelected != null &&
                (!preferToolbarAlphabet || compact))
              LibraryAlphaJumpBar(
                availableLetters: availableLetters,
                selectedLetter: selectedLetter,
                accent: accent,
                onLetterSelected: onLetterSelected!,
              ),
            Expanded(
              child: workspaceOverride == null
                  ? workspace
                  : IndexedStack(
                      index: 1,
                      children: [
                        workspace,
                        workspaceOverride!,
                      ],
                    ),
            ),
          ],
        );

        final sidebar = LibrarySidebar(
          type: type,
          accent: accent,
          buckets: projection.buckets,
          groupMode: groupMode,
          groupLoading: groupLoading,
          selectedBucket: resolvedSelectedBucket,
          onSelected: (bucket) => onBucketChanged(
            bucket == genericAllBucketLabel(type) ? null : bucket,
          ),
          onGroupModeChanged: onGroupModeChanged,
          breadcrumbs: sidebarBreadcrumbs,
          ancestorScopeLabels: sidebarAncestorScopeLabels,
          onNavigateBack: onSidebarNavigateBack,
          onNavigateToBreadcrumb: onSidebarNavigateToBreadcrumb,
          onNavigateToAncestorScope: onSidebarNavigateToAncestorScope,
          searchQuery: searchQuery,
          activeSmartListName: activeSmartListName,
          quickView: quickView,
          collectionStatusScope: collectionStatusScope,
          seriesCompletionScope: seriesCompletionScope,
          collectionStatusScopeLabel: collectionStatusScopeLabel,
          linkedMetadataFilterLabel: linkedMetadataFilterLabel,
          selectedLetter: sidebarSelectedLetter,
          seriesStatusSummary: seriesStatusSummary,
          filterSelection: filterSelection,
          hasActiveFilters: hasActiveFilter,
          onEditFilters: onEditFilters,
          onClearFilters: onClearFilters,
          onCollectionStatusScopeChanged: onCollectionStatusScopeChanged,
          onSeriesCompletionScopeChanged: onSeriesCompletionScopeChanged,
          onClearFilter:
              selectedBucket == null ? null : () => onBucketChanged(null),
          onSidebarVisibilityChanged: onSidebarVisibilityChanged,
          onManageBuckets: onManageBuckets,
          pinnedFolderPresets: pinnedFolderPresets,
          onPinnedFolderPresetsChanged: onPinnedFolderPresetsChanged,
        );
        final detailsLayoutWidget = LibraryDetailsAwareLayout(
          content: workspaceContent,
          detailsLayout: detailsLayout,
          inspector: details,
          frameInspector: type.inspectorPanelBuilder == null,
          rightWidth: viewState.detailsWidth,
          bottomHeight: viewState.detailsHeight,
          maxRightWidth: maxDetailsWidth,
          maxBottomHeight: maxDetailsHeight,
          onRightWidthChanged: onDetailsWidthChanged,
          onBottomHeightChanged: onDetailsHeightChanged,
          accentColor: accent,
        );
        return ColoredBox(
          color: palette.canvas,
          child: showSidebar
              ? _LibrarySidebarResizableLayout(
                  sidebar: sidebar,
                  content: detailsLayoutWidget,
                  initialWidth: sidebarWidth,
                  minWidth: sidebarMinWidth,
                  maxWidth: maxSidebarWidth,
                  accentColor: accent,
                  onSidebarWidthChanged: onSidebarWidthChanged,
                )
              : detailsLayoutWidget,
        );
      },
    );
  }
}

class _LibrarySidebarResizableLayout extends StatefulWidget {
  const _LibrarySidebarResizableLayout({
    required this.sidebar,
    required this.content,
    required this.initialWidth,
    required this.minWidth,
    required this.maxWidth,
    required this.accentColor,
    required this.onSidebarWidthChanged,
  });

  final Widget sidebar;
  final Widget content;
  final double initialWidth;
  final double minWidth;
  final double maxWidth;
  final Color accentColor;
  final ValueChanged<double> onSidebarWidthChanged;

  @override
  State<_LibrarySidebarResizableLayout> createState() =>
      _LibrarySidebarResizableLayoutState();
}

class _LibrarySidebarResizableLayoutState
    extends State<_LibrarySidebarResizableLayout> {
  late double _width;
  bool _dragging = false;
  Timer? _persistDebounce;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
  }

  @override
  void didUpdateWidget(covariant _LibrarySidebarResizableLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging) {
      _width = clampLibraryPaneWidth(
        widget.initialWidth,
        minWidth: widget.minWidth,
        maxWidth: widget.maxWidth,
      );
    }
  }

  @override
  void dispose() {
    _persistDebounce?.cancel();
    super.dispose();
  }

  void _scheduleSidebarWidthPersist(double width) {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 16), () {
      widget.onSidebarWidthChanged(width);
    });
  }

  void _flushSidebarWidthPersist() {
    _persistDebounce?.cancel();
    widget.onSidebarWidthChanged(_width);
  }

  void _handleDrag(double delta) {
    final nextWidth = clampLibraryPaneWidth(
      _width + delta,
      minWidth: widget.minWidth,
      maxWidth: widget.maxWidth,
    );
    if ((_width - nextWidth).abs() < 0.01) {
      return;
    }
    setState(() => _width = nextWidth);
    _scheduleSidebarWidthPersist(nextWidth);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: _width, child: widget.sidebar),
        LibraryResizableDivider(
          accentColor: widget.accentColor,
          onDragStart: () => _dragging = true,
          onDragEnd: () {
            _dragging = false;
            _flushSidebarWidthPersist();
          },
          onDragDelta: _handleDrag,
        ),
        Expanded(child: widget.content),
      ],
    );
  }
}
