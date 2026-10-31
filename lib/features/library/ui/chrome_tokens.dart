import 'package:collectarr_app/features/library/ui/metrics.dart';
import 'package:flutter/material.dart';

export 'metrics.dart';

EdgeInsets libraryPanelInsets(
    [LibraryDensity density = LibraryDensity.comfortable]) {
  return density.metrics.panelInsets;
}
