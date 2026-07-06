import 'package:flutter/material.dart';

enum LibraryDensity {
  comfortable,
  compact,
  dense,
}

extension LibraryDensityX on LibraryDensity {
  double get scale => switch (this) {
        LibraryDensity.comfortable => 1.0,
        LibraryDensity.compact => 0.9,
        LibraryDensity.dense => 0.8,
      };
}

const double kLibraryPanelHeaderMinHeight = 46;
const double kLibraryPanelHeaderCompactMinHeight = 42;
const double kLibraryPanelSurfaceRadius = 0;
const double kLibraryPanelHorizontalPadding = 12;
const double kLibraryPanelVerticalPadding = 12;
const double kLibrarySectionGap = 12;
const double kLibrarySectionTitleGap = 4;
const double kLibrarySectionBodyGap = 8;

EdgeInsets libraryPanelInsets([LibraryDensity density = LibraryDensity.comfortable]) {
  final scale = density.scale;
  return EdgeInsets.symmetric(
    horizontal: kLibraryPanelHorizontalPadding * scale,
    vertical: kLibraryPanelVerticalPadding * scale,
  );
}
