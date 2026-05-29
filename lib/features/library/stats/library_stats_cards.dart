import 'package:collectarr_app/features/library/stats/library_stats_style.dart';
import 'package:flutter/material.dart';

class LibraryStatsTile extends StatelessWidget {
  const LibraryStatsTile({
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
    final colors = libraryStatsColors(context);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border.all(color: colors.panelBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.accent),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryStatsDistributionCard extends StatelessWidget {
  const LibraryStatsDistributionCard({
    super.key,
    required this.title,
    required this.values,
  });

  final String title;
  final Map<String, int> values;

  @override
  Widget build(BuildContext context) {
    final colors = libraryStatsColors(context);
    final entries = values.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    return SizedBox(
      width: kLibraryStatsCardWidth,
      child: _StatsPanel(
        title: title,
        child: entries.isEmpty
            ? Text('-', style: TextStyle(color: colors.textMuted))
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

class LibraryStatsRankedCard extends StatelessWidget {
  const LibraryStatsRankedCard({
    super.key,
    required this.title,
    required this.values,
  });

  final String title;
  final Map<String, int> values;

  @override
  Widget build(BuildContext context) {
    final colors = libraryStatsColors(context);
    final entries = values.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    return _StatsPanel(
      title: title,
      child: entries.isEmpty
          ? Text('-', style: TextStyle(color: colors.textMuted))
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

class LibraryStatsMoneyRankedCard extends StatelessWidget {
  const LibraryStatsMoneyRankedCard({
    super.key,
    required this.title,
    required this.values,
    required this.currency,
  });

  final String title;
  final Map<String, int> values;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    final colors = libraryStatsColors(context);
    final entries = values.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    return _StatsPanel(
      title: title,
      child: entries.isEmpty
          ? Text('-', style: TextStyle(color: colors.textMuted))
          : Column(
              children: [
                for (final entry in entries.take(5))
                  _MoneyDistributionRow(
                    label: entry.key,
                    cents: entry.value,
                    fraction: total == 0 ? 0 : entry.value / total,
                    currency: currency,
                  ),
              ],
            ),
    );
  }
}

class LibraryStatsHealthCard extends StatelessWidget {
  const LibraryStatsHealthCard({
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

class LibraryMissingIssuesCard extends StatelessWidget {
  const LibraryMissingIssuesCard({
    super.key,
    required this.selectedSeries,
    required this.missingIssues,
  });

  final String? selectedSeries;
  final List<int> missingIssues;

  @override
  Widget build(BuildContext context) {
    final colors = libraryStatsColors(context);
    return SizedBox(
      width: kLibraryStatsCardWidth,
      child: _StatsPanel(
        title: selectedSeries == null ? 'Series gaps' : 'Gaps: $selectedSeries',
        child: selectedSeries == null
            ? Text(
                'Select a series',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              )
            : missingIssues.isEmpty
                ? Text(
                    'No gaps',
                    style: TextStyle(color: colors.textMuted, fontSize: 12),
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

class LibraryMissingSequenceCard extends StatelessWidget {
  const LibraryMissingSequenceCard({
    super.key,
    required this.title,
    required this.selectedSeries,
    required this.missingValues,
    required this.valueLabelBuilder,
  });

  final String title;
  final String? selectedSeries;
  final List<int> missingValues;
  final String Function(int value) valueLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final colors = libraryStatsColors(context);
    return SizedBox(
      width: kLibraryStatsCardWidth,
      child: _StatsPanel(
        title: selectedSeries == null ? title : '$title: $selectedSeries',
        child: selectedSeries == null
            ? Text(
                'Select a series',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              )
            : missingValues.isEmpty
                ? Text(
                    'No gaps',
                    style: TextStyle(color: colors.textMuted, fontSize: 12),
                  )
                : Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      for (final value in missingValues.take(10))
                        _MissingSequencePill(label: valueLabelBuilder(value)),
                      if (missingValues.length > 10)
                        _MissingSequencePill(
                          label: '+${missingValues.length - 10} more',
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
    final colors = libraryStatsColors(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.panel,
        border: Border.all(color: colors.panelBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.accent,
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

class _MissingSequencePill extends StatelessWidget {
  const _MissingSequencePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = libraryStatsColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.pillBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.pillBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
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
    final colors = libraryStatsColors(context);
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
                style: TextStyle(
                color: colors.textPrimary,
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
                backgroundColor: colors.meterBackground,
                valueColor: AlwaysStoppedAnimation(colors.accent),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              count.toString(),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colors.textMuted,
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

class _MoneyDistributionRow extends StatelessWidget {
  const _MoneyDistributionRow({
    required this.label,
    required this.cents,
    required this.fraction,
    required this.currency,
  });

  final String label;
  final int cents;
  final double fraction;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    final colors = libraryStatsColors(context);
    final prefix = currency == null || currency!.isEmpty ? '' : '${currency!} ';
    final amount = '$prefix${(cents / 100).toStringAsFixed(2)}';
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
                style: TextStyle(
                color: colors.textPrimary,
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
                backgroundColor: colors.meterBackground,
                valueColor: AlwaysStoppedAnimation(colors.accent),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colors.textMuted,
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
    final colors = libraryStatsColors(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.meterBackground,
        border: Border.all(color: colors.accent),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          more ? '+$issue' : '#$issue',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
