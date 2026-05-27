import 'package:collectarr_app/features/library/workspace/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_control_models.dart';
import 'package:flutter/material.dart';

class LibraryViewTableControls extends StatelessWidget {
  const LibraryViewTableControls({
    super.key,
    required this.state,
    required this.callbacks,
  });

  final LibraryViewTableControlState state;
  final LibraryViewTableControlCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: state.isSidebarVisible
              ? 'Hide folders panel'
              : 'Show folders panel',
          child: LibraryWorkspaceIconButton(
            onPressed: () =>
                callbacks.onSidebarVisibilityChanged(!state.isSidebarVisible),
            icon: state.isSidebarVisible ? Icons.menu_open : Icons.menu,
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Select columns',
          child: LibraryWorkspaceIconButton(
            onPressed: state.canEditColumns ? callbacks.onEditColumns : null,
            icon: Icons.view_column,
          ),
        ),
        const SizedBox(width: 6),
        LibraryViewControls(
          viewMode: state.viewMode,
          detailsLayout: state.detailsLayout,
          coverSize: state.coverSize,
          minCoverSize: state.minCoverSize,
          maxCoverSize: state.maxCoverSize,
          onViewModeChanged: callbacks.onViewModeChanged,
          onDetailsLayoutChanged: callbacks.onDetailsLayoutChanged,
          onCoverSizeChanged: callbacks.onCoverSizeChanged,
        ),
      ],
    );
  }
}
