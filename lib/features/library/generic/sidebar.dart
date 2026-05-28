import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_series_sidebar.dart';
import 'package:flutter/material.dart';

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
    this.breadcrumbs = const [],
    this.onNavigateBack,
    this.onNavigateToBreadcrumb,
    this.searchQuery,
    this.activeSmartListName,
    this.quickView,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.collectionStatusScopeLabel,
    this.linkedMetadataFilterLabel,
    this.selectedLetter,
    this.seriesStatusSummary,
    this.filterSelection = LibraryFilterSelection.none,
    this.hasActiveFilters = false,
    this.onEditFilters,
    this.onClearFilters,
    this.onCollectionStatusScopeChanged,
    required this.onClearFilter,
    this.onHideSidebar,
    this.onSidebarVisibilityChanged,
    this.pinnedGroupModes = const {},
    this.onTogglePinGroupMode,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final List<LibrarySeriesBucket> buckets;
  final LibraryGroupMode groupMode;
  final bool groupLoading;
  final String selectedBucket;
  final ValueChanged<String> onSelected;
  final ValueChanged<LibraryGroupMode> onGroupModeChanged;
  final List<String> breadcrumbs;
  final VoidCallback? onNavigateBack;
  final ValueChanged<int>? onNavigateToBreadcrumb;
  final String? searchQuery;
  final String? activeSmartListName;
  final LibraryQuickView? quickView;
  final LibraryCollectionStatusScope collectionStatusScope;
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
  final VoidCallback? onClearFilter;
  final VoidCallback? onHideSidebar;
  final ValueChanged<bool>? onSidebarVisibilityChanged;
  final Set<LibraryGroupMode> pinnedGroupModes;
  final ValueChanged<LibraryGroupMode>? onTogglePinGroupMode;

  @override
  Widget build(BuildContext context) {
    return LibrarySeriesSidebar(
      title: genericGroupModeSidebarTitle(groupMode, type),
      icon: genericGroupModeIcon(groupMode),
      series: buckets,
      selectedSeries: selectedBucket,
      onSelectSeries: onSelected,
      accentColor: accent,
      selectionColor: accent.withValues(alpha: 0.36),
      backgroundColor: appPalette(context).panel,
      headerColor: appPalette(context).surface,
      dividerColor: appPalette(context).divider,
      selectedBadgeColor: appPalette(context).highlight,
      mutedTextColor: appPalette(context).textMuted,
      headerOverride: _SidebarGroupDropdownHeader(
        type: type,
        groupMode: groupMode,
        accent: accent,
        icon: genericGroupModeIcon(groupMode),
        onChanged: onGroupModeChanged,
        breadcrumbs: breadcrumbs,
        onNavigateBack: onNavigateBack,
        onNavigateToBreadcrumb: onNavigateToBreadcrumb,
        groupLoading: groupLoading,
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
        pinnedGroupModes: pinnedGroupModes,
        onTogglePin: onTogglePinGroupMode,
      ),
    );
  }
}

class LibraryCompactBucketBar extends StatelessWidget {
  const LibraryCompactBucketBar({
    super.key,
    required this.type,
    required this.accent,
    required this.buckets,
    required this.selectedBucket,
    required this.onSelected,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final List<LibrarySeriesBucket> buckets;
  final String selectedBucket;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: appPalette(context).panel,
        border: Border(bottom: BorderSide(color: appPalette(context).divider)),
      ),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          itemCount: buckets.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final bucket = buckets[index];
            final selected = bucket.title == selectedBucket;
            return ChoiceChip(
              selected: selected,
              onSelected: (_) => onSelected(bucket.title),
              avatar: selected
                  ? Icon(genericLibrarySidebarIcon(type), size: 15)
                  : null,
              label: Text(libraryBucketLabel(bucket)),
              selectedColor: accent.withValues(alpha: 0.42),
              side: BorderSide(
                  color: selected ? accent : appPalette(context).divider),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          },
        ),
      ),
    );
  }
}

IconData genericLibrarySidebarIcon(LibraryTypeConfig type) {
  return switch (type.workspace.kind) {
    CatalogMediaKind.music => Icons.person_2_outlined,
    CatalogMediaKind.movie => Icons.movie_filter_outlined,
    _ => Icons.folder,
  };
}

enum _GroupModeMenuAction { toggleSidebar }

class LibraryGroupModeMenuButton extends StatelessWidget {
  const LibraryGroupModeMenuButton({
    super.key,
    required this.type,
    required this.groupMode,
    required this.accent,
    required this.icon,
    required this.onChanged,
    this.sidebarVisible = true,
    this.onSidebarVisibilityChanged,
    this.pinnedGroupModes = const {},
    this.onTogglePin,
    this.iconOnly = false,
  });

  final LibraryTypeConfig type;
  final LibraryGroupMode groupMode;
  final Color accent;
  final IconData icon;
  final ValueChanged<LibraryGroupMode> onChanged;
  final bool sidebarVisible;
  final ValueChanged<bool>? onSidebarVisibilityChanged;
  final Set<LibraryGroupMode> pinnedGroupModes;
  final ValueChanged<LibraryGroupMode>? onTogglePin;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final label = genericGroupModeSidebarTitle(groupMode, type);
    final child = iconOnly
        ? LibraryToolbarCompactDropdownTrigger(icon: icon)
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: accent),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 18, color: accent),
              ],
            ),
          );

    return Tooltip(
      message: 'Group by',
      child: InkWell(
        onTap: () => _showGroupModeMenu(context),
        borderRadius: BorderRadius.circular(6),
        child: child,
      ),
    );
  }

  void _showGroupModeMenu(BuildContext context) {
    final modes = libraryGroupModesForType(type);
    final categories = _SidebarGroupDropdownHeader._categorizeGroupModes(modes);
    final overlay = Overlay.of(context, rootOverlay: true)
        .context
        .findRenderObject() as RenderBox;
    final box = context.findRenderObject() as RenderBox;
    final target = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
    final selection = showGeneralDialog<Object?>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss group mode menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (dialogContext, _, __) {
        const menuWidth = 280.0;
        final screenSize = overlay.size;
        final left = target.left.clamp(8.0, screenSize.width - menuWidth - 8.0);
        final top = (target.bottom + 4).clamp(8.0, screenSize.height - 420.0);
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              child: _GroupModeDropdownMenu(
                type: type,
                accent: accent,
                selectedMode: groupMode,
                categories: categories,
                initialPinnedModes: pinnedGroupModes,
                onTogglePin: onTogglePin,
                sidebarVisible: sidebarVisible,
                hasSidebarVisibilityToggle: onSidebarVisibilityChanged != null,
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
            alignment: Alignment.topLeft,
            child: child,
          ),
        );
      },
    );
    selection.then((value) {
      if (value is LibraryGroupMode) {
        onChanged(value);
      } else if (value == _GroupModeMenuAction.toggleSidebar &&
          onSidebarVisibilityChanged != null) {
        onSidebarVisibilityChanged!(!sidebarVisible);
      }
    });
  }
}

class _SidebarGroupDropdownHeader extends StatelessWidget {
  const _SidebarGroupDropdownHeader({
    required this.type,
    required this.groupMode,
    required this.accent,
    required this.icon,
    required this.onChanged,
    required this.breadcrumbs,
    this.onNavigateBack,
    this.onNavigateToBreadcrumb,
    required this.selectedBucket,
    this.searchQuery,
    this.activeSmartListName,
    this.quickView,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.collectionStatusScopeLabel,
    this.linkedMetadataFilterLabel,
    this.selectedLetter,
    this.seriesStatusSummary,
    this.filterSelection = LibraryFilterSelection.none,
    this.hasActiveFilters = false,
    this.onEditFilters,
    this.onClearFilters,
    this.onCollectionStatusScopeChanged,
    this.groupLoading = false,
    this.onClearFilter,
    this.onHideSidebar,
    this.onSidebarVisibilityChanged,
    this.pinnedGroupModes = const {},
    this.onTogglePin,
  });

  final LibraryTypeConfig type;
  final LibraryGroupMode groupMode;
  final Color accent;
  final IconData icon;
  final ValueChanged<LibraryGroupMode> onChanged;
  final List<String> breadcrumbs;
  final VoidCallback? onNavigateBack;
  final ValueChanged<int>? onNavigateToBreadcrumb;
  final String selectedBucket;
  final String? searchQuery;
  final String? activeSmartListName;
  final LibraryQuickView? quickView;
  final LibraryCollectionStatusScope collectionStatusScope;
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
  final bool groupLoading;
  final VoidCallback? onClearFilter;
  final VoidCallback? onHideSidebar;
  final ValueChanged<bool>? onSidebarVisibilityChanged;
  final Set<LibraryGroupMode> pinnedGroupModes;
  final ValueChanged<LibraryGroupMode>? onTogglePin;

  @override
  Widget build(BuildContext context) {
    final isRootScope = onClearFilter == null;
    final scopeLabel = breadcrumbs.isNotEmpty
        ? breadcrumbs.last
        : (isRootScope ? 'All ${type.pluralLabel}' : selectedBucket);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      decoration: BoxDecoration(
        color: appPalette(context).surface,
        border: Border(bottom: BorderSide(color: appPalette(context).divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: constraints.maxWidth),
                        child: LibraryGroupModeMenuButton(
                          type: type,
                          groupMode: groupMode,
                          accent: accent,
                          icon: icon,
                          onChanged: onChanged,
                          sidebarVisible: true,
                          onSidebarVisibilityChanged:
                              onSidebarVisibilityChanged,
                          pinnedGroupModes: pinnedGroupModes,
                          onTogglePin: onTogglePin,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (groupLoading) ...[
                const SizedBox(width: 4),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
              if (onHideSidebar != null)
                IconButton(
                  tooltip: 'Hide folders panel',
                  onPressed: onHideSidebar,
                  icon: const Icon(Icons.menu_open, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              if (onNavigateBack != null)
                IconButton(
                  tooltip: 'Back to previous scope',
                  onPressed: onNavigateBack,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                )
              else if (!isRootScope)
                IconButton(
                  tooltip: 'Back to all ${type.pluralLabel.toLowerCase()}',
                  onPressed: onClearFilter,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                )
              else
                IconButton(
                  tooltip: 'Clear group filter',
                  onPressed: onClearFilter,
                  icon: const Icon(Icons.filter_alt_off, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
            ],
          ),
          if (breadcrumbs.length > 1) ...[
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < breadcrumbs.length; index++) ...[
                    if (index > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: appPalette(context).textMuted,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: index == breadcrumbs.length - 1
                          ? Text(
                              breadcrumbs[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            )
                          : ActionChip(
                              label: Text(
                                breadcrumbs[index],
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              onPressed: onNavigateToBreadcrumb == null
                                  ? null
                                  : () => onNavigateToBreadcrumb!(index),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            scopeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appPalette(context).textMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          _SidebarFilteringPanel(
            type: type,
            activeSmartListName: activeSmartListName,
            quickView: quickView,
            collectionStatusScope: collectionStatusScope,
            collectionStatusScopeLabel: collectionStatusScopeLabel,
            searchQuery: searchQuery,
            linkedMetadataFilterLabel: linkedMetadataFilterLabel,
            selectedLetter: selectedLetter,
            filterSelection: filterSelection,
            hasActiveFilters: hasActiveFilters,
            onEditFilters: onEditFilters,
            onClearFilters: onClearFilters,
            onCollectionStatusScopeChanged: onCollectionStatusScopeChanged,
          ),
          if (seriesStatusSummary != null) ...[
            const SizedBox(height: 6),
            _SidebarSeriesStatusPanel(
              summary: seriesStatusSummary!,
              selectedScope: collectionStatusScope,
              onScopeSelected: onCollectionStatusScopeChanged,
            ),
          ],
        ],
      ),
    );
  }

  static List<_GroupModeCategory> _categorizeGroupModes(
    List<LibraryGroupMode> modes,
  ) {
    const mainModes = {
      LibraryGroupMode.series,
      LibraryGroupMode.storyArc,
      LibraryGroupMode.character,
      LibraryGroupMode.title,
      LibraryGroupMode.publisher,
      LibraryGroupMode.year,
      LibraryGroupMode.genre,
      LibraryGroupMode.country,
      LibraryGroupMode.language,
      LibraryGroupMode.ageRating,
    };
    const editionModes = {
      LibraryGroupMode.format,
    };
    const crewModes = {
      LibraryGroupMode.director,
      LibraryGroupMode.creator,
    };
    // Everything else is personal.
    final main = modes.where(mainModes.contains).toList();
    final edition = modes.where(editionModes.contains).toList();
    final crew = modes.where(crewModes.contains).toList();
    final personal = modes
        .where((m) =>
            !mainModes.contains(m) &&
            !editionModes.contains(m) &&
            !crewModes.contains(m))
        .toList();
    return [
      if (main.isNotEmpty) _GroupModeCategory('Main', main),
      if (edition.isNotEmpty) _GroupModeCategory('Edition', edition),
      if (crew.isNotEmpty) _GroupModeCategory('Cast & Crew', crew),
      if (personal.isNotEmpty) _GroupModeCategory('Personal', personal),
    ];
  }
}

class _SidebarFilteringPanel extends StatelessWidget {
  const _SidebarFilteringPanel({
    required this.type,
    this.activeSmartListName,
    this.quickView,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.collectionStatusScopeLabel,
    this.searchQuery,
    this.linkedMetadataFilterLabel,
    this.selectedLetter,
    this.filterSelection = LibraryFilterSelection.none,
    this.hasActiveFilters = false,
    this.onEditFilters,
    this.onClearFilters,
    this.onCollectionStatusScopeChanged,
  });

  final LibraryTypeConfig type;
  final String? activeSmartListName;
  final LibraryQuickView? quickView;
  final LibraryCollectionStatusScope collectionStatusScope;
  final String? collectionStatusScopeLabel;
  final String? searchQuery;
  final String? linkedMetadataFilterLabel;
  final String? selectedLetter;
  final LibraryFilterSelection filterSelection;
  final bool hasActiveFilters;
  final VoidCallback? onEditFilters;
  final VoidCallback? onClearFilters;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (activeSmartListName != null && activeSmartListName!.trim().isNotEmpty)
        _SidebarFilterChip(
          icon: Icons.bookmarks_outlined,
          label: activeSmartListName!,
        ),
      if (quickView != null)
        _SidebarFilterChip(
          icon: quickView!.icon,
          label: quickView!.label,
        ),
      if (collectionStatusScopeLabel != null)
        _SidebarFilterChip(
          icon: Icons.inventory_2_outlined,
          label: collectionStatusScopeLabel!,
          selected: collectionStatusScope != LibraryCollectionStatusScope.all,
          onPressed: onCollectionStatusScopeChanged == null
              ? null
              : () => onCollectionStatusScopeChanged!(
                    LibraryCollectionStatusScope.all,
                  ),
        ),
      if (searchQuery != null && searchQuery!.trim().isNotEmpty)
        _SidebarFilterChip(
          icon: Icons.search,
          label: 'Search: ${searchQuery!.trim()}',
        ),
      if (linkedMetadataFilterLabel != null)
        _SidebarFilterChip(
          icon: Icons.link,
          label: linkedMetadataFilterLabel!,
        ),
      if (selectedLetter != null)
        _SidebarFilterChip(
          icon: Icons.sort_by_alpha,
          label: 'Letter: $selectedLetter',
        ),
      if (filterSelection.hasActiveFilters)
        _SidebarFilterChip(
          icon: Icons.filter_alt_outlined,
          label: '${filterSelection.activeFilterCount} advanced filter(s)',
        ),
    ];

    if (chips.isEmpty && !(hasActiveFilters && onClearFilters != null)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.filter_alt_outlined,
              size: 14,
              color: appPalette(context).textMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Filters',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            if (onEditFilters != null)
              TextButton(
                onPressed: onEditFilters,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
                child: const Text('Edit'),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: chips,
        ),
        if (hasActiveFilters && onClearFilters != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onClearFilters,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
              child: const Text('Clear all'),
            ),
          ),
        ],
      ],
    );
  }
}

class _SidebarFilterChip extends StatelessWidget {
  const _SidebarFilterChip({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return Chip(
        avatar: Icon(icon, size: 14, color: appPalette(context).textMuted),
        label: Text(label),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }
    return FilterChip(
      avatar: Icon(icon, size: 14, color: appPalette(context).textMuted),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onPressed!(),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _SidebarSeriesStatusPanel extends StatelessWidget {
  const _SidebarSeriesStatusPanel({
    required this.summary,
    this.selectedScope = LibraryCollectionStatusScope.all,
    this.onScopeSelected,
  });

  final LibrarySeriesStatusSummary summary;
  final LibraryCollectionStatusScope selectedScope;
  final ValueChanged<LibraryCollectionStatusScope>? onScopeSelected;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _SidebarFilterChip(
        icon: Icons.library_books_outlined,
        label: '${summary.totalCount} total',
        selected: selectedScope == LibraryCollectionStatusScope.all,
        onPressed: onScopeSelected == null
            ? null
            : () => onScopeSelected!(LibraryCollectionStatusScope.all),
      ),
      if (summary.ownedCount > 0)
        _SidebarFilterChip(
          icon: Icons.inventory_2_outlined,
          label: '${summary.ownedCount} owned',
          selected: selectedScope == LibraryCollectionStatusScope.inCollection,
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(
                    LibraryCollectionStatusScope.inCollection,
                  ),
        ),
      if (summary.wishlistCount > 0)
        _SidebarFilterChip(
          icon: Icons.star_border,
          label: '${summary.wishlistCount} wish list',
          selected: selectedScope == LibraryCollectionStatusScope.wishList,
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.wishList),
        ),
      if (summary.forSaleCount > 0)
        _SidebarFilterChip(
          icon: Icons.sell_outlined,
          label: '${summary.forSaleCount} for sale',
          selected: selectedScope == LibraryCollectionStatusScope.forSale,
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.forSale),
        ),
      if (summary.onOrderCount > 0)
        _SidebarFilterChip(
          icon: Icons.local_shipping_outlined,
          label: '${summary.onOrderCount} on order',
          selected: selectedScope == LibraryCollectionStatusScope.onOrder,
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.onOrder),
        ),
      if (summary.soldCount > 0)
        _SidebarFilterChip(
          icon: Icons.paid_outlined,
          label: '${summary.soldCount} sold',
          selected: selectedScope == LibraryCollectionStatusScope.sold,
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.sold),
        ),
      if (summary.catalogOnlyCount > 0)
        _SidebarFilterChip(
          icon: Icons.hide_source_outlined,
          label: '${summary.catalogOnlyCount} not in collection',
          selected:
              selectedScope == LibraryCollectionStatusScope.notInCollection,
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(
                    LibraryCollectionStatusScope.notInCollection,
                  ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.monitor_heart_outlined,
              size: 14,
              color: appPalette(context).textMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Status',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: chips,
        ),
        if (summary.missingIssueSummary != null) ...[
          const SizedBox(height: 4),
          Text(
            'Missing: ${summary.missingIssueSummary}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appPalette(context).textMuted,
                ),
          ),
        ],
      ],
    );
  }
}

class _GroupModeCategory {
  const _GroupModeCategory(this.label, this.modes);
  final String label;
  final List<LibraryGroupMode> modes;
}

class _GroupModeDropdownMenu extends StatefulWidget {
  const _GroupModeDropdownMenu({
    required this.type,
    required this.accent,
    required this.selectedMode,
    required this.categories,
    required this.initialPinnedModes,
    this.sidebarVisible = true,
    this.hasSidebarVisibilityToggle = false,
    this.onTogglePin,
  });

  final LibraryTypeConfig type;
  final Color accent;
  final LibraryGroupMode selectedMode;
  final List<_GroupModeCategory> categories;
  final Set<LibraryGroupMode> initialPinnedModes;
  final bool sidebarVisible;
  final bool hasSidebarVisibilityToggle;
  final ValueChanged<LibraryGroupMode>? onTogglePin;

  @override
  State<_GroupModeDropdownMenu> createState() => _GroupModeDropdownMenuState();
}

class _GroupModeDropdownMenuState extends State<_GroupModeDropdownMenu> {
  late Set<LibraryGroupMode> _pinnedModes;
  late Map<String, bool> _expandedSections;

  @override
  void initState() {
    super.initState();
    _pinnedModes = Set<LibraryGroupMode>.from(widget.initialPinnedModes);
    _expandedSections = {
      if (_pinnedModes.isNotEmpty) 'Favorites': true,
      for (final category in widget.categories)
        category.label: category.modes.any(
          (mode) => mode == widget.selectedMode || _pinnedModes.contains(mode),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final allModes = [
      for (final category in widget.categories) ...category.modes,
    ];
    final favoriteModes =
        allModes.where(_pinnedModes.contains).toList(growable: false);
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.divider),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.hasSidebarVisibilityToggle) ...[
                  _buildActionItem(
                    context,
                    icon: widget.sidebarVisible
                        ? Icons.folder_off_outlined
                        : Icons.folder_open_outlined,
                    label:
                        widget.sidebarVisible ? 'No folders' : 'Show folders',
                    onTap: () => Navigator.of(context).pop(
                      _GroupModeMenuAction.toggleSidebar,
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Manage Favorites',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      Icon(
                        Icons.settings_outlined,
                        size: 16,
                        color: palette.textMuted,
                      ),
                    ],
                  ),
                ),
                if (favoriteModes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Text(
                      'No favorites',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  )
                else
                  _buildSection(
                    context,
                    label: 'Favorites',
                    modes: favoriteModes,
                    accentLabel: true,
                  ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: Text(
                    'Folders',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: palette.textMuted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                  ),
                ),
                for (final category in widget.categories)
                  _buildSection(
                    context,
                    label: category.label,
                    modes: category.modes,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String label,
    required List<LibraryGroupMode> modes,
    bool accentLabel = false,
  }) {
    final palette = appPalette(context);
    final expanded = _expandedSections[label] ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedSections[label] = !expanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: accentLabel ? kAppHighlight : null,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: palette.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          for (final mode in modes) _buildModeItem(context, mode),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          child: Row(
            children: [
              Icon(icon, size: 16, color: palette.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeItem(BuildContext context, LibraryGroupMode mode) {
    final palette = appPalette(context);
    final isPinned = _pinnedModes.contains(mode);
    final isSelected = mode == widget.selectedMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.of(context).pop(mode),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      genericGroupModeIcon(mode),
                      size: 16,
                      color: isSelected ? widget.accent : palette.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        genericGroupModeLabel(mode, widget.type),
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w500,
                          color:
                              isSelected ? widget.accent : palette.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check, size: 16, color: widget.accent),
                  ],
                ),
              ),
            ),
          ),
          if (widget.onTogglePin != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  if (!isPinned) {
                    _pinnedModes.add(mode);
                    _expandedSections['Favorites'] = true;
                  } else {
                    _pinnedModes.remove(mode);
                    if (_pinnedModes.isEmpty) {
                      _expandedSections.remove('Favorites');
                    }
                  }
                });
                widget.onTogglePin!(mode);
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 15,
                  color: isPinned ? kAppHighlight : palette.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
