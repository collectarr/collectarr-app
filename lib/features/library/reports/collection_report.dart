import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Generates and shows a print/PDF dialog for the given collection items.
Future<void> printCollectionReport({
  required String title,
  required List<LibraryWorkspaceEntry> items,
}) async {
  final doc = _buildDocument(title, items);
  await Printing.layoutPdf(
    onLayout: (format) => doc.save(),
    name: '${title.replaceAll(RegExp(r'[^\w\s]'), '')}_report',
  );
}

pw.Document _buildDocument(
    String title, List<LibraryWorkspaceEntry> items) {
  final doc = pw.Document(
    title: title,
    author: 'Collectarr',
  );

  // Paginate items into chunks
  const itemsPerPage = 40;
  final pages = <List<LibraryWorkspaceEntry>>[];
  for (var i = 0; i < items.length; i += itemsPerPage) {
    pages.add(items.sublist(
        i, i + itemsPerPage > items.length ? items.length : i + itemsPerPage));
  }

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
                columnWidths: {
                  0: const pw.FlexColumnWidth(0.4),
                  1: const pw.FlexColumnWidth(2.5),
                  2: const pw.FlexColumnWidth(1.3),
                  3: const pw.FlexColumnWidth(0.6),
                  4: const pw.FlexColumnWidth(1),
                  5: const pw.FlexColumnWidth(1),
                  6: const pw.FlexColumnWidth(1.2),
                },
                children: [
                  if (pageIdx == 0)
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _headerCell('#'),
                        _headerCell('Title'),
                        _headerCell('Series'),
                        _headerCell('Issue'),
                        _headerCell('Condition'),
                        _headerCell('Publisher'),
                        _headerCell('Barcode'),
                      ],
                    ),
                  ...pageItems.asMap().entries.map((e) {
                    final idx =
                        pageIdx * itemsPerPage + e.key + 1;
                    final item = e.value;
                    return pw.TableRow(
                      children: [
                        _cell(idx.toString()),
                        _cell(item.title),
                        _cell(item.series?.seriesTitle ?? ''),
                        _cell(item.itemNumber ?? ''),
                        _cell(item.condition ?? ''),
                        _cell(item.publisher ?? ''),
                        _cell(item.barcode ?? ''),
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
