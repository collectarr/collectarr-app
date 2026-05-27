import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:file_selector/file_selector.dart';

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
      backgroundColor: kAppPanel,
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
              style: TextStyle(color: kAppTextMuted),
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
              icon: Icons.save_alt,
              label: 'Save CSV to file',
              subtitle: 'Save spreadsheet file to documents',
              onTap: () => _saveCsvToFile(context),
            ),
            const SizedBox(height: 8),
            _ShareOption(
              icon: Icons.data_object,
              label: 'Copy as JSON',
              subtitle: 'Structured data for import/export',
              onTap: () => _copyAsJson(context),
            ),
            const SizedBox(height: 8),
            _ShareOption(
              icon: Icons.save_alt,
              label: 'Save JSON to file',
              subtitle: 'Save structured data file to documents',
              onTap: () => _saveJsonToFile(context),
            ),
            const SizedBox(height: 8),
            _ShareOption(
              icon: Icons.language,
              label: 'Export as HTML page',
              subtitle: 'Self-contained web page you can host or share',
              onTap: () => _exportAsHtml(context),
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

  Future<void> _saveCsvToFile(BuildContext context) async {
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
    await _saveToFile(context, csv, 'csv');
  }

  Future<void> _saveJsonToFile(BuildContext context) async {
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
    await _saveToFile(context, json, 'json');
  }

  Future<void> _saveToFile(
      BuildContext context, String content, String ext) async {
    try {
      final safeTitle = title.replaceAll(RegExp(r'[^\w\s]'), '').trim();
      final fileName = '${safeTitle}_collection.$ext';
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          XTypeGroup(label: ext.toUpperCase(), extensions: [ext]),
        ],
      );
      if (location == null) return;
      final file = File(location.path);
      await file.writeAsString(content);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${file.path}')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  Future<void> _exportAsHtml(BuildContext context) async {
    final escapedTitle = _htmlEscape(title);
    final rows = StringBuffer();
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      rows.writeln('<tr>');
      rows.writeln('  <td>${i + 1}</td>');
      rows.writeln('  <td>${_htmlEscape(item.title)}</td>');
      rows.writeln('  <td>${_htmlEscape(item.itemNumber ?? '')}</td>');
      rows.writeln('  <td>${_htmlEscape(item.series?.seriesTitle ?? '')}</td>');
      rows.writeln('  <td>${_htmlEscape(item.publisher ?? '')}</td>');
      rows.writeln('  <td>${_htmlEscape(item.condition ?? '')}</td>');
      rows.writeln('</tr>');
    }
    final html = '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$escapedTitle</title>
<style>
  body { font-family: system-ui, -apple-system, sans-serif; margin: 2rem; background: #1a1a2e; color: #e0e0e0; }
  h1 { color: #e94560; margin-bottom: 0.25rem; }
  .count { color: #8888aa; margin-bottom: 1.5rem; }
  table { width: 100%; border-collapse: collapse; }
  th, td { padding: 8px 12px; text-align: left; border-bottom: 1px solid #333; }
  th { background: #16213e; color: #e94560; font-weight: 600; position: sticky; top: 0; }
  tr:hover { background: #16213e; }
  footer { margin-top: 2rem; color: #555; font-size: 0.85rem; }
</style>
</head>
<body>
<h1>$escapedTitle</h1>
<p class="count">${items.length} items</p>
<table>
<thead><tr><th>#</th><th>Title</th><th>Issue</th><th>Series</th><th>Publisher</th><th>Condition</th></tr></thead>
<tbody>
${rows.toString()}</tbody>
</table>
<footer>Exported from Collectarr</footer>
</body>
</html>''';

    try {
      final safeTitle = title.replaceAll(RegExp(r'[^\w\s]'), '').trim();
      final fileName = '${safeTitle}_collection.html';
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          const XTypeGroup(label: 'HTML', extensions: ['html']),
        ],
      );
      if (location == null) return;
      final file = File(location.path);
      await file.writeAsString(html);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${file.path}')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  static String _htmlEscape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
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
      color: kAppPanelRaised,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: kAppAccent),
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
                            TextStyle(fontSize: 11, color: kAppTextMuted)),
                  ],
                ),
              ),
              Icon(Icons.copy, size: 16, color: kAppTextMuted),
            ],
          ),
        ),
      ),
    );
  }
}
