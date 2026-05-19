import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/comics/stats/comics_stats_cards.dart';
import 'package:collectarr_app/features/comics/stats/comics_stats_metrics.dart';
import 'package:collectarr_app/features/comics/stats/comics_stats_style.dart';
import 'package:flutter/material.dart';

Future<void> showComicsStatsDashboardDialog(
  BuildContext context, {
  required ShelfState state,
  required String? selectedSeries,
  required List<int> missingIssues,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _StatsDashboardDialog(
      state: state,
      selectedSeries: selectedSeries,
      missingIssues: missingIssues,
    ),
  );
}

class _StatsDashboardDialog extends StatelessWidget {
  const _StatsDashboardDialog({
    required this.state,
    required this.selectedSeries,
    required this.missingIssues,
  });

  final ShelfState state;
  final String? selectedSeries;
  final List<int> missingIssues;

  @override
  Widget build(BuildContext context) {
    final missingMetadata = missingComicsMetadataCount(state.entries);
    final totalValue = state.totalPaidCents == null
        ? '-'
        : formatComicsStatsMoney(state.totalPaidCents, state.primaryCurrency);
    final valueCoverage =
        state.ownedCount == 0 ? 0.0 : state.pricedCount / state.ownedCount;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
        child: ColoredBox(
          color: kComicsStatsCanvas,
          child: Column(
            children: [
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  color: kComicsStatsToolbar,
                  border:
                      Border(bottom: BorderSide(color: kComicsStatsDivider)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.query_stats, color: kComicsStatsAccent),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Local Comics Statistics',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
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
                            label: 'Total value',
                            value: state.hasMixedCurrencies
                                ? '$totalValue +'
                                : totalValue,
                          ),
                          ComicsStatsTile(
                            icon: Icons.cloud_off,
                            label: 'Missing metadata',
                            value: missingMetadata.toString(),
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
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >=
                              kComicsStatsDialogWideBreakpoint;
                          final children = [
                            ComicsStatsDistributionCard(
                              title: 'Grades',
                              values: state.gradeCounts,
                            ),
                            ComicsStatsDistributionCard(
                              title: 'Conditions',
                              values: state.conditionCounts,
                            ),
                            ComicsStatsRankedCard(
                              title: 'Top Series',
                              values: topComicsSeriesCounts(state.entries),
                            ),
                            ComicsStatsRankedCard(
                              title: 'Top Publishers',
                              values: topComicsPublisherCounts(state.entries),
                            ),
                            ComicsStatsHealthCard(
                              title: 'Data Health',
                              rows: [
                                ComicsStatsHealthRow(
                                  label: 'Value coverage',
                                  fraction: valueCoverage,
                                ),
                                ComicsStatsHealthRow(
                                  label: 'Graded coverage',
                                  fraction: state.ownedCount == 0
                                      ? 0.0
                                      : (state.ownedCount -
                                              state.missingGradeCount) /
                                          state.ownedCount,
                                ),
                                ComicsStatsHealthRow(
                                  label: 'Metadata coverage',
                                  fraction: state.entries.isEmpty
                                      ? 0.0
                                      : (state.entries.length -
                                              missingMetadata) /
                                          state.entries.length,
                                ),
                              ],
                            ),
                            ComicsMissingIssuesCard(
                              selectedSeries: selectedSeries,
                              missingIssues: missingIssues,
                            ),
                          ];
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final child in children)
                                SizedBox(
                                  width: wide
                                      ? (constraints.maxWidth - 20) / 3
                                      : constraints.maxWidth,
                                  child: child,
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
