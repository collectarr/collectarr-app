import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_data_capability.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';

/// Encapsulates structural hierarchy, release nesting, and browser scopes.
class LibraryHierarchyCapability implements LibraryHierarchyDataCapability {
  const LibraryHierarchyCapability({
    this.supportsMediaReleaseSplit = false,
    this.mediaScopeGroupIds,
    this.releaseScopeGroupIds,
    this.mediaScopeSortIds,
    this.releaseScopeSortIds,
    this.childrenTitleBuilder,
    this.fetchChildrenCallback,
    this.browserDelegateBuilder,
  });

  final bool supportsMediaReleaseSplit;
  final Set<LibraryGroupIdRuntime>? mediaScopeGroupIds;
  final Set<LibraryGroupIdRuntime>? releaseScopeGroupIds;
  final Set<LibrarySortIdRuntime>? mediaScopeSortIds;
  final Set<LibrarySortIdRuntime>? releaseScopeSortIds;
  final String Function(int count)? childrenTitleBuilder;
  final Future<List<LibraryHierarchyNode>> Function({
    required ApiClient api,
    required String itemId,
    String? provider,
    String? providerItemId,
  })? fetchChildrenCallback;
  final LibraryKindBrowserDelegate Function()? browserDelegateBuilder;

  LibraryKindBrowserDelegate buildBrowserDelegate() {
    return browserDelegateBuilder?.call() ?? LibraryNoopBrowserDelegate();
  }

  @override
  Future<List<LibraryHierarchyNode>> fetchChildren({
    required ApiClient api,
    required String itemId,
    String? provider,
    String? providerItemId,
  }) async {
    if (fetchChildrenCallback != null) {
      return fetchChildrenCallback!(
        api: api,
        itemId: itemId,
        provider: provider,
        providerItemId: providerItemId,
      );
    }
    return const <LibraryHierarchyNode>[];
  }

  String childrenTitle(int count) =>
      childrenTitleBuilder?.call(count) ?? 'Contents ($count)';

  bool get scopesOptionsByBrowserMode =>
      supportsMediaReleaseSplit &&
      (mediaScopeGroupIds != null ||
          releaseScopeGroupIds != null ||
          mediaScopeSortIds != null ||
          releaseScopeSortIds != null);

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
