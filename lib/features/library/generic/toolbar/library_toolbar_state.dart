import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_search.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:flutter/material.dart';

class LibraryToolbarState {
  const LibraryToolbarState({
    required this.searchController,
    required this.viewState,
    required this.counts,
    this.searchTarget = LibrarySearchTarget.all,
    this.searchTargetOptions = const <LibrarySearchTarget>[],
    this.searchActive = false,
    this.searchSuggestions = const <LibraryToolbarSearchSuggestion>[],
    this.selectedBucket,
    required this.collectionStatusScope,
    required this.quickView,
    this.availableLetters = const <String>{},
    this.selectedLetter,
    this.activeViewPreset,
    this.pinnedViewPresets = const <LibraryWorkspacePreset>{},
    this.sortFavorites = const <LibrarySortFavorite>[],
    this.activeSortFavoriteId,
    this.pinnedSortFavoriteIds = const <String>{},
    this.columnFavoritePresets = const <LibraryTableColumnPreset>[],
    this.activeColumnFavoriteLabel,
    this.pinnedColumnFavoriteKeys = const <String>{},
    this.canJumpToNumber = false,
    required this.hasActiveFilters,
    this.activeFilterCount = 0,
    this.shelfState,
    this.groupMode,
    this.folderPreset,
    this.groupPresentation,
    this.availableGroupModes,
    this.pinnedFolderPresets = const <LibraryFolderPreset>[],
    this.selectionCallbacks,
    this.selectionEnabled = false,
    this.selectedCount = 0,
    this.totalSelectableCount = 0,
    this.showReleaseFolderBack = false,
    this.releaseFolderLabel,
  });

  final TextEditingController searchController;
  final LibraryWorkspaceViewState viewState;
  final LibraryToolbarCounts counts;
  final LibrarySearchTarget searchTarget;
  final List<LibrarySearchTarget> searchTargetOptions;
  final bool searchActive;
  final List<LibraryToolbarSearchSuggestion> searchSuggestions;
  final String? selectedBucket;
  final LibraryCollectionStatusScope collectionStatusScope;
  final LibraryQuickView? quickView;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final LibraryWorkspacePreset? activeViewPreset;
  final Set<LibraryWorkspacePreset> pinnedViewPresets;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;
  final Set<String> pinnedSortFavoriteIds;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final Set<String> pinnedColumnFavoriteKeys;
  final bool canJumpToNumber;
  final bool hasActiveFilters;
  final int activeFilterCount;
  final ShelfState? shelfState;
  final LibraryGroupMode? groupMode;
  final LibraryFolderPreset? folderPreset;
  final LibraryGroupPresentation? groupPresentation;
  final List<LibraryGroupMode>? availableGroupModes;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final LibrarySelectionCallbacks? selectionCallbacks;
  final bool selectionEnabled;
  final int selectedCount;
  final int totalSelectableCount;
  final bool showReleaseFolderBack;
  final String? releaseFolderLabel;
}
