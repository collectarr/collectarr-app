import 'package:collectarr_app/ui/app_management_content.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/platform/save_export_file.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/library_xml_export.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LibraryExportXmlPage extends StatefulWidget {
  const LibraryExportXmlPage(
      {super.key,
      required this.type,
      required this.database,
      required this.entries});
  final LibraryKindRegistration type;
  final LocalDatabase database;
  final List<LibraryEntryRef> entries;
  @override
  State<LibraryExportXmlPage> createState() => _LibraryExportXmlPageState();
}

class _LibraryExportXmlPageState extends State<LibraryExportXmlPage> {
  late final Future<String> _xml = LibraryEntryStore(widget.database)
      .findByRefs(widget.entries)
      .then((records) => encodeLibraryEntriesXml([
            for (final ref in widget.entries)
              if (records[ref] case final record?) record
          ]));
  bool _saving = false;
  Future<void> _save(String xml) async {
    setState(() => _saving = true);
    try {
      await saveExportText(
          filename: 'collectarr-${widget.type.kind.apiValue}.xml',
          content: xml,
          mimeType: 'application/xml');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Scaffold(
      backgroundColor: palette.surface,
      appBar: const AppPageHeader(
          title: Text('Export to XML'), icon: Icons.file_download_outlined),
      body: AppManagementContent(
          child: FutureBuilder<String>(
              future: _xml,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Export failed: ${snapshot.error}'));
                }
                final xml = snapshot.data;
                if (xml == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${widget.entries.length} selected ${widget.type.identity.pluralLabel.toLowerCase()}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    FilledButton.icon(
                                        onPressed:
                                            _saving ? null : () => _save(xml),
                                        icon: const Icon(Icons.download,
                                            size: 16),
                                        label: Text(_saving
                                            ? 'Saving...'
                                            : 'Download XML')),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                        onPressed: () async {
                                          await Clipboard.setData(
                                              ClipboardData(text: xml));
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content:
                                                        Text('XML copied')));
                                          }
                                        },
                                        icon: const Icon(Icons.copy, size: 16),
                                        label: const Text('Copy'))
                                  ]),
                                  const SizedBox(height: 16),
                                  Expanded(
                                      child: SingleChildScrollView(
                                          child: SelectableText(xml,
                                              style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 12,
                                                  color:
                                                      palette.textPrimary)))),
                                ]))));
              })),
    );
  }
}
