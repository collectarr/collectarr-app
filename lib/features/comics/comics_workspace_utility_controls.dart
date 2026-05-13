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
          message: 'Filters',
          child: Badge(
            isLabelVisible: state.hasActiveFilters,
            child: LibraryWorkspaceIconButton(
              onPressed: callbacks.onEditFilters,
              icon: Icons.filter_list,
            ),
          ),
        ),
      ],
    );
  }
}
