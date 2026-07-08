import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_utility_menu.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class LibraryToolbarActionContext {
  const LibraryToolbarActionContext({
    required this.type,
    required this.projection,
    required this.onJumpToNumberSubmitted,
    required this.onMissingSequenceReport,
  });

  final LibraryTypeConfig type;
  final LibraryProjection? projection;
  final ValueChanged<String>? onJumpToNumberSubmitted;
  final ValueChanged<LibraryProjection?>? onMissingSequenceReport;
}

class LibraryToolbarActionDescriptor {
  const LibraryToolbarActionDescriptor({
    required this.id,
    required this.label,
    required this.icon,
    required this.buildAction,
    this.section,
  });

  final String id;
  final String label;
  final IconData icon;
  final String? section;
  final LibraryUtilityMenuAction Function(
    BuildContext context,
    LibraryToolbarActionContext actionContext,
  ) buildAction;
}

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
  });

  final bool canScanCover;
  final bool canDownloadAllCovers;
  final bool canReadingQueue;
  final bool canReassignIndex;
  final bool canCompareMetadataWithServer;
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

extension LibraryTypeConfigToolbarAvailability on LibraryTypeConfig {
  LibraryToolbarActionAvailability get toolbarActionAvailability {
    return LibraryToolbarActionAvailability(
      declaredActions: workspace.toolbarActions.toSet(),
      capabilities: KindToolbarCapabilities(
        canScanCover: capabilities.canScanCover,
        canDownloadAllCovers: capabilities.canScanCover,
        canReadingQueue: capabilities.supportsReadingQueue,
        canReassignIndex: capabilities.supportsIndexReassignment,
        canCompareMetadataWithServer: capabilities.supportsMetadataCompare,
      ),
    );
  }
}
