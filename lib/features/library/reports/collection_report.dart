import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:barcode/barcode.dart' as bc;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Available columns for the PDF report.
enum ReportColumn {
  title('Title', 2.5),
  series('Series', 1.3),
  issue('Issue', 0.6),
  condition('Condition', 1.0),
  grade('Grade', 0.8),
  publisher('Publisher', 1.0),
  barcode('Barcode', 1.2),
  barcodeImage('Barcode (visual)', 1.8),
  year('Year', 0.6),
  format('Format', 0.8),
  creator('Creator', 1.2),
  tags('Tags', 1.0),
  storageBox('Storage', 1.0);

  const ReportColumn(this.label, this.flex);
  final String label;
  final double flex;

  String extractFrom(LibraryWorkspaceEntry item) {
    return switch (this) {
      ReportColumn.title => item.title,
      ReportColumn.series => item.series?.seriesTitle ?? '',
      ReportColumn.issue => item.itemNumber ?? '',
      ReportColumn.condition => item.condition ?? '',
      ReportColumn.grade => item.grade ?? '',
      ReportColumn.publisher => item.publisher ?? '',
      ReportColumn.barcode => item.barcode ?? '',
      ReportColumn.barcodeImage => item.barcode ?? '',
      ReportColumn.year => item.releaseYear?.toString() ?? '',
      ReportColumn.format => item.editions.firstOrNull?.physicalFormatLabel ?? '',
      ReportColumn.creator => (item.creators?.firstOrNull?['name']?.toString()) ?? '',
      ReportColumn.tags => item.tags ?? '',
      ReportColumn.storageBox => item.storageBox ?? '',
    };
  }
}

const _defaultReportColumns = [
  ReportColumn.title,
  ReportColumn.series,
  ReportColumn.issue,
  ReportColumn.condition,
  ReportColumn.publisher,
  ReportColumn.barcode,
];

/// Shows a column picker then generates the PDF report.
Future<void> printCollectionReport({
  required BuildContext context,
  required String title,
  required List<LibraryWorkspaceEntry> items,
}) async {
  final columns = await showDialog<List<ReportColumn>>(
    context: context,
    builder: (_) => _ReportColumnPickerDialog(accent: kAppAccent),
  );
  if (columns == null || columns.isEmpty) return;

  final doc = _buildDocument(title, items, columns);
  await Printing.layoutPdf(
    onLayout: (format) => doc.save(),
    name: '${title.replaceAll(RegExp(r'[^\w\s]'), '')}_report',
  );
}

pw.Document _buildDocument(
  String title,
  List<LibraryWorkspaceEntry> items,
  List<ReportColumn> columns,
) {
  final doc = pw.Document(
    title: title,
    author: 'Collectarr',
  );

  const itemsPerPage = 40;
  final pages = <List<LibraryWorkspaceEntry>>[];
  for (var i = 0; i < items.length; i += itemsPerPage) {
    pages.add(items.sublist(
        i, i + itemsPerPage > items.length ? items.length : i + itemsPerPage));
  }

  // Build column widths: #(0.4) + user columns
  final columnWidths = <int, pw.FlexColumnWidth>{
    0: const pw.FlexColumnWidth(0.4),
    for (var i = 0; i < columns.length; i++)
      i + 1: pw.FlexColumnWidth(columns[i].flex),
  };

  for (var pageIdx = 0; pageIdx < pages.length; pageIdx++) {
    final pageItems = pages[pageIdx];
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (pageIdx == 0)
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(title,
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('${items.length} items',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: columnWidths,
                children: [
                  if (pageIdx == 0)
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _headerCell('#'),
                        for (final col in columns) _headerCell(col.label),
                      ],
                    ),
                  ...pageItems.asMap().entries.map((e) {
                    final idx = pageIdx * itemsPerPage + e.key + 1;
                    final item = e.value;
                    return pw.TableRow(
                      children: [
                        _cell(idx.toString()),
                        for (final col in columns)
                          col == ReportColumn.barcodeImage
                              ? _barcodeCell(col.extractFrom(item))
                              : _cell(col.extractFrom(item)),
                      ],
                    );
                  }),
                ],
              ),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Page ${pageIdx + 1} of ${pages.length}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  return doc;
}

pw.Widget _headerCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
  );
}

pw.Widget _cell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(text,
        style: const pw.TextStyle(fontSize: 8),
        maxLines: 2,
        overflow: pw.TextOverflow.clip),
  );
}

pw.Widget _barcodeCell(String data) {
  if (data.isEmpty) return _cell('');
  try {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.BarcodeWidget(
        barcode: data.length == 13
            ? bc.Barcode.ean13()
            : data.length == 12
                ? bc.Barcode.upcA()
                : bc.Barcode.code128(),
        data: data,
        height: 18,
        drawText: true,
        textStyle: const pw.TextStyle(fontSize: 6),
      ),
    );
  } catch (_) {
    return _cell(data);
  }
}

// ---------------------------------------------------------------------------
// Column picker dialog
// ---------------------------------------------------------------------------

class _ReportColumnPickerDialog extends StatefulWidget {
  const _ReportColumnPickerDialog({required this.accent});
  final Color accent;

  @override
  State<_ReportColumnPickerDialog> createState() =>
      _ReportColumnPickerDialogState();
}

class _ReportColumnPickerDialogState extends State<_ReportColumnPickerDialog> {
  final _selected = Set<ReportColumn>.from(_defaultReportColumns);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report columns'),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final col in ReportColumn.values)
                CheckboxListTile(
                  value: _selected.contains(col),
                  title: Text(col.label),
                  dense: true,
                  activeColor: widget.accent,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selected.add(col);
                      } else {
                        _selected.remove(col);
                      }
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () {
                  // Maintain enum order
                  final ordered = ReportColumn.values
                      .where(_selected.contains)
                      .toList();
                  Navigator.pop(context, ordered);
                },
          child: const Text('Generate report'),
        ),
      ],
    );
  }
}
