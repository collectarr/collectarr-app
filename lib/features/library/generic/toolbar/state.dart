import 'package:collectarr_app/features/library/selection/commands.dart';
import 'package:collectarr_app/features/library/selection/action.dart';
import 'package:collectarr_app/features/library/generic/toolbar/alphabet_options.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/search_target.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/search.dart';
import 'package:collectarr_app/features/library/workspace/entry/view_state.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
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
    this.linkedMetadataFilters = const [],
    required this.collectionStatusScope,
    required this.quickView,
    this.availableLetters = const <String>{},
    this.selectedLetter,
    this.alphabetOptions,
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
    this.shelfState,
    this.groupMode,
    this.folderPreset,
    this.groupPresentation,
    this.availableGroupModes,
    this.pinnedFolderPresets = const <LibraryFolderPreset>[],
    this.selectionCallbacks,
    this.selectionActions = const [],
    this.selectionEnabled = false,
    this.selectedCount = 0,
    this.totalSelectableCount = 0,
  });

  final TextEditingController searchController;
  final LibraryWorkspaceViewState viewState;
  final LibraryToolbarCounts counts;
  final LibrarySearchTarget searchTarget;
  final List<LibrarySearchTarget> searchTargetOptions;
  final bool searchActive;
  final List<LibraryToolbarSearchSuggestion> searchSuggestions;
  final String? selectedBucket;
  final List<LibraryLinkedMetadataFilter> linkedMetadataFilters;
  final LibraryCollectionStatusScope collectionStatusScope;
  final LibraryQuickView? quickView;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final LibraryAlphabetOptions? alphabetOptions;
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
  final ShelfState? shelfState;
  final String? groupMode;
  final LibraryFolderPreset? folderPreset;
  final LibraryGroupPresentation? groupPresentation;
  final List<String>? availableGroupModes;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final LibrarySelectionStateCallbacks? selectionCallbacks;
  final List<ResolvedLibrarySelectionAction> selectionActions;
  final bool selectionEnabled;
  final int selectedCount;
  final int totalSelectableCount;
}
