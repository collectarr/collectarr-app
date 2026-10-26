import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum PdfOrientation { portrait, landscape }

enum PdfBorderType { none, middle, outside, all }

/// Prepared strings and options; generators never retain page or kind state.
class LibraryDelimitedReport {
  LibraryDelimitedReport({
    required List<String> headers,
    required List<List<String>> rows,
    required this.delimiter,
    required this.enclosure,
    required this.quoteAll,
    required this.includeHeaders,
  })  : headers = List.unmodifiable(headers),
        rows = List.unmodifiable(
            rows.map((row) => List<String>.unmodifiable(row)));

  final List<String> headers;
  final List<List<String>> rows;
  final String delimiter;
  final String enclosure;
  final bool quoteAll;
  final bool includeHeaders;
}

class LibraryPdfReport {
  LibraryPdfReport({
    required this.title,
    required this.emptyTitle,
    required List<String> headers,
    required List<List<String>> rows,
    required this.orientation,
    required this.marginMm,
    required this.fontFamily,
    required this.fontSize,
    required this.fontColor,
    required this.rowsPerPage,
    required this.repeatTitle,
    required this.dateTime,
    required this.repeatDateTime,
    required this.headerRow,
    required this.repeatHeaderRow,
    required this.alternatingRows,
    required this.pageNumbers,
    required this.borderType,
  })  : headers = List.unmodifiable(headers),
        rows = List.unmodifiable(
            rows.map((row) => List<String>.unmodifiable(row)));

  final String title;
  final String emptyTitle;
  final List<String> headers;
  final List<List<String>> rows;
  final PdfOrientation orientation;
  final double marginMm;
  final String fontFamily;
  final int fontSize;
  final int fontColor;
  final int rowsPerPage;
  final bool repeatTitle;
  final String? dateTime;
  final bool repeatDateTime;
  final bool headerRow;
  final bool repeatHeaderRow;
  final bool alternatingRows;
  final bool pageNumbers;
  final PdfBorderType borderType;
}

String formatLibraryDelimitedRow(
  List<String> cells, {
  required String delimiter,
  required String enclosure,
  required bool quoteAll,
}) {
  String cell(String value) {
    if (enclosure.isEmpty) {
      return value.replaceAll(delimiter, ' ').replaceAll('\n', ' ');
    }
    if (quoteAll ||
        value.contains(delimiter) ||
        value.contains(enclosure) ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '$enclosure${value.replaceAll(enclosure, '$enclosure$enclosure')}$enclosure';
    }
    return value;
  }

  return cells.map(cell).join(delimiter);
}

/// Stateless generation boundary, also injectable for other execution backends.
class LibraryReportGenerator {
  const LibraryReportGenerator();

  Future<String> delimited(LibraryDelimitedReport report) async {
    final output = StringBuffer();
    for (final row in [
      if (report.includeHeaders) report.headers,
      ...report.rows
    ]) {
      output.writeln(formatLibraryDelimitedRow(row,
          delimiter: report.delimiter,
          enclosure: report.enclosure,
          quoteAll: report.quoteAll));
    }
    return output.toString();
  }

  Future<Uint8List> pdf(LibraryPdfReport report) async {
    if (report.rowsPerPage <= 0) {
      throw ArgumentError.value(
          report.rowsPerPage, 'rowsPerPage', 'Must be positive');
    }
    final doc = pw.Document(title: report.title, author: 'Collectarr');
    final format = report.orientation == PdfOrientation.landscape
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4.portrait;
    final font = switch (report.fontFamily) {
      'Times New Roman' => pw.Font.times(),
      'Courier New' => pw.Font.courier(),
      _ => pw.Font.helvetica(),
    };
    final bold = switch (report.fontFamily) {
      'Times New Roman' => pw.Font.timesBold(),
      'Courier New' => pw.Font.courierBold(),
      _ => pw.Font.helveticaBold(),
    };
    final color = PdfColor.fromInt(report.fontColor);
    final border = switch (report.borderType) {
      PdfBorderType.none => const pw.TableBorder(),
      PdfBorderType.middle => pw.TableBorder.symmetric(
          inside: const pw.BorderSide(color: PdfColors.grey400, width: 0.5)),
      PdfBorderType.outside ||
      PdfBorderType.all =>
        pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    };
    final pages = <List<List<String>>>[];
    for (var offset = 0;
        offset < report.rows.length;
        offset += report.rowsPerPage) {
      final end = (offset + report.rowsPerPage).clamp(0, report.rows.length);
      pages.add(report.rows.sublist(offset, end));
    }
    if (pages.isEmpty) pages.add([]);
    pw.Widget textCell(String text, {bool header = false}) => pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(text,
            style: pw.TextStyle(
                font: header ? bold : font,
                fontSize: report.fontSize.toDouble(),
                color: color)));
    for (var page = 0; page < pages.length; page++) {
      final rows = pages[page];
      doc.addPage(pw.Page(
          pageFormat: format,
          margin: pw.EdgeInsets.all(report.marginMm * PdfPageFormat.mm),
          build: (_) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    if (page == 0 || report.repeatTitle) ...[
                      pw.Text(
                          report.title.isEmpty
                              ? report.emptyTitle
                              : report.title,
                          style: pw.TextStyle(
                              font: bold, fontSize: 18, color: color)),
                      if (report.dateTime != null &&
                          (page == 0 || report.repeatDateTime))
                        pw.Text(report.dateTime!,
                            style: pw.TextStyle(
                                font: font,
                                fontSize: 8,
                                color: PdfColors.grey600)),
                      pw.SizedBox(height: 10),
                    ],
                    pw.Table(border: border, children: [
                      if (report.headerRow &&
                          (page == 0 || report.repeatHeaderRow))
                        pw.TableRow(
                            decoration: const pw.BoxDecoration(
                                color: PdfColors.grey200),
                            children: [
                              for (final label in report.headers)
                                textCell(label, header: true)
                            ]),
                      for (var row = 0; row < rows.length; row++)
                        pw.TableRow(
                            decoration: pw.BoxDecoration(
                                color: report.alternatingRows && row.isOdd
                                    ? PdfColors.grey100
                                    : PdfColors.white),
                            children: [
                              for (final value in rows[row]) textCell(value)
                            ]),
                    ]),
                    pw.Spacer(),
                    if (report.pageNumbers)
                      pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text('Page ${page + 1} of ${pages.length}',
                              style: pw.TextStyle(
                                  font: font,
                                  fontSize: 8,
                                  color: PdfColors.grey600))),
                  ])));
    }
    return doc.save();
  }
}
