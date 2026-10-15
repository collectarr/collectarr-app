import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/import_review_panel.dart';
import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'import_file_picker.dart';
import 'import_rows_review.dart';

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
  final Future<int> Function(List<CollectionImportRow>) onImport;
  final ValueChanged<int> onComplete;
  final ImportFilePicker filePicker;
  @override
  State<GuidedImportPanel> createState() => _GuidedImportPanelState();
}

class _GuidedImportPanelState extends State<GuidedImportPanel> {
  String? _filename;
  String? _error;
  List<CollectionImportRow> _rows = const [];
  bool _importing = false;
  Future<void> _pick() async {
    try {
      final file = await widget.filePicker(
          label: widget.source.title, extensions: widget.source.fileExtensions);
      if (file == null || !mounted) return;
      setState(() {
        _filename = file.name;
        _rows = const [];
        _error = null;
      });
      final importer = widget.source.importer;
      if (importer == null) {
        throw const FormatException('No importer registered for this source.');
      }
      final rows = importer.parse(file.content);
      if (rows.isEmpty) {
        throw const FormatException(
            '0 records parsed. This export has no supported records.');
      }
      setState(() => _rows = rows);
    } catch (error) {
      if (mounted) {
        setState(() {
          _rows = const [];
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _import() async {
    if (_rows.isEmpty || _importing) return;
    setState(() {
      _importing = true;
      _error = null;
    });
    try {
      final count = await widget.onImport(_rows);
      if (!mounted) return;
      setState(() {
        _importing = false;
        _rows = const [];
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
        color: palette.panel,
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
          if (_rows.isNotEmpty) ...[
            ImportRowsReview(
                rows: _rows,
                onClear:
                    _importing ? null : () => setState(() => _rows = const [])),
            const SizedBox(height: 14)
          ],
          Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                  width: 240,
                  height: 32,
                  child: FilledButton(
                      key: const Key('import_guided.submit'),
                      style: FilledButton.styleFrom(
                          backgroundColor: palette.utilityAction,
                          foregroundColor: Colors.white),
                      onPressed: _rows.isEmpty || _importing ? null : _import,
                      child: _importing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              _rows.isEmpty
                                  ? 'Import'
                                  : 'Import ${_rows.length} ${widget.pluralLabel}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400))))),
        ]));
  }
}
