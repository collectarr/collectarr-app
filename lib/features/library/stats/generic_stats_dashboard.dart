import 'package:collectarr_app/features/comics/stats/comics_stats_cards.dart';
import 'package:collectarr_app/features/comics/stats/comics_stats_style.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:flutter/material.dart';

/// Shows a rich statistics dashboard dialog for any media type.
Future<void> showGenericStatsDashboardDialog(
  BuildContext context, {
  required LibraryTypeConfig type,
  required ShelfState state,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _GenericStatsDashboard(type: type, state: state),
  );
}

class _GenericStatsDashboard extends StatelessWidget {
  const _GenericStatsDashboard({required this.type, required this.state});

  final LibraryTypeConfig type;
  final ShelfState state;

  @override
  Widget build(BuildContext context) {
    final totalValue = state.totalPaidCents == null
        ? '-'
        : formatComicsStatsMoney(state.totalPaidCents, state.primaryCurrency);
    final sellValue = state.totalSellCents == null || state.totalSellCents == 0
        ? null
        : formatComicsStatsMoney(state.totalSellCents, state.primaryCurrency);
    final missingCovers =
        state.entries.where((e) => e.catalogItem?.displayCoverUrl == null).length;
    final missingMetadata = _missingMetadataCount(state.entries);
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
                    Icon(type.workspace.icon, color: kComicsStatsAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${type.pluralLabel} Statistics',
                        style: const TextStyle(fontWeight: FontWeight.w900),
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
                      // Summary tiles
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ComicsStatsTile(
                            icon: type.workspace.icon,
                            label: 'Total',
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
                            label: 'Total paid',
                            value: state.hasMixedCurrencies
                                ? '$totalValue +'
                                : totalValue,
                          ),
                          if (sellValue != null)
                            ComicsStatsTile(
                              icon: Icons.sell_outlined,
                              label: 'Sold total',
                              value: sellValue,
                            ),
                          ComicsStatsTile(
                            icon: Icons.image_not_supported_outlined,
                            label: 'Missing covers',
                            value: missingCovers.toString(),
                          ),
                          ComicsStatsTile(
                            icon: Icons.cloud_off,
                            label: 'Missing metadata',
                            value: missingMetadata.toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Detail cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >=
                              kComicsStatsDialogWideBreakpoint;
                          final children = <Widget>[
                            ComicsStatsRankedCard(
                              title: _seriesLabel,
                              values: _topSeriesCounts(state.entries),
                            ),
                            ComicsStatsRankedCard(
                              title: _publisherLabel,
                              values: _topPublisherCounts(state.entries),
                            ),
                            if (state.gradeCounts.isNotEmpty)
                              ComicsStatsDistributionCard(
                                title: 'Grades',
                                values: state.gradeCounts,
                              ),
                            if (state.conditionCounts.isNotEmpty)
                              ComicsStatsDistributionCard(
                                title: 'Conditions',
                                values: state.conditionCounts,
                              ),
                            _TrackingStatusCard(entries: state.entries),
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
                                ComicsStatsHealthRow(
                                  label: 'Cover coverage',
                                  fraction: state.entries.isEmpty
                                      ? 0.0
                                      : (state.entries.length -
                                              missingCovers) /
                                          state.entries.length,
                                ),
                              ],
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

  String get _seriesLabel {
    final kind = type.workspace.kind;
    return switch (kind) {
      'movie' || 'tv' || 'anime' => 'Top Franchises',
      'music' => 'Top Artists',
      _ => 'Top Series',
    };
  }

  String get _publisherLabel {
    final kind = type.workspace.kind;
    return switch (kind) {
      'movie' || 'tv' || 'anime' => 'Top Studios',
      'music' => 'Top Labels',
      'game' || 'boardgame' => 'Top Publishers / Studios',
      _ => 'Top Publishers',
    };
  }

  static Map<String, int> _topSeriesCounts(List<ShelfEntry> entries) {
    return _countBy(
      entries,
      (e) => e.catalogItem?.seriesTitle ?? e.catalogItem?.title ?? 'Unknown',
    );
  }

  static Map<String, int> _topPublisherCounts(List<ShelfEntry> entries) {
    return _countBy(
      entries,
      (e) => e.catalogItem?.publisher ?? 'Unknown',
    );
  }

  static int _missingMetadataCount(List<ShelfEntry> entries) {
    var count = 0;
    for (final entry in entries) {
      final cat = entry.catalogItem;
      if (cat == null ||
          (cat.synopsis == null || cat.synopsis!.trim().isEmpty) &&
              (cat.publisher == null || cat.publisher!.trim().isEmpty)) {
        count++;
      }
    }
    return count;
  }

  static Map<String, int> _countBy(
    Iterable<ShelfEntry> entries,
    String Function(ShelfEntry entry) keyFor,
  ) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final key = keyFor(entry).trim();
      final normalized = key.isEmpty ? 'Unknown' : key;
      counts[normalized] = (counts[normalized] ?? 0) + 1;
    }
    return counts;
  }
}

/// Card showing tracking status distribution.
class _TrackingStatusCard extends StatelessWidget {
  const _TrackingStatusCard({required this.entries});

  final List<ShelfEntry> entries;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final status = entry.ownedItem?.readStatus?.trim();
      if (status != null && status.isNotEmpty) {
        counts[status] = (counts[status] ?? 0) + 1;
      }
    }
    return ComicsStatsDistributionCard(title: 'Tracking', values: counts);
  }
}
