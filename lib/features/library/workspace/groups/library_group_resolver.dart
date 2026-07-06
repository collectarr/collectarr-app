export '../../generic/projection.dart'
    show
        LibraryBucketScopeFilter,
        LibraryFolderPreset,
        LibraryFolderTreeNode,
        genericAllBucketLabel,
        genericGroupModeFolderSetLabel,
        genericGroupModeIcon,
        genericGroupModeLabel,
        genericGroupModeSidebarTitle,
        genericGroupPresentationForMode,
        genericBucketForItemMode,
        libraryAllowsGroupDrilldown,
        libraryFolderTreeNodeId,
        libraryGroupEntriesForItems;

class LibraryGroupScopeRoute {
  const LibraryGroupScopeRoute({
    required this.groupMode,
    required this.bucket,
    this.folderDisplayMode,
  });

  final String groupMode;
  final String bucket;
  final String? folderDisplayMode;
}
