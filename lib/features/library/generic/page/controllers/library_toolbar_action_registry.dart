import 'dart:async';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
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
    required this.supportsTrackSearch,
    required this.onSearchChanged,
    required this.onSearchInputChanged,
    required this.onSearchTargetChanged,
    required this.onClearSearch,
    required this.onSearchSuggestionSelected,
  });

  final bool supportsTrackSearch;
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
    required this.onJumpToNumberSubmitted,
    required this.selectedProjectionItemFor,
    required this.canCompareMetadataWithServerItem,
  });

  final ValueChanged<LibraryProjection?> onRefreshMetadata;
  final ValueChanged<LibraryCollectionStatusScope> onSetCollectionStatusScope;
  final void Function(LibraryProjection projection, String value)
      onJumpToNumberSubmitted;
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
    required this.onShareCollection,
    required this.onCompareMetadataWithServer,
    required this.onMissingSequenceReport,
  });

  final ValueChanged<LibraryProjection?> onTransferFieldData;
  final ValueChanged<LibraryProjection?> onReassignIndex;
  final ValueChanged<LibraryProjection?> onPrintReport;
  final ValueChanged<LibraryProjection?> onShareCollection;
  final Future<void> Function(
    LibraryProjection projection, {
    LibraryProjectionItem? item,
  }) onCompareMetadataWithServer;
  final ValueChanged<LibraryProjection?> onMissingSequenceReport;
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
    required BuildContext buildContext,
    required LibraryPageToolbarActionContext actionContext,
    required LibraryProjection? projection,
    required LibraryWorkspaceViewState viewState,
    required ShelfState? shelfState,
  }) {
    final availability = actionContext.view.type.toolbarActionAvailability;
    final kindCapabilities = availability.capabilities;
    final kindToolbarActions = libraryKindModuleForType(actionContext.view.type)
        .toolbar
        .actions;
    bool enabled(LibraryToolbarActionId id) => availability.allows(id);
    final extraUtilityActions = kindToolbarActions
        .map(
          (descriptor) => descriptor.buildAction(
            buildContext,
            LibraryToolbarActionContext(
              type: actionContext.view.type,
              projection: projection,
              onJumpToNumberSubmitted: projection == null
                  ? null
                  : (value) =>
                      actionContext.metadata.onJumpToNumberSubmitted(
                        projection,
                        value,
                      ),
              onMissingSequenceReport:
                  actionContext.collectionActions.onMissingSequenceReport,
            ),
          ),
        )
        .toList(growable: false);

    return LibraryToolbarActions(
      onAdd: enabled(LibraryToolbarActionId.add)
          ? actionContext.view.onShowAddDialogFlow
          : () {},
      onScan: enabled(LibraryToolbarActionId.scan)
          ? actionContext.adminActions.onScanCover
          : () {},
      onSearchChanged: actionContext.search.onSearchChanged,
      onSearchInputChanged: actionContext.search.onSearchInputChanged,
      onSearchTargetChanged: actionContext.search.supportsTrackSearch
          ? actionContext.search.onSearchTargetChanged
          : null,
      onClearSearch: actionContext.search.onClearSearch,
      onSearchSuggestionSelected: actionContext.search.onSearchSuggestionSelected,
      onEditColumns: enabled(LibraryToolbarActionId.editColumns)
          ? actionContext.view.onShowColumnChooserFlow
          : () {},
      onSortChanged: (String column) =>
          actionContext.view.onUpdateViewState(
        (LibraryWorkspaceViewState next) =>
            next.withSortColumn(column, actionContext.view.adapter.viewProfile),
      ),
      onEditSort: actionContext.view.onShowSortDialogFlow,
      onSidebarVisibilityChanged: actionContext.view.onSetGroupingPanelVisibility,
      onViewModeChanged: (LibraryViewMode mode) =>
          actionContext.view.onUpdateViewState(
        (LibraryWorkspaceViewState next) => next.copyWith(viewMode: mode),
      ),
      onBrowserModeChanged: actionContext.view.onSetBrowserMode,
      onReleaseFolderBack: actionContext.view.showReleaseFolderBack
          ? actionContext.view.onCloseReleaseFolder
          : null,
      onDetailsLayoutChanged: (LibraryDetailsLayout layout) =>
          actionContext.view.onUpdateViewState(
        (LibraryWorkspaceViewState next) =>
            next.copyWith(detailsLayout: layout),
      ),
      onDensityPresetChanged: (LibraryWorkspaceDensityPreset densityPreset) =>
          actionContext.view.onUpdateViewState(
        (LibraryWorkspaceViewState next) =>
            next.copyWith(densityPreset: densityPreset),
      ),
      onCoverSizeChanged: (double size) => actionContext.view.onUpdateViewState(
        (LibraryWorkspaceViewState next) => next.copyWith(coverSize: size),
      ),
      onClearBucket: actionContext.view.onClearToolbarSearchChip,
      onRefreshMetadata: () =>
          actionContext.metadata.onRefreshMetadata(projection),
      onCollectionStatusScopeChanged:
          actionContext.metadata.onSetCollectionStatusScope,
      onQuickViewSelected: actionContext.view.onQuickViewSelected,
      onLetterSelected: actionContext.view.onSetSelectedLetter,
      onViewPresetSelected: actionContext.view.onApplyViewPreset,
      onTogglePinnedViewPreset: actionContext.view.onTogglePinnedViewPreset,
      onSortFavoriteSelected: actionContext.view.onApplySortFavorite,
      onTogglePinnedSortFavorite: actionContext.view.onTogglePinnedSortFavorite,
      onManageSortFavorites: actionContext.view.onShowSortFavoritesManagerFlow,
      onColumnFavoriteSelected: actionContext.view.onApplyColumnFavorite,
      onTogglePinnedColumnFavorite:
          actionContext.view.onTogglePinnedColumnFavorite,
      onJumpToNumberSubmitted: projection == null
          ? null
          : (String value) =>
              actionContext.metadata.onJumpToNumberSubmitted(projection, value),
      onClearFilters: actionContext.grouping.onClearFilters,
      onEditFilters: projection == null
          ? null
          : () => actionContext.grouping.onEditFilters(projection),
      onRandomPick: projection == null
          ? null
          : () => actionContext.grouping.onRandomPick(projection),
      onScanCover: kindCapabilities.canScanCover
          ? actionContext.adminActions.onScanCover
          : null,
      onDownloadAllCovers:
          kindCapabilities.canDownloadAllCovers && shelfState != null
              ? () => actionContext.adminActions.onDownloadAllCovers(shelfState)
              : null,
      onSmartLists: shelfState == null
          ? null
          : () => actionContext.grouping.onSmartLists(shelfState),
      onFolders: actionContext.grouping.onShowUserFoldersFlow,
      onReadingQueue: kindCapabilities.canReadingQueue
          ? actionContext.grouping.onShowReadingQueueFlow
          : null,
      onEditConditionPickList:
          actionContext.adminActions.onShowConditionPickListEditorFlow,
      onEditGradePickList: actionContext.adminActions.onShowGradePickListEditorFlow,
      onEditTagPickList: actionContext.adminActions.onShowTagPickListEditorFlow,
      onTransferFieldData: projection == null
          ? null
          : () => actionContext.collectionActions.onTransferFieldData(projection),
      onReassignIndex: projection == null || !kindCapabilities.canReassignIndex
          ? null
          : () => actionContext.collectionActions.onReassignIndex(projection),
      onPrintReport: projection != null && projection.filteredItems.isNotEmpty
          ? () => actionContext.collectionActions.onPrintReport(projection)
          : null,
      onShareCollection:
          projection != null && projection.filteredItems.isNotEmpty
              ? () => actionContext.collectionActions.onShareCollection(projection)
              : null,
      onCompareMetadataWithServer: (() {
        if (projection == null ||
            !kindCapabilities.canCompareMetadataWithServer ||
            !actionContext.view.type.kindUiAdapter.supportsMetadataCompareWithServer(
              actionContext.view.type,
            )) {
          return null;
        }
        final selected =
            actionContext.metadata.selectedProjectionItemFor(projection);
        if (selected == null ||
            !actionContext.metadata.canCompareMetadataWithServerItem(selected)) {
          return null;
        }
        return () async {
          await actionContext.collectionActions.onCompareMetadataWithServer(
            projection,
            item: selected,
          );
        };
      })(),
      onPinnedFolderPresetsChanged: (_) {},
      onGroupModeChanged: (_) {},
      onGroupPresentationChanged: (_) {},
      extraUtilityActions: extraUtilityActions,
    );
  }
}
