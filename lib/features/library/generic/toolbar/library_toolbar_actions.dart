import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_search.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

class LibraryToolbarActions {
  const LibraryToolbarActions({
    required this.onAdd,
    required this.onScan,
    required this.onSearchChanged,
    this.onSearchInputChanged,
    this.onSearchTargetChanged,
    this.onClearSearch,
    this.onSearchSuggestionSelected,
    required this.onEditColumns,
    required this.onSortChanged,
    this.onEditSort,
    required this.onSidebarVisibilityChanged,
    required this.onViewModeChanged,
    this.onBrowserModeChanged,
    this.onReleaseFolderBack,
    required this.onDetailsLayoutChanged,
    required this.onCoverSizeChanged,
    required this.onClearBucket,
    required this.onRefreshMetadata,
    this.onCollectionStatusScopeChanged,
    required this.onQuickViewSelected,
    this.onLetterSelected,
    this.onViewPresetSelected,
    this.onTogglePinnedViewPreset,
    this.onSortFavoriteSelected,
    this.onTogglePinnedSortFavorite,
    this.onManageSortFavorites,
    this.onColumnFavoriteSelected,
    this.onTogglePinnedColumnFavorite,
    this.onJumpToIssueSubmitted,
    required this.onClearFilters,
    this.onEditFilters,
    this.onRandomPick,
    this.onScanCover,
    this.onDownloadAllCovers,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onEditTagPickList,
    this.onTransferFieldData,
    this.onReassignIndex,
    this.onPrintReport,
    this.onMissingComics,
    this.onShareCollection,
    this.onCompareMetadataWithServer,
    this.onPinnedFolderPresetsChanged,
    this.onGroupModeChanged,
  });

  final VoidCallback onAdd;
  final VoidCallback onScan;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String>? onSearchInputChanged;
  final ValueChanged<LibrarySearchTarget>? onSearchTargetChanged;
  final VoidCallback? onClearSearch;
  final ValueChanged<LibraryToolbarSearchSuggestion>? onSearchSuggestionSelected;
  final VoidCallback onEditColumns;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final VoidCallback? onEditSort;
  final ValueChanged<bool> onSidebarVisibilityChanged;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryWorkspaceBrowserMode>? onBrowserModeChanged;
  final VoidCallback? onReleaseFolderBack;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final VoidCallback onClearBucket;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
  final ValueChanged<String?>? onLetterSelected;
  final ValueChanged<LibraryWorkspacePreset>? onViewPresetSelected;
  final ValueChanged<LibraryWorkspacePreset>? onTogglePinnedViewPreset;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final ValueChanged<LibrarySortFavorite>? onTogglePinnedSortFavorite;
  final VoidCallback? onManageSortFavorites;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
  final ValueChanged<LibraryTableColumnPreset>? onTogglePinnedColumnFavorite;
  final ValueChanged<String>? onJumpToIssueSubmitted;
  final VoidCallback onClearFilters;
  final VoidCallback? onEditFilters;
  final VoidCallback? onRandomPick;
  final VoidCallback? onScanCover;
  final VoidCallback? onDownloadAllCovers;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onEditTagPickList;
  final VoidCallback? onTransferFieldData;
  final VoidCallback? onReassignIndex;
  final VoidCallback? onPrintReport;
  final VoidCallback? onMissingComics;
  final VoidCallback? onShareCollection;
  final VoidCallback? onCompareMetadataWithServer;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedFolderPresetsChanged;
  final ValueChanged<LibraryFolderPreset>? onGroupModeChanged;
}
