import 'package:collectarr_app/features/comics/stats/comics_stats_style.dart';
import 'package:flutter/material.dart';

class ComicsStatsTile extends StatelessWidget {
  const ComicsStatsTile({
    super.key,
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
        color: kComicsStatsPanel,
        border: Border.all(color: kComicsStatsPanelBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kComicsStatsAccent),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: kComicsStatsTextMuted,
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

class ComicsStatsDistributionCard extends StatelessWidget {
  const ComicsStatsDistributionCard({
    super.key,
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
      width: kComicsStatsCardWidth,
      child: _StatsPanel(
        title: title,
        child: entries.isEmpty
            ? const Text('-', style: TextStyle(color: kComicsStatsTextMuted))
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

class ComicsStatsRankedCard extends StatelessWidget {
  const ComicsStatsRankedCard({
    super.key,
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
    return _StatsPanel(
      title: title,
      child: entries.isEmpty
          ? const Text('-', style: TextStyle(color: kComicsStatsTextMuted))
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

class ComicsStatsHealthCard extends StatelessWidget {
  const ComicsStatsHealthCard({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<ComicsStatsHealthRow> rows;

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

class ComicsStatsHealthRow {
  const ComicsStatsHealthRow({
    required this.label,
    required this.fraction,
  });

  final String label;
  final double fraction;
}

class ComicsMissingIssuesCard extends StatelessWidget {
  const ComicsMissingIssuesCard({
    super.key,
    required this.selectedSeries,
    required this.missingIssues,
  });

  final String? selectedSeries;
  final List<int> missingIssues;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kComicsStatsCardWidth,
      child: _StatsPanel(
        title: selectedSeries == null ? 'Series gaps' : 'Gaps: $selectedSeries',
        child: selectedSeries == null
            ? const Text(
                'Select a series',
                style: TextStyle(color: kComicsStatsTextMuted, fontSize: 12),
              )
            : missingIssues.isEmpty
                ? const Text(
                    'No gaps',
                    style:
                        TextStyle(color: kComicsStatsTextMuted, fontSize: 12),
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

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kComicsStatsPanel,
        border: Border.all(color: kComicsStatsPanelBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kComicsStatsAccent,
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
                value: fraction.clamp(0, 1).toDouble(),
                minHeight: 7,
                backgroundColor: kComicsStatsMeterBackground,
                valueColor: const AlwaysStoppedAnimation(kComicsStatsAccent),
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
                color: kComicsStatsTextMuted,
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

class _MissingIssuePill extends StatelessWidget {
  const _MissingIssuePill({required this.issue, this.more = false});

  final int issue;
  final bool more;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kComicsStatsMeterBackground,
        border: Border.all(color: kComicsStatsAccent),
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
