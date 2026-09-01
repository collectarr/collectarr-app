import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../session/library_workspace_session_controller.dart';
import 'library_workspace_key.dart';
import 'library_view_config_state.dart';

/// Derived read-only selector for [LibraryViewConfigState] from the single unified workspace session.
final libraryViewConfigProvider =
    Provider.family<LibraryViewConfigState, LibraryWorkspaceKey>(
  (ref, LibraryWorkspaceKey key) {
    final session = ref.watch(libraryWorkspaceSessionProvider(key));
    return LibraryViewConfigState(
      viewMode: session.view.viewMode,
      coverSize: session.view.coverSize,
      detailsLayout: session.view.detailsLayout,
      densityPreset: session.view.densityPreset,
      isSidebarVisible: session.view.sidebarVisible,
      sidebarWidth: session.view.sidebarWidth,
      detailsWidth: session.view.detailsWidth,
      detailsHeight: session.view.detailsHeight,
      columnWidths: {
        for (final entry in session.view.columnWidths.entries)
          entry.key.value: entry.value,
      },
    );
  },
);
