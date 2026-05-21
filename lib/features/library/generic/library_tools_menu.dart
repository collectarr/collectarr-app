import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/library_projection.dart';
import 'package:collectarr_app/features/library/inspector/library_duplicate_items.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/stats/stats_dashboard.dart';
import 'package:collectarr_app/features/library/workspace/library_utility_menu.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:flutter/material.dart';

class LibraryToolsButton extends StatelessWidget {
  const LibraryToolsButton({
    super.key,
    required this.type,
    required this.counts,
    required this.selectedBucket,
    required this.quickView,
    required this.hasActiveFilters,
    required this.onQuickViewSelected,
    required this.onClearFilters,
    this.onRandomPick,
    this.onDownloadAllCovers,
    this.shelfState,
  });

  final LibraryTypeConfig type;
  final LibraryToolbarCounts counts;
  final String? selectedBucket;
  final LibraryQuickView? quickView;
  final bool hasActiveFilters;
  final ValueChanged<LibraryQuickView> onQuickViewSelected;
  final VoidCallback onClearFilters;
  final VoidCallback? onRandomPick;
  final VoidCallback? onDownloadAllCovers;
  final ShelfState? shelfState;

  @override
  Widget build(BuildContext context) {
    return LibraryUtilityMenu<LibraryQuickView>(
      quickViews: [
        for (final view in LibraryQuickView.values)
          if (!view.requiresGrades || type.grades.isNotEmpty)
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
          onSelected: () {
            final state = shelfState;
            if (state != null) {
              showStatsDashboardDialog(context, type: type, state: state);
            } else {
              _showGenericStatsDialog(context, type, counts);
            }
          },
        ),
        if (onRandomPick != null)
          LibraryUtilityMenuAction(
            icon: Icons.casino_outlined,
            label: 'Random pick',
            onSelected: onRandomPick!,
          ),
        if (shelfState != null)
          LibraryUtilityMenuAction(
            icon: Icons.compare_arrows,
            label: 'Find duplicates',
            onSelected: () {
              final groups =
                  findDuplicateShelfGroups(shelfState!.entries);
              showDuplicateItemsDialog(context, duplicateGroups: groups);
            },
          ),
        LibraryUtilityMenuAction(
          icon: Icons.filter_alt_off_outlined,
          label: 'Clear filters',
          enabled: hasActiveFilters,
          onSelected: onClearFilters,
        ),
        if (onDownloadAllCovers != null)
          LibraryUtilityMenuAction(
            icon: Icons.download_outlined,
            label: 'Download all covers',
            onSelected: onDownloadAllCovers!,
          ),
        LibraryUtilityMenuAction(
          icon: Icons.image_not_supported_outlined,
          label: 'Missing covers',
          enabled: counts.missingCover > 0,
          trailing: Text(counts.missingCover.toString()),
          onSelected: () =>
              onQuickViewSelected(LibraryQuickView.missingCovers),
        ),
        LibraryUtilityMenuAction(
          icon: Icons.manage_search,
          label: 'Missing metadata',
          enabled: counts.missingMetadata > 0,
          trailing: Text(counts.missingMetadata.toString()),
          onSelected: () =>
              onQuickViewSelected(LibraryQuickView.missingMetadata),
        ),
        LibraryUtilityMenuAction(
          icon: Icons.auto_fix_high,
          label: 'Pre-fill settings...',
          onSelected: () {
            final accent = Theme.of(context).colorScheme.primary;
            showPrefillSettingsDialog(context: context, accent: accent);
          },
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
  LibraryToolbarCounts counts,
) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${type.pluralLabel} statistics'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
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
          if (counts.totalPricePaidCents > 0 ||
              counts.totalCoverPriceCents > 0 ||
              counts.totalSellPriceCents > 0) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Collection Value',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (counts.totalPricePaidCents > 0)
                  _StatsChipMoney(
                    'Total paid',
                    counts.totalPricePaidCents,
                    counts.priceCurrency,
                  ),
                if (counts.totalCoverPriceCents > 0)
                  _StatsChipMoney(
                    'Cover value',
                    counts.totalCoverPriceCents,
                    counts.priceCurrency,
                  ),
                if (counts.totalSellPriceCents > 0)
                  _StatsChipMoney(
                    'Sold total',
                    counts.totalSellPriceCents,
                    counts.priceCurrency,
                  ),
              ],
            ),
          ],
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

class _StatsChipMoney extends StatelessWidget {
  const _StatsChipMoney(this.label, this.cents, this.currency);

  final String label;
  final int cents;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    final cur = currency ?? 'USD';
    final amount = (cents / 100).toStringAsFixed(2);
    return Chip(
      label: Text('$label $amount $cur'),
      avatar: const Icon(Icons.attach_money, size: 16),
    );
  }
}
