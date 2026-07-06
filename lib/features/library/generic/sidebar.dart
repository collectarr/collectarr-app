import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/sidebar/sidebar_header.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_series_sidebar.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/generic/sidebar/compact_bucket_bar.dart';

class LibrarySidebar extends StatelessWidget {
  const LibrarySidebar({
    super.key,
    required this.type,
    required this.accent,
    required this.buckets,
    required this.groupMode,
    this.groupLoading = false,
    required this.selectedBucket,
    required this.onSelected,
    required this.onGroupModeChanged,
    this.availableGroupModes,
    this.breadcrumbs = const [],
    this.ancestorScopeLabels = const [],
    this.onNavigateBack,
    this.onNavigateToBreadcrumb,
    this.onNavigateToAncestorScope,
    this.searchQuery,
    this.activeSmartListName,
    this.quickView,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.seriesCompletionScope = LibrarySeriesCompletionScope.all,
    this.collectionStatusScopeLabel,
    this.linkedMetadataFilterLabel,
    this.selectedLetter,
    this.seriesStatusSummary,
    this.filterSelection = LibraryFilterSelection.none,
    this.hasActiveFilters = false,
    this.onEditFilters,
    this.onClearFilters,
    this.onCollectionStatusScopeChanged,
    this.onSeriesCompletionScopeChanged,
    required this.onClearFilter,
    this.onHideSidebar,
    this.onSidebarVisibilityChanged,
    this.onManageBuckets,
    this.folderPreset,
    this.pinnedFolderPresets = const [],
    this.onPinnedFolderPresetsChanged,
    this.folderDisplayMode = LibraryFolderDisplayMode.drilldown,
    this.treeRoots = const <LibraryFolderTreeNode>[],
    this.selectedTreeNodeId,
    this.expandedTreeNodeIds = const <String>{},
    this.onFolderDisplayModeChanged,
    this.onSelectTreeNodePath,
    this.onToggleTreeNodeExpanded,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final List<LibrarySeriesBucket> buckets;
  final LibraryGroupMode groupMode;
  final LibraryFolderPreset? folderPreset;
  final bool groupLoading;
  final String selectedBucket;
  final ValueChanged<String> onSelected;
  final ValueChanged<LibraryGroupMode> onGroupModeChanged;
  final List<LibraryGroupMode>? availableGroupModes;
  final List<String> breadcrumbs;
  final List<String> ancestorScopeLabels;
  final VoidCallback? onNavigateBack;
  final ValueChanged<int>? onNavigateToBreadcrumb;
  final ValueChanged<int>? onNavigateToAncestorScope;
  final String? searchQuery;
  final String? activeSmartListName;
  final LibraryQuickView? quickView;
  final LibraryCollectionStatusScope collectionStatusScope;
  final LibrarySeriesCompletionScope seriesCompletionScope;
  final String? collectionStatusScopeLabel;
  final String? linkedMetadataFilterLabel;
  final String? selectedLetter;
  final LibrarySeriesStatusSummary? seriesStatusSummary;
  final LibraryFilterSelection filterSelection;
  final bool hasActiveFilters;
  final VoidCallback? onEditFilters;
  final VoidCallback? onClearFilters;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final ValueChanged<LibrarySeriesCompletionScope>?
      onSeriesCompletionScopeChanged;
  final VoidCallback? onClearFilter;
  final VoidCallback? onHideSidebar;
  final ValueChanged<bool>? onSidebarVisibilityChanged;
  final VoidCallback? onManageBuckets;
  final List<LibraryFolderPreset> pinnedFolderPresets;
  final ValueChanged<List<LibraryFolderPreset>>? onPinnedFolderPresetsChanged;
  final LibraryFolderDisplayMode folderDisplayMode;
  final List<LibraryFolderTreeNode> treeRoots;
  final String? selectedTreeNodeId;
  final Set<String> expandedTreeNodeIds;
  final ValueChanged<LibraryFolderDisplayMode>? onFolderDisplayModeChanged;
  final ValueChanged<List<LibraryFolderTreeNode>>? onSelectTreeNodePath;
  final ValueChanged<String>? onToggleTreeNodeExpanded;

  @override
  Widget build(BuildContext context) {
    return LibrarySeriesSidebar(
      title: 'Folders',
      icon: Icons.folder_open_outlined,
      series: buckets,
      selectedSeries: selectedBucket,
      onSelectSeries: onSelected,
      accentColor: accent,
      selectionColor: accent.withValues(alpha: 0.42),
      backgroundColor: appPalette(context).panel,
      headerColor: appPalette(context).surface,
      dividerColor: appPalette(context).divider,
      selectedBadgeColor: appPalette(context).highlight,
      mutedTextColor: appPalette(context).textMuted,
      searchPlaceholder:
          'Search ${genericGroupModeLabel(groupMode, type).toLowerCase()}...',
      collectionStatusScope: collectionStatusScope,
      onCollectionStatusScopeChanged: onCollectionStatusScopeChanged,
      seriesCompletionScope: seriesCompletionScope,
      onSeriesCompletionScopeChanged: onSeriesCompletionScopeChanged,
      ancestorScopeLabels: ancestorScopeLabels,
      onNavigateToAncestorScope: onNavigateToAncestorScope,
      headerOverride: LibrarySidebarHeader(
        type: type,
        groupMode: groupMode,
        folderPreset: folderPreset,
        accent: accent,
        icon: genericFolderPresetIcon(
          folderPreset ?? LibraryFolderPreset.single(groupMode),
          type,
        ),
        onChanged: (preset) => onGroupModeChanged(preset.primaryMode),
        breadcrumbs: breadcrumbs,
        onNavigateBack: onNavigateBack,
        onNavigateToBreadcrumb: onNavigateToBreadcrumb,
        groupLoading: groupLoading,
        availableGroupModes: availableGroupModes,
        selectedBucket: selectedBucket,
        searchQuery: searchQuery,
        activeSmartListName: activeSmartListName,
        quickView: quickView,
        collectionStatusScope: collectionStatusScope,
        collectionStatusScopeLabel: collectionStatusScopeLabel,
        linkedMetadataFilterLabel: linkedMetadataFilterLabel,
        selectedLetter: selectedLetter,
        seriesStatusSummary: seriesStatusSummary,
        filterSelection: filterSelection,
        hasActiveFilters: hasActiveFilters,
        onEditFilters: onEditFilters,
        onClearFilters: onClearFilters,
        onCollectionStatusScopeChanged: onCollectionStatusScopeChanged,
        onClearFilter: onClearFilter,
        onHideSidebar: onHideSidebar,
        onSidebarVisibilityChanged: onSidebarVisibilityChanged,
        onManageBuckets: onManageBuckets,
        pinnedFolderPresets: pinnedFolderPresets,
        onPinnedFolderPresetsChanged: onPinnedFolderPresetsChanged,
        folderDisplayMode: folderDisplayMode,
        onFolderDisplayModeChanged: onFolderDisplayModeChanged,
      ),
      folderDisplayMode: folderDisplayMode,
      treeRoots: treeRoots,
      selectedTreeNodeId: selectedTreeNodeId,
      expandedTreeNodeIds: expandedTreeNodeIds,
      onFolderDisplayModeChanged: onFolderDisplayModeChanged,
      onSelectTreeNodePath: onSelectTreeNodePath,
      onToggleTreeNodeExpanded: onToggleTreeNodeExpanded,
    );
  }
}
