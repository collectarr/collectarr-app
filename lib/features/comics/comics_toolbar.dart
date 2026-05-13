import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_missing_issues.dart';
import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_toolbar_stat.dart';
import 'package:collectarr_app/features/library/workspace/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

enum _BulkToolbarAction { edit, owned, wishlist, remove, clear }

class ComicsToolbar extends StatelessWidget {
  const ComicsToolbar({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.totalCount,
    required this.selectedSeries,
    required this.viewMode,
    required this.detailsLayout,
    required this.coverSize,
    required this.hasActiveFilters,
    required this.missingIssues,
    required this.selectionMode,
    required this.selectedCount,
    required this.onSearch,
    required this.onAddComic,
    required this.onEditFilters,
    required this.onEditColumns,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onShowStats,
    required this.onClearSeries,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onViewPresetSelected,
    required this.onCoverSizeChanged,
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToOwned,
    required this.onBulkMoveToWishlist,
    required this.onBulkRemove,
  });

  final TextEditingController controller;
  final int itemCount;
  final int totalCount;
  final String? selectedSeries;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final double coverSize;
  final bool hasActiveFilters;
  final List<int> missingIssues;
  final bool selectionMode;
  final int selectedCount;
  final ValueChanged<String> onSearch;
  final VoidCallback onAddComic;
  final VoidCallback onEditFilters;
  final VoidCallback onEditColumns;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final VoidCallback onShowStats;
  final VoidCallback onClearSeries;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToOwned;
  final VoidCallback onBulkMoveToWishlist;
  final VoidCallback onBulkRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kClzToolbar,
        border: Border(bottom: BorderSide(color: kClzDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              height: 30,
              child: FilledButton.icon(
                onPressed: onAddComic,
                style: FilledButton.styleFrom(
                  backgroundColor: kClzYellow,
                  foregroundColor: const Color(0xFF151515),
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Add Comics'),
              ),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: 'Scan barcode',
              child: LibraryWorkspaceIconButton(
                icon: Icons.qr_code_scanner,
                onPressed: onScanBarcode,
              ),
            ),
            Tooltip(
              message: 'Refresh metadata',
              child: LibraryWorkspaceIconButton(
                icon: Icons.sync,
                onPressed: onRefreshMetadata,
              ),
            ),
            const LibraryWorkspaceSeparator(color: kClzDivider),
            SizedBox(
              width: 320,
              child: SearchBar(
                controller: controller,
                constraints: const BoxConstraints.tightFor(height: 32),
                hintText: 'Search comics...',
                leading: const Icon(Icons.search),
                trailing: [
                  Tooltip(
                    message: 'Search',
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => onSearch(controller.text),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                    ),
                  ),
                ],
                onSubmitted: onSearch,
              ),
            ),
            if (selectedSeries != null) ...[
              const SizedBox(width: 6),
              InputChip(
                visualDensity: VisualDensity.compact,
                backgroundColor: kClzSelection,
                label: Text(selectedSeries!),
                onDeleted: onClearSeries,
              ),
            ],
            const LibraryWorkspaceSeparator(color: kClzDivider),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message:
                            selectionMode ? 'Exit selection' : 'Select comics',
                        child: LibraryWorkspaceIconButton(
                          onPressed: () =>
                              onSelectionModeChanged(!selectionMode),
                          icon: selectionMode ? Icons.close : Icons.checklist,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (selectionMode) ...[
                        LibraryToolbarStat(
                          label: 'Selected',
                          value: selectedCount,
                        ),
                        const SizedBox(width: 6),
                        PopupMenuButton<_BulkToolbarAction>(
                          tooltip: 'Bulk actions',
                          enabled: selectedCount > 0,
                          icon: const Icon(Icons.more_vert),
                          onSelected: (action) {
                            if (action == _BulkToolbarAction.edit) {
                              onBulkEdit();
                            } else if (action == _BulkToolbarAction.owned) {
                              onBulkMoveToOwned();
                            } else if (action == _BulkToolbarAction.wishlist) {
                              onBulkMoveToWishlist();
                            } else if (action == _BulkToolbarAction.remove) {
                              onBulkRemove();
                            } else if (action == _BulkToolbarAction.clear) {
                              onClearSelection();
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: _BulkToolbarAction.edit,
                              child: ListTile(
                                leading: Icon(Icons.edit_note),
                                title: Text('Bulk edit'),
                              ),
                            ),
                            PopupMenuItem(
                              value: _BulkToolbarAction.owned,
                              child: ListTile(
                                leading: Icon(Icons.inventory_2_outlined),
                                title: Text('Move to owned'),
                              ),
                            ),
                            PopupMenuItem(
                              value: _BulkToolbarAction.wishlist,
                              child: ListTile(
                                leading: Icon(Icons.star_border),
                                title: Text('Move to wishlist'),
                              ),
                            ),
                            PopupMenuItem(
                              value: _BulkToolbarAction.remove,
                              child: ListTile(
                                leading: Icon(Icons.delete_outline),
                                title: Text('Remove selected'),
                              ),
                            ),
                            PopupMenuItem(
                              value: _BulkToolbarAction.clear,
                              child: ListTile(
                                leading: Icon(Icons.deselect),
                                title: Text('Clear selection'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                      ],
                      Tooltip(
                        message: 'Local statistics',
                        child: LibraryWorkspaceIconButton(
                          onPressed: onShowStats,
                          icon: Icons.query_stats,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Missing issues',
                        child: Badge(
                          isLabelVisible: missingIssues.isNotEmpty,
                          label: Text(missingIssues.length.toString()),
                          child: LibraryWorkspaceIconButton(
                            onPressed: missingIssues.isEmpty
                                ? null
                                : () => showComicsMissingIssuesDialog(
                                      context,
                                      selectedSeries: selectedSeries,
                                      missingIssues: missingIssues,
                                    ),
                            icon: Icons.format_list_numbered,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Filters',
                        child: Badge(
                          isLabelVisible: hasActiveFilters,
                          child: LibraryWorkspaceIconButton(
                            onPressed: onEditFilters,
                            icon: Icons.filter_list,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Select columns',
                        child: LibraryWorkspaceIconButton(
                          onPressed: viewMode == LibraryViewMode.list
                              ? onEditColumns
                              : null,
                          icon: Icons.view_column,
                        ),
                      ),
                      const SizedBox(width: 6),
                      LibraryToolbarStat(label: 'Shown', value: itemCount),
                      const SizedBox(width: 6),
                      LibraryToolbarStat(label: 'Total', value: totalCount),
                      const SizedBox(width: 6),
                      LibraryViewControls(
                        viewMode: viewMode,
                        detailsLayout: detailsLayout,
                        coverSize: coverSize,
                        minCoverSize: kComicsMinCoverSize,
                        maxCoverSize: kComicsMaxCoverSize,
                        onViewModeChanged: onViewModeChanged,
                        onDetailsLayoutChanged: onDetailsLayoutChanged,
                        onCoverSizeChanged: onCoverSizeChanged,
                        onPresetSelected: onViewPresetSelected,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
