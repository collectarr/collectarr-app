import 'dart:convert';

import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
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
    return AccentAlertDialog(
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
              if (format != ExportFormat.values.last) const SizedBox(height: 8),
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
    final module = libraryKindRuntimeForType(type);
    final data = switch (format) {
      ExportFormat.csv => _toCsv(module),
      ExportFormat.json => _toJson(module),
      ExportFormat.xml => _toXml(module),
      ExportFormat.markdown => _toMarkdown(module),
    };
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied ${format.label} to clipboard')),
    );
    Navigator.pop(context);
  }

  String _toCsv(LibraryKindRuntime module) {
    final buffer = StringBuffer();
    buffer.writeln('Title,Number,Series,Publisher,Barcode,Condition,Grade');
    for (final entry in shelfState.entries) {
      final projection = module.project(
        source: entry,
        node: LibraryTitleNodeRef(
          titleItemId: entry.catalogItem?.id ?? entry.itemId,
        ),
      );
      final dto = projection.dto;
      final own = entry.ownedItem;
      buffer.writeln([
        _escapeCsv(entry.title),
        _escapeCsv(dto.itemNumber ?? ''),
        _escapeCsv(dto.seriesTitle ?? ''),
        _escapeCsv(dto.publisher ?? ''),
        _escapeCsv(dto.barcode ?? ''),
        _escapeCsv(own?.condition ?? ''),
        _escapeCsv(own?.grade ?? ''),
      ].join(','));
    }
    return buffer.toString();
  }

  String _toJson(LibraryKindRuntime module) {
    final items = shelfState.entries.map((e) {
      final projection = module.project(
        source: e,
        node: LibraryTitleNodeRef(
          titleItemId: e.catalogItem?.id ?? e.itemId,
        ),
      );
      final dto = projection.dto;
      final cat = e.catalogItem;
      final own = e.ownedItem;
      return {
        'title': e.title,
        if (dto.itemNumber != null) 'number': dto.itemNumber,
        if (dto.seriesTitle != null) 'series': dto.seriesTitle,
        if (dto.publisher != null) 'publisher': dto.publisher,
        if (dto.barcode != null) 'barcode': dto.barcode,
        if (own?.condition != null) 'condition': own!.condition,
        if (own?.grade != null) 'grade': own!.grade,
        if (cat?.releaseYear != null) 'year': cat!.releaseYear,
      };
    }).toList();
    return const JsonEncoder.withIndent('  ').convert({
      'collection': type.workspace.title,
      'exported_at': DateTime.now().toIso8601String(),
      'item_count': items.length,
      'items': items,
    });
  }

  String _toXml(LibraryKindRuntime module) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
        '<collection name="${_escapeXml(type.workspace.title)}" count="${shelfState.entries.length}">');
    for (final entry in shelfState.entries) {
      final projection = module.project(
        source: entry,
        node: LibraryTitleNodeRef(
          titleItemId: entry.catalogItem?.id ?? entry.itemId,
        ),
      );
      final dto = projection.dto;
      final own = entry.ownedItem;
      buffer.writeln('  <item>');
      buffer.writeln('    <title>${_escapeXml(entry.title)}</title>');
      if (dto.itemNumber != null) {
        buffer.writeln('    <number>${_escapeXml(dto.itemNumber!)}</number>');
      }
      if (dto.seriesTitle != null) {
        buffer.writeln('    <series>${_escapeXml(dto.seriesTitle!)}</series>');
      }
      if (dto.publisher != null) {
        buffer.writeln(
            '    <publisher>${_escapeXml(dto.publisher!)}</publisher>');
      }
      if (dto.barcode != null) {
        buffer.writeln('    <barcode>${_escapeXml(dto.barcode!)}</barcode>');
      }
      if (own?.condition != null) {
        buffer.writeln(
            '    <condition>${_escapeXml(own!.condition!)}</condition>');
      }
      buffer.writeln('  </item>');
    }
    buffer.writeln('</collection>');
    return buffer.toString();
  }

  String _toMarkdown(LibraryKindRuntime module) {
    final buffer = StringBuffer();
    buffer.writeln('# ${type.workspace.title}');
    buffer.writeln('');
    buffer.writeln('**${shelfState.entries.length} items**');
    buffer.writeln('');
    for (final entry in shelfState.entries) {
      final projection = module.project(
        source: entry,
        node: LibraryTitleNodeRef(
          titleItemId: entry.catalogItem?.id ?? entry.itemId,
        ),
      );
      final dto = projection.dto;
      final parts = <String>[entry.title];
      if (dto.itemNumber != null && dto.itemNumber!.isNotEmpty) {
        parts.add('#${dto.itemNumber}');
      }
      if (dto.seriesTitle != null && dto.seriesTitle!.isNotEmpty) {
        parts.add('(${dto.seriesTitle})');
      }
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
