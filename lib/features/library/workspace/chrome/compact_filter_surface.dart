import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A touch-optimized horizontal filter bar and active filter surface designed for compact/mobile viewports.
class CompactFilterSurface extends StatelessWidget {
  const CompactFilterSurface({
    super.key,
    required this.selection,
    required this.onFilterChanged,
    this.onOpenFilterDialog,
    this.onClearAll,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  final LibraryFilterSelection selection;
  final ValueChanged<LibraryFilterSelection> onFilterChanged;
  final VoidCallback? onOpenFilterDialog;
  final VoidCallback? onClearAll;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accentData = LibraryAccentScope.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          bottom: BorderSide(color: palette.divider),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter dialog launcher with badge
            if (onOpenFilterDialog != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  key: const ValueKey('compact_filter_all_dialog_chip'),
                  avatar: Icon(
                    Icons.filter_list,
                    size: 16,
                    color: selection.hasActiveFilters
                        ? accentData.accent
                        : palette.textMuted,
                  ),
                  label: Text(
                    selection.hasActiveFilters
                        ? 'Filters (${selection.activeFilterCount})'
                        : 'Filters',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selection.hasActiveFilters
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: selection.hasActiveFilters
                          ? accentData.accent
                          : palette.textPrimary,
                    ),
                  ),
                  selected: selection.hasActiveFilters,
                  selectedColor: accentData.accent.withValues(alpha: 0.15),
                  backgroundColor: palette.surfaceSubtle,
                  side: BorderSide(
                    color: selection.hasActiveFilters
                        ? accentData.accent
                        : palette.divider,
                  ),
                  onSelected: (_) => onOpenFilterDialog?.call(),
                ),
              ),

            // Quick Filter: All
            _buildQuickChip(
              key: const ValueKey('quick_filter_all'),
              label: 'All',
              selected: !selection.hasActiveFilters,
              accent: accentData.accent,
              palette: palette,
              onSelected: (selected) {
                if (selected) {
                  onClearAll?.call();
                  onFilterChanged(LibraryFilterSelection.none);
                }
              },
            ),

            // Quick Filter: Owned
            _buildQuickChip(
              key: const ValueKey('quick_filter_owned'),
              label: 'Owned',
              selected:
                  selection.ownershipFilter == LibraryOwnershipFilter.owned,
              accent: accentData.accent,
              palette: palette,
              onSelected: (selected) {
                onFilterChanged(
                  selection.copyWith(
                    ownershipFilter: selected
                        ? LibraryOwnershipFilter.owned
                        : LibraryOwnershipFilter.all,
                  ),
                );
              },
            ),

            // Quick Filter: Wishlist
            _buildQuickChip(
              key: const ValueKey('quick_filter_wishlist'),
              label: 'Wishlist',
              selected:
                  selection.ownershipFilter == LibraryOwnershipFilter.wishlist,
              accent: accentData.accent,
              palette: palette,
              onSelected: (selected) {
                onFilterChanged(
                  selection.copyWith(
                    ownershipFilter: selected
                        ? LibraryOwnershipFilter.wishlist
                        : LibraryOwnershipFilter.all,
                  ),
                );
              },
            ),

            // Quick Filter: In Progress
            _buildQuickChip(
              key: const ValueKey('quick_filter_in_progress'),
              label: 'In Progress',
              selected: selection.trackingStatusFilter ==
                  LibraryTrackingStatusFilter.inProgress,
              accent: accentData.accent,
              palette: palette,
              onSelected: (selected) {
                onFilterChanged(
                  selection.copyWith(
                    trackingStatusFilter: selected
                        ? LibraryTrackingStatusFilter.inProgress
                        : LibraryTrackingStatusFilter.all,
                  ),
                );
              },
            ),

            // Quick Filter: Completed
            _buildQuickChip(
              key: const ValueKey('quick_filter_completed'),
              label: 'Completed',
              selected: selection.trackingStatusFilter ==
                  LibraryTrackingStatusFilter.completed,
              accent: accentData.accent,
              palette: palette,
              onSelected: (selected) {
                onFilterChanged(
                  selection.copyWith(
                    trackingStatusFilter: selected
                        ? LibraryTrackingStatusFilter.completed
                        : LibraryTrackingStatusFilter.all,
                  ),
                );
              },
            ),

            // Active Filter Removable Chips for Deep Filters
            if (selection.series != null)
              _buildRemovableChip(
                key: const ValueKey('active_filter_series'),
                label: 'Series: ${selection.series}',
                accent: accentData.accent,
                palette: palette,
                onDeleted: () =>
                    onFilterChanged(selection.copyWith(clearSeries: true)),
              ),
            if (selection.publisher != null)
              _buildRemovableChip(
                key: const ValueKey('active_filter_publisher'),
                label: 'Publisher: ${selection.publisher}',
                accent: accentData.accent,
                palette: palette,
                onDeleted: () =>
                    onFilterChanged(selection.copyWith(clearPublisher: true)),
              ),
            if (selection.tag != null)
              _buildRemovableChip(
                key: const ValueKey('active_filter_tag'),
                label: 'Tag: ${selection.tag}',
                accent: accentData.accent,
                palette: palette,
                onDeleted: () =>
                    onFilterChanged(selection.copyWith(clearTag: true)),
              ),
            if (selection.missingCover)
              _buildRemovableChip(
                key: const ValueKey('active_filter_missing_cover'),
                label: 'Missing Cover',
                accent: accentData.accent,
                palette: palette,
                onDeleted: () =>
                    onFilterChanged(selection.copyWith(missingCover: false)),
              ),

            // Clear all chip
            if (selection.hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: TextButton.icon(
                  key: const ValueKey('compact_filter_clear_all'),
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: palette.textMuted,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () {
                    onClearAll?.call();
                    onFilterChanged(LibraryFilterSelection.none);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip({
    Key? key,
    required String label,
    required bool selected,
    required Color accent,
    required AppThemePalette palette,
    required ValueChanged<bool> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        key: key,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? accent : palette.textPrimary,
          ),
        ),
        selected: selected,
        selectedColor: accent.withValues(alpha: 0.15),
        backgroundColor: palette.surfaceSubtle,
        side: BorderSide(
          color: selected ? accent : palette.divider,
        ),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onSelected: onSelected,
      ),
    );
  }

  Widget _buildRemovableChip({
    Key? key,
    required String label,
    required Color accent,
    required AppThemePalette palette,
    required VoidCallback onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InputChip(
        key: key,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
        deleteIcon: Icon(Icons.cancel, size: 14, color: accent),
        onDeleted: onDeleted,
        selected: true,
        selectedColor: accent.withValues(alpha: 0.15),
        side: BorderSide(color: accent),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
