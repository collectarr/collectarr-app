import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Available columns for the PDF report.
enum ReportColumn {
  title('Title', 2.5),
  kind('Kind', 0.9),
  reference('Reference', 1.8),
  owned('Owned', 0.7),
  wishlist('Wishlist', 0.8),
  quantity('Quantity', 0.8),
  location('Location', 1.0);

  const ReportColumn(this.label, this.flex);
  final String label;
  final double flex;

  String extractFrom(LibraryProjectionView item) {
    final ref = item.source.catalogRef;
    return switch (this) {
      ReportColumn.title => item.dto.title,
      ReportColumn.kind => item.source.mediaKind.apiValue,
      ReportColumn.reference => ref == null
          ? item.node.id
          : '${ref.kind.apiValue}:${ref.entityType.apiValue}:${ref.id}',
      ReportColumn.owned => item.source.isOwned ? 'yes' : 'no',
      ReportColumn.wishlist => item.source.isWishlisted ? 'yes' : 'no',
      ReportColumn.quantity => item.source.quantity.toString(),
      ReportColumn.location => item.source.locationPath ?? '',
    };
  }
}

const _defaultReportColumns = [
  ReportColumn.title,
  ReportColumn.kind,
  ReportColumn.reference,
  ReportColumn.owned,
  ReportColumn.quantity,
  ReportColumn.location,
];

/// Shows a column picker then generates the PDF report.
Future<void> printCollectionReport({
  required BuildContext context,
  required String title,
  required List<LibraryProjectionView> items,
}) async {
  final columns = await showDialog<List<ReportColumn>>(
    context: context,
    builder: (_) => _ReportColumnPickerDialog(accent: kAppAccent),
  );
  if (columns == null || columns.isEmpty) return;

  final doc = _buildDocument(
    title,
    items,
    columns,
  );
  await Printing.layoutPdf(
    onLayout: (format) => doc.save(),
    name: '${title.replaceAll(RegExp(r'[^\w\s]'), '')}_report',
  );
}

pw.Document _buildDocument(
  String title,
  List<LibraryProjectionView> items,
  List<ReportColumn> columns,
) {
  final doc = pw.Document(
    title: title,
    author: 'Collectarr',
  );

  const itemsPerPage = 40;
  final pages = <List<LibraryProjectionView>>[];
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
                        for (final col in columns) _cell(col.extractFrom(item)),
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
                  style: const pw.TextStyle(fontSize: 10),
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
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
  );
}

pw.Widget _cell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(text,
        style: const pw.TextStyle(fontSize: 9),
        maxLines: 2,
        overflow: pw.TextOverflow.clip),
  );
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
    return AccentAlertDialog(
      titlePadding: EdgeInsets.zero,
      title: AccentDialogHeader(
        title: 'Report columns',
        accent: widget.accent,
        icon: Icons.view_column_outlined,
      ),
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
                  final ordered =
                      ReportColumn.values.where(_selected.contains).toList();
                  Navigator.pop(context, ordered);
                },
          child: const Text('Generate report'),
        ),
      ],
    );
  }
}
