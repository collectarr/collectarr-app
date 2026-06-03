import 'dart:math' as math;

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/empty_state.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_flow_carousel.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_shelf_view.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
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
    required this.selectedBucket,
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
  final String? selectedBucket;
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

  bool get _showGrouped =>
      viewState.viewMode != LibraryViewMode.cardFlow &&
      viewState.viewMode != LibraryViewMode.shelves &&
      selectedBucket == null &&
      groupMode != LibraryGroupMode.title &&
      groupMode != LibraryGroupMode.ownership;

  bool _isSelected(LibraryProjectionItem item) {
    if (selectionEnabled) {
      return selectedIds.contains(item.entry.id);
    }
    return item.entry.id == selectedId;
  }

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
      if (_isSelected(item)) {
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
    final cardScale = defaultCoverSize > 0
      ? (viewState.coverSize / defaultCoverSize).clamp(0.78, 1.48)
      : 1.0;
    final cardCoverWidth = (uiPrefs.cardCoverWidth * cardScale)
        .clamp(60.0, 164.0)
        .toDouble();
    final cardTileWidth = (430.0 * cardScale).clamp(336.0, 620.0).toDouble();
    final cardTileHeight = (156.0 * cardScale).clamp(132.0, 228.0).toDouble();
    if (_showGrouped && items.isNotEmpty) {
      return switch (viewState.viewMode) {
        LibraryViewMode.grid => _GroupedGrid(
            items: items,
          adapter: adapter,
            type: type,
            groupMode: groupMode,
            selectedId: selectedId,
          selectionEnabled: selectionEnabled,
          selectedIds: selectedIds,
            accent: accent,
            maxCrossAxisExtent: viewState.coverSize,
            mainAxisExtent: viewState.coverSize * 1.53,
          onSelectionChanged: onBoxSelectionChanged,
            itemBuilder: (context, item) => LibraryCoverTile(
              key: ValueKey(item.entry.id),
              entry: item.entry,
              selected: _isSelected(item),
              onTap: _selectionTap(item),
              onDoubleTap: () => onOpenItem(item),
                onEditTap: () => onEditItem(item),
              onSecondaryTapUp: onItemContextMenu == null
                  ? null
                  : (d) => onItemContextMenu!(item, d.globalPosition),
              selectedColor: palette.selection,
              accentColor: accent,
              selectionColor: accent,
              mutedTextColor: palette.textMuted,
            ),
          ),
        LibraryViewMode.card => _GroupedGrid(
            items: items,
          adapter: adapter,
            type: type,
            groupMode: groupMode,
            selectedId: selectedId,
          selectionEnabled: selectionEnabled,
          selectedIds: selectedIds,
            accent: accent,
            maxCrossAxisExtent: cardTileWidth,
            mainAxisExtent: cardTileHeight,
          onSelectionChanged: onBoxSelectionChanged,
            itemBuilder: (context, item) => LibraryWorkspaceCard(
              key: ValueKey(item.entry.id),
              entry: item.entry,
              selected: _isSelected(item),
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
            ),
          ),
        LibraryViewMode.cardFlow => _GroupedGrid(
            items: items,
          adapter: adapter,
            type: type,
            groupMode: groupMode,
            selectedId: selectedId,
          selectionEnabled: selectionEnabled,
          selectedIds: selectedIds,
            accent: accent,
            maxCrossAxisExtent: 560,
            mainAxisExtent: 204,
          onSelectionChanged: onBoxSelectionChanged,
            itemBuilder: (context, item) => const SizedBox.shrink(),
          ),
        LibraryViewMode.list => _buildTable(),
        LibraryViewMode.shelves =>
          const SizedBox.shrink(), // shelves never grouped
      };
    }
    return switch (viewState.viewMode) {
      LibraryViewMode.grid => LibraryWorkspaceGrid<LibraryProjectionItem>(
          items: items,
          emptyBuilder: _emptyBuilder,
          maxCrossAxisExtent: viewState.coverSize,
          mainAxisExtent: viewState.coverSize * 1.53,
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
            selected: _isSelected(item),
            onTap: _selectionTap(item),
            onDoubleTap: () => onOpenItem(item),
            onEditTap: () => onEditItem(item),
            onSecondaryTapUp: onItemContextMenu == null
                ? null
                : (d) => onItemContextMenu!(item, d.globalPosition),
            selectedColor: palette.selection,
            accentColor: accent,
            selectionColor: accent,
            mutedTextColor: palette.textMuted,
          ),
        ),
      LibraryViewMode.card => LibraryWorkspaceGrid<LibraryProjectionItem>(
          items: items,
          emptyBuilder: _emptyBuilder,
          maxCrossAxisExtent: cardTileWidth,
          mainAxisExtent: cardTileHeight,
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
            selected: _isSelected(item),
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
          ),
        ),
        LibraryViewMode.cardFlow => LibraryFlowCarousel(
          items: items,
          selectedId: selectedId,
          selectedAnchorId: selectedAnchorId,
          selectedIds: selectedIds,
          accent: accent,
          emptyBuilder: _emptyBuilder,
          onApplySelection: onApplySelection,
          onActivateItem: onActivateItem,
          onToggleSelectionItem: onToggleSelectionItem,
          onOpenItem: onOpenItem,
          onItemContextMenu: onItemContextMenu,
        ),
      LibraryViewMode.list => _buildTable(),
      LibraryViewMode.shelves => LibraryShelfView<LibraryProjectionItem>(
          items: items,
          entryOf: (item) => item.entry,
          isSelected: _isSelected,
          onTap: (item) => _selectionTap(item)(),
          onDoubleTap: onOpenItem,
          onSecondaryTapUp: onItemContextMenu == null
              ? null
              : (item, d) => onItemContextMenu!(item, d.globalPosition),
          accent: accent,
          shelfHeight: viewState.coverSize * 1.53,
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
                  isSelected: _isSelected,
                  onEntryTap: (item) => _selectionTap(item)(),
                    onEntryDoubleTap: onOpenItem,
                  onEntrySecondaryTapUp: onItemContextMenu == null
                      ? null
                      : (item, details) =>
                          onItemContextMenu!(item, details.globalPosition),
                  onSortChanged: onSortChanged,
                  onColumnWidthChanged: onColumnWidthChanged,
                  onColumnReordered: onColumnReordered,
                  headerHeight: compact ? 24 : 26,
                  rowHeight: compact ? 30 : 32,
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

class _GroupedGrid extends StatefulWidget {
  const _GroupedGrid({
    required this.items,
    required this.adapter,
    required this.type,
    required this.groupMode,
    required this.selectedId,
    required this.selectionEnabled,
    required this.selectedIds,
    required this.accent,
    required this.maxCrossAxisExtent,
    required this.mainAxisExtent,
    required this.itemBuilder,
    this.onSelectionChanged,
  });

  final List<LibraryProjectionItem> items;
  final LibraryMediaAdapter adapter;
  final LibraryTypeConfig type;
  final LibraryGroupMode groupMode;
  final String? selectedId;
  final bool selectionEnabled;
  final Set<String> selectedIds;
  final Color accent;
  final double maxCrossAxisExtent;
  final double mainAxisExtent;
  final LibraryGridItemBuilder<LibraryProjectionItem> itemBuilder;
  final ValueChanged<Set<String>>? onSelectionChanged;

  @override
  State<_GroupedGrid> createState() => _GroupedGridState();
}

class _GroupedGridState extends State<_GroupedGrid> {
  final _collapsed = <String>{};

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<LibraryProjectionItem>>{};
    for (final item in widget.items) {
      final key =
          genericBucketForItemMode(item, widget.type, widget.groupMode);
      (groups[key] ??= []).add(item);
    }
    final sortedKeys = groups.keys.toList()..sort();

    final useSubGroups = widget.groupMode == LibraryGroupMode.series;

    return ColoredBox(
      color: kAppGridCanvas,
      child: CustomScrollView(
        slivers: [
          for (final key in sortedKeys) ...[
            SliverToBoxAdapter(
              child: _GroupHeader(
                title: key,
                count: groups[key]!.length,
                collapsed: _collapsed.contains(key),
                accent: widget.accent,
                onToggle: () => setState(() {
                  if (_collapsed.contains(key)) {
                    _collapsed.remove(key);
                  } else {
                    _collapsed.add(key);
                  }
                }),
              ),
            ),
            if (!_collapsed.contains(key))
              ..._buildGroupContent(
                groups[key]!,
                useSubGroups: useSubGroups,
              ),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 10)),
        ],
      ),
    );
  }

  List<Widget> _buildGroupContent(
    List<LibraryProjectionItem> items, {
    required bool useSubGroups,
  }) {
    if (!useSubGroups) {
      return [_buildGrid(items)];
    }

    // Check if any item has volume/season data worth sub-grouping.
    final hasSubGroups = items.any(
      (item) =>
          widget.adapter.subgroupKeyForEntry(item.entry, widget.groupMode) !=
          null,
    );
    if (!hasSubGroups) {
      return [_buildGrid(items)];
    }

    // Build sub-groups by volume/season.
    final subGroups = <String, List<LibraryProjectionItem>>{};
    for (final item in items) {
      final subKey =
          widget.adapter.subgroupKeyForEntry(item.entry, widget.groupMode) ??
              '—';
      (subGroups[subKey] ??= []).add(item);
    }
    final sortedSubKeys = subGroups.keys.toList()
      ..sort(
        (left, right) =>
            widget.adapter.compareSubgroupKeys(left, right, widget.groupMode),
      );

    return [
      for (final subKey in sortedSubKeys) ...[
        SliverToBoxAdapter(
          child: _SubGroupHeader(
            title: subKey,
            count: subGroups[subKey]!.length,
            collapsed: _collapsed.contains(subKey),
            accent: widget.accent,
            onToggle: () => setState(() {
              if (_collapsed.contains(subKey)) {
                _collapsed.remove(subKey);
              } else {
                _collapsed.add(subKey);
              }
            }),
          ),
        ),
        if (!_collapsed.contains(subKey)) _buildGrid(subGroups[subKey]!),
      ],
    ];
  }

  Widget _buildGrid(List<LibraryProjectionItem> items) {
    if (widget.onSelectionChanged != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: LibraryWorkspaceGrid<LibraryProjectionItem>(
            items: items,
            itemBuilder: widget.itemBuilder,
            emptyBuilder: (_) => const SizedBox.shrink(),
            maxCrossAxisExtent: widget.maxCrossAxisExtent,
            mainAxisExtent: widget.mainAxisExtent,
            selectionEnabled: widget.selectionEnabled,
            selectedIds: widget.selectedIds,
            itemIdOf: (item) => item.entry.id,
            onSelectionChanged: widget.onSelectionChanged,
            shrinkWrap: true,
            scrollable: false,
            padding: const EdgeInsets.symmetric(vertical: 10),
            backgroundColor: Colors.transparent,
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => widget.itemBuilder(context, items[index]),
          childCount: items.length,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: widget.maxCrossAxisExtent,
          mainAxisExtent: widget.mainAxisExtent,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
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

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.title,
    required this.count,
    required this.collapsed,
    required this.accent,
    required this.onToggle,
  });

  final String title;
  final int count;
  final bool collapsed;
  final Color accent;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            Icon(
              collapsed
                  ? Icons.keyboard_arrow_right
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: accent,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 12,
                color: accent.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubGroupHeader extends StatelessWidget {
  const _SubGroupHeader({
    required this.title,
    required this.count,
    required this.collapsed,
    required this.accent,
    required this.onToggle,
  });

  final String title;
  final int count;
  final bool collapsed;
  final Color accent;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.only(left: 34, right: 14, top: 4, bottom: 4),
        child: Row(
          children: [
            Icon(
              collapsed
                  ? Icons.keyboard_arrow_right
                  : Icons.keyboard_arrow_down,
              size: 16,
              color: accent.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: accent.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 11,
                color: accent.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
