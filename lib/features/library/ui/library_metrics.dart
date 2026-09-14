import 'package:flutter/material.dart';

/// Density presets used by the shared Library UI.
enum LibraryDensity {
  comfortable,
  compact,
  dense,
}

/// The shared geometry vocabulary for Library surfaces.
class LibraryMetrics {
  const LibraryMetrics({
    required this.scale,
    required this.fieldHeight,
    required this.buttonHeight,
    required this.iconButtonSize,
    required this.searchScale,
    required this.dialogHeaderHeight,
    required this.panelHeaderHeight,
    required this.panelHeaderVerticalPadding,
    required this.tableRowHeight,
    required this.resultRowHeight,
    required this.panelPadding,
    required this.sectionPadding,
    required this.footerVerticalPadding,
    required this.tableHorizontalMarginScale,
    required this.tableVerticalPaddingScale,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
    required this.compactBreakpoint,
    required this.wideBreakpoint,
  });

  const LibraryMetrics.comfortable()
      : this(
          scale: 1.0,
          fieldHeight: 34,
          buttonHeight: 36,
          iconButtonSize: 32,
          searchScale: 1.0,
          dialogHeaderHeight: 46,
          panelHeaderHeight: 46,
          panelHeaderVerticalPadding: 6,
          tableRowHeight: 38,
          resultRowHeight: 72,
          panelPadding: 12,
          sectionPadding: 12,
          footerVerticalPadding: 6,
          tableHorizontalMarginScale: 1.0,
          tableVerticalPaddingScale: 1.0,
          gapXs: 4,
          gapSm: 8,
          gapMd: 12,
          gapLg: 16,
          compactBreakpoint: 720,
          wideBreakpoint: 1100,
        );

  const LibraryMetrics.compact()
      : this(
          scale: 0.9,
          fieldHeight: 32,
          buttonHeight: 34,
          iconButtonSize: 30,
          searchScale: 0.9,
          dialogHeaderHeight: 42,
          panelHeaderHeight: 42,
          panelHeaderVerticalPadding: 4,
          tableRowHeight: 34,
          resultRowHeight: 64,
          panelPadding: 10,
          sectionPadding: 10,
          footerVerticalPadding: 4,
          tableHorizontalMarginScale: 0.82,
          tableVerticalPaddingScale: 0.8,
          gapXs: 4,
          gapSm: 6,
          gapMd: 10,
          gapLg: 14,
          compactBreakpoint: 720,
          wideBreakpoint: 1040,
        );

  const LibraryMetrics.dense()
      : this(
          scale: 0.8,
          fieldHeight: 30,
          buttonHeight: 32,
          iconButtonSize: 28,
          searchScale: 0.82,
          dialogHeaderHeight: 42,
          panelHeaderHeight: 42,
          panelHeaderVerticalPadding: 4,
          tableRowHeight: 30,
          resultRowHeight: 56,
          panelPadding: 8,
          sectionPadding: 8,
          footerVerticalPadding: 4,
          tableHorizontalMarginScale: 0.68,
          tableVerticalPaddingScale: 0.66,
          gapXs: 2,
          gapSm: 4,
          gapMd: 8,
          gapLg: 12,
          compactBreakpoint: 680,
          wideBreakpoint: 980,
        );

  final double scale;
  final double fieldHeight;
  final double buttonHeight;
  final double iconButtonSize;
  final double searchScale;
  final double dialogHeaderHeight;
  final double panelHeaderHeight;
  final double panelHeaderVerticalPadding;
  final double tableRowHeight;
  final double resultRowHeight;
  final double panelPadding;
  final double sectionPadding;
  final double footerVerticalPadding;
  final double tableHorizontalMarginScale;
  final double tableVerticalPaddingScale;
  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;
  final double compactBreakpoint;
  final double wideBreakpoint;

  EdgeInsets get panelInsets => EdgeInsets.all(panelPadding);
}

extension LibraryDensityX on LibraryDensity {
  LibraryMetrics get metrics => switch (this) {
        LibraryDensity.comfortable => const LibraryMetrics.comfortable(),
        LibraryDensity.compact => const LibraryMetrics.compact(),
        LibraryDensity.dense => const LibraryMetrics.dense(),
      };

  double get scale => metrics.scale;
}
