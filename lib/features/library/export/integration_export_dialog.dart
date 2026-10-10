import 'dart:convert';
import 'package:collectarr_app/core/platform/save_export_file.dart';

import 'package:collectarr_app/features/collection/csv/collection_csv_codec.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/services.dart';

/// Supported export formats for collection integration.
enum ExportFormat {
  csv('CSV', 'Spreadsheet', Icons.table_chart_outlined),
  json('JSON', 'Structured data for APIs', Icons.data_object),
  xml('XML', 'Structured collection export', Icons.code),
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
  ExportFormat? format,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _IntegrationExportDialog(
      type: type,
      shelfState: shelfState,
      format: format,
    ),
  );
}

class _IntegrationExportDialog extends ConsumerWidget {
  const _IntegrationExportDialog({
    required this.type,
    required this.shelfState,
    this.format,
  });

  final LibraryKindRegistration type;
  final ShelfState shelfState;
  final ExportFormat? format;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            for (final format
                in format == null ? ExportFormat.values : [format!]) ...[
              _ExportFormatTile(
                format: format,
                onTap: () => _export(context, ref, format),
              ),
              if (format != ExportFormat.values.last) const SizedBox(height: 8),
            ],
            if (format == ExportFormat.xml)
              FilledButton.icon(
                onPressed: () async {
                  final saved = await saveExportText(
                      filename: '${type.kind.apiValue}.xml',
                      content: _toXml(),
                      mimeType: 'application/xml');
                  if (saved && context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.download),
                label: const Text('Download XML'),
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

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    ExportFormat format,
  ) async {
    final entryRecordsByRef = await LibraryEntryStore(
      ref.read(localDatabaseProvider),
    ).findByRefs(
      shelfState.entries
          .map((entry) => entry.libraryEntryRef)
          .whereType<LibraryEntryRef>(),
    );
    if (!context.mounted) return;
    final data = switch (format) {
      ExportFormat.csv => _toCsv(entryRecordsByRef),
      ExportFormat.json => _toJson(),
      ExportFormat.xml => _toXml(),
      ExportFormat.markdown => _toMarkdown(type),
    };
    await Clipboard.setData(ClipboardData(text: data));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied ${format.label} to clipboard')),
    );
    Navigator.pop(context);
  }

  String _toCsv(Map<LibraryEntryRef, LibraryEntryRecord> entryRecordsByRef) {
    return CollectionCsvCodec(profiles: collectionCsvKindProfiles).exportShelf(
      shelfState.entries,
      entryRecordsByRef: entryRecordsByRef,
    );
  }

  String _toJson() {
    final items = shelfState.entries
        .map(
          (entry) => {
            'id': entry.target.id,
            'ref': entry.target.stableKey,
            'kind': entry.mediaKind.apiValue,
            'title': entry.title,
            'entry': entry.isEntry,
            'wishlist': entry.isWishlisted,
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
          '  <item id="${_escapeXml(entry.target.id)}" ref="${_escapeXml(entry.target.stableKey)}" kind="${entry.mediaKind.apiValue}">');
      buffer.writeln('    <title>${_escapeXml(entry.title)}</title>');
      buffer.writeln('    <entry>${entry.isEntry}</entry>');
      buffer.writeln('    <wishlist>${entry.isWishlisted}</wishlist>');
      buffer.writeln('  </item>');
    }
    buffer.writeln('</collection>');
    return buffer.toString();
  }

  String _toMarkdown(LibraryKindRegistration registration) {
    final buffer = StringBuffer();
    buffer.writeln('# ${type.identity.title}');
    buffer.writeln('');
    buffer.writeln('**${shelfState.entries.length} items**');
    buffer.writeln('');
    for (final entry in shelfState.entries) {
      final projection = libraryKindWorkspaceForKind(registration.kind).project(
        source: entry,
      );
      final card = libraryCardPresentationForEntry(
        LibraryProjectionItem(
          source: entry,
          dto: projection.dto,
        ),
      );
      final parts = <String>[entry.title];
      if (card.itemNumber != null && card.itemNumber!.isNotEmpty) {
        parts.add('#${card.itemNumber}');
      }
      if (card.seriesTitle != null && card.seriesTitle!.isNotEmpty) {
        parts.add('(${card.seriesTitle})');
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
        mouseCursor: WidgetStateMouseCursor.clickable,
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
                            TextStyle(fontSize: 12, color: palette.textMuted)),
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
