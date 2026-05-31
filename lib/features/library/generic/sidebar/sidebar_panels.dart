import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibrarySidebarFilteringPanel extends StatelessWidget {
  const LibrarySidebarFilteringPanel({
    super.key,
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
        LibrarySidebarFilterChip(
          icon: Icons.bookmarks_outlined,
          label: activeSmartListName!,
        ),
      if (quickView != null)
        LibrarySidebarFilterChip(
          icon: quickView!.icon,
          label: quickView!.label,
        ),
      if (collectionStatusScopeLabel != null)
        LibrarySidebarFilterChip(
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
        LibrarySidebarFilterChip(
          icon: Icons.search,
          label: 'Search: ${searchQuery!.trim()}',
        ),
      if (linkedMetadataFilterLabel != null)
        LibrarySidebarFilterChip(
          icon: Icons.link,
          label: linkedMetadataFilterLabel!,
        ),
      if (selectedLetter != null)
        LibrarySidebarFilterChip(
          icon: Icons.sort_by_alpha,
          label: 'Letter: $selectedLetter',
        ),
      if (filterSelection.hasActiveFilters)
        LibrarySidebarFilterChip(
          icon: Icons.filter_alt_outlined,
          label: '${filterSelection.activeFilterCount} advanced filter(s)',
        ),
    ];

    if (chips.isEmpty && !(hasActiveFilters && onClearFilters != null)) {
      return const SizedBox.shrink();
    }

    return _LibrarySidebarSectionCard(
      child: Column(
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
          const SizedBox(height: 6),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
                child: const Text('Clear all'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LibrarySidebarSectionCard extends StatelessWidget {
  const _LibrarySidebarSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.divider),
      ),
      child: child,
    );
  }
}

class LibrarySidebarFilterChip extends StatelessWidget {
  const LibrarySidebarFilterChip({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.selectedBorderColor,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color? selectedBorderColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final resolvedBorderColor = selected && selectedBorderColor != null
        ? selectedBorderColor!.withValues(alpha: 0.9)
        : palette.divider;
    final resolvedAvatarColor = selected && selectedBorderColor != null
        ? selectedBorderColor!
        : palette.textMuted;
    if (onPressed == null) {
      return Chip(
        avatar: Icon(icon, size: 14, color: resolvedAvatarColor),
        label: Text(label),
        side: BorderSide(color: resolvedBorderColor),
        backgroundColor: palette.panel,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }
    return FilterChip(
      avatar: Icon(icon, size: 14, color: resolvedAvatarColor),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      side: BorderSide(color: resolvedBorderColor),
      backgroundColor: palette.panel,
      selectedColor: selectedBorderColor == null
          ? null
          : Color.alphaBlend(
              selectedBorderColor!.withValues(alpha: 0.14),
              palette.panelRaised,
            ),
      onSelected: (_) => onPressed!(),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class LibrarySidebarSeriesStatusPanel extends StatelessWidget {
  const LibrarySidebarSeriesStatusPanel({
    super.key,
    required this.summary,
    this.selectedScope = LibraryCollectionStatusScope.all,
    this.onScopeSelected,
  });

  final LibrarySeriesStatusSummary summary;
  final LibraryCollectionStatusScope selectedScope;
  final ValueChanged<LibraryCollectionStatusScope>? onScopeSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accent = Theme.of(context).colorScheme.primary;
    final chips = <Widget>[
      LibrarySidebarFilterChip(
        icon: Icons.library_books_outlined,
        label: '${summary.totalCount} total',
        selected: selectedScope == LibraryCollectionStatusScope.all,
        selectedBorderColor: libraryCollectionStatusScopeColor(
          LibraryCollectionStatusScope.all,
          accent,
          palette.textMuted,
        ),
        onPressed: onScopeSelected == null
            ? null
            : () => onScopeSelected!(LibraryCollectionStatusScope.all),
      ),
      if (summary.ownedCount > 0)
        LibrarySidebarFilterChip(
          icon: Icons.inventory_2_outlined,
          label: '${summary.ownedCount} owned',
          selected: selectedScope == LibraryCollectionStatusScope.inCollection,
          selectedBorderColor: libraryCollectionStatusScopeColor(
            LibraryCollectionStatusScope.inCollection,
            accent,
            palette.textMuted,
          ),
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(
                    LibraryCollectionStatusScope.inCollection,
                  ),
        ),
      if (summary.wishlistCount > 0)
        LibrarySidebarFilterChip(
          icon: Icons.star_border,
          label: '${summary.wishlistCount} wish list',
          selected: selectedScope == LibraryCollectionStatusScope.wishList,
          selectedBorderColor: libraryCollectionStatusScopeColor(
            LibraryCollectionStatusScope.wishList,
            accent,
            palette.textMuted,
          ),
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.wishList),
        ),
      if (summary.forSaleCount > 0)
        LibrarySidebarFilterChip(
          icon: Icons.sell_outlined,
          label: '${summary.forSaleCount} for sale',
          selected: selectedScope == LibraryCollectionStatusScope.forSale,
          selectedBorderColor: libraryCollectionStatusScopeColor(
            LibraryCollectionStatusScope.forSale,
            accent,
            palette.textMuted,
          ),
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.forSale),
        ),
      if (summary.onOrderCount > 0)
        LibrarySidebarFilterChip(
          icon: Icons.local_shipping_outlined,
          label: '${summary.onOrderCount} on order',
          selected: selectedScope == LibraryCollectionStatusScope.onOrder,
          selectedBorderColor: libraryCollectionStatusScopeColor(
            LibraryCollectionStatusScope.onOrder,
            accent,
            palette.textMuted,
          ),
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.onOrder),
        ),
      if (summary.soldCount > 0)
        LibrarySidebarFilterChip(
          icon: Icons.paid_outlined,
          label: '${summary.soldCount} sold',
          selected: selectedScope == LibraryCollectionStatusScope.sold,
          selectedBorderColor: libraryCollectionStatusScopeColor(
            LibraryCollectionStatusScope.sold,
            accent,
            palette.textMuted,
          ),
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.sold),
        ),
      if (summary.catalogOnlyCount > 0)
        LibrarySidebarFilterChip(
          icon: Icons.hide_source_outlined,
          label: '${summary.catalogOnlyCount} not in collection',
          selected:
              selectedScope == LibraryCollectionStatusScope.notInCollection,
          selectedBorderColor: libraryCollectionStatusScopeColor(
            LibraryCollectionStatusScope.notInCollection,
            accent,
            palette.textMuted,
          ),
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(
                    LibraryCollectionStatusScope.notInCollection,
                  ),
        ),
    ];

    return _LibrarySidebarSectionCard(
      child: Column(
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
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips,
          ),
          if (summary.missingIssueSummary != null) ...[
            const SizedBox(height: 6),
            Text(
              'Missing: ${summary.missingIssueSummary}',
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
