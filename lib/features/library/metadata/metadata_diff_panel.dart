import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_summary_widgets.dart';
import 'package:flutter/material.dart';

class MetadataDiffEntry {
  const MetadataDiffEntry({
    required this.label,
    required this.localValue,
    required this.serverValue,
    this.onAccept,
  });

  final String label;
  final String localValue;
  final String serverValue;
  final VoidCallback? onAccept;

  bool get isDifferent => localValue.trim() != serverValue.trim();
}

/// One section of the Core comparison as a table: each field on one row
/// with your value beside Core's, differing rows marked.
class MetadataDiffPanel extends StatelessWidget {
  const MetadataDiffPanel({
    super.key,
    required this.title,
    required this.entries,
    this.onAcceptAll,
    this.emptyText = 'No differences found.',
    this.showOnlyDifferences = true,
  });

  final String title;
  final List<MetadataDiffEntry> entries;
  final VoidCallback? onAcceptAll;
  final String emptyText;
  final bool showOnlyDifferences;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final visible = showOnlyDifferences
        ? entries.where((entry) => entry.isDifferent).toList()
        : entries;
    final differences = entries.where((entry) => entry.isDifferent).length;
    final canAccept = visible.any((entry) => entry.onAccept != null);
    final header = TextStyle(
        color: palette.textMuted, fontSize: 13, fontWeight: FontWeight.w700);
    TableRow row(int index, MetadataDiffEntry entry) {
      final different = entry.isDifferent;
      final value = TextStyle(
        color: palette.textPrimary,
        fontSize: 14,
        fontWeight: different ? FontWeight.w700 : FontWeight.w400,
      );
      Widget cell(Widget child) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: child,
          );
      return TableRow(
        key: ValueKey('metadata-diff-${entry.label}'),
        decoration: BoxDecoration(
          color: index.isEven ? palette.tableEvenRow : palette.tableOddRow,
          border: Border(
            left: BorderSide(
              width: 3,
              color: different ? palette.difference : Colors.transparent,
            ),
          ),
        ),
        children: [
          cell(Text(entry.label,
              style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700))),
          cell(SelectableText(_shown(entry.localValue), style: value)),
          cell(SelectableText(_shown(entry.serverValue),
              style: different ? value.copyWith(color: palette.link) : value)),
          if (canAccept)
            entry.onAccept == null || !different
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Use the Core value',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.arrow_back, size: 16, color: palette.link),
                    onPressed: entry.onAccept,
                  ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      color: palette.link,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                differences == 0
                    ? 'Same as Core'
                    : '$differences ${differences == 1 ? 'difference' : 'differences'}',
                style: TextStyle(
                    color: differences == 0
                        ? palette.textMuted
                        : palette.difference,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
              if (onAcceptAll != null && differences > 0)
                TextButton.icon(
                  onPressed: onAcceptAll,
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text('Use all Core values'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (visible.isEmpty)
            Text(emptyText, style: TextStyle(color: palette.textMuted))
          else
            Table(
              columnWidths: {
                0: const FixedColumnWidth(170),
                1: const FlexColumnWidth(),
                2: const FlexColumnWidth(),
                if (canAccept) 3: const FixedColumnWidth(40),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: palette.divider)),
                  ),
                  children: [
                    for (final label in ['Field', 'Your value', 'Core value'])
                      Padding(
                        padding: const EdgeInsets.fromLTRB(11, 4, 8, 4),
                        child: Text(label, style: header),
                      ),
                    if (canAccept) const SizedBox.shrink(),
                  ],
                ),
                for (var i = 0; i < visible.length; i++) row(i, visible[i]),
              ],
            ),
        ],
      ),
    );
  }
}

String _shown(String value) => value.trim().isEmpty ? '—' : value;

String formatDiffText(String? value) {
  final normalized = value?.trim() ?? '';
  return normalized.isEmpty ? '—' : normalized;
}

String formatDiffDate(DateTime? value) =>
    value == null ? '—' : formatDate(value);

String formatDiffList(Iterable<String>? values) {
  if (values == null) {
    return '—';
  }
  final normalized = values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  return normalized.isEmpty ? '—' : normalized.join(', ');
}
