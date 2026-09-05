import 'package:collectarr_app/features/library/ui/library_metrics.dart';
import 'package:flutter/material.dart';

export 'library_metrics.dart';

const double kLibraryPanelSurfaceRadius = 0;

EdgeInsets libraryPanelInsets(
    [LibraryDensity density = LibraryDensity.comfortable]) {
  return density.metrics.panelInsets;
}
