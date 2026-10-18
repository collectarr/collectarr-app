import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/platform/save_export_file.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/library_xml_export.dart';
import 'package:collectarr_app/ui/app_message_dialog.dart';
import 'package:collectarr_app/ui/app_progress_dialog.dart';
import 'package:flutter/material.dart';

/// Confirms, then saves the complete local entries as XML, as the reference
/// does from the menu and the selection bar.
Future<void> exportLibraryEntriesXml({
  required BuildContext context,
  required LibraryKindRegistration type,
  required LocalDatabase database,
  required List<LibraryEntryRef> entries,
}) async {
  if (entries.isEmpty) return;
  final confirmed = await showAppMessageDialog(
      context: context,
      title: 'Export to XML',
      message: 'Click Export below to start exporting your data to XML',
      confirmLabel: 'Export');
  if (!confirmed || !context.mounted) return;
  try {
    final content = await runWithProgressDialog(
        context: context,
        title: 'Export to XML',
        message: 'Generating your XML file...',
        task: () async {
          final records = await LibraryEntryStore(database).findByRefs(entries);
          return encodeLibraryEntriesXml([
            for (final ref in entries)
              if (records[ref] case final record?) record
          ]);
        });
    if (!context.mounted) return;
    await showAppMessageDialog(
        context: context,
        title: 'XML file generated successfully.',
        message: 'Click Download below to download it to your computer.',
        confirmLabel: 'Download',
        showCancel: false);
    await saveExportText(
        filename: 'collectarr-${type.kind.apiValue}.xml',
        content: content,
        mimeType: 'application/xml');
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }
}
