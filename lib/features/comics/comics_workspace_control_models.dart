import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_control_models.dart';
import 'package:flutter/material.dart';

class ComicsWorkspaceControlState {
  const ComicsWorkspaceControlState({
    required this.selection,
    required this.utility,
    required this.view,
  });

  final ComicsSelectionControlState selection;
  final ComicsWorkspaceUtilityState utility;
  final ComicsViewTableControlState view;
}

class ComicsWorkspaceControlCallbacks {
  const ComicsWorkspaceControlCallbacks({
    required this.selection,
    required this.utility,
    required this.view,
  });

  final ComicsSelectionControlCallbacks selection;
  final ComicsWorkspaceUtilityCallbacks utility;
  final ComicsViewTableControlCallbacks view;
}

class ComicsWorkspaceCounts extends LibraryWorkspaceCounts {
  const ComicsWorkspaceCounts({
    required super.shown,
    required super.total,
  });
}

class ComicsSelectionControlState {
  const ComicsSelectionControlState({
    required this.enabled,
    required this.selectedCount,
  });

  final bool enabled;
  final int selectedCount;
}

class ComicsSelectionControlCallbacks {
  const ComicsSelectionControlCallbacks({
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToOwned,
    required this.onBulkMoveToWishlist,
    required this.onBulkRemove,
  });

  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToOwned;
  final VoidCallback onBulkMoveToWishlist;
  final VoidCallback onBulkRemove;
}

class ComicsWorkspaceUtilityState {
  const ComicsWorkspaceUtilityState({
    required this.selectedSeries,
    required this.hasActiveFilters,
    required this.missingIssues,
  });

  final String? selectedSeries;
  final bool hasActiveFilters;
  final List<int> missingIssues;
}

class ComicsWorkspaceUtilityCallbacks {
  const ComicsWorkspaceUtilityCallbacks({
    required this.onShowStats,
    required this.onEditFilters,
  });

  final VoidCallback onShowStats;
  final VoidCallback onEditFilters;
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
