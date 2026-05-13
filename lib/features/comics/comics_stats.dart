import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:flutter/material.dart';

const Color _kClzToolbar = Color(0xFF2B2B2B);
const Color _kClzPanel = Color(0xFF242424);
const Color _kClzCanvas = Color(0xFF141414);
const Color _kClzAccent = Color(0xFF10A8D8);
const Color _kClzDivider = Color(0xFF4A4A4A);
const Color _kClzTextMuted = Color(0xFFB8B8B8);

class ComicsStatsBar extends StatelessWidget {
  const ComicsStatsBar({
    required this.state,
    required this.selectedSeries,
    required this.missingIssues,
    super.key,
  });

  final ShelfState state;
  final String? selectedSeries;
  final List<int> missingIssues;

  @override
  Widget build(BuildContext context) {
    final value = state.totalPaidCents == null
        ? '-'
        : _formatOptionalMoney(state.totalPaidCents, state.primaryCurrency);
    final missingMetadataCount = missingComicsMetadataCount(state.entries);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF181818),
        border: Border(bottom: BorderSide(color: _kClzDivider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Column(
          children: [
            Row(
              children: [
                _StatsTile(
                  icon: Icons.menu_book,
                  label: 'Local comics',
                  value: state.entries.length.toString(),
                ),
                _StatsTile(
                  icon: Icons.check_box,
                  label: 'Owned',
                  value: state.ownedCount.toString(),
                ),
                _StatsTile(
                  icon: Icons.star,
                  label: 'Wishlist',
                  value: state.wishlistCount.toString(),
                ),
                _StatsTile(
                  icon: Icons.attach_money,
                  label: 'Value',
                  value: state.hasMixedCurrencies ? '$value +' : value,
                ),
                _StatsTile(
                  icon: Icons.workspace_premium,
                  label: 'Graded',
                  value: '${state.ownedCount - state.missingGradeCount}',
                ),
                _StatsTile(
                  icon: Icons.report_gmailerrorred,
                  label: 'Missing grade',
                  value: state.missingGradeCount.toString(),
                ),
                _StatsTile(
                  icon: Icons.cloud_off,
                  label: 'Missing metadata',
                  value: missingMetadataCount.toString(),
                ),
                _StatsTile(
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
                _StatsDistributionCard(
                  title: 'Grades',
                  values: state.gradeCounts,
                ),
                const SizedBox(width: 8),
                _StatsDistributionCard(
                  title: 'Conditions',
                  values: state.conditionCounts,
                ),
                const SizedBox(width: 8),
                _MissingIssuesCard(
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
        : _formatOptionalMoney(state.totalPaidCents, state.primaryCurrency);
    final valueCoverage =
        state.ownedCount == 0 ? 0.0 : state.pricedCount / state.ownedCount;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
        child: ColoredBox(
          color: _kClzCanvas,
          child: Column(
            children: [
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  color: _kClzToolbar,
                  border: Border(bottom: BorderSide(color: _kClzDivider)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.query_stats, color: _kClzAccent),
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
                          _StatsTile(
                            icon: Icons.menu_book,
                            label: 'Local comics',
                            value: state.entries.length.toString(),
                          ),
                          _StatsTile(
                            icon: Icons.check_box,
                            label: 'Owned',
                            value: state.ownedCount.toString(),
                          ),
                          _StatsTile(
                            icon: Icons.star,
                            label: 'Wishlist',
                            value: state.wishlistCount.toString(),
                          ),
                          _StatsTile(
                            icon: Icons.attach_money,
                            label: 'Total value',
                            value: state.hasMixedCurrencies
                                ? '$totalValue +'
                                : totalValue,
                          ),
                          _StatsTile(
                            icon: Icons.cloud_off,
                            label: 'Missing metadata',
                            value: missingMetadata.toString(),
                          ),
                          _StatsTile(
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
                          final wide = constraints.maxWidth >= 760;
                          final children = [
                            _StatsDistributionCard(
                              title: 'Grades',
                              values: state.gradeCounts,
                            ),
                            _StatsDistributionCard(
                              title: 'Conditions',
                              values: state.conditionCounts,
                            ),
                            _StatsRankedCard(
                              title: 'Top Series',
                              values: _topSeriesCounts(state.entries),
                            ),
                            _StatsRankedCard(
                              title: 'Top Publishers',
                              values: _topPublisherCounts(state.entries),
                            ),
                            _StatsHealthCard(
                              title: 'Data Health',
                              rows: [
                                _StatsHealthRow(
                                  label: 'Value coverage',
                                  fraction: valueCoverage,
                                ),
                                _StatsHealthRow(
                                  label: 'Graded coverage',
                                  fraction: state.ownedCount == 0
                                      ? 0
                                      : (state.ownedCount -
                                              state.missingGradeCount) /
                                          state.ownedCount,
                                ),
                                _StatsHealthRow(
                                  label: 'Metadata coverage',
                                  fraction: state.entries.isEmpty
                                      ? 0
                                      : (state.entries.length -
                                              missingMetadata) /
                                          state.entries.length,
                                ),
                              ],
                            ),
                            _MissingIssuesCard(
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

class _StatsTile extends StatelessWidget {
  const _StatsTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _kClzPanel,
        border: Border.all(color: const Color(0xFF383838)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _kClzAccent),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: _kClzTextMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsDistributionCard extends StatelessWidget {
  const _StatsDistributionCard({
    required this.title,
    required this.values,
  });

  final String title;
  final Map<String, int> values;

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    return SizedBox(
      width: 260,
      child: _StatsPanel(
        title: title,
        child: entries.isEmpty
            ? const Text('-', style: TextStyle(color: _kClzTextMuted))
            : Column(
                children: [
                  for (final entry in entries.take(4))
                    _DistributionRow(
                      label: entry.key,
                      count: entry.value,
                      fraction: total == 0 ? 0 : entry.value / total,
                    ),
                ],
              ),
      ),
    );
  }
}

class _StatsRankedCard extends StatelessWidget {
  const _StatsRankedCard({required this.title, required this.values});

  final String title;
  final Map<String, int> values;

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    return _StatsPanel(
      title: title,
      child: entries.isEmpty
          ? const Text('-', style: TextStyle(color: _kClzTextMuted))
          : Column(
              children: [
                for (final entry in entries.take(5))
                  _DistributionRow(
                    label: entry.key,
                    count: entry.value,
                    fraction: total == 0 ? 0 : entry.value / total,
                  ),
              ],
            ),
    );
  }
}

class _StatsHealthCard extends StatelessWidget {
  const _StatsHealthCard({required this.title, required this.rows});

  final String title;
  final List<_StatsHealthRow> rows;

  @override
  Widget build(BuildContext context) {
    return _StatsPanel(
      title: title,
      child: Column(
        children: [
          for (final row in rows)
            _DistributionRow(
              label: row.label,
              count: (row.fraction * 100).round(),
              fraction: row.fraction,
            ),
        ],
      ),
    );
  }
}

class _StatsHealthRow {
  const _StatsHealthRow({
    required this.label,
    required this.fraction,
  });

  final String label;
  final double fraction;
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kClzPanel,
        border: Border.all(color: const Color(0xFF383838)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _kClzAccent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.label,
    required this.count,
    required this.fraction,
  });

  final String label;
  final int count;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fraction.clamp(0, 1),
                minHeight: 7,
                backgroundColor: const Color(0xFF151515),
                valueColor: const AlwaysStoppedAnimation(_kClzAccent),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              count.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _kClzTextMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingIssuesCard extends StatelessWidget {
  const _MissingIssuesCard({
    required this.selectedSeries,
    required this.missingIssues,
  });

  final String? selectedSeries;
  final List<int> missingIssues;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: _StatsPanel(
        title: selectedSeries == null ? 'Series gaps' : 'Gaps: $selectedSeries',
        child: selectedSeries == null
            ? const Text(
                'Select a series',
                style: TextStyle(color: _kClzTextMuted, fontSize: 12),
              )
            : missingIssues.isEmpty
                ? const Text(
                    'No gaps',
                    style: TextStyle(color: _kClzTextMuted, fontSize: 12),
                  )
                : Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      for (final issue in missingIssues.take(10))
                        _MissingIssuePill(issue: issue),
                      if (missingIssues.length > 10)
                        _MissingIssuePill(
                          issue: missingIssues.length - 10,
                          more: true,
                        ),
                    ],
                  ),
      ),
    );
  }
}

class _MissingIssuePill extends StatelessWidget {
  const _MissingIssuePill({required this.issue, this.more = false});

  final int issue;
  final bool more;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        border: Border.all(color: _kClzAccent),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          more ? '+$issue' : '#$issue',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

Map<String, int> _topSeriesCounts(List<ShelfEntry> entries) {
  return _countBy(entries, (entry) => entry.catalogItem?.title ?? 'Missing');
}

Map<String, int> _topPublisherCounts(List<ShelfEntry> entries) {
  return _countBy(
    entries,
    (entry) => entry.catalogItem?.publisher ?? 'Unknown',
  );
}

Map<String, int> _countBy(
  Iterable<ShelfEntry> entries,
  String Function(ShelfEntry entry) keyFor,
) {
  final counts = <String, int>{};
  for (final entry in entries) {
    final key = _ifEmpty(keyFor(entry).trim(), 'Unknown');
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

int missingComicsMetadataCount(List<ShelfEntry> entries) {
  var count = 0;
  for (final entry in entries) {
    final item = entry.catalogItem;
    if (item == null ||
        item.displayCoverUrl == null ||
        item.publisher == null ||
        item.releaseDate == null ||
        item.synopsis == null) {
      count++;
    }
  }
  return count;
}

String _formatOptionalMoney(int? cents, String? currency) {
  if (cents == null) {
    return '';
  }
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  final prefix = currency == null || currency.isEmpty ? '' : '$currency ';
  return '$prefix$sign$whole.$fraction';
}

String _ifEmpty(String value, String fallback) {
  return value.isEmpty ? fallback : value;
}
