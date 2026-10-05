import 'dart:math' as math;

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/empty_state.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_flow_carousel.dart';
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
  required LibraryKindRegistration type,
  required double coverSize,
}) {
  return coverSize * libraryViewProfileForKind(type.kind).coverGridHeightFactor;
}

class LibraryWorkspace extends ConsumerWidget {
  const LibraryWorkspace({
    super.key,
    required this.type,
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

  final LibraryKindRegistration type;
  final List<LibraryProjectionItem> items;
  final LibraryWorkspaceViewState viewState;
  final String? selectedId;
  final String? selectedAnchorId;
  final bool selectionEnabled;
  final Set<String> selectedIds;
  final String groupMode;
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
  final ValueChanged<String> onSortChanged;
  final void Function(String column, double width) onColumnWidthChanged;
  final void Function(String column, String? beforeColumn) onColumnReordered;
  final LibraryItemContextMenuCallback? onItemContextMenu;
  final int? initialCrossAxisCount;

  bool _isActive(LibraryProjectionItem item) => item.target.id == selectedId;

  bool _isSelectionSelected(LibraryProjectionItem item) =>
      selectedIds.contains(item.target.id);

  bool _isHighlighted(LibraryProjectionItem item) =>
      selectionEnabled ? _isSelectionSelected(item) : _isActive(item);

  VoidCallback _selectionTap(LibraryProjectionItem item) {
    return () {
      final isRangeSelection = isLibraryRangeModifierPressed();
      final isToggleSelection = isLibraryToggleModifierPressed();
      if (isRangeSelection) {
        final anchorId = selectedAnchorId ?? selectedId ?? item.target.id;
        final orderedIds = <String>[
          for (final candidate in items) candidate.target.id
        ];
        final rangeIds = selectionRangeItemIds(
          orderedIds,
          anchorId: anchorId,
          targetId: item.target.id,
        );
        onApplySelection(
          isToggleSelection ? {...selectedIds, ...rangeIds} : rangeIds,
          item.target.id,
        );
        return;
      }
      if (isToggleSelection) {
        onToggleSelectionItem(item.target.id);
        return;
      }
      if (_isActive(item) && !selectionEnabled) {
        return;
      }
      onActivateItem(item.target.id);
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiPrefs = ref.watch(uiPreferencesProvider);
    final palette = appPalette(context);
    final gridSpacing = uiPrefs.gridSpacing;
    final gridPadding = EdgeInsets.all(uiPrefs.gridSpacing);
    final registration = type;
    final defaultCoverSize =
        libraryViewProfileForKind(registration.kind).defaultCoverSize;
    final viewProfile = libraryViewProfileForKind(registration.kind);
    final fallbackCoverAspectRatio = 1 / viewProfile.coverGridHeightFactor;
    final cardLayout = viewProfile.cardLayout;
    final usesCoverFocusedCards =
        cardLayout == LibraryWorkspaceCardLayout.coverFocused;
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
    final coverFocusedTileWidth =
        ((viewState.coverSize + 56) * density.cardScaleFactor)
            .clamp(164.0, 248.0)
            .toDouble();
    final coverFocusedTileHeight = (viewState.coverSize *
            (1.38 + ((density.cardScaleFactor - 0.86) * 0.5)))
        .clamp(224.0, 360.0)
        .toDouble();
    final coverMainAxisExtent = libraryWorkspaceGridMainAxisExtent(
      type: type,
      coverSize: viewState.coverSize,
    );

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
          itemIdOf: (item) => item.target.id,
          onSelectionChanged: onBoxSelectionChanged,
          backgroundColor: palette.gridCanvas,
          itemBuilder: (context, item) => LibraryCoverTile(
            key: ValueKey(item.target.id),
            item: item,
            customFieldBadges: item.customFieldBadges,
            active: _isActive(item),
            selected: _isSelectionSelected(item),
            selectionMode: selectionEnabled,
            onTap: _selectionTap(item),
            onSelectionToggleTap: () => onToggleSelectionItem(item.target.id),
            onDoubleTap: () => onOpenItem(item),
            onEditTap: () => onEditItem(item),
            onSecondaryTapUp: onItemContextMenu == null
                ? null
                : (d) => onItemContextMenu!(item, d.globalPosition),
            coverSize: viewState.coverSize,
            fallbackCoverAspectRatio: fallbackCoverAspectRatio,
            selectedColor: palette.selection,
            accentColor: accent,
            selectionColor: accent,
            mutedTextColor: palette.textMuted,
          ),
        ),
      LibraryViewMode.card => LibraryWorkspaceGrid<LibraryProjectionItem>(
          items: items,
          emptyBuilder: _emptyBuilder,
          maxCrossAxisExtent: usesCoverFocusedCards
              ? coverFocusedTileWidth
              : standardVerticalTileWidth,
          mainAxisExtent: usesCoverFocusedCards
              ? coverFocusedTileHeight
              : standardVerticalTileHeight,
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
          padding: gridPadding,
          selectionEnabled: selectionEnabled,
          selectedIds: selectedIds,
          itemIdOf: (item) => item.target.id,
          onSelectionChanged: onBoxSelectionChanged,
          backgroundColor: palette.gridCanvas,
          itemBuilder: (context, item) => LibraryWorkspaceCard(
            key: ValueKey(item.target.id),
            item: item,
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
            coverWidth:
                usesCoverFocusedCards ? viewState.coverSize : cardCoverWidth,
            cardLayout: LibraryCardLayout.vertical,
            selectionMode: selectionEnabled,
            onSelectionToggleTap: () => onToggleSelectionItem(item.target.id),
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
          entryOf: (item) => item,
          isActive: _isActive,
          isSelected: _isSelectionSelected,
          selectionEnabled: selectionEnabled,
          onTap: (item) => _selectionTap(item)(),
          onToggleSelectionItem: (item) => onToggleSelectionItem(item.target.id),
          onDoubleTap: onOpenItem,
          onSecondaryTapUp: onItemContextMenu == null
              ? null
              : (item, d) => onItemContextMenu!(item, d.globalPosition),
          accent: accent,
          shelfHeight: coverMainAxisExtent,
          bookWidth: viewState.coverSize,
          fallbackCoverAspectRatio: fallbackCoverAspectRatio,
          emptyBuilder: _emptyBuilder,
        ),
    };
  }

  Widget _emptyBuilder(BuildContext context) {
    return LibraryEmptyState(
      type: type,
      icon: type.identity.icon,
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
        final density = viewState.densityPreset;
        final registration = type;
        final workspace = libraryKindWorkspaceForKind(registration.kind);
        final schemaNode = items.first.target;
        final visibleColumns = workspace.orderedTableColumns(
          viewState.visibleColumnIds,
          target: schemaNode,
        );
        final tableWidth = workspace.tableWidthForColumns(
          viewState.visibleColumnIds,
          viewState.columnWidths,
          target: schemaNode,
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
                  columns: [for (final column in visibleColumns) column.value],
                  sortColumn: viewState.sortId.value,
                  sortAscending: viewState.sortAscending,
                  sortRules: [
                    for (final rule in viewState.sortRules)
                      LibrarySortRule(
                        column: rule.sortId.value,
                        ascending: rule.ascending,
                      ),
                  ],
                  columnWidthFor: (column) => workspace.tableColumnWidth(
                    workspace.fieldsForTarget(schemaNode).decodeColumnId(column),
                    viewState.columnWidths,
                    target: schemaNode,
                  ),
                  defaultColumnWidthFor: (column) =>
                      workspace.defaultTableColumnWidth(
                    workspace.fieldsForTarget(schemaNode).decodeColumnId(column),
                    target: schemaNode,
                  ),
                  columnSortFor: (column) => workspace
                      .columnSort(
                          workspace
                              .fieldsForTarget(schemaNode)
                              .decodeColumnId(column),
                          target: schemaNode)
                      ?.value,
                  columnLabelFor: (column) => workspace.columnLabel(
                    workspace.fieldsForTarget(schemaNode).decodeColumnId(column),
                    target: schemaNode,
                  ),
                  columnIsNumeric: (column) => workspace.columnIsNumeric(
                    workspace.fieldsForTarget(schemaNode).decodeColumnId(column),
                    target: schemaNode,
                  ),
                  cellBuilder: (entry, column) => _tableCell(entry, column),
                  isSelected: _isHighlighted,
                  onEntryTap: (item) => _selectionTap(item)(),
                  onEntryDoubleTap: onOpenItem,
                  onEntrySecondaryTapUp: onItemContextMenu == null
                      ? null
                      : (item, details) =>
                          onItemContextMenu!(item, details.globalPosition),
                  onSortChanged: (column) => onSortChanged(column),
                  onColumnWidthChanged: (column, width) =>
                      onColumnWidthChanged(column, width),
                  onColumnReordered: (column, beforeColumn) =>
                      onColumnReordered(
                    column,
                    beforeColumn,
                  ),
                  headerHeight: density.tableHeaderHeight,
                  rowHeight: density.tableRowHeight,
                  columnSpacing: 8,
                  horizontalMargin: 6,
                  selectionRailWidth: 2,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Horizontal cards describe the card orientation, not a forced
        // single-row carousel. Keep the tile wide enough for its content,
        // while allowing the grid to wrap cards into additional rows when
        // the workspace is narrower than the preferred tile width.
        final availableTileWidth = constraints.hasBoundedWidth
            ? math.max(1.0, constraints.maxWidth - (spacing * 2))
            : cardTileWidth;
        final tileWidth = math.min(cardTileWidth, availableTileWidth);
        final tileCoverWidth = math.min(
          cardCoverWidth,
          math.max(48.0, tileWidth - 90.0),
        );
        return LibraryWorkspaceGrid<LibraryProjectionItem>(
          items: items,
          emptyBuilder: _emptyBuilder,
          maxCrossAxisExtent: tileWidth,
          mainAxisExtent: cardTileHeight,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          padding: EdgeInsets.all(spacing),
          selectionEnabled: selectionEnabled,
          selectedIds: selectedIds,
          itemIdOf: (item) => item.target.id,
          onSelectionChanged: onBoxSelectionChanged,
          backgroundColor: backgroundColor,
          itemBuilder: (context, item) {
            final palette = appPalette(context);
            return LibraryWorkspaceCard(
              key: ValueKey(item.target.id),
              item: item,
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
              coverWidth: tileCoverWidth,
              cardLayout: LibraryCardLayout.horizontal,
              selectionMode: selectionEnabled,
              onSelectionToggleTap: () => onToggleSelectionItem(item.target.id),
              onEditTap: () => onEditItem(item),
            );
          },
        );
      },
    );
  }

  Widget _tableCell(LibraryProjectionItem item, String column) {
    final registration = type;
    final workspace = libraryKindWorkspaceForKind(registration.kind);
    return workspace.buildTableCell(
      item,
      workspace.fieldsForTarget(item.target).decodeColumnId(column),
    );
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
