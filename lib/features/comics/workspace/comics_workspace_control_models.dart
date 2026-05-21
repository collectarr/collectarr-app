import 'package:collectarr_app/features/comics/workspace/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/inspector/library_duplicate_items.dart';
import 'package:collectarr_app/features/comics/shelf/comics_filters.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_control_models.dart';
import 'package:flutter/material.dart';

class ComicsWorkspaceControlState {
  const ComicsWorkspaceControlState({
    required this.selectionEnabled,
    required this.selectedCount,
    required this.utility,
    required this.view,
  });

  final bool selectionEnabled;
  final int selectedCount;
  final ComicsWorkspaceUtilityState utility;
  final ComicsViewTableControlState view;
}

class ComicsWorkspaceControlCallbacks {
  const ComicsWorkspaceControlCallbacks({
    required this.selection,
    required this.utility,
    required this.view,
  });

  final LibrarySelectionCallbacks selection;
  final ComicsWorkspaceUtilityCallbacks utility;
  final ComicsViewTableControlCallbacks view;
}

class ComicsWorkspaceCounts extends LibraryWorkspaceCounts {
  const ComicsWorkspaceCounts({
    required super.shown,
    required super.total,
  });
}

class ComicsWorkspaceUtilityState {
  const ComicsWorkspaceUtilityState({
    required this.selectedSeries,
    required this.hasActiveFilters,
    required this.activeFilterCount,
    required this.quickView,
    required this.missingIssues,
    required this.duplicateGroups,
  });

  final String? selectedSeries;
  final bool hasActiveFilters;
  final int activeFilterCount;
  final ComicsShelfQuickView? quickView;
  final List<int> missingIssues;
  final List<LibraryDuplicateGroup> duplicateGroups;
}

class ComicsWorkspaceUtilityCallbacks {
  const ComicsWorkspaceUtilityCallbacks({
    required this.onShowStats,
    required this.onQuickViewSelected,
    required this.onEditFilters,
    required this.onClearFilters,
  });

  final VoidCallback onShowStats;
  final ValueChanged<ComicsShelfQuickView> onQuickViewSelected;
  final VoidCallback onEditFilters;
  final VoidCallback onClearFilters;
}

class ComicsViewTableControlState extends LibraryViewTableControlState {
  const ComicsViewTableControlState({
    required super.counts,
    required super.viewMode,
    required super.detailsLayout,
    required super.coverSize,
    super.minCoverSize = kComicsMinCoverSize,
    super.maxCoverSize = kComicsMaxCoverSize,
  });
}

class ComicsViewTableControlCallbacks extends LibraryViewTableControlCallbacks {
  const ComicsViewTableControlCallbacks({
    required super.onEditColumns,
    required super.onViewModeChanged,
    required super.onDetailsLayoutChanged,
    required super.onViewPresetSelected,
    required super.onCoverSizeChanged,
  });
}
