import 'dart:async';

import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/page/sidebar_scope_snapshot.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';

/// Owns the mutable interaction state shared by the generic library page.
///
/// Selection, facets and persisted view preferences have separate interfaces
/// so page modules can depend on the slice they operate on.
final class LibraryPageSession {
  LibraryPageSession({
    LibraryPageSelectionSession? selection,
    LibraryPageFacetSession? facets,
    LibraryPagePreferencesSession? preferences,
  })  : selection = selection ?? LibraryPageSelectionSession(),
        facets = facets ?? LibraryPageFacetSession(),
        preferences = preferences ?? LibraryPagePreferencesSession();

  final LibraryPageSelectionSession selection;
  final LibraryPageFacetSession facets;
  final LibraryPagePreferencesSession preferences;
}

final class LibraryPageSelectionSession {
  String? selectedId;
  String? anchorId;
  Timer? hydrationDebounce;
  LibrarySelectionState value = LibrarySelectionState.empty();
  LibraryFilterSelection filterSelection = LibraryFilterSelection.none;
}

final class LibraryPageFacetSession {
  String? selectedBucket;
  String? selectedLetter;
  String? lastEnsureSignature;
  LibraryFacetIdRuntime? lastEnsureFacetId;
  LibraryLinkedMetadataFilter? linkedMetadataFilter;
  LibraryQuickView? quickView;
  LibraryCollectionStatusScope collectionStatusScope =
      LibraryCollectionStatusScope.all;
  LibraryBucketCompletionScope bucketCompletionScope =
      LibraryBucketCompletionScope.all;
}

final class LibraryPagePreferencesSession {
  LibraryWorkspaceViewState? viewState;
  String? groupMode;
  LibraryFolderPreset? folderPreset;
  LibraryGroupPresentation? groupPresentationOverride;
  Set<String> collapsedGroupBuckets = const <String>{};
  LibraryFolderDisplayMode folderDisplayMode =
      LibraryFolderDisplayMode.drilldown;
  Set<String> folderTreeExpandedNodeIds = const <String>{};
  String? folderTreeSelectedNodeId;
  List<LibraryFolderPreset> pinnedFolderPresets = const [];
  String? activeSmartListId;
  String? activeSmartListName;
  Set<LibraryWorkspacePreset> pinnedViewPresets = const {};
  Set<String> pinnedSortFavoriteIds = const {};
  Set<String> pinnedColumnFavoriteKeys = const {};
  List<LibraryTableColumnPreset> savedColumnFavoritePresets = const [];
  List<LibrarySidebarScopeSnapshot> scopeHistory = const [];
  int viewStateLoadToken = 0;
  int viewPreferenceLoadToken = 0;
  int folderTreePreferenceLoadToken = 0;
  int columnFavoritesLoadToken = 0;
  Timer? viewStateSaveDebounce;
}
