import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/compact_toolbar.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
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
    required this.quickView,
    required this.onQuickViewSelected,
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
  final LibraryQuickView? quickView;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                  addForegroundColor: _toolbarForegroundForAccent(accent),
                ),
                const LibraryWorkspaceSeparator(color: kAppDivider),
                LibraryToolbarSearch(
                  controller: searchController,
                  hintText: 'Search ${type.pluralLabel.toLowerCase()}...',
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
                if (selectionCallbacks != null)
                  LibrarySelectionControls(
                    selectedCount: selectedCount,
                    callbacks: selectionCallbacks!,
                  ),
                if (selectionCallbacks != null && selectedCount > 0)
                  const LibraryWorkspaceSeparator(color: kAppDivider),
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
                        onSidebarVisibilityChanged: onSidebarVisibilityChanged,
                        onViewModeChanged: onViewModeChanged,
                        onDetailsLayoutChanged: onDetailsLayoutChanged,
                        onCoverSizeChanged: onCoverSizeChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          activeCount > 0
              ? Icons.filter_alt
              : Icons.filter_alt_outlined,
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
            Icon(Icons.attach_money, size: 13, color: Colors.greenAccent.withValues(alpha: 0.8)),
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
