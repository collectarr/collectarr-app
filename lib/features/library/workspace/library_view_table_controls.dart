import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
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
        if (state.canEditColumns)
          _LibraryLegacyColumnLauncher(state: state, callbacks: callbacks)
        else
          Tooltip(
            message: 'Select columns',
            child: LibraryWorkspaceIconButton(
              onPressed: null,
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

enum _LegacyColumnLauncherAction { manage }

class _LibraryLegacyColumnLauncher extends StatelessWidget {
  const _LibraryLegacyColumnLauncher({
    required this.state,
    required this.callbacks,
  });

  final LibraryViewTableControlState state;
  final LibraryViewTableControlCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final entries = <LibraryDenseMenuEntry<Object>>[
      for (final preset in state.columnFavoritePresets)
        LibraryDenseMenuEntry<Object>(
          value: preset,
          label: preset.label,
          icon: Icons.bookmark_outline,
          active: preset.label == state.activeColumnFavoriteLabel,
          trailingLabel: state.pinnedColumnFavoriteKeys.contains(
            libraryColumnFavoriteKey(preset),
          )
              ? 'Pinned'
              : null,
        ),
      const LibraryDenseMenuEntry<Object>(
        value: _LegacyColumnLauncherAction.manage,
        label: 'Manage columns',
        icon: Icons.tune,
      ),
    ];

    return LibraryDenseSplitButton<Object>(
      key: const ValueKey('legacy-library-column-split-button'),
      label: state.activeColumnFavoriteLabel ?? 'Custom columns',
      icon: Icons.view_column_outlined,
      onPressed: callbacks.onEditColumns,
      entries: entries,
      onSelected: (value) {
        if (value is LibraryTableColumnPreset) {
          callbacks.onColumnFavoriteSelected?.call(value);
          return;
        }
        callbacks.onEditColumns();
      },
      tone: LibraryDenseButtonTone.surface,
      tooltip: 'Select columns',
    );
  }
}
