import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:flutter/material.dart';

class PullListResultsPane extends StatelessWidget {
  const PullListResultsPane({
    super.key,
    required this.rows,
    required this.onSearchRow,
  });

  final List<PullListCandidate> rows;
  final ValueChanged<PullListCandidate> onSearchRow;

  @override
  Widget build(BuildContext context) {
    final visibleRows = rows.isEmpty ? _pullListPlaceholderRows : rows;
    return ColoredBox(
      color: const Color(0xFF2E2E2E),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: const BoxDecoration(
              color: Color(0xFF252525),
              border: Border(bottom: BorderSide(color: Color(0xFF444444))),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFF18B7EB), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Local Pull List',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                LibraryAddResultBadge(
                  rows.isEmpty
                      ? 'needs local shelf'
                      : '${rows.length} suggestion${rows.length == 1 ? '' : 's'}',
                ),
              ],
            ),
          ),
          const _PullListPreviewHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: visibleRows.length,
              itemBuilder: (context, index) {
                final row = visibleRows[index];
                return _PullListPreviewRow(
                  row: row,
                  onSearch: rows.isEmpty ? null : () => onSearchRow(row),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              rows.isEmpty
                  ? 'Add a few owned or wishlist comics first. Pull List will use local series and wishlist gaps to search Collectarr Core for likely next issues.'
                  : 'Pull List is generated from the local shelf only. Use Search Core on a row to query server metadata for that next issue.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFCCCCCC)),
            ),
          ),
        ],
      ),
    );
  }
}

class PullListCandidate {
  const PullListCandidate({
    required this.series,
    required this.issue,
    required this.release,
    required this.status,
    this.publisher,
  });

  final String series;
  final String issue;
  final String release;
  final String status;
  final String? publisher;
}

List<PullListCandidate> pullListCandidates(ShelfState? shelf) {
  final entries = shelf?.entries ?? const <ShelfEntry>[];
  final bySeries = <String, List<ShelfEntry>>{};
  for (final entry in entries) {
    final item = entry.catalogItem;
    if (item == null || (!entry.isOwned && !entry.isWishlisted)) {
      continue;
    }
    bySeries.putIfAbsent(item.title, () => []).add(entry);
  }
  final rows = <PullListCandidate>[];
  for (final group in bySeries.entries) {
    final numbered = [
      for (final entry in group.value)
        if (_issueNumberSortValue(entry.catalogItem?.itemNumber) != null)
          (
            entry: entry,
            number: _issueNumberSortValue(entry.catalogItem?.itemNumber)!,
          ),
    ]..sort((a, b) => a.number.compareTo(b.number));
    if (numbered.isEmpty) {
      continue;
    }
    final last = numbered.last;
    final nextIssue = _formatIssueNumber(last.number + 1);
    final publisher = last.entry.catalogItem?.publisher;
    rows.add(
      PullListCandidate(
        series: group.key,
        issue: nextIssue,
        release: publisher ?? 'Collectarr Core',
        status: group.value.any((entry) => entry.isWishlisted)
            ? 'wishlist gap'
            : 'next issue',
        publisher: publisher,
      ),
    );
  }
  rows.sort((a, b) => a.series.toLowerCase().compareTo(b.series.toLowerCase()));
  return rows.take(25).toList(growable: false);
}

const _pullListPlaceholderRows = [
  PullListCandidate(
    series: 'Watched series',
    issue: 'next',
    release: 'local shelf',
    status: 'waiting',
  ),
  PullListCandidate(
    series: 'Wishlist gaps',
    issue: 'missing',
    release: 'Collectarr Core',
    status: 'planned',
  ),
  PullListCandidate(
    series: 'New releases',
    issue: 'weekly',
    release: 'ComicVine',
    status: 'planned',
  ),
];

class _PullListPreviewHeader extends StatelessWidget {
  const _PullListPreviewHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: const Color(0xFF383838),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: const Row(
        children: [
          Expanded(flex: 4, child: Text('Series')),
          Expanded(flex: 2, child: Text('Issue')),
          Expanded(flex: 3, child: Text('Release')),
          Expanded(flex: 3, child: Text('Status')),
          SizedBox(width: 96, child: Text('Action')),
        ],
      ),
    );
  }
}

class _PullListPreviewRow extends StatelessWidget {
  const _PullListPreviewRow({
    required this.row,
    required this.onSearch,
  });

  final PullListCandidate row;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF3B3B3B))),
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(row.series)),
          Expanded(flex: 2, child: Text('#${row.issue}')),
          Expanded(flex: 3, child: Text(row.release)),
          Expanded(
            flex: 3,
            child: Text(
              row.status,
              style: const TextStyle(color: Color(0xFFBFEFFF)),
            ),
          ),
          SizedBox(
            width: 96,
            child: OutlinedButton(
              onPressed: onSearch,
              child: const Text('Search Core'),
            ),
          ),
        ],
      ),
    );
  }
}

double? _issueNumberSortValue(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final match = RegExp(r'^\s*(\d+(?:\.\d+)?)').firstMatch(value);
  return match == null ? null : double.tryParse(match.group(1)!);
}

String _formatIssueNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}
