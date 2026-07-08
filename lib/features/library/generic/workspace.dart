import 'dart:math' as math;

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/empty_state.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_flow_carousel.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_grouped_shelf_view.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_shelf_view.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_workspace_grid.dart';
import 'package:collectarr_app/features/library/workspace/table/library_workspace_table.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef LibraryItemContextMenuCallback = void Function(
  LibraryProjectionItem item,
  Offset globalPosition,
);

double libraryWorkspaceGridMainAxisExtent({
  required LibraryMediaAdapter adapter,
  required double coverSize,
}) {
  return coverSize * adapter.viewProfile.coverGridHeightFactor;
}

class LibraryWorkspace extends ConsumerWidget {
  const LibraryWorkspace({
    super.key,
    required this.type,
    required this.adapter,
    required this.items,
    required this.viewState,
    required this.selectedId,
    required this.selectedAnchorId,
    required this.selectionEnabled,
    required this.selectedIds,
    required this.groupMode,
    required this.groupPresentation,
    required this.selectedBucket,
    required this.onBucketChanged,
    required this.collapsedGroupBuckets,
    required this.onGroupBucketCollapsedToggled,
    this.onSetCollapsedGroupBuckets,
    required this.accent,
    required this.hasActiveFilter,
    required this.onAdd,
    required this.onClearFilters,
    required this.onApplySelection,
    required this.onActivateItem,
    required this.onToggleSelectionItem,
    required this.onOpenItem,
    required this.onEditItem,
    this.onBoxSelectionChanged,
    required this.onSortChanged,
    required this.onColumnWidthChanged,
    required this.onColumnReordered,
    this.onItemContextMenu,
    this.initialCrossAxisCount,
  });

  final LibraryTypeConfig type;
  final LibraryMediaAdapter adapter;
  final List<LibraryProjectionItem> items;
  final LibraryWorkspaceViewState viewState;
  final String? selectedId;
  final String? selectedAnchorId;
  final bool selectionEnabled;
  final Set<String> selectedIds;
  final LibraryGroupMode groupMode;
  final LibraryGroupPresentation groupPresentation;
  final String? selectedBucket;
  final ValueChanged<String?> onBucketChanged;
  final Set<String> collapsedGroupBuckets;
  final ValueChanged<String> onGroupBucketCollapsedToggled;
  final ValueChanged<Set<String>>? onSetCollapsedGroupBuckets;
  final Color accent;
  final bool hasActiveFilter;
  final VoidCallback onAdd;
  final VoidCallback onClearFilters;
  final void Function(Set<String> ids, String focusedId) onApplySelection;
  final ValueChanged<String> onActivateItem;
  final ValueChanged<String> onToggleSelectionItem;
  final ValueChanged<LibraryProjectionItem> onOpenItem;
  final ValueChanged<LibraryProjectionItem> onEditItem;
  final ValueChanged<Set<String>>? onBoxSelectionChanged;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final void Function(LibraryTableColumn column, double width)
      onColumnWidthChanged;
  final void Function(
          LibraryTableColumn column, LibraryTableColumn? beforeColumn)
      onColumnReordered;
  final LibraryItemContextMenuCallback? onItemContextMenu;
  final int? initialCrossAxisCount;

  bool get _showGrouped =>
      viewState.viewMode != LibraryViewMode.horizontalCards &&
      viewState.viewMode != LibraryViewMode.cardFlow &&
      viewState.viewMode != LibraryViewMode.shelves &&
      selectedBucket == null &&
      groupMode != LibraryGroupMode.title &&
      groupMode != LibraryGroupMode.ownership;

  bool _isActive(LibraryProjectionItem item) => item.entry.id == selectedId;

  bool _isSelectionSelected(LibraryProjectionItem item) =>
      selectedIds.contains(item.entry.id);

  bool _isHighlighted(LibraryProjectionItem item) =>
      selectionEnabled ? _isSelectionSelected(item) : _isActive(item);

  VoidCallback _selectionTap(LibraryProjectionItem item) {
    return () {
      final isRangeSelection = isLibraryRangeModifierPressed();
      final isToggleSelection = isLibraryToggleModifierPressed();
      if (isRangeSelection) {
        final anchorId = selectedAnchorId ?? selectedId ?? item.entry.id;
        final orderedIds = [for (final candidate in items) candidate.entry.id];
        final rangeIds = selectionRangeItemIds(
          orderedIds,
          anchorId: anchorId,
          targetId: item.entry.id,
        );
        onApplySelection(
          isToggleSelection ? {...selectedIds, ...rangeIds} : rangeIds,
          item.entry.id,
        );
        return;
      }
      if (isToggleSelection) {
        onToggleSelectionItem(item.entry.id);
        return;
      }
      if (_isActive(item) && !selectionEnabled) {
        return;
      }
      onActivateItem(item.entry.id);
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiPrefs = ref.watch(uiPreferencesProvider);
    final palette = appPalette(context);
    final gridSpacing = uiPrefs.gridSpacing;
    final gridPadding = EdgeInsets.all(uiPrefs.gridSpacing);
    final defaultCoverSize = adapter.viewProfile.defaultCoverSize;
    final isMusicLibrary = type.capabilities.prefersSquareCovers;
    final density = viewState.densityPreset;
    final cardScale = defaultCoverSize > 0
        ? ((viewState.coverSize / defaultCoverSize).clamp(0.72, 1.44) *
            density.cardScaleFactor)
        : 1.0;
    final cardCoverWidth =
        (uiPrefs.cardCoverWidth * cardScale).clamp(60.0, 164.0).toDouble();
    final cardTileWidth = (430.0 * cardScale).clamp(312.0, 620.0).toDouble();
    final cardTileHeight = (156.0 * cardScale).clamp(124.0, 228.0).toDouble();
    final standardVerticalTileWidth =
        ((viewState.coverSize + 54) * density.cardScaleFactor)
            .clamp(160.0, 244.0)
            .toDouble();
    final standardVerticalTileHeight = (standardVerticalTileWidth *
            (1.34 + ((density.cardScaleFactor - 0.86) * 0.4)))
        .clamp(220.0, 352.0)
        .toDouble();
    final musicVerticalTileWidth =
        ((viewState.coverSize + 56) * density.cardScaleFactor)
            .clamp(164.0, 248.0)
            .toDouble();
    final musicVerticalTileHeight = (viewState.coverSize *
            (1.38 + ((density.cardScaleFactor - 0.86) * 0.5)))
        .clamp(224.0, 360.0)
        .toDouble();
    final coverMainAxisExtent = libraryWorkspaceGridMainAxisExtent(
      adapter: adapter,
      coverSize: viewState.coverSize,
    );
    if (_showGrouped && items.isNotEmpty) {
      final groups = libraryGroupEntriesForItems(
        items,
        type,
        groupMode,
        presentationOverride: groupPresentation,
      );
      return LibraryGroupedShelfView(
        type: type,
        adapter: adapter,
        groups: groups,
        viewState: viewState,
        selectedId: selectedId,
        selectionEnabled: selectionEnabled,
        selectedIds: selectedIds,
        accent: accent,
        onSelectGroupBucket: onBucketChanged,
        collapsedGroupBuckets: collapsedGroupBuckets,
        onGroupBucketCollapsedToggled: onGroupBucketCollapsedToggled,
        onSetCollapsedGroupBuckets: onSetCollapsedGroupBuckets,
        onOpenGroupDetails: (group) => onOpenItem(group.representativeItem),
        onActivateItem: onActivateItem,
        onToggleSelectionItem: onToggleSelectionItem,
        onOpenItem: onOpenItem,
        onEditItem: onEditItem,
        emptyBuilder: _emptyBuilder,
        onItemContextMenu: onItemContextMenu,
        onBoxSelectionChanged: onBoxSelectionChanged,
      );
    }
    return switch (viewState.viewMode) {
      LibraryViewMode.grid => LibraryWorkspaceGrid<LibraryProjectionItem>(
          items: items,
          emptyBuilder: _emptyBuilder,
          maxCrossAxisExtent: viewState.coverSize,
          mainAxisExtent: coverMainAxisExtent,
          initialCrossAxisCount: initialCrossAxisCount,
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
          padding: gridPadding,
          selectionEnabled: selectionEnabled,
          selectedIds: selectedIds,
          itemIdOf: (item) => item.entry.id,
          onSelectionChanged: onBoxSelectionChanged,
          backgroundColor: palette.gridCanvas,
          itemBuilder: (context, item) => LibraryCoverTile(
            key: ValueKey(item.entry.id),
            entry: item.entry,
            customFieldBadges: item.customFieldBadges,
            active: _isActive(item),
            selected: _isSelectionSelected(item),
            selectionMode: selectionEnabled,
            onTap: _selectionTap(item),
            onSelectionToggleTap: () => onToggleSelectionItem(item.entry.id),
            onDoubleTap: () => onOpenItem(item),
            onEditTap: () => onEditItem(item),
            onSecondaryTapUp: onItemContextMenu == null
                ? null
                : (d) => onItemContextMenu!(item, d.globalPosition),
            coverSize: viewState.coverSize,
            selectedColor: palette.selection,
            accentColor: accent,
            selectionColor: accent,
            mutedTextColor: palette.textMuted,
          ),
        ),
      LibraryViewMode.card => LibraryWorkspaceGrid<LibraryProjectionItem>(
          items: items,
          emptyBuilder: _emptyBuilder,
          maxCrossAxisExtent: isMusicLibrary
              ? musicVerticalTileWidth
              : standardVerticalTileWidth,
          mainAxisExtent: isMusicLibrary
              ? musicVerticalTileHeight
              : standardVerticalTileHeight,
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
          padding: gridPadding,
          selectionEnabled: selectionEnabled,
          selectedIds: selectedIds,
          itemIdOf: (item) => item.entry.id,
          onSelectionChanged: onBoxSelectionChanged,
          backgroundColor: palette.gridCanvas,
          itemBuilder: (context, item) => LibraryWorkspaceCard(
            key: ValueKey(item.entry.id),
            entry: item.entry,
            customFieldBadges: item.customFieldBadges,
            selected: _isHighlighted(item),
            onTap: _selectionTap(item),
            onDoubleTap: () => onOpenItem(item),
            onSecondaryTapUp: onItemContextMenu == null
                ? null
                : (d) => onItemContextMenu!(item, d.globalPosition),
            dateFormatter: formatDate,
            moneyFormatter: formatMoney,
            selectedColor: palette.selection,
            accentColor: accent,
            mutedTextColor: palette.textMuted,
            coverWidth: isMusicLibrary ? viewState.coverSize : cardCoverWidth,
            musicLayout: LibraryMusicCardLayout.vertical,
            cardLayout: LibraryCardLayout.vertical,
            selectionMode: selectionEnabled,
            onSelectionToggleTap: () => onToggleSelectionItem(item.entry.id),
            onEditTap: () => onEditItem(item),
          ),
        ),
      LibraryViewMode.horizontalCards => _buildHorizontalCards(
          cardTileWidth: cardTileWidth,
          cardTileHeight: cardTileHeight,
          cardCoverWidth: cardCoverWidth,
          spacing: gridSpacing,
          backgroundColor: palette.gridCanvas,
        ),
      LibraryViewMode.cardFlow => LibraryFlowCarousel(
          items: items,
          selectedId: selectedId,
          selectedAnchorId: selectedAnchorId,
          selectedIds: const <String>{},
          accent: accent,
          emptyBuilder: _emptyBuilder,
          selectionEnabled: false,
          onApplySelection: (_, __) {},
          onActivateItem: onActivateItem,
          onToggleSelectionItem: (_) {},
          onOpenItem: onOpenItem,
          onEditItem: onEditItem,
          onItemContextMenu: onItemContextMenu,
        ),
      LibraryViewMode.list => _buildTable(),
      LibraryViewMode.shelves => LibraryShelfView<LibraryProjectionItem>(
          items: items,
          entryOf: (item) => item.entry,
          isActive: _isActive,
          isSelected: _isSelectionSelected,
          selectionEnabled: selectionEnabled,
          onTap: (item) => _selectionTap(item)(),
          onToggleSelectionItem: (item) => onToggleSelectionItem(item.entry.id),
          onDoubleTap: onOpenItem,
          onSecondaryTapUp: onItemContextMenu == null
              ? null
              : (item, d) => onItemContextMenu!(item, d.globalPosition),
          accent: accent,
          shelfHeight: coverMainAxisExtent,
          bookWidth: viewState.coverSize,
          emptyBuilder: _emptyBuilder,
        ),
    };
  }

  Widget _emptyBuilder(BuildContext context) {
    return LibraryEmptyState(
      type: type,
      icon: type.workspace.icon,
      accent: accent,
      hasActiveFilter: hasActiveFilter,
      onAdd: onAdd,
      onClearFilter: onClearFilters,
    );
  }

  Widget _buildTable() {
    if (items.isEmpty) {
      return Builder(builder: _emptyBuilder);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final palette = appPalette(context);
        final compact = type.presentation.usesCompactTableLayout;
        final density = viewState.densityPreset;
        final tableWidth = adapter.tableWidthForColumns(
          viewState.visibleColumns,
          viewState.columnWidths,
        );
        final contentWidth = math.max(tableWidth + 16, constraints.maxWidth);
        return ColoredBox(
          color: palette.panel,
          child: _LibraryHorizontalScrollbar(
            child: SizedBox(
              width: contentWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: LibraryWorkspaceTable<LibraryProjectionItem>(
                  entries: items,
                  columns:
                      adapter.orderedTableColumns(viewState.visibleColumns),
                  sortColumn: viewState.sortColumn,
                  sortAscending: viewState.sortAscending,
                  sortRules: viewState.sortRules,
                  columnWidthFor: (column) => adapter.tableColumnWidth(
                    column,
                    viewState.columnWidths,
                  ),
                  defaultColumnWidthFor: adapter.defaultTableColumnWidth,
                  columnSortFor: adapter.columnSort,
                  columnLabelFor: adapter.columnLabel,
                  columnIsNumeric: adapter.columnIsNumeric,
                  cellBuilder: _tableCell,
                  isSelected: _isHighlighted,
                  onEntryTap: (item) => _selectionTap(item)(),
                  onEntryDoubleTap: onOpenItem,
                  onEntrySecondaryTapUp: onItemContextMenu == null
                      ? null
                      : (item, details) =>
                          onItemContextMenu!(item, details.globalPosition),
                  onSortChanged: onSortChanged,
                  onColumnWidthChanged: onColumnWidthChanged,
                  onColumnReordered: onColumnReordered,
                  headerHeight: density.tableHeaderHeight,
                  rowHeight: density.tableRowHeight,
                  columnSpacing: compact ? 6 : 8,
                  horizontalMargin: compact ? 4 : 6,
                  selectionRailWidth: compact ? 1 : 2,
                  headerColor: palette.surface,
                  dividerColor: palette.divider,
                  selectedColor: Color.lerp(Colors.black, accent, 0.45)!,
                  oddColor: palette.tableOddRow,
                  evenColor: palette.tableEvenRow,
                  selectionRailColor: accent,
                  bottomBorderColor: palette.tableBottomBorder,
                  hoverColor: palette.tableHover,
                  accentColor: accent,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalCards({
    required double cardTileWidth,
    required double cardTileHeight,
    required double cardCoverWidth,
    required double spacing,
    required Color backgroundColor,
  }) {
    if (items.isEmpty) {
      return Builder(builder: _emptyBuilder);
    }
    return ColoredBox(
      color: backgroundColor,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(spacing),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final item = items[index];
          final palette = appPalette(context);
          return Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: cardTileWidth,
              height: cardTileHeight,
              child: LibraryWorkspaceCard(
                key: ValueKey(item.entry.id),
                entry: item.entry,
                customFieldBadges: item.customFieldBadges,
                selected: _isHighlighted(item),
                onTap: _selectionTap(item),
                onDoubleTap: () => onOpenItem(item),
                onSecondaryTapUp: onItemContextMenu == null
                    ? null
                    : (d) => onItemContextMenu!(item, d.globalPosition),
                dateFormatter: formatDate,
                moneyFormatter: formatMoney,
                selectedColor: palette.selection,
                accentColor: accent,
                mutedTextColor: palette.textMuted,
                coverWidth: cardCoverWidth,
                musicLayout: LibraryMusicCardLayout.horizontal,
                cardLayout: LibraryCardLayout.horizontal,
                selectionMode: selectionEnabled,
                onSelectionToggleTap: () =>
                    onToggleSelectionItem(item.entry.id),
                onEditTap: () => onEditItem(item),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tableCell(LibraryProjectionItem item, LibraryTableColumn column) {
    return adapter.buildTableCell(item.entry, column);
  }
}

class _LibraryHorizontalScrollbar extends StatefulWidget {
  const _LibraryHorizontalScrollbar({required this.child});

  final Widget child;

  @override
  State<_LibraryHorizontalScrollbar> createState() =>
      _LibraryHorizontalScrollbarState();
}

class _LibraryHorizontalScrollbarState
    extends State<_LibraryHorizontalScrollbar> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        primary: false,
        scrollDirection: Axis.horizontal,
        child: widget.child,
      ),
    );
  }
}

bool isLibraryRangeModifierPressed() {
  return HardwareKeyboard.instance.isShiftPressed;
}

bool isLibraryToggleModifierPressed() {
  final keyboard = HardwareKeyboard.instance;
  return keyboard.isControlPressed || keyboard.isMetaPressed;
}
