import 'package:collectarr_app/features/library/workspace/layout/library_folder_row.dart';
import 'dart:async';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_group_values.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryBucket {
  const LibraryBucket({
    required this.title,
    required this.count,
    this.coverUrl,
    this.startYear,
    this.entryCount,
    this.missingNumbers = const <int>[],
  });

  final String title;
  final int count;
  final String? coverUrl;
  final int? startYear;
  final int? entryCount;
  final List<int> missingNumbers;

  int? get completionPercent {
    final entry = entryCount;
    if (entry == null || count <= 0) {
      return null;
    }
    final percent = ((entry / count) * 100).round();
    if (percent < 0) {
      return 0;
    }
    if (percent > 100) {
      return 100;
    }
    return percent;
  }
}

class LibraryBucketSidebar extends ConsumerStatefulWidget {
  const LibraryBucketSidebar({
    super.key,
    required this.buckets,
    required this.selectedBucket,
    required this.onSelectBucket,
    this.title = 'Buckets',
    this.allBucketLabel,
    this.preferenceStore,
    this.folderPreset,
    this.icon = Icons.folder,
    this.trailing,
    this.headerOverride,
    this.backgroundColor = kAppPanel,
    this.headerColor = kAppSurface,
    this.dividerColor = kAppDivider,
    this.accentColor = kAppAccent,
    this.selectionColor = kAppSelection,
    this.badgeColor = kAppBadgeBackground,
    this.selectedBadgeColor = kAppHighlight,
    this.mutedTextColor = kAppTextMuted,
    this.searchPlaceholder = 'Search folders',
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.onCollectionStatusScopeChanged,
    this.bucketCompletionScope = LibraryBucketCompletionScope.all,
    this.onBucketCompletionScopeChanged,
    this.ancestorScopeLabels = const <String>[],
    this.onNavigateToAncestorScope,
    this.folderDisplayMode = LibraryFolderDisplayMode.drilldown,
    this.treeRoots = const <LibraryFolderTreeNode>[],
    this.selectedTreeNodeId,
    this.expandedTreeNodeIds = const <String>{},
    this.onFolderDisplayModeChanged,
    this.onSelectTreeNodePath,
    this.onToggleTreeNodeExpanded,
  });

  final List<LibraryBucket> buckets;
  final String? selectedBucket;
  final ValueChanged<String> onSelectBucket;
  final String title;
  final String? allBucketLabel;
  final LibraryViewPreferenceStore? preferenceStore;
  final LibraryFolderPreset? folderPreset;
  final IconData icon;
  final Widget? trailing;
  final Widget? headerOverride;
  final Color backgroundColor;
  final Color headerColor;
  final Color dividerColor;
  final Color accentColor;
  final Color selectionColor;
  final Color badgeColor;
  final Color selectedBadgeColor;
  final Color mutedTextColor;
  final String searchPlaceholder;
  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final LibraryBucketCompletionScope bucketCompletionScope;
  final ValueChanged<LibraryBucketCompletionScope>?
      onBucketCompletionScopeChanged;
  final List<String> ancestorScopeLabels;
  final ValueChanged<int>? onNavigateToAncestorScope;
  final LibraryFolderDisplayMode folderDisplayMode;
  final List<LibraryFolderTreeNode> treeRoots;
  final String? selectedTreeNodeId;
  final Set<String> expandedTreeNodeIds;
  final ValueChanged<LibraryFolderDisplayMode>? onFolderDisplayModeChanged;
  final ValueChanged<List<LibraryFolderTreeNode>>? onSelectTreeNodePath;
  final ValueChanged<String>? onToggleTreeNodeExpanded;

  @override
  ConsumerState<LibraryBucketSidebar> createState() =>
      _LibraryBucketSidebarState();
}

class _LibraryBucketSidebarState extends ConsumerState<LibraryBucketSidebar> {
  final _searchController = TextEditingController();
  var _sortMode = LibraryFolderSortMode.alphabetical;

  int _sortRevision = 0;
  Future<void> _sortWrite = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _restoreSortMode();
  }

  @override
  void didUpdateWidget(covariant LibraryBucketSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preferenceStore?.kind != widget.preferenceStore?.kind ||
        oldWidget.folderPreset?.storageValue !=
            widget.folderPreset?.storageValue) {
      _searchController.clear();
      _restoreSortMode();
    }
  }

  void _restoreSortMode() {
    final revision = ++_sortRevision;
    final store = widget.preferenceStore;
    final preset = widget.folderPreset;
    _sortMode = store != null && preset != null
        ? store.cachedFolderSortMode(preset) ??
            LibraryFolderSortMode.alphabetical
        : LibraryFolderSortMode.alphabetical;
    if (store == null || preset == null) return;
    unawaited(() async {
      try {
        final restored = await store.readFolderSortMode(preset);
        if (!mounted || revision != _sortRevision) return;
        setState(
            () => _sortMode = restored ?? LibraryFolderSortMode.alphabetical);
      } catch (error) {
        debugPrint('Could not restore folder sorting: $error');
      }
    }());
  }

  void _toggleSortMode() {
    ++_sortRevision;
    setState(() {
      _sortMode = _sortMode == LibraryFolderSortMode.alphabetical
          ? LibraryFolderSortMode.byCount
          : LibraryFolderSortMode.alphabetical;
    });
    final store = widget.preferenceStore;
    final preset = widget.folderPreset;
    final mode = _sortMode;
    if (store == null || preset == null) return;
    _sortWrite = _sortWrite
        .then((_) => store.writeFolderSortMode(preset, mode))
        .catchError((Object error) {
      debugPrint('Could not save folder sorting: $error');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LibraryBucket> get _filteredSorted {
    final query = _searchController.text.trim().toLowerCase();
    var items = widget.buckets.where((b) {
      if (query.isEmpty) return true;
      return b.title.toLowerCase().contains(query);
    }).where((bucket) {
      return switch (widget.bucketCompletionScope) {
        LibraryBucketCompletionScope.all => true,
        LibraryBucketCompletionScope.completed =>
          bucket.completionPercent != null && bucket.completionPercent! >= 100,
        LibraryBucketCompletionScope.notCompleted =>
          bucket.completionPercent == null || bucket.completionPercent! < 100,
      };
    }).toList();
    switch (_sortMode) {
      case LibraryFolderSortMode.alphabetical:
        // Keep original order (already alphabetical from projection).
        break;
      case LibraryFolderSortMode.byCount:
        items.sort(
            (a, b) => _compareFolders(a.title, a.count, b.title, b.count));
    }
    return items;
  }

  int _compareFolders(String a, int aCount, String b, int bCount) {
    if (a == b) return 0;
    if (a == widget.allBucketLabel) return -1;
    if (b == widget.allBucketLabel) return 1;
    if (a == libraryEmptyGroupLabel || b == libraryEmptyGroupLabel) {
      return compareLibraryGroupBuckets(a, b);
    }
    if (_sortMode == LibraryFolderSortMode.byCount) {
      final countOrder = bCount.compareTo(aCount);
      if (countOrder != 0) return countOrder;
    }
    return compareLibraryGroupBuckets(a, b);
  }

  List<LibraryFolderTreeNode> _filteredSortedTree(
    List<LibraryFolderTreeNode> nodes,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _filterTreeNodes(nodes, query);
    return _sortTreeNodes(filtered);
  }

  List<LibraryFolderTreeNode> _filterTreeNodes(
    List<LibraryFolderTreeNode> nodes,
    String query,
  ) {
    return [
      for (final node in nodes)
        if (_nodeMatchesQuery(node, query)) _filterTreeNode(node, query),
    ];
  }

  bool _nodeMatchesQuery(LibraryFolderTreeNode node, String query) {
    if (query.isEmpty) {
      return true;
    }
    if (node.label.toLowerCase().contains(query)) {
      return true;
    }
    return node.children.any((child) => _nodeMatchesQuery(child, query));
  }

  LibraryFolderTreeNode _filterTreeNode(
    LibraryFolderTreeNode node,
    String query,
  ) {
    final filteredChildren = _filterTreeNodes(node.children, query);
    final expanded = query.isNotEmpty ||
        node.isExpanded ||
        widget.expandedTreeNodeIds.contains(node.id);
    return node.copyWith(
      children: filteredChildren,
      isExpanded: expanded,
    );
  }

  List<LibraryFolderTreeNode> _sortTreeNodes(
      List<LibraryFolderTreeNode> nodes) {
    final sorted = nodes.toList(growable: true);
    sorted.sort((a, b) => _compareFolders(
          a.label,
          a.count,
          b.label,
          b.count,
        ));
    return [
      for (final node in sorted)
        node.copyWith(children: _sortTreeNodes(node.children)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final filtered = _filteredSorted;
    Iterable<int> treeCounts(List<LibraryFolderTreeNode> nodes) sync* {
      for (final node in nodes) {
        yield node.count;
        yield* treeCounts(node.children);
      }
    }

    final countWidth = libraryFolderCountWidth(context, [
      for (final bucket in widget.buckets) bucket.count,
      ...treeCounts(widget.treeRoots),
    ]);
    final density = LibraryDensityScope.maybeOf(context)?.density ??
        LibraryDensity.comfortable;
    final densityScale = switch (density) {
      LibraryDensity.comfortable => 1.0,
      LibraryDensity.compact => 0.9,
      LibraryDensity.dense => 0.8,
    };
    final resolvedBackgroundColor = widget.backgroundColor == kAppPanel
        ? libraryFolderDepthColor(context, 0)
        : widget.backgroundColor;
    final resolvedHeaderColor = widget.headerColor == kAppSurface
        ? palette.surface
        : widget.headerColor;
    final resolvedDividerColor = widget.dividerColor == kAppDivider
        ? palette.divider
        : widget.dividerColor;
    final resolvedSelectionColor = widget.selectionColor == kAppSelection
        ? palette.selection
        : widget.selectionColor;
    final resolvedMutedTextColor = widget.mutedTextColor == kAppTextMuted
        ? palette.textMuted
        : widget.mutedTextColor;
    return DecoratedBox(
      decoration: BoxDecoration(color: resolvedBackgroundColor),
      child: Column(
        children: [
          widget.headerOverride ??
              Container(
                height: 32 * densityScale,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 8 * densityScale),
                decoration: BoxDecoration(
                  color: resolvedHeaderColor,
                  border:
                      Border(bottom: BorderSide(color: resolvedDividerColor)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Collapse the header as a whole while the sidebar is
                    // transitioning to its narrow rail state.
                    if (constraints.maxWidth < 96) {
                      return Align(
                        alignment: Alignment.center,
                        child: Icon(
                          widget.icon,
                          size: 16,
                          color: widget.accentColor,
                        ),
                      );
                    }
                    return Row(
                      children: [
                        Icon(widget.icon, size: 16, color: widget.accentColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.12,
                                ),
                          ),
                        ),
                        if (widget.trailing != null) widget.trailing!,
                      ],
                    );
                  },
                ),
              ),
          _SidebarSearchAndSort(
            controller: _searchController,
            sortMode: _sortMode,
            searchPlaceholder: widget.searchPlaceholder,
            accentColor: widget.accentColor,
            dividerColor: resolvedDividerColor,
            mutedTextColor: resolvedMutedTextColor,
            bucketCompletionScope: widget.bucketCompletionScope,
            onBucketCompletionScopeChanged:
                widget.onBucketCompletionScopeChanged,
            onChanged: () => setState(() {}),
            onToggleSort: _toggleSortMode,
          ),
          Expanded(
            child: ((widget.folderPreset != null &&
                        widget.folderPreset!.modes.length > 1 &&
                        widget.treeRoots.isNotEmpty) ||
                    widget.folderDisplayMode == LibraryFolderDisplayMode.tree)
                ? _FolderTreePane(
                    roots: _filteredSortedTree(widget.treeRoots),
                    countWidth: countWidth,
                    selectedNodeId: widget.selectedTreeNodeId,
                    accentColor: widget.accentColor,
                    rowPadding: ref.watch(
                      uiPreferencesProvider.select((p) => p.sidebarRowPadding),
                    ),
                    onSelectPath: widget.onSelectTreeNodePath,
                    onToggleExpanded: widget.onToggleTreeNodeExpanded,
                  )
                : ListView.builder(
                    itemCount:
                        widget.ancestorScopeLabels.length + filtered.length,
                    itemBuilder: (context, index) {
                      if (index < widget.ancestorScopeLabels.length) {
                        return _SidebarAncestorScopeRow(
                          label: widget.ancestorScopeLabels[index],
                          depth: index,
                          dividerColor: resolvedDividerColor,
                          accentColor: widget.accentColor,
                          mutedTextColor: resolvedMutedTextColor,
                          onTap: widget.onNavigateToAncestorScope == null
                              ? null
                              : () => widget.onNavigateToAncestorScope!(index),
                        );
                      }
                      final bucket =
                          filtered[index - widget.ancestorScopeLabels.length];
                      final selected = bucket.title == widget.selectedBucket;
                      final rowPadding = ref.watch(
                        uiPreferencesProvider
                            .select((p) => p.sidebarRowPadding),
                      );
                      return _LibrarySeriesRow(
                        bucket: bucket,
                        countWidth: countWidth,
                        selected: selected,
                        onTap: () => widget.onSelectBucket(bucket.title),
                        selectionColor: resolvedSelectionColor,
                        leadingInset: widget.ancestorScopeLabels.isEmpty
                            ? 0
                            : 14.0 + widget.ancestorScopeLabels.length * 12.0,
                        extraVerticalPadding:
                            (rowPadding * densityScale).clamp(0.0, 12.0),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSearchAndSort extends StatelessWidget {
  const _SidebarSearchAndSort({
    required this.controller,
    required this.sortMode,
    required this.searchPlaceholder,
    required this.accentColor,
    required this.dividerColor,
    required this.mutedTextColor,
    required this.bucketCompletionScope,
    required this.onBucketCompletionScopeChanged,
    required this.onChanged,
    required this.onToggleSort,
  });

  final TextEditingController controller;
  final LibraryFolderSortMode sortMode;
  final String searchPlaceholder;
  final Color accentColor;
  final Color dividerColor;
  final Color mutedTextColor;
  final LibraryBucketCompletionScope bucketCompletionScope;
  final ValueChanged<LibraryBucketCompletionScope>?
      onBucketCompletionScopeChanged;
  final VoidCallback onChanged;
  final VoidCallback onToggleSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The sidebar can be temporarily narrower than its preferred width
          // while the surrounding layout is resized. Keep fixed controls from
          // starving the search field and causing a RenderFlex overflow.
          final availableWidth = constraints.maxWidth;
          final showCompletionScope =
              onBucketCompletionScopeChanged != null && availableWidth >= 220;
          final showSort = availableWidth >= 140;
          final trailingWidth =
              (showCompletionScope ? 34.0 : 0.0) + (showSort ? 65.0 : 0.0);
          final searchWidth = availableWidth - trailingWidth;
          final showClearButton = searchWidth >= 72;
          final showSearchField = searchWidth >= 44;

          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 26,
                  child: showSearchField
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xff444444)
                                    : appPalette(context).panelRaised,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Row(children: [
                            Expanded(
                                child: TextField(
                              controller: controller,
                              cursorColor: accentColor,
                              textAlignVertical: TextAlignVertical.center,
                              onChanged: (_) => onChanged(),
                              style: libraryFolderTextStyle(context)
                                  .copyWith(height: 1),
                              decoration: InputDecoration(
                                hintText: searchPlaceholder,
                                hintStyle: libraryFolderTextStyle(context)
                                    .copyWith(height: 1, color: mutedTextColor),
                                filled: false,
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            )),
                            if (showClearButton)
                              SizedBox(
                                width: 26,
                                height: 26,
                                child: IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                  ),
                                  tooltip: controller.text.isEmpty
                                      ? 'Search folders'
                                      : 'Clear folder search',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 26, minHeight: 26),
                                  onPressed: () {
                                    if (controller.text.isNotEmpty) {
                                      controller.clear();
                                    }
                                    onChanged();
                                  },
                                  icon: Icon(
                                      controller.text.isEmpty
                                          ? Icons.search
                                          : Icons.close,
                                      size: 14,
                                      color: mutedTextColor),
                                ),
                              ),
                          ]),
                        )
                      : Center(
                          child: Icon(Icons.search,
                              size: 14, color: mutedTextColor)),
                ),
              ),
              if (showCompletionScope) ...[
                const SizedBox(width: 6),
                _SidebarStatusScopeButton(
                  accentColor: accentColor,
                  mutedTextColor: mutedTextColor,
                  dividerColor: dividerColor,
                  scope: bucketCompletionScope,
                  onSelected: onBucketCompletionScopeChanged!,
                ),
              ],
              if (showSort) ...[
                const SizedBox(width: 5),
                _SidebarSortSwitch(
                  sortMode: sortMode,
                  accentColor: accentColor,
                  dividerColor: dividerColor,
                  mutedTextColor: mutedTextColor,
                  onTap: onToggleSort,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SidebarStatusScopeButton extends StatelessWidget {
  const _SidebarStatusScopeButton({
    required this.scope,
    required this.accentColor,
    required this.mutedTextColor,
    required this.dividerColor,
    required this.onSelected,
  });

  final LibraryBucketCompletionScope scope;
  final Color accentColor;
  final Color mutedTextColor;
  final Color dividerColor;
  final ValueChanged<LibraryBucketCompletionScope> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LibraryBucketCompletionScope>(
      tooltip: scope.label,
      initialValue: scope,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      padding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: scope == LibraryBucketCompletionScope.all
                ? dividerColor
                : accentColor.withValues(alpha: 0.6),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.checklist_rounded, size: 16, color: mutedTextColor),
      ),
      itemBuilder: (context) => [
        for (final value in LibraryBucketCompletionScope.values)
          PopupMenuItem<LibraryBucketCompletionScope>(
            value: value,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: value == scope
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.check,
                  size: 16,
                  color: value == scope ? accentColor : Colors.transparent,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SidebarSortSwitch extends StatelessWidget {
  const _SidebarSortSwitch(
      {required this.sortMode,
      required this.accentColor,
      required this.dividerColor,
      required this.mutedTextColor,
      required this.onTap});
  final LibraryFolderSortMode sortMode;
  final Color accentColor, dividerColor, mutedTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alphabetical = sortMode == LibraryFolderSortMode.alphabetical;
    return Tooltip(
      message: alphabetical ? 'Sort by count' : 'Sort alphabetically',
      child: Semantics(
        button: true,
        label: alphabetical
            ? 'Folders sorted alphabetically'
            : 'Folders sorted by count',
        child: Material(
          color: appPalette(context).surface,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 60,
              height: 26,
              child: Stack(children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: alphabetical
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      width: 26,
                      height: 22,
                      decoration: BoxDecoration(
                        color: libraryFolderHoverColor(context),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.55)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Row(children: [
                  for (final mode in LibraryFolderSortMode.values)
                    Expanded(
                        child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: mode == sortMode ? 1 : 0.25,
                      child: Icon(
                          mode == LibraryFolderSortMode.alphabetical
                              ? Icons.sort_by_alpha
                              : Icons.sort,
                          size: 18,
                          color: appPalette(context).textPrimary),
                    )),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _FolderTreePane extends StatelessWidget {
  const _FolderTreePane({
    required this.roots,
    required this.selectedNodeId,
    required this.accentColor,
    required this.rowPadding,
    required this.countWidth,
    this.onSelectPath,
    this.onToggleExpanded,
  });
  final List<LibraryFolderTreeNode> roots;
  final String? selectedNodeId;
  final Color accentColor;
  final double rowPadding, countWidth;
  final ValueChanged<List<LibraryFolderTreeNode>>? onSelectPath;
  final ValueChanged<String>? onToggleExpanded;

  @override
  Widget build(BuildContext context) => ListView(children: [
        for (final node in roots)
          _FolderTreeNodeView(
            node: node,
            path: const [],
            selectedNodeId: selectedNodeId,
            accent: accentColor,
            rowPadding: rowPadding,
            countWidth: countWidth,
            onSelectPath: onSelectPath,
            onToggleExpanded: onToggleExpanded,
          ),
      ]);
}

class _FolderTreeNodeView extends StatelessWidget {
  const _FolderTreeNodeView({
    required this.node,
    required this.path,
    required this.selectedNodeId,
    required this.accent,
    required this.rowPadding,
    required this.countWidth,
    this.onSelectPath,
    this.onToggleExpanded,
  });
  final LibraryFolderTreeNode node;
  final List<LibraryFolderTreeNode> path;
  final String? selectedNodeId;
  final Color accent;
  final double rowPadding, countWidth;
  final ValueChanged<List<LibraryFolderTreeNode>>? onSelectPath;
  final ValueChanged<String>? onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final nextPath = [...path, node];
    final selected = node.id == selectedNodeId;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      LibraryFolderRow(
        separateAfter: node.label == libraryEmptyGroupLabel,
        label: node.label,
        count: node.count,
        selected: selected,
        accent: accent,
        depth: path.length,
        indentation: path.length * 12,
        rowPadding: rowPadding,
        countWidth: countWidth,
        onTap: onSelectPath == null ? null : () => onSelectPath!(nextPath),
        leading: node.id == 'root'
            ? null
            : SizedBox(
                width: 26,
                height: 26,
                child: node.hasChildren
                    ? IconButton(
                        tooltip: node.isExpanded ? 'Collapse' : 'Expand',
                        onPressed: onToggleExpanded == null
                            ? null
                            : () => onToggleExpanded!(node.id),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 26, minHeight: 26),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                            node.isExpanded
                                ? Icons.expand_more
                                : Icons.chevron_right,
                            size: 16,
                            color: selected
                                ? appContrastingTextColor(accent)
                                : appPalette(context).textMuted),
                      )
                    : null,
              ),
      ),
      if (node.isExpanded)
        Container(
          decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(
                      color: node.id == 'root'
                          ? Colors.transparent
                          : selected
                              ? accent
                              : appPalette(context).divider))),
          child: Column(children: [
            for (final child in node.children)
              _FolderTreeNodeView(
                node: child,
                path: node.id == 'root' ? path : nextPath,
                selectedNodeId: selectedNodeId,
                accent: accent,
                rowPadding: rowPadding,
                countWidth: countWidth,
                onSelectPath: onSelectPath,
                onToggleExpanded: onToggleExpanded,
              ),
          ]),
        ),
    ]);
  }
}

class _LibrarySeriesRow extends StatelessWidget {
  const _LibrarySeriesRow({
    required this.bucket,
    required this.selected,
    required this.onTap,
    required this.selectionColor,
    required this.countWidth,
    this.leadingInset = 0,
    this.extraVerticalPadding = 4,
  });
  final LibraryBucket bucket;
  final bool selected;
  final VoidCallback onTap;
  final Color selectionColor;
  final double countWidth, leadingInset, extraVerticalPadding;

  @override
  Widget build(BuildContext context) {
    final row = LibraryFolderRow(
      separateAfter: bucket.title == libraryEmptyGroupLabel,
      label: bucket.title,
      count: bucket.count,
      selected: selected,
      onTap: onTap,
      accent: selectionColor,
      countWidth: countWidth,
      indentation: leadingInset,
      rowPadding: extraVerticalPadding,
    );
    return bucket.missingNumbers.isEmpty
        ? row
        : Tooltip(
            message: 'Missing: ${_formatMissingNumbers(bucket.missingNumbers)}',
            waitDuration: const Duration(milliseconds: 400),
            child: row,
          );
  }
}

class _SidebarAncestorScopeRow extends StatelessWidget {
  const _SidebarAncestorScopeRow({
    required this.label,
    required this.depth,
    required this.dividerColor,
    required this.accentColor,
    required this.mutedTextColor,
    this.onTap,
  });

  final String label;
  final int depth;
  final Color dividerColor;
  final Color accentColor;
  final Color mutedTextColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: SizedBox(
        height: kLibraryFolderRowHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 72 + depth * 12) {
              return const SizedBox.expand();
            }
            return Padding(
              padding: EdgeInsets.only(left: 8 + depth * 12, right: 8),
              child: Row(
                children: [
                  Icon(Icons.folder_open_outlined,
                      size: 15, color: accentColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: mutedTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right, size: 16, color: mutedTextColor),
                ],
              ),
            );
          },
        ),
      ),
    );
    if (onTap == null) {
      return row;
    }
    return InkWell(
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: onTap,
        child: row);
  }
}

String libraryBucketLabel(LibraryBucket bucket) {
  final completionPercent = bucket.completionPercent;
  if (completionPercent == null) {
    return '${bucket.title} ${bucket.count}';
  }
  return '${bucket.title} ${bucket.count} ($completionPercent%)';
}

/// Formats a list of missing issue numbers into compact ranges.
/// Example: [1,2,3,5,8,9] → "#1–3, #5, #8–9"
String _formatMissingNumbers(List<int> numbers) {
  if (numbers.isEmpty) return '';
  final sorted = numbers.toList()..sort();
  final parts = <String>[];
  var start = sorted.first;
  var end = start;
  for (var i = 1; i < sorted.length; i++) {
    if (sorted[i] == end + 1) {
      end = sorted[i];
    } else {
      parts.add(start == end ? '#$start' : '#$start–#$end');
      start = sorted[i];
      end = start;
    }
  }
  parts.add(start == end ? '#$start' : '#$start–#$end');
  if (parts.length > 10) {
    return '${parts.take(10).join(', ')} … +${parts.length - 10} more';
  }
  return parts.join(', ');
}
