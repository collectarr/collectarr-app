import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';

/// Structural topology owned by a library kind.
///
/// Content hierarchy (seasons, discs, chapters, and so on) remains in
/// [LibraryHierarchyCapability]. This contract only describes the optional
/// work -> release browser split and the mapping needed by the generic host.
final class LibraryKindTopology {
  const LibraryKindTopology({this.supportsWorkReleaseSplit = false});

  final bool supportsWorkReleaseSplit;

  LibraryWorkspaceBrowserMode browserModeForViewState(
    LibraryWorkspaceViewState viewState, {
    String? releaseFolderWorkId,
  }) {
    if (!supportsWorkReleaseSplit) {
      return LibraryWorkspaceBrowserMode.work;
    }
    if (releaseFolderWorkId != null) {
      return LibraryWorkspaceBrowserMode.release;
    }
    return viewState.browserMode;
  }

  LibraryEntityScope editScopeForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) {
    return browserMode == LibraryWorkspaceBrowserMode.release
        ? LibraryEntityScope.release
        : LibraryEntityScope.work;
  }

  bool shouldOpenReleaseFolderOnOpen({
    required LibraryWorkspaceBrowserMode browserMode,
    required LibraryEntityScope browseScope,
    bool hasReleaseCapability = true,
  }) {
    return supportsWorkReleaseSplit &&
        hasReleaseCapability &&
        browserMode == LibraryWorkspaceBrowserMode.work &&
        browseScope == LibraryEntityScope.work;
  }

  bool shouldShowReleaseFolderBack({
    required LibraryWorkspaceBrowserMode browserMode,
    String? releaseFolderWorkId,
  }) {
    return supportsWorkReleaseSplit &&
        browserMode == LibraryWorkspaceBrowserMode.release &&
        releaseFolderWorkId != null;
  }
}
