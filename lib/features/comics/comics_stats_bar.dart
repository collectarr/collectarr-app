import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_stats_cards.dart';
import 'package:collectarr_app/features/comics/comics_stats_metrics.dart';
import 'package:collectarr_app/features/comics/comics_stats_style.dart';
import 'package:flutter/material.dart';

class ComicsStatsBar extends StatelessWidget {
  const ComicsStatsBar({
    super.key,
    required this.state,
    required this.selectedSeries,
    required this.missingIssues,
  });

  final ShelfState state;
  final String? selectedSeries;
  final List<int> missingIssues;

  @override
  Widget build(BuildContext context) {
    final value = state.totalPaidCents == null
        ? '-'
        : formatComicsStatsMoney(state.totalPaidCents, state.primaryCurrency);
    final missingMetadataCount = missingComicsMetadataCount(state.entries);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF181818),
        border: Border(bottom: BorderSide(color: kComicsStatsDivider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Column(
          children: [
            Row(
              children: [
                ComicsStatsTile(
                  icon: Icons.menu_book,
                  label: 'Local comics',
                  value: state.entries.length.toString(),
                ),
                ComicsStatsTile(
                  icon: Icons.check_box,
                  label: 'Owned',
                  value: state.ownedCount.toString(),
                ),
                ComicsStatsTile(
                  icon: Icons.star,
                  label: 'Wishlist',
                  value: state.wishlistCount.toString(),
                ),
                ComicsStatsTile(
                  icon: Icons.attach_money,
                  label: 'Value',
                  value: state.hasMixedCurrencies ? '$value +' : value,
                ),
                ComicsStatsTile(
                  icon: Icons.workspace_premium,
                  label: 'Graded',
                  value: '${state.ownedCount - state.missingGradeCount}',
                ),
                ComicsStatsTile(
                  icon: Icons.report_gmailerrorred,
                  label: 'Missing grade',
                  value: state.missingGradeCount.toString(),
                ),
                ComicsStatsTile(
                  icon: Icons.cloud_off,
                  label: 'Missing metadata',
                  value: missingMetadataCount.toString(),
                ),
                ComicsStatsTile(
                  icon: Icons.format_list_numbered,
                  label: selectedSeries == null
                      ? 'Missing issues'
                      : 'Missing in series',
                  value: missingIssues.length.toString(),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                ComicsStatsDistributionCard(
                  title: 'Grades',
                  values: state.gradeCounts,
                ),
                const SizedBox(width: 8),
                ComicsStatsDistributionCard(
                  title: 'Conditions',
                  values: state.conditionCounts,
                ),
                const SizedBox(width: 8),
                ComicsMissingIssuesCard(
                  selectedSeries: selectedSeries,
                  missingIssues: missingIssues,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
