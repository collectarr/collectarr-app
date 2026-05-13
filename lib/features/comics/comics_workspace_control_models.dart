import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
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

class ComicsWorkspaceCounts {
  const ComicsWorkspaceCounts({
    required this.shown,
    required this.total,
  });

  final int shown;
  final int total;
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

class ComicsViewTableControlState {
  const ComicsViewTableControlState({
    required this.counts,
    required this.viewMode,
    required this.detailsLayout,
    required this.coverSize,
  });

  final ComicsWorkspaceCounts counts;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final double coverSize;
}

class ComicsViewTableControlCallbacks {
  const ComicsViewTableControlCallbacks({
    required this.onEditColumns,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onViewPresetSelected,
    required this.onCoverSizeChanged,
  });

  final VoidCallback onEditColumns;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<double> onCoverSizeChanged;
}
