import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/compact_toolbar.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/tools_menu.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_view_table_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_control_models.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class LibraryToolbar extends StatelessWidget {
  const LibraryToolbar({
    super.key,
    required this.type,
    required this.searchController,
    required this.viewState,
    required this.adapter,
    required this.counts,
    required this.onAdd,
    required this.onScan,
    required this.onSearchChanged,
    required this.onEditColumns,
    required this.onSortChanged,
    this.onEditSort,
    required this.onSidebarVisibilityChanged,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onCoverSizeChanged,
    required this.selectedBucket,
    required this.onClearBucket,
    required this.onRefreshMetadata,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.onCollectionStatusScopeChanged,
    required this.quickView,
    required this.onQuickViewSelected,
    this.availableLetters = const {},
    this.selectedLetter,
    this.onLetterSelected,
    this.activeViewPreset,
    this.onViewPresetSelected,
    this.sortFavorites = const [],
    this.activeSortFavoriteId,
    this.onSortFavoriteSelected,
    this.columnFavoritePresets = const [],
    this.activeColumnFavoriteLabel,
    this.onColumnFavoriteSelected,
    this.canJumpToIssue = false,
    this.onJumpToIssue,
    required this.hasActiveFilters,
    required this.onClearFilters,
    this.onEditFilters,
    this.activeFilterCount = 0,
    this.onRandomPick,
    this.onScanCover,
    this.onDownloadAllCovers,
    this.selectionEnabled = false,
    this.selectedCount = 0,
    this.selectionCallbacks,
    this.shelfState,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onEditTagPickList,
    this.onTransferFieldData,
    this.onReassignIndex,
    this.onPrintReport,
    this.onShareCollection,
  });

  final LibraryTypeConfig type;
  final TextEditingController searchController;
  final LibraryWorkspaceViewState viewState;
  final LibraryMediaAdapter adapter;
  final LibraryToolbarCounts counts;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onEditColumns;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final VoidCallback? onEditSort;
  final ValueChanged<bool> onSidebarVisibilityChanged;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final String? selectedBucket;
  final VoidCallback onClearBucket;
  final VoidCallback onRefreshMetadata;
  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final LibraryQuickView? quickView;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final ValueChanged<String?>? onLetterSelected;
  final LibraryWorkspacePreset? activeViewPreset;
  final ValueChanged<LibraryWorkspacePreset>? onViewPresetSelected;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
  final bool canJumpToIssue;
  final VoidCallback? onJumpToIssue;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final VoidCallback? onEditFilters;
  final int activeFilterCount;
  final VoidCallback? onRandomPick;
  final VoidCallback? onScanCover;
  final VoidCallback? onDownloadAllCovers;
  final ShelfState? shelfState;
  final bool selectionEnabled;
  final int selectedCount;
  final LibrarySelectionCallbacks? selectionCallbacks;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onEditTagPickList;
  final VoidCallback? onTransferFieldData;
  final VoidCallback? onReassignIndex;
  final VoidCallback? onPrintReport;
  final VoidCallback? onShareCollection;

  @override
  Widget build(BuildContext context) {
    final targetAccent = libraryAccentForKind(type.workspace.kind);
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: targetAccent),
      duration: kAppAnimNormal,
      curve: Curves.easeOutCubic,
      builder: (context, color, _) {
        final accent = color ?? targetAccent;
        return LibraryToolbarFrame(
          backgroundColor: kAppToolbar,
          dividerColor: kAppDivider,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return CompactLibraryToolbar(
                  type: type,
                  searchController: searchController,
                  counts: counts,
                  selectedBucket: selectedBucket,
                  onAdd: onAdd,
                  onScan: onScan,
                  onSearchChanged: onSearchChanged,
                  onRefreshMetadata: onRefreshMetadata,
                  onViewModeChanged: onViewModeChanged,
                  onCoverSizeChanged: onCoverSizeChanged,
                  quickView: quickView,
                  onQuickViewSelected: onQuickViewSelected,
                  hasActiveFilters: hasActiveFilters,
                  onClearFilters: onClearFilters,
                  onRandomPick: onRandomPick,
                  onDownloadAllCovers: onDownloadAllCovers,
                  onEditConditionPickList: onEditConditionPickList,
                  onEditGradePickList: onEditGradePickList,
                  onEditTagPickList: onEditTagPickList,
                  onEditSort: onEditSort,
                );
              }

              final showChromeRow = onCollectionStatusScopeChanged != null ||
                  onViewPresetSelected != null ||
                  (sortFavorites.isNotEmpty &&
                      onSortFavoriteSelected != null) ||
                  (columnFavoritePresets.isNotEmpty &&
                      onColumnFavoriteSelected != null) ||
                  canJumpToIssue;
              final showAlphabetRow =
                  availableLetters.isNotEmpty && onLetterSelected != null;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        LibraryToolbarPrimaryActions(
                          addLabel: 'Add ${type.pluralLabel}',
                          onAdd: onAdd,
                          onScanBarcode: onScan,
                          onRefreshMetadata: onRefreshMetadata,
                          onRandomPick: onRandomPick,
                          onScanCover: onScanCover,
                          addBackgroundColor: accent,
                          addForegroundColor:
                              _toolbarForegroundForAccent(accent),
                        ),
                        const LibraryWorkspaceSeparator(color: kAppDivider),
                        LibraryToolbarSearch(
                          controller: searchController,
                          hintText:
                              'Search ${type.pluralLabel.toLowerCase()}...',
                          selectedFilterLabel: selectedBucket,
                          onSearch: onSearchChanged,
                          onClearFilter: onClearBucket,
                          onChanged: onSearchChanged,
                          selectionColor: kAppSelection,
                        ),
                        const SizedBox(width: 8),
                        _ItemCountLabel(
                          shown: counts.shown,
                          total: counts.total,
                          pluralLabel: type.pluralLabel,
                        ),
                        if (counts.totalPricePaidCents > 0) ...[
                          const SizedBox(width: 8),
                          _CollectionValueChip(
                            totalPaidCents: counts.totalPricePaidCents,
                            totalCoverCents: counts.totalCoverPriceCents,
                            totalSellCents: counts.totalSellPriceCents,
                            currency: counts.priceCurrency,
                          ),
                        ],
                        const Spacer(),
                        LibraryWorkspaceControlStrip(
                          children: [
                            LibraryToolsButton(
                              type: type,
                              counts: counts,
                              selectedBucket: selectedBucket,
                              quickView: quickView,
                              hasActiveFilters: hasActiveFilters,
                              onQuickViewSelected: onQuickViewSelected,
                              onClearFilters: onClearFilters,
                              onRandomPick: onRandomPick,
                              onDownloadAllCovers: onDownloadAllCovers,
                              shelfState: shelfState,
                              onSmartLists: onSmartLists,
                              onFolders: onFolders,
                              onReadingQueue: onReadingQueue,
                              onEditConditionPickList: onEditConditionPickList,
                              onEditGradePickList: onEditGradePickList,
                              onEditTagPickList: onEditTagPickList,
                              onEditSort: onEditSort,
                              onTransferFieldData: onTransferFieldData,
                              onReassignIndex: onReassignIndex,
                              onPrintReport: onPrintReport,
                              onShareCollection: onShareCollection,
                            ),
                            if (onEditFilters != null)
                              _FilterButton(
                                activeCount: activeFilterCount,
                                onPressed: onEditFilters!,
                              ),
                            LibraryViewTableControls(
                              state: LibraryViewTableControlState(
                                counts: LibraryWorkspaceCounts(
                                  shown: counts.shown,
                                  total: counts.total,
                                ),
                                viewMode: viewState.viewMode,
                                detailsLayout: viewState.detailsLayout,
                                isSidebarVisible: viewState.isSidebarVisible,
                                coverSize: viewState.coverSize,
                                minCoverSize: adapter.viewProfile.minCoverSize,
                                maxCoverSize: adapter.viewProfile.maxCoverSize,
                              ),
                              callbacks: LibraryViewTableControlCallbacks(
                                onEditColumns: onEditColumns,
                                onSidebarVisibilityChanged:
                                    onSidebarVisibilityChanged,
                                onViewModeChanged: onViewModeChanged,
                                onDetailsLayoutChanged: onDetailsLayoutChanged,
                                onCoverSizeChanged: onCoverSizeChanged,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (selectionCallbacks != null && selectedCount > 0) ...[
                    const _ToolbarDividerLine(),
                    _SelectionToolbarBand(
                      selectedCount: selectedCount,
                      callbacks: selectionCallbacks!,
                    ),
                  ],
                  if (showChromeRow) ...[
                    const _ToolbarDividerLine(),
                    _ToolbarChromeRow(
                      collectionStatusScope: collectionStatusScope,
                      onCollectionStatusScopeChanged:
                          onCollectionStatusScopeChanged,
                      activeViewPreset: activeViewPreset,
                      onViewPresetSelected: onViewPresetSelected,
                      sortFavorites: sortFavorites,
                      activeSortFavoriteId: activeSortFavoriteId,
                      onSortFavoriteSelected: onSortFavoriteSelected,
                      columnFavoritePresets: columnFavoritePresets,
                      activeColumnFavoriteLabel: activeColumnFavoriteLabel,
                      onColumnFavoriteSelected: onColumnFavoriteSelected,
                      onManageColumns: onEditColumns,
                      canJumpToIssue: canJumpToIssue,
                      onJumpToIssue: onJumpToIssue,
                    ),
                  ],
                  if (showAlphabetRow) ...[
                    const _ToolbarDividerLine(),
                    _ToolbarAlphabetRow(
                      letters: availableLetters,
                      selectedLetter: selectedLetter,
                      onLetterSelected: onLetterSelected!,
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}

Color _toolbarForegroundForAccent(Color accent) {
  return Colors.white;
}

class _ToolbarDividerLine extends StatelessWidget {
  const _ToolbarDividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: kAppDivider);
  }
}

class _SelectionToolbarBand extends StatelessWidget {
  const _SelectionToolbarBand({
    required this.selectedCount,
    required this.callbacks,
  });

  final int selectedCount;
  final LibrarySelectionCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.select_all, size: 16, color: kAppTextMuted),
          const SizedBox(width: 8),
          Text(
            'Selection',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          LibrarySelectionControls(
            selectedCount: selectedCount,
            callbacks: callbacks,
          ),
        ],
      ),
    );
  }
}

class _ToolbarChromeRow extends StatelessWidget {
  const _ToolbarChromeRow({
    required this.collectionStatusScope,
    this.onCollectionStatusScopeChanged,
    this.activeViewPreset,
    this.onViewPresetSelected,
    this.sortFavorites = const [],
    this.activeSortFavoriteId,
    this.onSortFavoriteSelected,
    this.columnFavoritePresets = const [],
    this.activeColumnFavoriteLabel,
    this.onColumnFavoriteSelected,
    required this.onManageColumns,
    this.canJumpToIssue = false,
    this.onJumpToIssue,
  });

  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final LibraryWorkspacePreset? activeViewPreset;
  final ValueChanged<LibraryWorkspacePreset>? onViewPresetSelected;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
  final VoidCallback onManageColumns;
  final bool canJumpToIssue;
  final VoidCallback? onJumpToIssue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            if (onCollectionStatusScopeChanged != null)
              PopupMenuButton<LibraryCollectionStatusScope>(
                initialValue: collectionStatusScope,
                tooltip: 'Collection scope',
                onSelected: onCollectionStatusScopeChanged,
                itemBuilder: (context) => [
                  for (final scope in LibraryCollectionStatusScope.values)
                    PopupMenuItem<LibraryCollectionStatusScope>(
                      value: scope,
                      child: ListTile(
                        dense: true,
                        leading: Icon(scope.icon, size: 18),
                        title: Text(scope.label),
                        trailing: scope == collectionStatusScope
                            ? const Icon(Icons.check, size: 18)
                            : null,
                      ),
                    ),
                ],
                child: _ToolbarChromeButton(
                  icon: collectionStatusScope.icon,
                  label: collectionStatusScope.label,
                ),
              ),
            if (onCollectionStatusScopeChanged != null)
              const SizedBox(width: 6),
            if (onViewPresetSelected != null)
              PopupMenuButton<LibraryWorkspacePreset>(
                initialValue: activeViewPreset,
                tooltip: 'View favorites',
                onSelected: onViewPresetSelected,
                itemBuilder: (context) => [
                  for (final preset in LibraryWorkspacePreset.values)
                    PopupMenuItem<LibraryWorkspacePreset>(
                      value: preset,
                      child: ListTile(
                        dense: true,
                        leading: Icon(preset.icon, size: 18),
                        title: Text(preset.label),
                        trailing: preset == activeViewPreset
                            ? const Icon(Icons.check, size: 18)
                            : null,
                      ),
                    ),
                ],
                child: _ToolbarChromeButton(
                  icon: (activeViewPreset ?? LibraryWorkspacePreset.cover).icon,
                  label: activeViewPreset?.label ?? 'View favorites',
                ),
              ),
            if (onViewPresetSelected != null) const SizedBox(width: 6),
            if (sortFavorites.isNotEmpty && onSortFavoriteSelected != null)
              PopupMenuButton<LibrarySortFavorite>(
                tooltip: 'Sorting favorites',
                initialValue: _activeSortFavorite(),
                onSelected: onSortFavoriteSelected,
                itemBuilder: (context) => [
                  for (final favorite in sortFavorites)
                    PopupMenuItem<LibrarySortFavorite>(
                      value: favorite,
                      child: ListTile(
                        dense: true,
                        leading: Icon(favorite.icon, size: 18),
                        title: Text(favorite.label),
                        trailing: favorite.id == activeSortFavoriteId
                            ? const Icon(Icons.check, size: 18)
                            : null,
                      ),
                    ),
                ],
                child: _ToolbarChromeButton(
                  icon: _activeSortFavorite()?.icon ?? Icons.sort,
                  label: _activeSortFavorite()?.label ?? 'Sorting favorites',
                ),
              ),
            if (sortFavorites.isNotEmpty && onSortFavoriteSelected != null)
              const SizedBox(width: 6),
            if (onColumnFavoriteSelected != null)
              PopupMenuButton<Object>(
                tooltip: 'Column favorites',
                onSelected: (selection) {
                  if (selection
                      is _ToolbarPresetSelection<LibraryTableColumnPreset>) {
                    onColumnFavoriteSelected!(selection.value);
                    return;
                  }
                  if (selection is _ToolbarActionSelection) {
                    selection.onSelected();
                  }
                },
                itemBuilder: (context) => [
                  for (final preset in columnFavoritePresets)
                    PopupMenuItem<Object>(
                      value: _ToolbarPresetSelection<LibraryTableColumnPreset>(
                          preset),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.view_column, size: 18),
                        title: Text(preset.label),
                        trailing: preset.label == activeColumnFavoriteLabel
                            ? const Icon(Icons.check, size: 18)
                            : null,
                      ),
                    ),
                  const PopupMenuDivider(),
                  PopupMenuItem<Object>(
                    value: _ToolbarActionSelection(onManageColumns),
                    child: const ListTile(
                      dense: true,
                      leading: Icon(Icons.tune, size: 18),
                      title: Text('Manage columns...'),
                    ),
                  ),
                ],
                child: _ToolbarChromeButton(
                  icon: Icons.view_column,
                  label: activeColumnFavoriteLabel ?? 'Column favorites',
                ),
              ),
            if (onColumnFavoriteSelected != null) const SizedBox(width: 6),
            if (canJumpToIssue && onJumpToIssue != null)
              _ToolbarChromeButton(
                icon: Icons.tag,
                label: 'Jump to issue',
                onPressed: onJumpToIssue,
              ),
          ],
        ),
      ),
    );
  }

  LibrarySortFavorite? _activeSortFavorite() {
    for (final favorite in sortFavorites) {
      if (favorite.id == activeSortFavoriteId) {
        return favorite;
      }
    }
    return null;
  }
}

class _ToolbarAlphabetRow extends StatelessWidget {
  const _ToolbarAlphabetRow({
    required this.letters,
    required this.selectedLetter,
    required this.onLetterSelected,
  });

  final Set<String> letters;
  final String? selectedLetter;
  final ValueChanged<String?> onLetterSelected;

  @override
  Widget build(BuildContext context) {
    final sortedLetters = letters.toList(growable: false)..sort();
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            ChoiceChip(
              selected: selectedLetter == null,
              onSelected: (_) => onLetterSelected(null),
              label: const Text('All'),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 6),
            for (final letter in sortedLetters) ...[
              ChoiceChip(
                selected: selectedLetter == letter,
                onSelected: (_) =>
                    onLetterSelected(selectedLetter == letter ? null : letter),
                label: Text(letter),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolbarChromeButton extends StatelessWidget {
  const _ToolbarChromeButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}

class _ToolbarPresetSelection<T> {
  const _ToolbarPresetSelection(this.value);

  final T value;
}

class _ToolbarActionSelection {
  const _ToolbarActionSelection(this.onSelected);

  final VoidCallback onSelected;
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.activeCount,
    required this.onPressed,
  });

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: activeCount > 0,
      label: Text(activeCount.toString()),
      child: IconButton(
        icon: Icon(
          activeCount > 0 ? Icons.filter_alt : Icons.filter_alt_outlined,
          size: 20,
        ),
        tooltip: 'Edit filters',
        onPressed: onPressed,
      ),
    );
  }
}

class _ItemCountLabel extends StatelessWidget {
  const _ItemCountLabel({
    required this.shown,
    required this.total,
    required this.pluralLabel,
  });

  final int shown;
  final int total;
  final String pluralLabel;

  @override
  Widget build(BuildContext context) {
    final label = shown == total
        ? '$total ${pluralLabel.toLowerCase()}'
        : '$shown of $total ${pluralLabel.toLowerCase()}';
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        color: kAppTextMuted,
      ),
    );
  }
}

class _CollectionValueChip extends StatelessWidget {
  const _CollectionValueChip({
    required this.totalPaidCents,
    required this.totalCoverCents,
    required this.totalSellCents,
    required this.currency,
  });

  final int totalPaidCents;
  final int totalCoverCents;
  final int totalSellCents;
  final String? currency;

  String _fmt(int cents) {
    final cur = currency ?? 'USD';
    return '${(cents / 100).toStringAsFixed(2)} $cur';
  }

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (totalPaidCents > 0) parts.add('Paid ${_fmt(totalPaidCents)}');
    if (totalCoverCents > 0) parts.add('Cover ${_fmt(totalCoverCents)}');
    if (totalSellCents > 0) parts.add('Sold ${_fmt(totalSellCents)}');
    if (parts.isEmpty) return const SizedBox.shrink();
    return Tooltip(
      message: parts.join('\n'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_money,
                size: 13, color: Colors.greenAccent.withValues(alpha: 0.8)),
            const SizedBox(width: 3),
            Text(
              _fmt(totalPaidCents > 0 ? totalPaidCents : totalCoverCents),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.greenAccent.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
