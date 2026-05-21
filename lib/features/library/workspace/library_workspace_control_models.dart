import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
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
    required this.coverSize,
    required this.minCoverSize,
    required this.maxCoverSize,
  });

  final LibraryWorkspaceCounts counts;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final double coverSize;
  final double minCoverSize;
  final double maxCoverSize;

  bool get canEditColumns => viewMode == LibraryViewMode.list;
}

class LibraryViewTableControlCallbacks {
  const LibraryViewTableControlCallbacks({
    required this.onEditColumns,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onCoverSizeChanged,
  });

  final VoidCallback onEditColumns;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<double> onCoverSizeChanged;
}
