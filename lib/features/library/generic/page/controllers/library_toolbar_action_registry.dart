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

class LibraryToolbarSearchContext {
  const LibraryToolbarSearchContext({
    required this.supportsMusicTrackSearch,
    required this.onSearchChanged,
    required this.onSearchInputChanged,
    required this.onSearchTargetChanged,
    required this.onClearSearch,
    required this.onSearchSuggestionSelected,
  });

  final bool supportsMusicTrackSearch;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchInputChanged;
  final ValueChanged<LibrarySearchTarget>? onSearchTargetChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<LibraryToolbarSearchSuggestion> onSearchSuggestionSelected;
}

class LibraryToolbarViewContext {
  const LibraryToolbarViewContext({
    required this.type,
    required this.activeBrowserMode,
    required this.activeReleaseFolderTitleItemId,
    required this.adapter,
    required this.onShowAddDialogFlow,
    required this.onShowColumnChooserFlow,
    required this.onShowSortDialogFlow,
    required this.onSetGroupingPanelVisibility,
    required this.onUpdateViewState,
    required this.onSetBrowserMode,
    required this.onCloseReleaseFolder,
    required this.onClearToolbarSearchChip,
    required this.onQuickViewSelected,
    required this.onSetSelectedLetter,
    required this.onApplyViewPreset,
    required this.onTogglePinnedViewPreset,
    required this.onApplySortFavorite,
    required this.onTogglePinnedSortFavorite,
    required this.onShowSortFavoritesManagerFlow,
    required this.onApplyColumnFavorite,
    required this.onTogglePinnedColumnFavorite,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceBrowserMode activeBrowserMode;
  final String? activeReleaseFolderTitleItemId;
  final LibraryMediaAdapter adapter;
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
  final ValueChanged<LibraryQuickView?> onQuickViewSelected;
  final ValueChanged<String?> onSetSelectedLetter;
  final ValueChanged<LibraryWorkspacePreset> onApplyViewPreset;
  final ValueChanged<LibraryWorkspacePreset> onTogglePinnedViewPreset;
  final ValueChanged<LibrarySortFavorite> onApplySortFavorite;
  final ValueChanged<LibrarySortFavorite> onTogglePinnedSortFavorite;
  final VoidCallback onShowSortFavoritesManagerFlow;
  final ValueChanged<LibraryTableColumnPreset> onApplyColumnFavorite;
  final ValueChanged<LibraryTableColumnPreset> onTogglePinnedColumnFavorite;

  bool get showReleaseFolderBack =>
      type.kindUiAdapter.shouldShowReleaseFolderBack(
        type,
        browserMode: activeBrowserMode,
        releaseFolderTitleItemId: activeReleaseFolderTitleItemId,
      );
}

class LibraryToolbarGroupingContext {
  const LibraryToolbarGroupingContext({
    required this.onClearFilters,
    required this.onEditFilters,
    required this.onRandomPick,
    required this.onSmartLists,
    required this.onShowUserFoldersFlow,
    required this.onShowReadingQueueFlow,
  });

  final VoidCallback onClearFilters;
  final ValueChanged<LibraryProjection?> onEditFilters;
  final ValueChanged<LibraryProjection?> onRandomPick;
  final ValueChanged<ShelfState?> onSmartLists;
  final VoidCallback onShowUserFoldersFlow;
  final VoidCallback onShowReadingQueueFlow;
}

class LibraryToolbarMetadataContext {
  const LibraryToolbarMetadataContext({
    required this.onRefreshMetadata,
    required this.onSetCollectionStatusScope,
    required this.onJumpToIssueSubmitted,
    required this.selectedProjectionItemFor,
    required this.canCompareMetadataWithServerItem,
  });

  final ValueChanged<LibraryProjection?> onRefreshMetadata;
  final ValueChanged<LibraryCollectionStatusScope> onSetCollectionStatusScope;
  final void Function(LibraryProjection projection, String value)
      onJumpToIssueSubmitted;
  final LibraryProjectionItem? Function(LibraryProjection projection)
      selectedProjectionItemFor;
  final bool Function(LibraryProjectionItem item)
      canCompareMetadataWithServerItem;
}

class LibraryToolbarCollectionActionsContext {
  const LibraryToolbarCollectionActionsContext({
    required this.onTransferFieldData,
    required this.onReassignIndex,
    required this.onPrintReport,
    required this.onMissingComics,
    required this.onShareCollection,
    required this.onCompareMetadataWithServer,
  });

  final ValueChanged<LibraryProjection?> onTransferFieldData;
  final ValueChanged<LibraryProjection?> onReassignIndex;
  final ValueChanged<LibraryProjection?> onPrintReport;
  final ValueChanged<LibraryProjection?> onMissingComics;
  final ValueChanged<LibraryProjection?> onShareCollection;
  final Future<void> Function(
    LibraryProjection projection, {
    LibraryProjectionItem? item,
  }) onCompareMetadataWithServer;
}

class LibraryToolbarAdminActionsContext {
  const LibraryToolbarAdminActionsContext({
    required this.onScanCover,
    required this.onDownloadAllCovers,
    required this.onShowConditionPickListEditorFlow,
    required this.onShowGradePickListEditorFlow,
    required this.onShowTagPickListEditorFlow,
  });

  final VoidCallback onScanCover;
  final ValueChanged<ShelfState> onDownloadAllCovers;
  final VoidCallback? onShowConditionPickListEditorFlow;
  final VoidCallback? onShowGradePickListEditorFlow;
  final VoidCallback onShowTagPickListEditorFlow;
}

class LibraryPageToolbarActionContext {
  const LibraryPageToolbarActionContext({
    required this.search,
    required this.view,
    required this.grouping,
    required this.metadata,
    required this.collectionActions,
    required this.adminActions,
  });

  final LibraryToolbarSearchContext search;
  final LibraryToolbarViewContext view;
  final LibraryToolbarGroupingContext grouping;
  final LibraryToolbarMetadataContext metadata;
  final LibraryToolbarCollectionActionsContext collectionActions;
  final LibraryToolbarAdminActionsContext adminActions;
}

class LibraryToolbarActionRegistry {
  const LibraryToolbarActionRegistry();

  LibraryToolbarActions build({
    required LibraryPageToolbarActionContext context,
    required LibraryProjection? projection,
    required LibraryWorkspaceViewState viewState,
    required ShelfState? shelfState,
  }) {
    final availability = context.view.type.toolbarActionAvailability;
    final kindCapabilities = availability.capabilities;
    bool enabled(LibraryToolbarActionId id) => availability.allows(id);

    return LibraryToolbarActions(
      onAdd: enabled(LibraryToolbarActionId.add)
          ? context.view.onShowAddDialogFlow
          : () {},
      onScan: enabled(LibraryToolbarActionId.scan)
          ? context.adminActions.onScanCover
          : () {},
      onSearchChanged: context.search.onSearchChanged,
      onSearchInputChanged: context.search.onSearchInputChanged,
      onSearchTargetChanged: context.search.supportsMusicTrackSearch
          ? context.search.onSearchTargetChanged
          : null,
      onClearSearch: context.search.onClearSearch,
      onSearchSuggestionSelected: context.search.onSearchSuggestionSelected,
      onEditColumns: enabled(LibraryToolbarActionId.editColumns)
          ? context.view.onShowColumnChooserFlow
          : () {},
      onSortChanged: (LibrarySortColumn column) =>
          context.view.onUpdateViewState(
        (LibraryWorkspaceViewState next) =>
            next.withSortColumn(column, context.view.adapter.viewProfile),
      ),
      onEditSort: context.view.onShowSortDialogFlow,
      onSidebarVisibilityChanged: context.view.onSetGroupingPanelVisibility,
      onViewModeChanged: (LibraryViewMode mode) =>
          context.view.onUpdateViewState(
        (LibraryWorkspaceViewState next) => next.copyWith(viewMode: mode),
      ),
      onBrowserModeChanged: context.view.onSetBrowserMode,
      onReleaseFolderBack: context.view.showReleaseFolderBack
          ? context.view.onCloseReleaseFolder
          : null,
      onDetailsLayoutChanged: (LibraryDetailsLayout layout) =>
          context.view.onUpdateViewState(
        (LibraryWorkspaceViewState next) =>
            next.copyWith(detailsLayout: layout),
      ),
      onDensityPresetChanged: (LibraryWorkspaceDensityPreset densityPreset) =>
          context.view.onUpdateViewState(
        (LibraryWorkspaceViewState next) =>
            next.copyWith(densityPreset: densityPreset),
      ),
      onCoverSizeChanged: (double size) => context.view.onUpdateViewState(
        (LibraryWorkspaceViewState next) => next.copyWith(coverSize: size),
      ),
      onClearBucket: context.view.onClearToolbarSearchChip,
      onRefreshMetadata: () => context.metadata.onRefreshMetadata(projection),
      onCollectionStatusScopeChanged:
          context.metadata.onSetCollectionStatusScope,
      onQuickViewSelected: context.view.onQuickViewSelected,
      onLetterSelected: context.view.onSetSelectedLetter,
      onViewPresetSelected: context.view.onApplyViewPreset,
      onTogglePinnedViewPreset: context.view.onTogglePinnedViewPreset,
      onSortFavoriteSelected: context.view.onApplySortFavorite,
      onTogglePinnedSortFavorite: context.view.onTogglePinnedSortFavorite,
      onManageSortFavorites: context.view.onShowSortFavoritesManagerFlow,
      onColumnFavoriteSelected: context.view.onApplyColumnFavorite,
      onTogglePinnedColumnFavorite: context.view.onTogglePinnedColumnFavorite,
      onJumpToIssueSubmitted: projection == null
          ? null
          : (String value) =>
              context.metadata.onJumpToIssueSubmitted(projection, value),
      onClearFilters: context.grouping.onClearFilters,
      onEditFilters: projection == null
          ? null
          : () => context.grouping.onEditFilters(projection),
      onRandomPick: projection == null
          ? null
          : () => context.grouping.onRandomPick(projection),
      onScanCover: kindCapabilities.canScanCover
          ? context.adminActions.onScanCover
          : null,
      onDownloadAllCovers:
          kindCapabilities.canDownloadAllCovers && shelfState != null
              ? () => context.adminActions.onDownloadAllCovers(shelfState)
              : null,
      onSmartLists: shelfState == null
          ? null
          : () => context.grouping.onSmartLists(shelfState),
      onFolders: context.grouping.onShowUserFoldersFlow,
      onReadingQueue: kindCapabilities.canReadingQueue
          ? context.grouping.onShowReadingQueueFlow
          : null,
      onEditConditionPickList:
          context.adminActions.onShowConditionPickListEditorFlow,
      onEditGradePickList: context.adminActions.onShowGradePickListEditorFlow,
      onEditTagPickList: context.adminActions.onShowTagPickListEditorFlow,
      onTransferFieldData: projection == null
          ? null
          : () => context.collectionActions.onTransferFieldData(projection),
      onReassignIndex: projection == null || !kindCapabilities.canReassignIndex
          ? null
          : () => context.collectionActions.onReassignIndex(projection),
      onPrintReport: projection != null && projection.filteredItems.isNotEmpty
          ? () => context.collectionActions.onPrintReport(projection)
          : null,
      onMissingComics: projection != null &&
              kindCapabilities.canMissingComicsReport &&
              context.view.type.kindUiAdapter.supportsMissingComicsReport(
                context.view.type,
              )
          ? () => context.collectionActions.onMissingComics(projection)
          : null,
      onShareCollection:
          projection != null && projection.filteredItems.isNotEmpty
              ? () => context.collectionActions.onShareCollection(projection)
              : null,
      onCompareMetadataWithServer: (() {
        if (projection == null ||
            !kindCapabilities.canCompareMetadataWithServer ||
            !context.view.type.kindUiAdapter.supportsMetadataCompareWithServer(
              context.view.type,
            )) {
          return null;
        }
        final selected = context.metadata.selectedProjectionItemFor(projection);
        if (selected == null ||
            !context.metadata.canCompareMetadataWithServerItem(selected)) {
          return null;
        }
        return () async {
          await context.collectionActions.onCompareMetadataWithServer(
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
