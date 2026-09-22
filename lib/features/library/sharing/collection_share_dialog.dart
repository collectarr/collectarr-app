import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/services.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:file_selector/file_selector.dart';

/// Shows a dialog to share the current collection view.
/// Offers: copy as text list, copy as CSV, export as CSV file.
Future<void> showCollectionShareDialog({
  required BuildContext context,
  required String title,
  required List<LibraryProjectionView> items,
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
  final List<LibraryProjectionView> items;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      titlePadding: EdgeInsets.zero,
      title: AccentDialogHeader(
        title: 'Share collection',
        accent: kAppAccent,
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Exporting ${items.length} items',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
            ),
            const SizedBox(height: 16),
            _ShareOption(
              icon: Icons.copy,
              label: 'Copy as plain text',
              onTap: () => _copyAsText(context),
            ),
            const SizedBox(height: 8),
            _ShareOption(
              icon: Icons.table_chart_outlined,
              label: 'Copy as CSV',
              onTap: () => _copyAsCsv(context),
            ),
            const SizedBox(height: 8),
            _ShareOption(
              icon: Icons.code,
              label: 'Copy as JSON',
              onTap: () => _copyAsJson(context),
            ),
            const SizedBox(height: 16),
            _ShareOption(
              icon: Icons.download,
              label: 'Save CSV file',
              onTap: () => _saveCsvToFile(context),
            ),
            const SizedBox(height: 8),
            _ShareOption(
              icon: Icons.download_for_offline,
              label: 'Save JSON file',
              onTap: () => _saveJsonToFile(context),
            ),
            const SizedBox(height: 8),
            _ShareOption(
              icon: Icons.html,
              label: 'Save HTML page',
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
      final ref = item.source.catalogRef;
      final reference = ref == null ? item.node.id : _referenceLabel(ref);
      buffer.writeln(
        '${item.dto.primaryLabel} [${item.source.mediaKind.apiValue}: $reference]',
      );
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied as text')),
    );
    Navigator.pop(context);
  }

  void _copyAsCsv(BuildContext context) {
    final rows = <List<String>>[
      _structuralHeaders,
      ...items.map(_structuralRow),
    ];
    final csv = const CsvWriter().write(rows);
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied as CSV')),
    );
    Navigator.pop(context);
  }

  void _copyAsJson(BuildContext context) {
    final data = items.map(_structuralJson).toList();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied as JSON')),
    );
    Navigator.pop(context);
  }

  Future<void> _saveCsvToFile(BuildContext context) async {
    final rows = <List<String>>[
      _structuralHeaders,
      ...items.map(_structuralRow),
    ];
    final csv = const CsvWriter().write(rows);
    await _saveToFile(context, csv, 'csv');
  }

  Future<void> _saveJsonToFile(BuildContext context) async {
    final data = items.map(_structuralJson).toList();
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
      for (final value in _structuralRow(item)) {
        rows.writeln('  <td>${_htmlEscape(value)}</td>');
      }
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
<thead><tr><th>#</th><th>Title</th><th>Kind</th><th>Reference</th><th>Owned</th><th>Wishlist</th><th>Quantity</th><th>Location</th></tr></thead>
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

  static const _structuralHeaders = <String>[
    'Title',
    'Kind',
    'Reference',
    'Owned',
    'Wishlist',
    'Quantity',
    'Location',
  ];

  List<String> _structuralRow(LibraryProjectionView item) {
    final ref = item.source.catalogRef;
    return [
      item.dto.primaryLabel,
      item.source.mediaKind.apiValue,
      ref == null ? item.node.id : _referenceLabel(ref),
      item.source.isOwned.toString(),
      item.source.isWishlisted.toString(),
      item.source.quantity.toString(),
      item.source.locationPath ?? '',
    ];
  }

  Map<String, Object?> _structuralJson(LibraryProjectionView item) {
    final ref = item.source.catalogRef;
    return {
      'title': item.dto.primaryLabel,
      'kind': item.source.mediaKind.apiValue,
      'reference': ref?.toJson() ?? item.node.id,
      'owned': item.source.isOwned,
      'wishlist': item.source.isWishlisted,
      'quantity': item.source.quantity,
      if (item.source.locationPath case final location?) 'location': location,
    };
  }

  static String _referenceLabel(CatalogEntityRef ref) =>
      '${ref.kind.apiValue}:${ref.entityType.apiValue}:${ref.id}';

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
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Material(
      color: palette.panelRaised,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: kAppAccent),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
