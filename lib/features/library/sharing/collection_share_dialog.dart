import 'dart:convert';

import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

/// Shows a dialog to share the current collection view.
/// Offers: copy as text list, copy as CSV, export as CSV file.
Future<void> showCollectionShareDialog({
  required BuildContext context,
  required String title,
  required List<LibraryWorkspaceEntry> items,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _CollectionShareDialog(title: title, items: items),
  );
}

class _CollectionShareDialog extends StatelessWidget {
  const _CollectionShareDialog({
    required this.title,
    required this.items,
  });

  final String title;
  final List<LibraryWorkspaceEntry> items;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kClzPanel,
      title: Row(
        children: [
          const Icon(Icons.share, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text('Share "$title"')),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${items.length} items in current view',
              style: TextStyle(color: kClzTextMuted),
            ),
            const SizedBox(height: 16),
            _ShareOption(
              icon: Icons.list_alt,
              label: 'Copy as text list',
              subtitle: 'Plain text with titles and issue numbers',
              onTap: () => _copyAsText(context),
            ),
            const SizedBox(height: 8),
            _ShareOption(
              icon: Icons.table_chart_outlined,
              label: 'Copy as CSV',
              subtitle: 'Spreadsheet-compatible format',
              onTap: () => _copyAsCsv(context),
            ),
            const SizedBox(height: 8),
            _ShareOption(
              icon: Icons.data_object,
              label: 'Copy as JSON',
              subtitle: 'Structured data for import/export',
              onTap: () => _copyAsJson(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _copyAsText(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln(title);
    buffer.writeln('─' * title.length);
    for (final item in items) {
      final series = item.series;
      final parts = <String>[item.title];
      if (item.itemNumber != null) parts.add('#${item.itemNumber}');
      if (series?.seriesTitle != null) parts.add('(${series!.seriesTitle})');
      buffer.writeln(parts.join(' '));
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied as text')),
    );
    Navigator.pop(context);
  }

  void _copyAsCsv(BuildContext context) {
    final rows = <List<String>>[
      ['Title', 'Issue', 'Series', 'Publisher', 'Condition', 'Barcode'],
      ...items.map((item) => [
            item.title,
            item.itemNumber ?? '',
        item.series?.seriesTitle ?? '',
            item.publisher ?? '',
            item.condition ?? '',
            item.barcode ?? '',
          ]),
    ];
    final csv = const CsvEncoder().convert(rows);
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied as CSV')),
    );
    Navigator.pop(context);
  }

  void _copyAsJson(BuildContext context) {
    final data = items
        .map((item) => {
              'title': item.title,
              if (item.itemNumber != null) 'issue': item.itemNumber,
              if (item.series?.seriesTitle != null)
                'series': item.series!.seriesTitle,
              if (item.publisher != null) 'publisher': item.publisher,
              if (item.condition != null) 'condition': item.condition,
              if (item.barcode != null) 'barcode': item.barcode,
            })
        .toList();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied as JSON')),
    );
    Navigator.pop(context);
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kClzPanelRaised,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: kClzAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style:
                            TextStyle(fontSize: 11, color: kClzTextMuted)),
                  ],
                ),
              ),
              Icon(Icons.copy, size: 16, color: kClzTextMuted),
            ],
          ),
        ),
      ),
    );
  }
}
