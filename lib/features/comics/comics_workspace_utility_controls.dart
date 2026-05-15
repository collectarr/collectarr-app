import 'package:collectarr_app/features/comics/comics_duplicate_items.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_missing_issues.dart';
import 'package:collectarr_app/features/comics/comics_workspace_control_models.dart';
import 'package:flutter/material.dart';

enum _ComicsUtilityAction {
  stats,
  filters,
  clearFilters,
  missingIssues,
  duplicates,
}

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
    return Badge(
      isLabelVisible: _utilityBadgeCount > 0,
      label: Text(_utilityBadgeCount.toString()),
      child: PopupMenuButton<Object>(
        tooltip: 'Library tools',
        initialValue: state.quickView,
        icon: Icon(
          state.quickView?.icon ?? Icons.tune,
          size: 18,
        ),
        onSelected: (action) => _handleSelected(context, action),
        itemBuilder: (context) => [
          const PopupMenuItem<Object>(
            enabled: false,
            child: Text('Quick views'),
          ),
          for (final view in ComicsShelfQuickView.values)
            PopupMenuItem<Object>(
              value: view,
              child: ListTile(
                dense: true,
                leading: Icon(view.icon),
                title: Text(view.label),
                trailing: state.quickView == view
                    ? const Icon(Icons.check, size: 18)
                    : null,
              ),
            ),
          const PopupMenuDivider(),
          const PopupMenuItem<Object>(
            value: _ComicsUtilityAction.filters,
            child: ListTile(
              dense: true,
              leading: Icon(Icons.filter_list),
              title: Text('Filters'),
            ),
          ),
          if (state.hasActiveFilters)
            const PopupMenuItem<Object>(
              value: _ComicsUtilityAction.clearFilters,
              child: ListTile(
                dense: true,
                leading: Icon(Icons.filter_alt_off_outlined),
                title: Text('Clear filters'),
              ),
            ),
          const PopupMenuItem<Object>(
            value: _ComicsUtilityAction.stats,
            child: ListTile(
              dense: true,
              leading: Icon(Icons.query_stats),
              title: Text('Statistics'),
            ),
          ),
          PopupMenuItem<Object>(
            value: _ComicsUtilityAction.missingIssues,
            enabled: state.missingIssues.isNotEmpty,
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.format_list_numbered),
              title: const Text('Missing issues'),
              trailing: Text(state.missingIssues.length.toString()),
            ),
          ),
          PopupMenuItem<Object>(
            value: _ComicsUtilityAction.duplicates,
            enabled: state.duplicateGroups.isNotEmpty,
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.content_copy),
              title: const Text('Duplicates'),
              trailing: Text(state.duplicateGroups.length.toString()),
            ),
          ),
        ],
      ),
    );
  }

  int get _utilityBadgeCount {
    return state.activeFilterCount +
        state.missingIssues.length +
        state.duplicateGroups.length;
  }

  void _handleSelected(BuildContext context, Object action) {
    if (action is ComicsShelfQuickView) {
      callbacks.onQuickViewSelected(action);
      return;
    }
    switch (action) {
      case _ComicsUtilityAction.stats:
        callbacks.onShowStats();
      case _ComicsUtilityAction.filters:
        callbacks.onEditFilters();
      case _ComicsUtilityAction.clearFilters:
        callbacks.onClearFilters();
      case _ComicsUtilityAction.missingIssues:
        showComicsMissingIssuesDialog(
          context,
          selectedSeries: state.selectedSeries,
          missingIssues: state.missingIssues,
        );
      case _ComicsUtilityAction.duplicates:
        showComicsDuplicateItemsDialog(
          context,
          duplicateGroups: state.duplicateGroups,
        );
      default:
        break;
    }
  }
}
