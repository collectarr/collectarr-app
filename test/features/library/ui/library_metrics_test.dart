import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LibraryMetrics', () {
    test('provides the shared comfortable geometry vocabulary', () {
      final metrics = LibraryDensity.comfortable.metrics;

      expect(metrics.fieldHeight, 34);
      expect(metrics.buttonHeight, 36);
      expect(metrics.iconButtonSize, 32);
      expect(metrics.panelHeaderHeight, 46);
      expect(metrics.tableRowHeight, 38);
      expect(metrics.resultRowHeight, 72);
      expect(metrics.panelPadding, 12);
      expect(metrics.gapMd, 12);
      expect(metrics.wideBreakpoint, 1100);
    });

    test('reduces geometry consistently for compact and dense presets', () {
      final compact = LibraryDensity.compact.metrics;
      final dense = LibraryDensity.dense.metrics;

      expect(compact.scale, lessThan(1));
      expect(dense.scale, lessThan(compact.scale));
      expect(dense.fieldHeight, lessThan(compact.fieldHeight));
      expect(dense.tableRowHeight, lessThan(compact.tableRowHeight));
      expect(dense.panelPadding, lessThan(compact.panelPadding));
      expect(dense.gapMd, lessThan(compact.gapMd));
    });

    test('retains the existing table margin scaling rules', () {
      expect(LibraryDensity.comfortable.metrics.tableHorizontalMarginScale, 1);
      expect(LibraryDensity.compact.metrics.tableHorizontalMarginScale, 0.82);
      expect(LibraryDensity.dense.metrics.tableHorizontalMarginScale, 0.68);
      expect(LibraryDensity.compact.metrics.tableVerticalPaddingScale, 0.8);
      expect(LibraryDensity.dense.metrics.tableVerticalPaddingScale, 0.66);
    });
  });
}
