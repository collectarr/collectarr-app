import 'dart:convert';

import 'package:collectarr_app/features/collection/csv/collection_csv_codec.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/services.dart';

/// Supported export formats for collection integration.
enum ExportFormat {
  csv('CSV', 'Spreadsheet', Icons.table_chart_outlined),
  json('JSON', 'Structured data for APIs', Icons.data_object),
  xml('XML', 'For CLZ import', Icons.code),
  markdown('Markdown', 'Readable checklist', Icons.text_snippet_outlined);

  const ExportFormat(this.label, this.description, this.icon);
  final String label;
  final String description;
  final IconData icon;
}

/// Shows an export dialog with multiple format options.
Future<void> showIntegrationExportDialog({
  required BuildContext context,
  required LibraryKindRegistration type,
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

  final LibraryKindRegistration type;
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
              '${shelfState.entries.length} items in ${type.identity.title}',
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
    final data = switch (format) {
      ExportFormat.csv => _toCsv(type),
      ExportFormat.json => _toJson(),
      ExportFormat.xml => _toXml(),
      ExportFormat.markdown => _toMarkdown(type),
    };
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied ${format.label} to clipboard')),
    );
    Navigator.pop(context);
  }

  String _toCsv(LibraryKindRegistration module) {
    return CollectionCsvCodec().exportShelf(
      shelfState.entries,
    );
  }

  String _toJson() {
    final items = shelfState.entries
        .map(
          (entry) => {
            'id': entry.catalogRef?.id ?? entry.itemId,
            'kind': entry.mediaKind.apiValue,
            'title': entry.title,
            'owned': entry.isOwned,
            'wishlist': entry.isWishlisted,
            if (entry.isOwned) 'quantity': entry.quantity,
          },
        )
        .toList();
    return const JsonEncoder.withIndent('  ').convert({
      'collection': type.identity.title,
      'exported_at': DateTime.now().toIso8601String(),
      'item_count': items.length,
      'items': items,
    });
  }

  String _toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
        '<collection name="${_escapeXml(type.identity.title)}" count="${shelfState.entries.length}">');
    for (final entry in shelfState.entries) {
      buffer.writeln(
          '  <item id="${_escapeXml(entry.catalogRef?.id ?? entry.itemId)}" kind="${entry.mediaKind.apiValue}">');
      buffer.writeln('    <title>${_escapeXml(entry.title)}</title>');
      buffer.writeln('    <owned>${entry.isOwned}</owned>');
      buffer.writeln('    <wishlist>${entry.isWishlisted}</wishlist>');
      buffer.writeln('  </item>');
    }
    buffer.writeln('</collection>');
    return buffer.toString();
  }

  String _toMarkdown(LibraryKindRegistration module) {
    final buffer = StringBuffer();
    buffer.writeln('# ${type.identity.title}');
    buffer.writeln('');
    buffer.writeln('**${shelfState.entries.length} items**');
    buffer.writeln('');
    for (final entry in shelfState.entries) {
      final projection = libraryKindWorkspaceForKind(module.kind).project(
        source: entry,
        node: LibraryTitleNodeRef(
          titleItemId: entry.catalogRef?.id ?? entry.itemId,
        ),
      );
      final dto = projection.dto;
      final adapter = dto is WorkspaceDtoAdapter ? dto : null;
      final parts = <String>[entry.title];
      if (adapter?.itemNumber != null && adapter!.itemNumber!.isNotEmpty) {
        parts.add('#${adapter.itemNumber}');
      }
      if (adapter?.seriesTitle != null && adapter!.seriesTitle!.isNotEmpty) {
        parts.add('(${adapter.seriesTitle})');
      }
      buffer.writeln('- [ ] ${parts.join(' ')}');
    }
    return buffer.toString();
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
