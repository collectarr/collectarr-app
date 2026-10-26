import 'dart:convert';

import 'package:collectarr_app/features/library/reports/library_report_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = LibraryReportGenerator();

  test('delimited exports escape quotes, delimiters and multiline values',
      () async {
    final headers = ['Title', 'Notes'];
    final rows = [
      ['A, "B"', 'first\nsecond']
    ];
    final report = LibraryDelimitedReport(
        headers: headers,
        rows: rows,
        delimiter: ',',
        enclosure: '"',
        quoteAll: true,
        includeHeaders: true);
    headers.clear();
    rows.first.clear();
    expect(await generator.delimited(report),
        '"Title","Notes"\n"A, ""B""","first\nsecond"\n');
  });

  test('TXT options omit headers and preserve the configured quoting policy',
      () async {
    expect(
        await generator.delimited(LibraryDelimitedReport(
            headers: [
              'Ignored'
            ],
            rows: [
              ['plain', 'a;b', "a'b"]
            ],
            delimiter: ';',
            enclosure: "'",
            quoteAll: false,
            includeHeaders: false)),
        "plain;'a;b';'a''b'\n");
    expect(
        formatLibraryDelimitedRow(['a\tb', 'a\nb'],
            delimiter: '\t', enclosure: '', quoteAll: false),
        'a b\ta b');
  });

  LibraryPdfReport pdfReport(int rowsPerPage, List<List<String>> rows) =>
      LibraryPdfReport(
          title: 'Test report',
          emptyTitle: 'My Collection',
          headers: ['Title'],
          rows: rows,
          orientation: PdfOrientation.portrait,
          marginMm: 10,
          fontFamily: 'Helvetica',
          fontSize: 10,
          fontColor: 0xff000000,
          rowsPerPage: rowsPerPage,
          repeatTitle: true,
          dateTime: '2024-01-02',
          repeatDateTime: true,
          headerRow: true,
          repeatHeaderRow: true,
          alternatingRows: true,
          pageNumbers: true,
          borderType: PdfBorderType.all);

  test('PDF generator creates a valid paginated document from prepared rows',
      () async {
    final bytes = await generator.pdf(pdfReport(2, [
      ['First'],
      ['Second'],
      ['Third']
    ]));
    final document = latin1.decode(bytes);
    expect(document, startsWith('%PDF-'));
    expect(document, contains(RegExp(r'/Count\s+2\b')));
    expect(document, contains('%%EOF'));
    final empty = latin1.decode(await generator.pdf(pdfReport(2, [])));
    expect(empty, contains(RegExp(r'/Count\s+1\b')));
  });

  test('PDF generation rejects an invalid page size instead of looping',
      () async {
    await expectLater(
        generator.pdf(pdfReport(0, [
          ['Row']
        ])),
        throwsArgumentError);
  });
}
