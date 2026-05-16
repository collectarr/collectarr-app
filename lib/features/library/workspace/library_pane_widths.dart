const double kLibrarySidebarMinWidth = 180;
const double kLibrarySidebarDefaultWidth = 250;
const double kLibrarySidebarMaxWidth = 360;
const double kLibraryDetailsMinWidth = 260;
const double kLibraryDetailsDefaultWidth = 340;
const double kLibraryDetailsMaxWidth = 520;

double clampLibraryPaneWidth(
  double width, {
  required double minWidth,
  required double maxWidth,
}) {
  final effectiveMax = maxWidth < minWidth ? minWidth : maxWidth;
  return width.clamp(minWidth, effectiveMax).toDouble();
}

double maxLibraryPaneWidthForViewport({
  required double viewportWidth,
  required double preferredMaxWidth,
  required double viewportFraction,
}) {
  return (viewportWidth * viewportFraction)
      .clamp(0, preferredMaxWidth)
      .toDouble();
}
