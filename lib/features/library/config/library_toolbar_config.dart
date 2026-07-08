import 'package:collectarr_app/features/library/config/library_type_config.dart';

enum LibraryToolbarActionId {
  add,
  scan,
  editColumns,
  sort,
  sidebar,
  browserMode,
  releaseFolderBack,
  detailsLayout,
  densityPreset,
  coverSize,
  clearBucket,
  refreshMetadata,
  collectionStatusScope,
  quickView,
  letter,
  viewPreset,
  togglePinnedViewPreset,
  sortFavorite,
  togglePinnedSortFavorite,
  manageSortFavorites,
  columnFavorite,
  togglePinnedColumnFavorite,
  jumpToIssue,
  clearFilters,
  editFilters,
  randomPick,
  scanCover,
  downloadAllCovers,
  smartLists,
  folders,
  readingQueue,
  editConditionPickList,
  editGradePickList,
  editTagPickList,
  transferFieldData,
  reassignIndex,
  printReport,
  missingSequenceReport,
  shareCollection,
  compareMetadataWithServer,
  pinnedFolderPresets,
  groupMode,
  groupPresentation,
}

const kDefaultLibraryToolbarActions = <LibraryToolbarActionId>[
  LibraryToolbarActionId.add,
  LibraryToolbarActionId.scan,
  LibraryToolbarActionId.editColumns,
  LibraryToolbarActionId.sort,
  LibraryToolbarActionId.sidebar,
  LibraryToolbarActionId.browserMode,
  LibraryToolbarActionId.releaseFolderBack,
  LibraryToolbarActionId.detailsLayout,
  LibraryToolbarActionId.densityPreset,
  LibraryToolbarActionId.coverSize,
  LibraryToolbarActionId.clearBucket,
  LibraryToolbarActionId.refreshMetadata,
  LibraryToolbarActionId.collectionStatusScope,
  LibraryToolbarActionId.quickView,
  LibraryToolbarActionId.letter,
  LibraryToolbarActionId.viewPreset,
  LibraryToolbarActionId.togglePinnedViewPreset,
  LibraryToolbarActionId.sortFavorite,
  LibraryToolbarActionId.togglePinnedSortFavorite,
  LibraryToolbarActionId.manageSortFavorites,
  LibraryToolbarActionId.columnFavorite,
  LibraryToolbarActionId.togglePinnedColumnFavorite,
  LibraryToolbarActionId.jumpToIssue,
  LibraryToolbarActionId.clearFilters,
  LibraryToolbarActionId.editFilters,
  LibraryToolbarActionId.randomPick,
  LibraryToolbarActionId.scanCover,
  LibraryToolbarActionId.downloadAllCovers,
  LibraryToolbarActionId.smartLists,
  LibraryToolbarActionId.folders,
  LibraryToolbarActionId.readingQueue,
  LibraryToolbarActionId.editConditionPickList,
  LibraryToolbarActionId.editGradePickList,
  LibraryToolbarActionId.editTagPickList,
  LibraryToolbarActionId.transferFieldData,
  LibraryToolbarActionId.reassignIndex,
  LibraryToolbarActionId.printReport,
  LibraryToolbarActionId.missingSequenceReport,
  LibraryToolbarActionId.shareCollection,
  LibraryToolbarActionId.compareMetadataWithServer,
  LibraryToolbarActionId.pinnedFolderPresets,
  LibraryToolbarActionId.groupMode,
  LibraryToolbarActionId.groupPresentation,
];

class KindToolbarCapabilities {
  const KindToolbarCapabilities({
    this.canScanCover = false,
    this.canDownloadAllCovers = false,
    this.canReadingQueue = false,
    this.canReassignIndex = false,
    this.canCompareMetadataWithServer = false,
    this.canMissingSequenceReport = false,
  });

  final bool canScanCover;
  final bool canDownloadAllCovers;
  final bool canReadingQueue;
  final bool canReassignIndex;
  final bool canCompareMetadataWithServer;
  final bool canMissingSequenceReport;
}

class LibraryToolbarActionAvailability {
  const LibraryToolbarActionAvailability({
    required this.declaredActions,
    required this.capabilities,
  });

  final Set<LibraryToolbarActionId> declaredActions;
  final KindToolbarCapabilities capabilities;

  bool allows(LibraryToolbarActionId action) =>
      declaredActions.contains(action);
}

extension LibraryTypeCapabilitiesToolbar on LibraryTypeCapabilities {
  KindToolbarCapabilities get toolbarCapabilities {
    return KindToolbarCapabilities(
      canScanCover: canScanCover,
      canDownloadAllCovers: canScanCover,
      canReadingQueue: supportsReadingQueue,
      canReassignIndex: supportsIndexReassignment,
      canCompareMetadataWithServer: supportsMetadataCompare,
      canMissingSequenceReport: usesComicCollectorFields,
    );
  }
}

extension LibraryTypeConfigToolbarAvailability on LibraryTypeConfig {
  LibraryToolbarActionAvailability get toolbarActionAvailability {
    return LibraryToolbarActionAvailability(
      declaredActions: workspace.toolbarActions.toSet(),
      capabilities: capabilities.toolbarCapabilities,
    );
  }
}
