import 'package:collectarr_app/features/library/config/library_type_capabilities.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';

/// Encapsulates structural hierarchy, release nesting, and volume/issue scoping.
class LibraryHierarchyCapability {
  const LibraryHierarchyCapability({
    this.contentHierarchy = LibraryContentHierarchy.flat,
    this.supportsSeriesSubgroups = false,
    this.supportsMediaReleaseSplit = false,
    this.supportsIndexReassignment = false,
    this.showsReadingQueue = false,
    this.collectionExportTitleLabel = 'Title',
    this.mediaReleaseScopeLabel = 'Media',
  });

  final LibraryContentHierarchy contentHierarchy;
  final bool supportsSeriesSubgroups;
  final bool supportsMediaReleaseSplit;
  final bool supportsIndexReassignment;
  final bool showsReadingQueue;
  final String collectionExportTitleLabel;
  final String mediaReleaseScopeLabel;

  LibraryWorkspaceBrowserMode browserModeForViewState(
    LibraryWorkspaceViewState viewState, {
    String? releaseFolderTitleItemId,
  }) {
    if (!supportsMediaReleaseSplit) {
      return LibraryWorkspaceBrowserMode.media;
    }
    if (releaseFolderTitleItemId != null) {
      return LibraryWorkspaceBrowserMode.releases;
    }
    return viewState.browserMode;
  }

  LibraryEditScope editScopeForBrowserMode(
    LibraryWorkspaceBrowserMode browserMode,
  ) {
    return browserMode == LibraryWorkspaceBrowserMode.releases
        ? LibraryEditScope.release
        : LibraryEditScope.media;
  }

  bool shouldOpenReleaseFolderOnOpen({
    required LibraryWorkspaceBrowserMode browserMode,
    required LibraryBrowserScope browseScope,
  }) {
    return supportsMediaReleaseSplit &&
        browserMode == LibraryWorkspaceBrowserMode.media &&
        browseScope == LibraryBrowserScope.title;
  }

  bool shouldShowReleaseFolderBack({
    required LibraryWorkspaceBrowserMode browserMode,
    String? releaseFolderTitleItemId,
  }) {
    return supportsMediaReleaseSplit &&
        browserMode == LibraryWorkspaceBrowserMode.releases &&
        releaseFolderTitleItemId != null;
  }
}
