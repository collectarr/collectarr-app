import 'package:collectarr_app/features/comics/comics_duplicate_items.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_missing_issues.dart';
import 'package:collectarr_app/features/comics/comics_workspace_control_models.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:flutter/material.dart';

class ComicsWorkspaceUtilityControls extends StatelessWidget {
  const ComicsWorkspaceUtilityControls({
    super.key,
    required this.state,
    required this.callbacks,
  });

  final ComicsWorkspaceUtilityState state;
  final ComicsWorkspaceUtilityCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Local statistics',
          child: LibraryWorkspaceIconButton(
            onPressed: callbacks.onShowStats,
            icon: Icons.query_stats,
          ),
        ),
        const SizedBox(width: 6),
        PopupMenuButton<ComicsShelfQuickView>(
          tooltip: 'Shelf views',
          initialValue: state.quickView,
          icon: Icon(
            state.quickView?.icon ?? Icons.saved_search_outlined,
            size: 18,
          ),
          onSelected: callbacks.onQuickViewSelected,
          itemBuilder: (context) => [
            for (final view in ComicsShelfQuickView.values)
              PopupMenuItem(
                value: view,
                child: ListTile(
                  dense: true,
                  leading: Icon(view.icon),
                  title: Text(view.label),
                ),
              ),
          ],
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Missing issues',
          child: Badge(
            isLabelVisible: state.missingIssues.isNotEmpty,
            label: Text(state.missingIssues.length.toString()),
            child: LibraryWorkspaceIconButton(
              onPressed: state.missingIssues.isEmpty
                  ? null
                  : () => showComicsMissingIssuesDialog(
                        context,
                        selectedSeries: state.selectedSeries,
                        missingIssues: state.missingIssues,
                      ),
              icon: Icons.format_list_numbered,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Duplicate candidates',
          child: Badge(
            isLabelVisible: state.duplicateGroups.isNotEmpty,
            label: Text(state.duplicateGroups.length.toString()),
            child: LibraryWorkspaceIconButton(
              onPressed: state.duplicateGroups.isEmpty
                  ? null
                  : () => showComicsDuplicateItemsDialog(
                        context,
                        duplicateGroups: state.duplicateGroups,
                      ),
              icon: Icons.content_copy,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Filters',
          child: Badge(
            isLabelVisible: state.hasActiveFilters,
            label: Text(state.activeFilterCount.toString()),
            child: LibraryWorkspaceIconButton(
              onPressed: callbacks.onEditFilters,
              icon: Icons.filter_list,
            ),
          ),
        ),
        if (state.hasActiveFilters) ...[
          const SizedBox(width: 6),
          Tooltip(
            message: 'Clear filters',
            child: LibraryWorkspaceIconButton(
              onPressed: callbacks.onClearFilters,
              icon: Icons.filter_alt_off_outlined,
            ),
          ),
        ],
      ],
    );
  }
}
