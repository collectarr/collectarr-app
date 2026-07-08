import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar/library_toolbar_actions.dart';
import 'package:collectarr_app/features/library/generic/toolbar/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/generic/toolbar/library_toolbar_state.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_sections.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

export 'toolbar/library_toolbar_actions.dart';
export 'toolbar/library_toolbar_config.dart';
export 'toolbar/library_toolbar_presentation.dart';
export 'toolbar/library_toolbar_state.dart';
export 'toolbar/toolbar_auxiliary_controls.dart';
export 'toolbar/toolbar_sections.dart';

class LibraryToolbar extends StatelessWidget {
  const LibraryToolbar({
    super.key,
    required this.type,
    required this.searchController,
    required this.viewState,
    required this.adapter,
    required this.counts,
    required this.onAdd,
    required this.onScan,
    required this.onSearchChanged,
    this.onSearchInputChanged,
    this.searchTarget = LibrarySearchTarget.all,
    this.searchTargetOptions = const <LibrarySearchTarget>[],
    this.onSearchTargetChanged,
    this.onClearSearch,
    this.searchActive = false,
    this.searchSuggestions = const <LibraryToolbarSearchSuggestion>[],
    this.onSearchSuggestionSelected,
    required this.onEditColumns,
    required this.onSortChanged,
    this.onEditSort,
    required this.onSidebarVisibilityChanged,
    required this.onViewModeChanged,
    this.browserMode = LibraryWorkspaceBrowserMode.media,
    this.supportsMediaReleaseSplit = false,
    this.onBrowserModeChanged,
    this.showReleaseFolderBack = false,
    this.releaseFolderLabel,
    this.onReleaseFolderBack,
    required this.onDetailsLayoutChanged,
    this.onDensityPresetChanged = _noopDensityPresetChanged,
    required this.onCoverSizeChanged,
    required this.selectedBucket,
    required this.onClearBucket,
    required this.onRefreshMetadata,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.onCollectionStatusScopeChanged,
    required this.quickView,
    required this.onQuickViewSelected,
    this.availableLetters = const {},
    this.selectedLetter,
    this.onLetterSelected,
    this.activeViewPreset,
    this.onViewPresetSelected,
    this.pinnedViewPresets = const {},
    this.onTogglePinnedViewPreset,
    this.sortFavorites = const [],
    this.activeSortFavoriteId,
    this.onSortFavoriteSelected,
    this.pinnedSortFavoriteIds = const {},
    this.onTogglePinnedSortFavorite,
    this.onManageSortFavorites,
    this.columnFavoritePresets = const [],
    this.activeColumnFavoriteLabel,
    this.onColumnFavoriteSelected,
    this.pinnedColumnFavoriteKeys = const {},
    this.onTogglePinnedColumnFavorite,
    this.canJumpToIssue = false,
    this.onJumpToIssueSubmitted,
    required this.hasActiveFilters,
    required this.onClearFilters,
    this.onEditFilters,
    this.activeFilterCount = 0,
    this.onRandomPick,
    this.onScanCover,
    this.onDownloadAllCovers,
    this.selectionEnabled = false,
    this.selectedCount = 0,
    this.totalSelectableCount = 0,
    this.selectionCallbacks,
    this.shelfState,
    this.onSmartLists,
    this.onFolders,
    this.onReadingQueue,
    this.onEditConditionPickList,
    this.onEditGradePickList,
    this.onEditTagPickList,
    this.onTransferFieldData,
    this.onReassignIndex,
    this.onPrintReport,
    this.onMissingSequenceReport,
    this.onShareCollection,
    this.onCompareMetadataWithServer,
    this.groupMode,
    this.folderPreset,
    this.groupPresentation,
    this.availableGroupModes,
    this.pinnedFolderPresets = const [],
    this.onPinnedFolderPresetsChanged,
    this.onGroupModeChanged,
    this.onGroupPresentationChanged,
    this.includeDesktopSecondaryBand = true,
  });

  static void _noopDensityPresetChanged(LibraryWorkspaceDensityPreset _) {}

  LibraryToolbar.grouped({
    super.key,
    required LibraryToolbarConfig config,
    required LibraryToolbarState state,
    required LibraryToolbarActions actions,
  })  : type = config.type,
        searchController = state.searchController,
        viewState = state.viewState,
        adapter = config.adapter,
        counts = state.counts,
        onAdd = actions.onAdd,
        onScan = actions.onScan,
        onSearchChanged = actions.onSearchChanged,
        onSearchInputChanged = actions.onSearchInputChanged,
        searchTarget = state.searchTarget,
        searchTargetOptions = state.searchTargetOptions,
        onSearchTargetChanged = actions.onSearchTargetChanged,
        onClearSearch = actions.onClearSearch,
        searchActive = state.searchActive,
        searchSuggestions = state.searchSuggestions,
        onSearchSuggestionSelected = actions.onSearchSuggestionSelected,
        onEditColumns = actions.onEditColumns,
        onSortChanged = actions.onSortChanged,
        onEditSort = actions.onEditSort,
        onSidebarVisibilityChanged = actions.onSidebarVisibilityChanged,
        onViewModeChanged = actions.onViewModeChanged,
        browserMode = config.browserMode,
        supportsMediaReleaseSplit = config.supportsMediaReleaseSplit,
        onBrowserModeChanged = actions.onBrowserModeChanged,
        showReleaseFolderBack = state.showReleaseFolderBack,
        releaseFolderLabel = state.releaseFolderLabel,
        onReleaseFolderBack = actions.onReleaseFolderBack,
        onDetailsLayoutChanged = actions.onDetailsLayoutChanged,
        onDensityPresetChanged = actions.onDensityPresetChanged,
        onCoverSizeChanged = actions.onCoverSizeChanged,
        selectedBucket = state.selectedBucket,
        onClearBucket = actions.onClearBucket,
        onRefreshMetadata = actions.onRefreshMetadata,
        collectionStatusScope = state.collectionStatusScope,
        onCollectionStatusScopeChanged = actions.onCollectionStatusScopeChanged,
        quickView = state.quickView,
        onQuickViewSelected = actions.onQuickViewSelected,
        availableLetters = state.availableLetters,
        selectedLetter = state.selectedLetter,
        onLetterSelected = actions.onLetterSelected,
        activeViewPreset = state.activeViewPreset,
        onViewPresetSelected = actions.onViewPresetSelected,
        pinnedViewPresets = state.pinnedViewPresets,
        onTogglePinnedViewPreset = actions.onTogglePinnedViewPreset,
        sortFavorites = state.sortFavorites,
        activeSortFavoriteId = state.activeSortFavoriteId,
        onSortFavoriteSelected = actions.onSortFavoriteSelected,
        pinnedSortFavoriteIds = state.pinnedSortFavoriteIds,
        onTogglePinnedSortFavorite = actions.onTogglePinnedSortFavorite,
        onManageSortFavorites = actions.onManageSortFavorites,
        columnFavoritePresets = state.columnFavoritePresets,
        activeColumnFavoriteLabel = state.activeColumnFavoriteLabel,
        onColumnFavoriteSelected = actions.onColumnFavoriteSelected,
        pinnedColumnFavoriteKeys = state.pinnedColumnFavoriteKeys,
        onTogglePinnedColumnFavorite = actions.onTogglePinnedColumnFavorite,
        canJumpToIssue = state.canJumpToIssue,
        onJumpToIssueSubmitted = actions.onJumpToIssueSubmitted,
        hasActiveFilters = state.hasActiveFilters,
        onClearFilters = actions.onClearFilters,
        onEditFilters = actions.onEditFilters,
        activeFilterCount = state.activeFilterCount,
        onRandomPick = actions.onRandomPick,
        onScanCover = actions.onScanCover,
        onDownloadAllCovers = actions.onDownloadAllCovers,
        selectionEnabled = state.selectionEnabled,
        selectedCount = state.selectedCount,
        totalSelectableCount = state.totalSelectableCount,
        selectionCallbacks = state.selectionCallbacks,
        shelfState = state.shelfState,
        onSmartLists = actions.onSmartLists,
        onFolders = actions.onFolders,
        onReadingQueue = actions.onReadingQueue,
        onEditConditionPickList = actions.onEditConditionPickList,
        onEditGradePickList = actions.onEditGradePickList,
        onEditTagPickList = actions.onEditTagPickList,
        onTransferFieldData = actions.onTransferFieldData,
        onReassignIndex = actions.onReassignIndex,
        onPrintReport = actions.onPrintReport,
        onMissingSequenceReport = actions.onMissingSequenceReport,
        onShareCollection = actions.onShareCollection,
        onCompareMetadataWithServer = actions.onCompareMetadataWithServer,
        groupMode = state.groupMode,
        folderPreset = state.folderPreset,
        groupPresentation = state.groupPresentation,
        availableGroupModes = state.availableGroupModes,
        pinnedFolderPresets = state.pinnedFolderPresets,
        onPinnedFolderPresetsChanged = actions.onPinnedFolderPresetsChanged,
        onGroupModeChanged = actions.onGroupModeChanged,
        onGroupPresentationChanged = actions.onGroupPresentationChanged,
        includeDesktopSecondaryBand = config.includeDesktopSecondaryBand;

  final LibraryTypeConfig type;
  final TextEditingController searchController;
  final LibraryWorkspaceViewState viewState;
  final LibraryMediaAdapter adapter;
  final LibraryToolbarCounts counts;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String>? onSearchInputChanged;
  final LibrarySearchTarget searchTarget;
  final List<LibrarySearchTarget> searchTargetOptions;
  final ValueChanged<LibrarySearchTarget>? onSearchTargetChanged;
  final VoidCallback? onClearSearch;
  final bool searchActive;
  final List<LibraryToolbarSearchSuggestion> searchSuggestions;
  final ValueChanged<LibraryToolbarSearchSuggestion>?
      onSearchSuggestionSelected;
  final VoidCallback onEditColumns;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final VoidCallback? onEditSort;
  final ValueChanged<bool> onSidebarVisibilityChanged;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final LibraryWorkspaceBrowserMode browserMode;
  final bool supportsMediaReleaseSplit;
  final ValueChanged<LibraryWorkspaceBrowserMode>? onBrowserModeChanged;
  final bool showReleaseFolderBack;
  final String? releaseFolderLabel;
  final VoidCallback? onReleaseFolderBack;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspaceDensityPreset> onDensityPresetChanged;
  final ValueChanged<double> onCoverSizeChanged;
  final String? selectedBucket;
  final VoidCallback onClearBucket;
  final VoidCallback onRefreshMetadata;
  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final LibraryQuickView? quickView;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final ValueChanged<String?>? onLetterSelected;
  final LibraryWorkspacePreset? activeViewPreset;
  final ValueChanged<LibraryWorkspacePreset>? onViewPresetSelected;
  final Set<LibraryWorkspacePreset> pinnedViewPresets;
  final ValueChanged<LibraryWorkspacePreset>? onTogglePinnedViewPreset;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final Set<String> pinnedSortFavoriteIds;
  final ValueChanged<LibrarySortFavorite>? onTogglePinnedSortFavorite;
  final VoidCallback? onManageSortFavorites;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
  final Set<String> pinnedColumnFavoriteKeys;
  final ValueChanged<LibraryTableColumnPreset>? onTogglePinnedColumnFavorite;
  final bool canJumpToIssue;
  final ValueChanged<String>? onJumpToIssueSubmitted;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final VoidCallback? onEditFilters;
  final int activeFilterCount;
  final VoidCallback? onRandomPick;
  final VoidCallback? onScanCover;
  final VoidCallback? onDownloadAllCovers;
  final ShelfState? shelfState;
  final bool selectionEnabled;
  final int selectedCount;
  final int totalSelectableCount;
  final LibrarySelectionCallbacks? selectionCallbacks;
  final VoidCallback? onSmartLists;
  final VoidCallback? onFolders;
  final VoidCallback? onReadingQueue;
  final VoidCallback? onEditConditionPickList;
  final VoidCallback? onEditGradePickList;
  final VoidCallback? onEditTagPickList;
  final VoidCallback? onTransferFieldData;
  final VoidCallback? onReassignIndex;
  final VoidCallback? onPrintReport;
  final VoidCallback? onMissingSequenceReport;
  final VoidCallback? onShareCollection;
  final VoidCallback? onCompareMetadataWithServer;
  final LibraryGroupMode? groupMode;
  final LibraryFolderPreset? folderPreset;
  final LibraryGroupPresentation? groupPresentation;
  final List<LibraryGroupMode>? availableGroupModes;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedFolderPresetsChanged;
  final ValueChanged<LibraryFolderPreset>? onGroupModeChanged;
  final ValueChanged<LibraryGroupPresentation>? onGroupPresentationChanged;
  final bool includeDesktopSecondaryBand;

  @override
  Widget build(BuildContext context) {
    final targetAccent = libraryAccentForKind(type.workspace.kind);
    final effectiveScanCover =
        type.capabilities.canScanCover ? onScanCover : null;
    final effectiveReadingQueue =
        type.capabilities.supportsReadingQueue ? onReadingQueue : null;
    final effectiveReassignIndex =
        type.capabilities.supportsIndexReassignment ? onReassignIndex : null;
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: targetAccent),
      duration: kAppAnimNormal,
      curve: Curves.easeOutCubic,
      builder: (context, color, _) {
        final accent = color ?? targetAccent;
        final palette = appPalette(context);
        return LibraryToolbarFrame(
          backgroundColor: palette.toolbar,
          dividerColor: palette.divider,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < kLibraryToolbarCompactBreakpoint) {
                return LibraryCompactToolbarContent(
                  type: type,
                  searchController: searchController,
                  accent: accent,
                  counts: counts,
                  viewMode: viewState.viewMode,
                  selectedBucket: selectedBucket,
                  onAdd: onAdd,
                  onScan: onScan,
                  onSearchChanged: onSearchChanged,
                  onSearchInputChanged: onSearchInputChanged,
                  searchTarget: searchTarget,
                  searchTargetOptions: searchTargetOptions,
                  onSearchTargetChanged: onSearchTargetChanged,
                  onClearSearch: onClearSearch,
                  searchActive: searchActive,
                  onRefreshMetadata: onRefreshMetadata,
                  onViewModeChanged: onViewModeChanged,
                  onDetailsLayoutChanged: onDetailsLayoutChanged,
                  onDensityPresetChanged: onDensityPresetChanged,
                  onCoverSizeChanged: onCoverSizeChanged,
                  quickView: quickView,
                  onQuickViewSelected: onQuickViewSelected,
                  collectionStatusScope: collectionStatusScope,
                  onCollectionStatusScopeChanged:
                      onCollectionStatusScopeChanged,
                  activeViewPreset: activeViewPreset,
                  onViewPresetSelected: onViewPresetSelected,
                  pinnedViewPresets: pinnedViewPresets,
                  onTogglePinnedViewPreset: onTogglePinnedViewPreset,
                  sortFavorites: sortFavorites,
                  activeSortFavoriteId: activeSortFavoriteId,
                  onSortFavoriteSelected: onSortFavoriteSelected,
                  pinnedSortFavoriteIds: pinnedSortFavoriteIds,
                  onTogglePinnedSortFavorite: onTogglePinnedSortFavorite,
                  columnFavoritePresets: columnFavoritePresets,
                  activeColumnFavoriteLabel: activeColumnFavoriteLabel,
                  onColumnFavoriteSelected: onColumnFavoriteSelected,
                  pinnedColumnFavoriteKeys: pinnedColumnFavoriteKeys,
                  onTogglePinnedColumnFavorite: onTogglePinnedColumnFavorite,
                  onManageColumns: onEditColumns,
                  canJumpToIssue: canJumpToIssue,
                  onJumpToIssueSubmitted: onJumpToIssueSubmitted,
                  hasActiveFilters: hasActiveFilters,
                  onClearFilters: onClearFilters,
                  onClearBucket: onClearBucket,
                  onEditFilters: onEditFilters,
                  activeFilterCount: activeFilterCount,
                  onRandomPick: onRandomPick,
                  onDownloadAllCovers: onDownloadAllCovers,
                  onSmartLists: onSmartLists,
                  onFolders: onFolders,
                  onReadingQueue: effectiveReadingQueue,
                  onEditConditionPickList: onEditConditionPickList,
                  onEditGradePickList: onEditGradePickList,
                  onEditTagPickList: onEditTagPickList,
                  onEditSort: onEditSort,
                  onCompareMetadataWithServer: onCompareMetadataWithServer,
                  availableLetters: availableLetters,
                  selectedLetter: selectedLetter,
                  onLetterSelected: onLetterSelected,
                  selectionCallbacks: selectionCallbacks,
                  selectedCount: selectedCount,
                  totalSelectableCount: totalSelectableCount,
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LibraryDesktopFilteringToolbar(
                    type: type,
                    accent: accent,
                    searchController: searchController,
                    collectionStatusScope: collectionStatusScope,
                    onCollectionStatusScopeChanged:
                        onCollectionStatusScopeChanged,
                    availableLetters: availableLetters,
                    selectedLetter: selectedLetter,
                    onLetterSelected: onLetterSelected,
                    selectedBucket: selectedBucket,
                    onAdd: onAdd,
                    onScan: onScan,
                    onRefreshMetadata: onRefreshMetadata,
                    onRandomPick: onRandomPick,
                    onScanCover: effectiveScanCover,
                    onSearchChanged: onSearchChanged,
                    onSearchInputChanged: onSearchInputChanged,
                    searchTarget: searchTarget,
                    searchTargetOptions: searchTargetOptions,
                    onSearchTargetChanged: onSearchTargetChanged,
                    onClearSearch: onClearSearch,
                    searchActive: searchActive,
                    searchSuggestions: searchSuggestions,
                    onSearchSuggestionSelected: onSearchSuggestionSelected,
                    onClearBucket: onClearBucket,
                  ),
                  if (includeDesktopSecondaryBand)
                    const LibraryToolbarDividerLine(),
                  if (includeDesktopSecondaryBand)
                    LibraryDesktopSecondaryToolbar(
                      type: type,
                      viewState: viewState,
                      adapter: adapter,
                      counts: counts,
                      onEditColumns: onEditColumns,
                      columnFavoritePresets: columnFavoritePresets,
                      activeColumnFavoriteLabel: activeColumnFavoriteLabel,
                      onColumnFavoriteSelected: onColumnFavoriteSelected,
                      pinnedColumnFavoriteKeys: pinnedColumnFavoriteKeys,
                      onEditSort: onEditSort,
                      onSidebarVisibilityChanged: onSidebarVisibilityChanged,
                      onViewModeChanged: onViewModeChanged,
                      browserMode: browserMode,
                      supportsMediaReleaseSplit: supportsMediaReleaseSplit,
                      onBrowserModeChanged: onBrowserModeChanged,
                      showReleaseFolderBack: showReleaseFolderBack,
                      releaseFolderLabel: releaseFolderLabel,
                      onReleaseFolderBack: onReleaseFolderBack,
                      onDetailsLayoutChanged: onDetailsLayoutChanged,
                      onDensityPresetChanged: onDensityPresetChanged,
                      onCoverSizeChanged: onCoverSizeChanged,
                      selectedBucket: selectedBucket,
                      onClearBucket: onClearBucket,
                      quickView: quickView,
                      activeSortFavoriteId: activeSortFavoriteId,
                      sortFavorites: sortFavorites,
                      onSortFavoriteSelected: onSortFavoriteSelected,
                      pinnedSortFavoriteIds: pinnedSortFavoriteIds,
                      onTogglePinnedSortFavorite: onTogglePinnedSortFavorite,
                      onManageSortFavorites: onManageSortFavorites,
                      hasActiveFilters: hasActiveFilters,
                      onQuickViewSelected: onQuickViewSelected,
                      onClearFilters: onClearFilters,
                      onEditFilters: onEditFilters,
                      activeFilterCount: activeFilterCount,
                      onRandomPick: onRandomPick,
                      onDownloadAllCovers: onDownloadAllCovers,
                      shelfState: shelfState,
                      onSmartLists: onSmartLists,
                      onFolders: onFolders,
                      onReadingQueue: effectiveReadingQueue,
                      onEditConditionPickList: onEditConditionPickList,
                      onEditGradePickList: onEditGradePickList,
                      onEditTagPickList: onEditTagPickList,
                      onTransferFieldData: onTransferFieldData,
                      onReassignIndex: effectiveReassignIndex,
                      onPrintReport: onPrintReport,
                      onShareCollection: onShareCollection,
                      onCompareMetadataWithServer: onCompareMetadataWithServer,
                      groupMode: groupMode,
                      folderPreset: folderPreset,
                      groupPresentation: groupPresentation,
                      availableGroupModes: availableGroupModes,
                      pinnedFolderPresets: pinnedFolderPresets,
                      onPinnedFolderPresetsChanged:
                          onPinnedFolderPresetsChanged,
                      onGroupModeChanged: onGroupModeChanged,
                      onGroupPresentationChanged: onGroupPresentationChanged,
                      selectionCallbacks: selectionCallbacks,
                      selectedCount: selectedCount,
                      totalSelectableCount: totalSelectableCount,
                      showBottomBorder: false,
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
