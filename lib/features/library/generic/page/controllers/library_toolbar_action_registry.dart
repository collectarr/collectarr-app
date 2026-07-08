import 'dart:async';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/generic/toolbar/library_toolbar_actions.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_search.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class LibraryPageToolbarActionContext {
  const LibraryPageToolbarActionContext({
    required this.type,
    required this.activeBrowserMode,
    required this.activeReleaseFolderTitleItemId,
    required this.adapter,
    required this.supportsMusicTrackSearch,
    required this.onSearchChanged,
    required this.onSearchInputChanged,
    required this.onSearchTargetChanged,
    required this.onClearSearch,
    required this.onSearchSuggestionSelected,
    required this.onShowAddDialogFlow,
    required this.onShowColumnChooserFlow,
    required this.onShowSortDialogFlow,
    required this.onSetGroupingPanelVisibility,
    required this.onUpdateViewState,
    required this.onSetBrowserMode,
    required this.onCloseReleaseFolder,
    required this.onClearToolbarSearchChip,
    required this.onRefreshMetadata,
    required this.onSetCollectionStatusScope,
    required this.onQuickViewSelected,
    required this.onSetSelectedLetter,
    required this.onApplyViewPreset,
    required this.onTogglePinnedViewPreset,
    required this.onApplySortFavorite,
    required this.onTogglePinnedSortFavorite,
    required this.onShowSortFavoritesManagerFlow,
    required this.onApplyColumnFavorite,
    required this.onTogglePinnedColumnFavorite,
    required this.onJumpToIssueSubmitted,
    required this.onClearFilters,
    required this.onEditFilters,
    required this.onRandomPick,
    required this.onScanCover,
    required this.onDownloadAllCovers,
    required this.onSmartLists,
    required this.onShowUserFoldersFlow,
    required this.onShowReadingQueueFlow,
    required this.onShowConditionPickListEditorFlow,
    required this.onShowGradePickListEditorFlow,
    required this.onShowTagPickListEditorFlow,
    required this.onTransferFieldData,
    required this.onReassignIndex,
    required this.onPrintReport,
    required this.onMissingComics,
    required this.onShareCollection,
    required this.onCompareMetadataWithServer,
    required this.selectedProjectionItemFor,
    required this.canCompareMetadataWithServerItem,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceBrowserMode activeBrowserMode;
  final String? activeReleaseFolderTitleItemId;
  final LibraryMediaAdapter adapter;
  final bool supportsMusicTrackSearch;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchInputChanged;
  final ValueChanged<LibrarySearchTarget>? onSearchTargetChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<LibraryToolbarSearchSuggestion> onSearchSuggestionSelected;
  final VoidCallback onShowAddDialogFlow;
  final VoidCallback onShowColumnChooserFlow;
  final VoidCallback onShowSortDialogFlow;
  final ValueChanged<bool> onSetGroupingPanelVisibility;
  final void Function(
    LibraryWorkspaceViewState Function(LibraryWorkspaceViewState),
  ) onUpdateViewState;
  final ValueChanged<LibraryWorkspaceBrowserMode> onSetBrowserMode;
  final VoidCallback onCloseReleaseFolder;
  final VoidCallback onClearToolbarSearchChip;
  final ValueChanged<LibraryProjection?> onRefreshMetadata;
  final ValueChanged<LibraryCollectionStatusScope> onSetCollectionStatusScope;
  final ValueChanged<LibraryQuickView?> onQuickViewSelected;
  final ValueChanged<String?> onSetSelectedLetter;
  final ValueChanged<LibraryWorkspacePreset> onApplyViewPreset;
  final ValueChanged<LibraryWorkspacePreset> onTogglePinnedViewPreset;
  final ValueChanged<LibrarySortFavorite> onApplySortFavorite;
  final ValueChanged<LibrarySortFavorite> onTogglePinnedSortFavorite;
  final VoidCallback onShowSortFavoritesManagerFlow;
  final ValueChanged<LibraryTableColumnPreset> onApplyColumnFavorite;
  final ValueChanged<LibraryTableColumnPreset> onTogglePinnedColumnFavorite;
  final void Function(LibraryProjection projection, String value)
      onJumpToIssueSubmitted;
  final VoidCallback onClearFilters;
  final ValueChanged<LibraryProjection?> onEditFilters;
  final ValueChanged<LibraryProjection?> onRandomPick;
  final VoidCallback onScanCover;
  final ValueChanged<ShelfState> onDownloadAllCovers;
  final ValueChanged<ShelfState?> onSmartLists;
  final VoidCallback onShowUserFoldersFlow;
  final VoidCallback onShowReadingQueueFlow;
  final VoidCallback? onShowConditionPickListEditorFlow;
  final VoidCallback? onShowGradePickListEditorFlow;
  final VoidCallback onShowTagPickListEditorFlow;
  final ValueChanged<LibraryProjection?> onTransferFieldData;
  final ValueChanged<LibraryProjection?> onReassignIndex;
  final ValueChanged<LibraryProjection?> onPrintReport;
  final ValueChanged<LibraryProjection?> onMissingComics;
  final ValueChanged<LibraryProjection?> onShareCollection;
  final Future<void> Function(
    LibraryProjection projection, {
    LibraryProjectionItem? item,
  }) onCompareMetadataWithServer;
  final LibraryProjectionItem? Function(LibraryProjection projection)
      selectedProjectionItemFor;
  final bool Function(LibraryProjectionItem item)
      canCompareMetadataWithServerItem;

  bool get showReleaseFolderBack =>
      type.kindUiAdapter.shouldShowReleaseFolderBack(
        type,
        browserMode: activeBrowserMode,
        releaseFolderTitleItemId: activeReleaseFolderTitleItemId,
      );
}

class LibraryToolbarActionRegistry {
  const LibraryToolbarActionRegistry();

  LibraryToolbarActions build({
    required LibraryPageToolbarActionContext context,
    required LibraryProjection? projection,
    required LibraryWorkspaceViewState viewState,
    required ShelfState? shelfState,
  }) {
    final availability = context.type.toolbarActionAvailability;
    final kindCapabilities = availability.capabilities;
    bool enabled(LibraryToolbarActionId id) => availability.allows(id);

    return LibraryToolbarActions(
      onAdd: enabled(LibraryToolbarActionId.add)
          ? context.onShowAddDialogFlow
          : () {},
      onScan:
          enabled(LibraryToolbarActionId.scan) ? context.onScanCover : () {},
      onSearchChanged: context.onSearchChanged,
      onSearchInputChanged: context.onSearchInputChanged,
      onSearchTargetChanged: context.supportsMusicTrackSearch
          ? context.onSearchTargetChanged
          : null,
      onClearSearch: context.onClearSearch,
      onSearchSuggestionSelected: context.onSearchSuggestionSelected,
      onEditColumns: enabled(LibraryToolbarActionId.editColumns)
          ? context.onShowColumnChooserFlow
          : () {},
      onSortChanged: (LibrarySortColumn column) => context.onUpdateViewState(
        (LibraryWorkspaceViewState next) =>
            next.withSortColumn(column, context.adapter.viewProfile),
      ),
      onEditSort: context.onShowSortDialogFlow,
      onSidebarVisibilityChanged: context.onSetGroupingPanelVisibility,
      onViewModeChanged: (LibraryViewMode mode) => context.onUpdateViewState(
        (LibraryWorkspaceViewState next) => next.copyWith(viewMode: mode),
      ),
      onBrowserModeChanged: context.onSetBrowserMode,
      onReleaseFolderBack:
          context.showReleaseFolderBack ? context.onCloseReleaseFolder : null,
      onDetailsLayoutChanged: (LibraryDetailsLayout layout) =>
          context.onUpdateViewState(
        (LibraryWorkspaceViewState next) =>
            next.copyWith(detailsLayout: layout),
      ),
      onDensityPresetChanged: (LibraryWorkspaceDensityPreset densityPreset) =>
          context.onUpdateViewState(
        (LibraryWorkspaceViewState next) =>
            next.copyWith(densityPreset: densityPreset),
      ),
      onCoverSizeChanged: (double size) => context.onUpdateViewState(
        (LibraryWorkspaceViewState next) => next.copyWith(coverSize: size),
      ),
      onClearBucket: context.onClearToolbarSearchChip,
      onRefreshMetadata: () => context.onRefreshMetadata(projection),
      onCollectionStatusScopeChanged: context.onSetCollectionStatusScope,
      onQuickViewSelected: context.onQuickViewSelected,
      onLetterSelected: context.onSetSelectedLetter,
      onViewPresetSelected: context.onApplyViewPreset,
      onTogglePinnedViewPreset: context.onTogglePinnedViewPreset,
      onSortFavoriteSelected: context.onApplySortFavorite,
      onTogglePinnedSortFavorite: context.onTogglePinnedSortFavorite,
      onManageSortFavorites: context.onShowSortFavoritesManagerFlow,
      onColumnFavoriteSelected: context.onApplyColumnFavorite,
      onTogglePinnedColumnFavorite: context.onTogglePinnedColumnFavorite,
      onJumpToIssueSubmitted: projection == null
          ? null
          : (String value) => context.onJumpToIssueSubmitted(projection, value),
      onClearFilters: context.onClearFilters,
      onEditFilters:
          projection == null ? null : () => context.onEditFilters(projection),
      onRandomPick:
          projection == null ? null : () => context.onRandomPick(projection),
      onScanCover: kindCapabilities.canScanCover ? context.onScanCover : null,
      onDownloadAllCovers:
          kindCapabilities.canDownloadAllCovers && shelfState != null
              ? () => context.onDownloadAllCovers(shelfState)
              : null,
      onSmartLists:
          shelfState == null ? null : () => context.onSmartLists(shelfState),
      onFolders: context.onShowUserFoldersFlow,
      onReadingQueue: kindCapabilities.canReadingQueue
          ? context.onShowReadingQueueFlow
          : null,
      onEditConditionPickList: context.onShowConditionPickListEditorFlow,
      onEditGradePickList: context.onShowGradePickListEditorFlow,
      onEditTagPickList: context.onShowTagPickListEditorFlow,
      onTransferFieldData: projection == null
          ? null
          : () => context.onTransferFieldData(projection),
      onReassignIndex: projection == null || !kindCapabilities.canReassignIndex
          ? null
          : () => context.onReassignIndex(projection),
      onPrintReport: projection != null && projection.filteredItems.isNotEmpty
          ? () => context.onPrintReport(projection)
          : null,
      onMissingComics: projection != null &&
              kindCapabilities.canMissingComicsReport &&
              context.type.kindUiAdapter.supportsMissingComicsReport(
                context.type,
              )
          ? () => context.onMissingComics(projection)
          : null,
      onShareCollection:
          projection != null && projection.filteredItems.isNotEmpty
              ? () => context.onShareCollection(projection)
              : null,
      onCompareMetadataWithServer: (() {
        if (projection == null ||
            !kindCapabilities.canCompareMetadataWithServer ||
            !context.type.kindUiAdapter.supportsMetadataCompareWithServer(
              context.type,
            )) {
          return null;
        }
        final selected = context.selectedProjectionItemFor(projection);
        if (selected == null ||
            !context.canCompareMetadataWithServerItem(selected)) {
          return null;
        }
        return () async {
          await context.onCompareMetadataWithServer(
            projection,
            item: selected,
          );
        };
      })(),
      onPinnedFolderPresetsChanged: (_) {},
      onGroupModeChanged: (_) {},
      onGroupPresentationChanged: (_) {},
    );
  }
}
