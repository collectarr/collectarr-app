import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
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
    this.collectionStatusScopeLabel,
    this.linkedMetadataFilterLabel,
    this.selectedLetter,
    this.seriesStatusSummary,
    this.filterSelection = LibraryFilterSelection.none,
    this.hasActiveFilters = false,
    this.onEditFilters,
    this.onClearFilters,
    required this.onClearFilter,
    this.onHideSidebar,
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
  final String? collectionStatusScopeLabel;
  final String? linkedMetadataFilterLabel;
  final String? selectedLetter;
  final LibrarySeriesStatusSummary? seriesStatusSummary;
  final LibraryFilterSelection filterSelection;
  final bool hasActiveFilters;
  final VoidCallback? onEditFilters;
  final VoidCallback? onClearFilters;
  final VoidCallback? onClearFilter;
  final VoidCallback? onHideSidebar;
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
        collectionStatusScopeLabel: collectionStatusScopeLabel,
        linkedMetadataFilterLabel: linkedMetadataFilterLabel,
        selectedLetter: selectedLetter,
        seriesStatusSummary: seriesStatusSummary,
        filterSelection: filterSelection,
        hasActiveFilters: hasActiveFilters,
        onEditFilters: onEditFilters,
        onClearFilters: onClearFilters,
        onClearFilter: onClearFilter,
        onHideSidebar: onHideSidebar,
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
    this.collectionStatusScopeLabel,
    this.linkedMetadataFilterLabel,
    this.selectedLetter,
    this.seriesStatusSummary,
    this.filterSelection = LibraryFilterSelection.none,
    this.hasActiveFilters = false,
    this.onEditFilters,
    this.onClearFilters,
    this.groupLoading = false,
    this.onClearFilter,
    this.onHideSidebar,
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
  final String? collectionStatusScopeLabel;
  final String? linkedMetadataFilterLabel;
  final String? selectedLetter;
  final LibrarySeriesStatusSummary? seriesStatusSummary;
  final LibraryFilterSelection filterSelection;
  final bool hasActiveFilters;
  final VoidCallback? onEditFilters;
  final VoidCallback? onClearFilters;
  final bool groupLoading;
  final VoidCallback? onClearFilter;
  final VoidCallback? onHideSidebar;
  final Set<LibraryGroupMode> pinnedGroupModes;
  final ValueChanged<LibraryGroupMode>? onTogglePin;

  @override
  Widget build(BuildContext context) {
    final label = genericGroupModeSidebarTitle(groupMode, type);
    final isRootScope = onClearFilter == null;
    final scopeLabel = breadcrumbs.isNotEmpty
        ? breadcrumbs.last
        : (isRootScope ? 'All ${type.pluralLabel}' : selectedBucket);
    final scopeTone = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: appPalette(context).textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: BoxDecoration(
        color: appPalette(context).surface,
        border: Border(bottom: BorderSide(color: appPalette(context).divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.folder_copy_outlined,
                  size: 16, color: appPalette(context).textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Folders',
                  style: scopeTone,
                ),
              ),
              if (groupLoading) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 4),
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
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: 'Group by',
                  child: InkWell(
                    onTap: () => _showGroupModeMenu(context),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: accent,
                                  ),
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, size: 18, color: accent),
                        ],
                      ),
                    ),
                  ),
                ),
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
            const SizedBox(height: 6),
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
                          ? Chip(
                              label: Text(breadcrumbs[index]),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            )
                          : ActionChip(
                              label: Text(breadcrumbs[index]),
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
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                isRootScope ? Icons.public : Icons.subdirectory_arrow_right,
                size: 14,
                color: appPalette(context).textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  scopeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: appPalette(context).textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SidebarFilteringPanel(
            type: type,
            activeSmartListName: activeSmartListName,
            quickView: quickView,
            collectionStatusScopeLabel: collectionStatusScopeLabel,
            searchQuery: searchQuery,
            linkedMetadataFilterLabel: linkedMetadataFilterLabel,
            selectedLetter: selectedLetter,
            filterSelection: filterSelection,
            hasActiveFilters: hasActiveFilters,
            onEditFilters: onEditFilters,
            onClearFilters: onClearFilters,
          ),
          if (seriesStatusSummary != null) ...[
            const SizedBox(height: 8),
            _SidebarSeriesStatusPanel(summary: seriesStatusSummary!),
          ],
        ],
      ),
    );
  }

  void _showGroupModeMenu(BuildContext context) {
    final modes = libraryGroupModesForType(type);
    final categories = _categorizeGroupModes(modes);
    final pinned = modes.where(pinnedGroupModes.contains).toList();
    final box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset(0, box.size.height));
    showMenu<LibraryGroupMode>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + box.size.width,
        offset.dy,
      ),
      constraints: const BoxConstraints(maxWidth: 240),
      items: [
        if (pinned.isNotEmpty) ...[
          PopupMenuItem<LibraryGroupMode>(
            enabled: false,
            height: 28,
            child: Text(
              'Favorites',
              style: TextStyle(
                color: kAppHighlight,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          for (final mode in pinned) _buildGroupModeItem(mode),
          const PopupMenuDivider(height: 8),
        ],
        for (final category in categories) ...[
          PopupMenuItem<LibraryGroupMode>(
            enabled: false,
            height: 28,
            child: Text(
              category.label,
              style: TextStyle(
                color: appPalette(context).textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          for (final mode in category.modes) _buildGroupModeItem(mode),
        ],
      ],
    ).then((value) {
      if (value != null) onChanged(value);
    });
  }

  PopupMenuItem<LibraryGroupMode> _buildGroupModeItem(LibraryGroupMode mode) {
    final isPinned = pinnedGroupModes.contains(mode);
    return PopupMenuItem<LibraryGroupMode>(
      value: mode,
      height: 36,
      child: Row(
        children: [
          Icon(
            genericGroupModeIcon(mode),
            size: 16,
            color: mode == groupMode ? accent : kAppTextSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              genericGroupModeLabel(mode, type),
              style: TextStyle(
                fontWeight:
                    mode == groupMode ? FontWeight.w800 : FontWeight.w500,
                color: mode == groupMode ? accent : null,
              ),
            ),
          ),
          if (mode == groupMode) Icon(Icons.check, size: 16, color: accent),
          if (onTogglePin != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTogglePin!(mode),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 14,
                  color: isPinned ? kAppHighlight : kAppTextMuted,
                ),
              ),
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
    this.collectionStatusScopeLabel,
    this.searchQuery,
    this.linkedMetadataFilterLabel,
    this.selectedLetter,
    this.filterSelection = LibraryFilterSelection.none,
    this.hasActiveFilters = false,
    this.onEditFilters,
    this.onClearFilters,
  });

  final LibraryTypeConfig type;
  final String? activeSmartListName;
  final LibraryQuickView? quickView;
  final String? collectionStatusScopeLabel;
  final String? searchQuery;
  final String? linkedMetadataFilterLabel;
  final String? selectedLetter;
  final LibraryFilterSelection filterSelection;
  final bool hasActiveFilters;
  final VoidCallback? onEditFilters;
  final VoidCallback? onClearFilters;

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: appPalette(context).panel.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appPalette(context).divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 15,
                color: appPalette(context).textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Filtering',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (onEditFilters != null)
                TextButton.icon(
                  onPressed: onEditFilters,
                  icon: const Icon(Icons.tune, size: 14),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (chips.isEmpty)
            Text(
              'No scoped filters yet. Use quick views, metadata links, alpha jump, or advanced filters to narrow ${type.pluralLabel.toLowerCase()}.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: appPalette(context).textMuted,
                  ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: chips,
            ),
          if (hasActiveFilters && onClearFilters != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all, size: 14),
                label: const Text('Clear all'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SidebarFilterChip extends StatelessWidget {
  const _SidebarFilterChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14, color: appPalette(context).textMuted),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _SidebarSeriesStatusPanel extends StatelessWidget {
  const _SidebarSeriesStatusPanel({required this.summary});

  final LibrarySeriesStatusSummary summary;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _SidebarFilterChip(
        icon: Icons.library_books_outlined,
        label: '${summary.totalCount} total',
      ),
      if (summary.ownedCount > 0)
        _SidebarFilterChip(
          icon: Icons.inventory_2_outlined,
          label: '${summary.ownedCount} owned',
        ),
      if (summary.wishlistCount > 0)
        _SidebarFilterChip(
          icon: Icons.star_border,
          label: '${summary.wishlistCount} wish list',
        ),
      if (summary.forSaleCount > 0)
        _SidebarFilterChip(
          icon: Icons.sell_outlined,
          label: '${summary.forSaleCount} for sale',
        ),
      if (summary.onOrderCount > 0)
        _SidebarFilterChip(
          icon: Icons.local_shipping_outlined,
          label: '${summary.onOrderCount} on order',
        ),
      if (summary.soldCount > 0)
        _SidebarFilterChip(
          icon: Icons.paid_outlined,
          label: '${summary.soldCount} sold',
        ),
      if (summary.catalogOnlyCount > 0)
        _SidebarFilterChip(
          icon: Icons.hide_source_outlined,
          label: '${summary.catalogOnlyCount} not in collection',
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: appPalette(context).panel.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appPalette(context).divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monitor_heart_outlined,
                size: 15,
                color: appPalette(context).textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Series status',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            summary.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appPalette(context).textMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips,
          ),
          if (summary.missingIssueSummary != null) ...[
            const SizedBox(height: 8),
            Text(
              'Missing issues: ${summary.missingIssueSummary}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: appPalette(context).textMuted,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupModeCategory {
  const _GroupModeCategory(this.label, this.modes);
  final String label;
  final List<LibraryGroupMode> modes;
}
