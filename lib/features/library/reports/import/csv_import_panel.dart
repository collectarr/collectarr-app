import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:collectarr_app/ui/app_progress_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'import_file_picker.dart';
import 'import_format_settings.dart';
import 'import_rows_review.dart';

class CsvImportPanel extends StatefulWidget {
  const CsvImportPanel(
      {super.key,
      required this.capability,
      required this.pluralLabel,
      required this.onImport,
      required this.onComplete,
      required this.filePicker});
  final LibraryKindImportCapability capability;
  final String pluralLabel;

  /// Imports the rows, reporting the share done (0 to 1).
  final Future<int> Function(List<CollectionImportRow> rows,
      void Function(double fraction) onProgress) onImport;
  final ValueChanged<int> onComplete;
  final ImportFilePicker filePicker;
  @override
  State<CsvImportPanel> createState() => _CsvImportPanelState();
}

class _CsvImportPanelState extends State<CsvImportPanel> {
  String? _selectedFileName;
  String? _csvRawContent;
  List<List<String>> _parsedRows = [];
  List<String> _csvHeaders = [];
  Map<int, String?> _columnMappings = {};
  bool _skipFirstRow = true;
  ImportFieldDelimiter _delimiter = ImportFieldDelimiter.comma;
  ImportFieldEnclosure _enclosure = ImportFieldEnclosure.doubleQuote;
  ImportMultiFieldDelimiter _multiDelimiter =
      ImportMultiFieldDelimiter.semicolon;
  bool _isImporting = false;
  String? _statusMessage;
  List<CollectionImportRow>? _reviewRows;
  LibraryKindImportCapability get _importCapability => widget.capability;
  String get _pluralLabel => widget.pluralLabel;
  @override
  Widget build(BuildContext context) =>
      _buildCsvTxtView(appPalette(context), appPalette(context).utilityAction);
  Widget _buildCsvTxtView(AppThemePalette palette, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.panel,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Import ${_pluralLabel.toLowerCase()} from CSV / TXT',
                style: TextStyle(
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // 1. Upload file
              Text(
                '1. Upload your .csv or .txt file:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ImportFilePickerBar(
                selectedFileName: _selectedFileName,
                onPick: _isImporting ? null : _pickCsvFile,
              ),
              const SizedBox(height: 16),

              // 2. Data format settings
              Text(
                '2. Choose your data format settings:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ImportFormatSettings(
                  skipFirstRow: _skipFirstRow,
                  delimiter: _delimiter,
                  enclosure: _enclosure,
                  multiDelimiter: _multiDelimiter,
                  onSkipFirstRowChanged: (value) => setState(() {
                        _skipFirstRow = value;
                        _reparseCsv();
                      }),
                  onDelimiterChanged: (value) => setState(() {
                        _delimiter = value;
                        _reparseCsv();
                      }),
                  onEnclosureChanged: (value) => setState(() {
                        _enclosure = value;
                        _reparseCsv();
                      }),
                  onMultiDelimiterChanged: (value) => setState(() {
                        _multiDelimiter = value;
                        _reviewRows = null;
                      })),
              const SizedBox(height: 16),

              // 3. Field mapping
              Text(
                '3. Map your fields to our fields:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: palette.textPrimary,
                  ),
                  children: [
                    TextSpan(text: 'Click the column headers below to map '),
                    TextSpan(
                      text: 'your',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' fields to '),
                    TextSpan(
                      text: 'our',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' fields.'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildFieldMappingArea(palette),
              const SizedBox(height: 20),

              if (_statusMessage != null) ...[
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.startsWith('Error')
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              if (_reviewRows != null) ...[
                ImportRowsReview(
                    rows: _reviewRows!,
                    onClear: _isImporting
                        ? null
                        : () => setState(() => _reviewRows = null)),
                const SizedBox(height: 12),
              ],
              // Bottom Button
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 600;
                  final button = SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      key: const Key('import_csv.submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: _isImporting
                          ? null
                          : () {
                              if (_parsedRows.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please upload a .csv or .txt file first.',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              _reviewRows == null
                                  ? _prepareReview()
                                  : _executeCsvImport();
                            },
                      child: _isImporting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _reviewRows == null
                                  ? 'Review Import'
                                  : 'Import ${_reviewRows!.length} $_pluralLabel',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                    ),
                  );

                  if (isDesktop) {
                    return Row(
                      children: [
                        const Spacer(),
                        Expanded(child: button),
                      ],
                    );
                  }
                  return button;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldMappingArea(AppThemePalette palette) {
    if (_parsedRows.isEmpty) {
      return Container(
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.panel,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: palette.isDark
                  ? appManagementCanvasColor(context)
                  : palette.divider),
        ),
        child: const Icon(
          Icons.description,
          size: 26,
          color: Color(0xFFAAAAAA),
        ),
      );
    }

    final fields = _importCapability.mappableFields;
    final numCols = _csvHeaders.isNotEmpty
        ? _csvHeaders.length
        : (_parsedRows.isNotEmpty ? _parsedRows.first.length : 0);

    return Container(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.cardBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(180),
          border: TableBorder(
            horizontalInside: BorderSide(color: palette.cardBorder),
            verticalInside: BorderSide(color: palette.cardBorder),
          ),
          children: [
            // Dropdown mapping row
            TableRow(
              decoration: BoxDecoration(color: palette.panel),
              children: [
                for (int col = 0; col < numCols; col++)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _csvHeaders.length > col
                              ? _csvHeaders[col]
                              : 'Column ${col + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: palette.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: palette.cardBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: _columnMappings[col],
                              dropdownColor: palette.panel,
                              style: TextStyle(
                                fontSize: 12,
                                color: palette.textPrimary,
                              ),
                              hint: Text(
                                '-- Ignore --',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: palette.textMuted,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    '-- Do not import --',
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ),
                                for (final field in fields)
                                  DropdownMenuItem<String?>(
                                    value: field.key,
                                    child: Text(field.label),
                                  ),
                                if (_importCapability.allowsCustomFieldColumns)
                                  const DropdownMenuItem<String?>(
                                    value: importCustomFieldMappingKey,
                                    child: Text('Custom field (column name)'),
                                  ),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _columnMappings[col] = val;
                                  _reviewRows = null;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            // Data preview rows (up to 5 rows)
            for (final row in _parsedRows.take(5))
              TableRow(
                children: [
                  for (int col = 0; col < numCols; col++)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        col < row.length ? row[col] : '',
                        style:
                            TextStyle(fontSize: 12, color: palette.textMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCsvFile() async {
    try {
      final file = await widget
          .filePicker(label: 'CSV or Text', extensions: ['csv', 'txt']);
      if (file == null || !mounted) return;
      _selectedFileName = file.name;
      _csvRawContent = file.content;
      await runWithProgressDialog(
          context: context,
          title: 'Reading file',
          message: 'Parsing ${file.name}...',
          task: () async => _reparseCsv());
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) {
        setState(() {
          _reviewRows = null;
          _statusMessage = 'Error reading file: $error';
        });
      }
    }
  }

  void _reparseCsv() {
    _reviewRows = null;
    _statusMessage = null;
    final raw = _csvRawContent;
    if (raw == null || raw.trim().isEmpty) {
      _parsedRows = [];
      _csvHeaders = [];
      _columnMappings = {};
      return;
    }

    try {
      final reader = CsvReader(
        fieldDelimiter: _delimiter.char,
        textDelimiter: _enclosure.char,
        strict: true,
      );
      final allRows = reader.read(raw);
      if (allRows.any((row) => row.length != allRows.first.length)) {
        throw const FormatException(
            'A record has a different column count. Check delimiters and quoting.');
      }
      if (allRows.isEmpty) {
        _parsedRows = [];
        _csvHeaders = [];
        _columnMappings = {};
        return;
      }

      if (_skipFirstRow) {
        _csvHeaders = allRows.first;
        _parsedRows = allRows.skip(1).toList();
      } else {
        _csvHeaders = List.generate(
          allRows.first.length,
          (i) => 'Column ${i + 1}',
        );
        _parsedRows = allRows;
      }

      // Auto-map columns based on aliases
      final availableFields = _importCapability.mappableFields;
      _columnMappings = {};

      for (int i = 0; i < _csvHeaders.length; i++) {
        final colHeader = _csvHeaders[i].trim().toLowerCase();
        for (final field in availableFields) {
          if (field.label.toLowerCase() == colHeader ||
              field.aliases.any((a) => a.toLowerCase() == colHeader)) {
            _columnMappings[i] = field.key;
            break;
          }
        }
      }
    } catch (e) {
      _statusMessage = 'Error parsing CSV: $e';
      _parsedRows = [];
    }
  }

  Future<void> _prepareReview() async {
    try {
      final importer = widget.capability.mappedCsvImporter;
      if (importer == null) {
        throw const FormatException(
            'This kind does not support mapped CSV import.');
      }
      final rows = await runWithProgressDialog(
          context: context,
          title: 'Reading file',
          message: 'Preparing ${_parsedRows.length} ${widget.pluralLabel}...',
          task: () async => importer.parse(_parsedRows,
              mappings: {
                for (final entry in _columnMappings.entries)
                  if (entry.value != null) entry.key: entry.value!,
              },
              multiValueDelimiter: _multiDelimiter.char,
              headers: _csvHeaders));
      if (!mounted) return;
      setState(() {
        _reviewRows = rows;
        _statusMessage = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _reviewRows = null;
        _statusMessage = 'Error: $error';
      });
    }
  }

  Future<void> _executeCsvImport() async {
    final rows = _reviewRows;
    if (rows == null || rows.isEmpty || _isImporting) return;
    setState(() {
      _isImporting = true;
      _statusMessage = null;
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
        _isImporting = false;
        _reviewRows = null;
      });
      widget.onComplete(count);
    } catch (error) {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _statusMessage = 'Error importing data: $error';
        });
      }
    }
  }
}
