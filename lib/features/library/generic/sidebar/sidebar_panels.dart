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
    final entries = <_LibrarySidebarDetailEntryData>[
      if (activeSmartListName != null && activeSmartListName!.trim().isNotEmpty)
        _LibrarySidebarDetailEntryData(
          icon: Icons.bookmarks_outlined,
          label: 'Smart list',
          value: activeSmartListName!,
        ),
      if (quickView != null)
        _LibrarySidebarDetailEntryData(
          icon: quickView!.icon,
          label: 'Quick view',
          value: quickView!.label,
        ),
      if (collectionStatusScopeLabel != null)
        _LibrarySidebarDetailEntryData(
          icon: Icons.inventory_2_outlined,
          label: 'Collection',
          value: collectionStatusScopeLabel!,
          active: collectionStatusScope != LibraryCollectionStatusScope.all,
          onPressed: onCollectionStatusScopeChanged == null
              ? null
              : () => onCollectionStatusScopeChanged!(
                    LibraryCollectionStatusScope.all,
                  ),
        ),
      if (searchQuery != null && searchQuery!.trim().isNotEmpty)
        _LibrarySidebarDetailEntryData(
          icon: Icons.search,
          label: 'Search',
          value: searchQuery!.trim(),
        ),
      if (linkedMetadataFilterLabel != null)
        _LibrarySidebarDetailEntryData(
          icon: Icons.link,
          label: 'Linked metadata',
          value: linkedMetadataFilterLabel!,
        ),
      if (selectedLetter != null)
        _LibrarySidebarDetailEntryData(
          icon: Icons.sort_by_alpha,
          label: 'Letter',
          value: selectedLetter!,
        ),
      if (filterSelection.hasActiveFilters)
        _LibrarySidebarDetailEntryData(
          icon: Icons.filter_alt_outlined,
          label: 'Advanced filters',
          value: '${filterSelection.activeFilterCount} active',
        ),
    ];

    if (entries.isEmpty && !(hasActiveFilters && onClearFilters != null)) {
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
            if (entries.isNotEmpty) const SizedBox(height: 6),
            for (var index = 0; index < entries.length; index++) ...[
              _LibrarySidebarDetailRow(entry: entries[index]),
              if (index < entries.length - 1)
                Divider(height: 10, color: appPalette(context).divider),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: child,
    );
  }
}

class _LibrarySidebarDetailEntryData {
  const _LibrarySidebarDetailEntryData({
    required this.icon,
    required this.label,
    required this.value,
    this.active = false,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool active;
  final VoidCallback? onPressed;
}

class _LibrarySidebarDetailRow extends StatelessWidget {
  const _LibrarySidebarDetailRow({required this.entry});

  final _LibrarySidebarDetailEntryData entry;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final activeColor = Theme.of(context).colorScheme.primary;
    final row = Row(
      children: [
        Icon(
          entry.icon,
          size: 14,
          color: entry.active ? activeColor : palette.textMuted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            entry.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            entry.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: entry.active ? FontWeight.w800 : FontWeight.w600,
                  color: entry.active ? activeColor : palette.textPrimary,
                ),
          ),
        ),
      ],
    );
    if (entry.onPressed == null) {
      return row;
    }
    return InkWell(
      onTap: entry.onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: row,
      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        backgroundColor: palette.surface,
        padding: const EdgeInsets.symmetric(horizontal: 4),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      backgroundColor: palette.surface,
      selectedColor: selectedBorderColor == null
          ? null
          : Color.alphaBlend(
              selectedBorderColor!.withValues(alpha: 0.14),
              palette.surface,
            ),
      onSelected: (_) => onPressed!(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
    final rows = <_LibrarySidebarStatusEntry>[
      _LibrarySidebarStatusEntry(
        icon: Icons.library_books_outlined,
        label: 'All items',
        count: summary.totalCount,
        selected: selectedScope == LibraryCollectionStatusScope.all,
        accent: libraryCollectionStatusScopeColor(
          LibraryCollectionStatusScope.all,
          accent,
          palette.textMuted,
        ),
        onPressed: onScopeSelected == null
            ? null
            : () => onScopeSelected!(LibraryCollectionStatusScope.all),
      ),
      if (summary.ownedCount > 0)
        _LibrarySidebarStatusEntry(
          icon: Icons.inventory_2_outlined,
          label: 'Owned',
          count: summary.ownedCount,
          selected: selectedScope == LibraryCollectionStatusScope.inCollection,
          accent: libraryCollectionStatusScopeColor(
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
        _LibrarySidebarStatusEntry(
          icon: Icons.star_border,
          label: 'Wish list',
          count: summary.wishlistCount,
          selected: selectedScope == LibraryCollectionStatusScope.wishList,
          accent: libraryCollectionStatusScopeColor(
            LibraryCollectionStatusScope.wishList,
            accent,
            palette.textMuted,
          ),
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.wishList),
        ),
      if (summary.forSaleCount > 0)
        _LibrarySidebarStatusEntry(
          icon: Icons.sell_outlined,
          label: 'For sale',
          count: summary.forSaleCount,
          selected: selectedScope == LibraryCollectionStatusScope.forSale,
          accent: libraryCollectionStatusScopeColor(
            LibraryCollectionStatusScope.forSale,
            accent,
            palette.textMuted,
          ),
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.forSale),
        ),
      if (summary.onOrderCount > 0)
        _LibrarySidebarStatusEntry(
          icon: Icons.local_shipping_outlined,
          label: 'On order',
          count: summary.onOrderCount,
          selected: selectedScope == LibraryCollectionStatusScope.onOrder,
          accent: libraryCollectionStatusScopeColor(
            LibraryCollectionStatusScope.onOrder,
            accent,
            palette.textMuted,
          ),
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.onOrder),
        ),
      if (summary.soldCount > 0)
        _LibrarySidebarStatusEntry(
          icon: Icons.paid_outlined,
          label: 'Sold',
          count: summary.soldCount,
          selected: selectedScope == LibraryCollectionStatusScope.sold,
          accent: libraryCollectionStatusScopeColor(
            LibraryCollectionStatusScope.sold,
            accent,
            palette.textMuted,
          ),
          onPressed: onScopeSelected == null
              ? null
              : () => onScopeSelected!(LibraryCollectionStatusScope.sold),
        ),
      if (summary.catalogOnlyCount > 0)
        _LibrarySidebarStatusEntry(
          icon: Icons.hide_source_outlined,
          label: 'Not in collection',
          count: summary.catalogOnlyCount,
          selected:
              selectedScope == LibraryCollectionStatusScope.notInCollection,
          accent: libraryCollectionStatusScopeColor(
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
          for (var index = 0; index < rows.length; index++) ...[
            _LibrarySidebarStatusRow(entry: rows[index]),
            if (index < rows.length - 1)
              Divider(height: 8, color: appPalette(context).divider),
          ],
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

class _LibrarySidebarStatusEntry {
  const _LibrarySidebarStatusEntry({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.accent,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final Color accent;
  final VoidCallback? onPressed;
}

class _LibrarySidebarStatusRow extends StatelessWidget {
  const _LibrarySidebarStatusRow({required this.entry});

  final _LibrarySidebarStatusEntry entry;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final row = Row(
      children: [
        Container(
          width: 2,
          height: 14,
          color: entry.selected ? entry.accent : Colors.transparent,
        ),
        const SizedBox(width: 6),
        Icon(
          entry.icon,
          size: 14,
          color: entry.selected ? entry.accent : palette.textMuted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            entry.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: entry.selected ? FontWeight.w800 : FontWeight.w600,
                  color: entry.selected ? palette.textPrimary : palette.textMuted,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          entry.count.toString(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: entry.selected ? entry.accent : palette.textPrimary,
              ),
        ),
      ],
    );
    if (entry.onPressed == null) {
      return row;
    }
    return InkWell(
      onTap: entry.onPressed,
      borderRadius: BorderRadius.circular(2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: row,
      ),
    );
  }
}
