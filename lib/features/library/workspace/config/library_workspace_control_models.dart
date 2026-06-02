import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/widgets.dart';

class LibraryWorkspaceCounts {
  const LibraryWorkspaceCounts({
    required this.shown,
    required this.total,
  });

  final int shown;
  final int total;
}

class LibraryViewTableControlState {
  const LibraryViewTableControlState({
    required this.counts,
    required this.viewMode,
    required this.detailsLayout,
    required this.isSidebarVisible,
    required this.coverSize,
    required this.minCoverSize,
    required this.maxCoverSize,
    this.columnFavoritePresets = const [],
    this.activeColumnFavoriteLabel,
    this.pinnedColumnFavoriteKeys = const {},
  });

  final LibraryWorkspaceCounts counts;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final bool isSidebarVisible;
  final double coverSize;
  final double minCoverSize;
  final double maxCoverSize;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final Set<String> pinnedColumnFavoriteKeys;

  bool get canEditColumns => viewMode == LibraryViewMode.list;
}

class LibraryViewTableControlCallbacks {
  const LibraryViewTableControlCallbacks({
    required this.onEditColumns,
    required this.onSidebarVisibilityChanged,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onCoverSizeChanged,
    this.onColumnFavoriteSelected,
  });

  final VoidCallback onEditColumns;
  final ValueChanged<bool> onSidebarVisibilityChanged;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
}
