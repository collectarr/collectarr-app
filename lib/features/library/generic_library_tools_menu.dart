import 'package:collectarr_app/features/library/generic_library_projection.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_utility_menu.dart';
import 'package:flutter/material.dart';

class GenericLibraryToolsButton extends StatelessWidget {
  const GenericLibraryToolsButton({
    super.key,
    required this.type,
    required this.counts,
    required this.selectedBucket,
    required this.quickView,
    required this.hasActiveFilters,
    required this.onQuickViewSelected,
    required this.onClearFilters,
  });

  final LibraryTypeConfig type;
  final GenericToolbarCounts counts;
  final String? selectedBucket;
  final GenericQuickView? quickView;
  final bool hasActiveFilters;
  final ValueChanged<GenericQuickView> onQuickViewSelected;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return LibraryUtilityMenu<GenericQuickView>(
      quickViews: [
        for (final view in GenericQuickView.values)
          LibraryUtilityQuickView(
            value: view,
            label: view.label,
            icon: view.icon,
          ),
      ],
      selectedQuickView: quickView,
      onQuickViewSelected: onQuickViewSelected,
      badgeCount: _utilityBadgeCount,
      actions: [
        LibraryUtilityMenuAction(
          icon: Icons.query_stats,
          label: 'Statistics',
          onSelected: () => _showGenericStatsDialog(context, type, counts),
        ),
        LibraryUtilityMenuAction(
          icon: Icons.filter_alt_off_outlined,
          label: 'Clear filters',
          enabled: hasActiveFilters,
          onSelected: onClearFilters,
        ),
        LibraryUtilityMenuAction(
          icon: Icons.image_not_supported_outlined,
          label: 'Missing covers',
          enabled: false,
          trailing: Text(counts.missingCover.toString()),
        ),
        LibraryUtilityMenuAction(
          icon: Icons.manage_search,
          label: 'Missing metadata',
          enabled: false,
          trailing: Text(counts.missingMetadata.toString()),
        ),
      ],
    );
  }

  int get _utilityBadgeCount {
    return (selectedBucket != null ? 1 : 0) + (quickView != null ? 1 : 0);
  }
}

void _showGenericStatsDialog(
  BuildContext context,
  LibraryTypeConfig type,
  GenericToolbarCounts counts,
) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${type.pluralLabel} statistics'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _StatsChip('Shown', counts.shown),
          _StatsChip('Total', counts.total),
          _StatsChip('Owned', counts.owned),
          _StatsChip('Wishlist', counts.wishlist),
          _StatsChip('Missing covers', counts.missingCover),
          _StatsChip('Missing metadata', counts.missingMetadata),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

class _StatsChip extends StatelessWidget {
  const _StatsChip(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label $value'),
      avatar: const Icon(Icons.query_stats, size: 16),
    );
  }
}
