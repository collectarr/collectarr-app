import 'dart:convert';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Supported export formats for collection integration.
enum ExportFormat {
  csv('CSV', 'Spreadsheet-compatible', Icons.table_chart_outlined),
  json('JSON', 'Structured data for APIs', Icons.data_object),
  xml('XML', 'For CLZ/legacy import', Icons.code),
  markdown('Markdown', 'Readable checklist', Icons.text_snippet_outlined);

  const ExportFormat(this.label, this.description, this.icon);
  final String label;
  final String description;
  final IconData icon;
}

/// Shows an export dialog with multiple format options.
Future<void> showIntegrationExportDialog({
  required BuildContext context,
  required LibraryTypeConfig type,
  required ShelfState shelfState,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _IntegrationExportDialog(
      type: type,
      shelfState: shelfState,
    ),
  );
}

class _IntegrationExportDialog extends StatelessWidget {
  const _IntegrationExportDialog({
    required this.type,
    required this.shelfState,
  });

  final LibraryTypeConfig type;
  final ShelfState shelfState;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AlertDialog(
      backgroundColor: palette.panel,
      title: const Row(
        children: [
          Icon(Icons.upload_outlined, size: 22),
          SizedBox(width: 8),
          Text('Export Collection'),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${shelfState.entries.length} items in ${type.workspace.title}',
              style: TextStyle(color: palette.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            for (final format in ExportFormat.values) ...[
              _ExportFormatTile(
                format: format,
                onTap: () => _export(context, format),
              ),
              if (format != ExportFormat.values.last)
                const SizedBox(height: 8),
            ],
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

  void _export(BuildContext context, ExportFormat format) {
    final data = switch (format) {
      ExportFormat.csv => _toCsv(),
      ExportFormat.json => _toJson(),
      ExportFormat.xml => _toXml(),
      ExportFormat.markdown => _toMarkdown(),
    };
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied ${format.label} to clipboard')),
    );
    Navigator.pop(context);
  }

  String _toCsv() {
    final buffer = StringBuffer();
    buffer.writeln('Title,Issue,Series,Publisher,Barcode,Condition,Grade');
    for (final entry in shelfState.entries) {
      final cat = entry.catalogItem;
      final own = entry.ownedItem;
      final series = cat?.series;
      buffer.writeln([
        _escapeCsv(entry.title),
        _escapeCsv(cat?.itemNumber ?? ''),
        _escapeCsv(series?.seriesTitle ?? ''),
        _escapeCsv(cat?.publisher ?? ''),
        _escapeCsv(cat?.barcode ?? ''),
        _escapeCsv(own?.condition ?? ''),
        _escapeCsv(own?.grade ?? ''),
      ].join(','));
    }
    return buffer.toString();
  }

  String _toJson() {
    final items = shelfState.entries
        .map((e) {
          final cat = e.catalogItem;
          final own = e.ownedItem;
          final series = cat?.series;
          return {
            'title': e.title,
            if (cat?.itemNumber != null) 'issue': cat!.itemNumber,
            if (series?.seriesTitle != null) 'series': series!.seriesTitle,
            if (cat?.publisher != null) 'publisher': cat!.publisher,
            if (cat?.barcode != null) 'barcode': cat!.barcode,
            if (own?.condition != null) 'condition': own!.condition,
            if (own?.grade != null) 'grade': own!.grade,
            if (cat?.releaseYear != null) 'year': cat!.releaseYear,
          };
        })
        .toList();
    return const JsonEncoder.withIndent('  ').convert({
      'collection': type.workspace.title,
      'exported_at': DateTime.now().toIso8601String(),
      'item_count': items.length,
      'items': items,
    });
  }

  String _toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<collection name="${_escapeXml(type.workspace.title)}" count="${shelfState.entries.length}">');
    for (final entry in shelfState.entries) {
      final cat = entry.catalogItem;
      final own = entry.ownedItem;
      final series = cat?.series;
      buffer.writeln('  <item>');
      buffer.writeln('    <title>${_escapeXml(entry.title)}</title>');
      if (cat?.itemNumber != null) {
        buffer.writeln('    <issue>${_escapeXml(cat!.itemNumber!)}</issue>');
      }
      if (series?.seriesTitle != null) {
        buffer.writeln('    <series>${_escapeXml(series!.seriesTitle!)}</series>');
      }
      if (cat?.publisher != null) {
        buffer.writeln('    <publisher>${_escapeXml(cat!.publisher!)}</publisher>');
      }
      if (cat?.barcode != null) {
        buffer.writeln('    <barcode>${_escapeXml(cat!.barcode!)}</barcode>');
      }
      if (own?.condition != null) {
        buffer.writeln('    <condition>${_escapeXml(own!.condition!)}</condition>');
      }
      buffer.writeln('  </item>');
    }
    buffer.writeln('</collection>');
    return buffer.toString();
  }

  String _toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# ${type.workspace.title}');
    buffer.writeln('');
    buffer.writeln('**${shelfState.entries.length} items**');
    buffer.writeln('');
    for (final entry in shelfState.entries) {
      final cat = entry.catalogItem;
      final series = cat?.series;
      final parts = <String>[entry.title];
      if (cat?.itemNumber != null) parts.add('#${cat!.itemNumber!}');
      if (series?.seriesTitle != null) parts.add('(${series!.seriesTitle!})');
      buffer.writeln('- [ ] ${parts.join(' ')}');
    }
    return buffer.toString();
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _escapeXml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

class _ExportFormatTile extends StatelessWidget {
  const _ExportFormatTile({required this.format, required this.onTap});

  final ExportFormat format;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(format.icon, size: 20, color: kAppAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(format.label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(format.description,
                        style:
                            TextStyle(fontSize: 11, color: palette.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.copy, size: 16, color: palette.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
