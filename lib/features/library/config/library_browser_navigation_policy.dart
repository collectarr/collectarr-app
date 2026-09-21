import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';

/// UI policy for navigating the universal Work -> Release browser topology.
///
/// Structural truth is represented by [LibraryEntityScope]; this class
/// describes how the generic browser presents it.
final class LibraryBrowserNavigationPolicy {
  const LibraryBrowserNavigationPolicy();

  LibraryWorkspaceBrowserMode browserModeForViewState(
    LibraryWorkspaceViewState viewState, {
    String? releaseFolderWorkId,
  }) {
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

  LibraryEntityScope entityScopeForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) =>
      browserMode == LibraryWorkspaceBrowserMode.release
          ? LibraryEntityScope.release
          : LibraryEntityScope.work;

  bool shouldOpenReleaseFolderOnOpen({
    required LibraryWorkspaceBrowserMode browserMode,
    required LibraryEntityScope browseScope,
  }) {
    return browserMode == LibraryWorkspaceBrowserMode.work &&
        browseScope == LibraryEntityScope.work;
  }

  bool shouldShowReleaseFolderBack({
    required LibraryWorkspaceBrowserMode browserMode,
    String? releaseFolderWorkId,
  }) {
    return browserMode == LibraryWorkspaceBrowserMode.release &&
        releaseFolderWorkId != null;
  }
}

const libraryBrowserNavigationPolicy = LibraryBrowserNavigationPolicy();
