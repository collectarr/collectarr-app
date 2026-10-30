import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/import_review_panel.dart';
import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_progress_dialog.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:flutter/material.dart';
import 'import_file_picker.dart';

class GuidedImportPanel extends StatefulWidget {
  const GuidedImportPanel(
      {super.key,
      required this.source,
      required this.pluralLabel,
      required this.onImport,
      required this.onComplete,
      required this.filePicker});
  final LibraryImportSourceDefinition source;
  final String pluralLabel;

  /// Imports the rows, reporting the share done (0 to 1).
  final Future<int> Function(List<CollectionImportRow> rows,
      void Function(double fraction) onProgress) onImport;
  final ValueChanged<int> onComplete;
  final ImportFilePicker filePicker;
  @override
  State<GuidedImportPanel> createState() => _GuidedImportPanelState();
}

class _GuidedImportPanelState extends State<GuidedImportPanel> {
  String? _filename;
  String? _content;
  String? _error;
  bool _importing = false;
  Future<void> _pick() async {
    final file = await widget.filePicker(
        label: widget.source.title, extensions: widget.source.fileExtensions);
    if (file == null || !mounted) return;
    setState(() {
      _filename = file.name;
      _content = file.content;
      _error = null;
    });
  }

  Future<void> _import() async {
    final content = _content;
    if (content == null || _importing) return;
    final List<CollectionImportRow> rows;
    try {
      final importer = widget.source.importer;
      if (importer == null) {
        throw const FormatException('No importer registered for this source.');
      }
      rows = importer.parse(content);
      if (rows.isEmpty) {
        throw const FormatException(
            '0 records parsed. This export has no supported records.');
      }
    } catch (error) {
      setState(() => _error = error.toString());
      return;
    }
    setState(() {
      _importing = true;
      _error = null;
    });
    try {
      final count = await runWithReportedProgressDialog(
          context: context,
          title: 'Import',
          message: 'Importing your ${widget.pluralLabel.toLowerCase()}...',
          task: (report) => widget.onImport(
              rows,
              (fraction) =>
                  report(fraction, fraction >= 1 ? 'Finishing...' : null)));
      if (!mounted) return;
      setState(() {
        _importing = false;
        _filename = null;
        _content = null;
      });
      widget.onComplete(count);
    } catch (error) {
      if (mounted) {
        setState(() {
          _importing = false;
          _error = 'Import failed: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.source;
    final palette = appPalette(context);
    return Container(
        decoration: BoxDecoration(
            color: palette.panel,
            border: Border.all(
                color: palette.isDark
                    ? const Color(0xff262626)
                    : palette.cardBorder)),
        padding: const EdgeInsets.all(10),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Import from ${source.title}',
              style: const TextStyle(
                  fontSize: 30, height: 1.1, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (source.description.isNotEmpty) ...[
            Text(source.description,
                style: const TextStyle(fontSize: 14, height: 1.4)),
            const SizedBox(height: 10)
          ],
          for (var i = 0; i < source.instructions.length; i++)
            Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text('${i + 1}. ${source.instructions[i]}',
                    style: const TextStyle(fontSize: 14, height: 20 / 14))),
          const SizedBox(height: 16),
          Text(source.filePrompt,
              style: const TextStyle(
                  fontSize: 22, height: 1.1, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ImportFilePickerBar(
              selectedFileName: _filename, onPick: _importing ? null : _pick),
          const SizedBox(height: 20),
          if (_error != null) ...[
            ImportReviewPanel(title: 'Import needs attention', items: [
              ImportReviewItem(
                  title: 'Unsupported / invalid export',
                  description: _error!,
                  trailingLabel: '0 records saved',
                  severity: ImportReviewSeverity.error)
            ]),
            const SizedBox(height: 14)
          ],
          Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                  width: 240,
                  height: 32,
                  child: FilledButton(
                      key: const Key('import_guided.submit'),
                      style: dialogActionButtonStyle(context,
                          primary: true, width: 240),
                      onPressed:
                          _content == null || _importing ? null : _import,
                      child: _importing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Import',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400))))),
        ]));
  }
}
