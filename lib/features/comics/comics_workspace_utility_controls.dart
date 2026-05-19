import 'package:collectarr_app/features/comics/comics_duplicate_items.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_missing_issues.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_control_models.dart';
import 'package:collectarr_app/features/library/workspace/library_utility_menu.dart';
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
    return LibraryUtilityMenu<ComicsShelfQuickView>(
      quickViews: [
        for (final view in ComicsShelfQuickView.values)
          LibraryUtilityQuickView(
            value: view,
            label: view.label,
            icon: view.icon,
          ),
      ],
      selectedQuickView: state.quickView,
      onQuickViewSelected: callbacks.onQuickViewSelected,
      badgeCount: _utilityBadgeCount,
      actions: [
        LibraryUtilityMenuAction(
          icon: Icons.filter_list,
          label: 'Filters',
          onSelected: callbacks.onEditFilters,
        ),
        if (state.hasActiveFilters)
          LibraryUtilityMenuAction(
            icon: Icons.filter_alt_off_outlined,
            label: 'Clear filters',
            onSelected: callbacks.onClearFilters,
          ),
        LibraryUtilityMenuAction(
          icon: Icons.query_stats,
          label: 'Statistics',
          onSelected: callbacks.onShowStats,
        ),
        LibraryUtilityMenuAction(
          icon: Icons.format_list_numbered,
          label: 'Missing issues',
          enabled: state.missingIssues.isNotEmpty,
          trailing: Text(state.missingIssues.length.toString()),
          onSelected: () => showComicsMissingIssuesDialog(
            context,
            selectedSeries: state.selectedSeries,
            missingIssues: state.missingIssues,
          ),
        ),
        LibraryUtilityMenuAction(
          icon: Icons.content_copy,
          label: 'Duplicates',
          enabled: state.duplicateGroups.isNotEmpty,
          trailing: Text(state.duplicateGroups.length.toString()),
          onSelected: () => showComicsDuplicateItemsDialog(
            context,
            duplicateGroups: state.duplicateGroups,
          ),
        ),
      ],
    );
  }

  int get _utilityBadgeCount {
    return state.activeFilterCount +
        state.missingIssues.length +
        state.duplicateGroups.length;
  }
}
