import 'dart:async';
import 'dart:typed_data';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/reports/library_export_csv_txt_page.dart';
import 'package:collectarr_app/features/library/reports/library_print_pdf_page.dart';
import 'package:collectarr_app/features/library/reports/library_report_generator.dart';
import 'package:collectarr_app/ui/app_block_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final pdf in [false, true]) {
    testWidgets(
        '${pdf ? 'PDF' : 'CSV'} generation recovers and survives page disposal',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final generator = _ControlledGenerator();
      final type = defaultLibraryKindRegistry.require(CatalogMediaKind.music);
      await tester.pumpWidget(MaterialApp(
          home: pdf
              ? LibraryPrintPdfPage(
                  type: type, items: const [], generator: generator)
              : LibraryExportCsvTxtPage(
                  type: type, items: const [], generator: generator)));
      await tester.pumpAndSettle();
      final generate = find.byWidgetPredicate((widget) =>
          widget is AppBlockButton && widget.label.startsWith('Generate'));
      await tester.ensureVisible(generate);
      await tester.tap(generate);
      await tester.pumpAndSettle();
      expect(generator.attempts, 1);
      expect(find.textContaining('Failed to generate'), findsOneWidget);
      expect(tester.widget<AppBlockButton>(generate).onPressed, isNotNull);
      await tester.tap(generate);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(generator.attempts, 2);
      final busy = find.byWidgetPredicate((widget) =>
          widget is AppBlockButton && widget.label.startsWith('Generating'));
      expect(tester.widget<AppBlockButton>(busy).onPressed, isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      if (pdf) {
        generator.pdfResult.completeError(StateError('late PDF error'));
      } else {
        generator.textResult.complete('completed after page disposal');
      }
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

class _ControlledGenerator extends LibraryReportGenerator {
  var attempts = 0;
  final textResult = Completer<String>();
  final pdfResult = Completer<Uint8List>();

  @override
  Future<String> delimited(LibraryDelimitedReport report) async {
    if (++attempts == 1) throw StateError('first attempt failed');
    return textResult.future;
  }

  @override
  Future<Uint8List> pdf(LibraryPdfReport report) async {
    if (++attempts == 1) throw StateError('first attempt failed');
    return pdfResult.future;
  }
}
