const double kLibrarySidebarMinWidth = 180;
const double kLibrarySidebarDefaultWidth = 250;
const double kLibrarySidebarMaxWidth = 360;
const double kLibraryDetailsMinWidth = 260;
const double kLibraryDetailsDefaultWidth = 340;
const double kLibraryDetailsMaxWidth = 520;
const double kLibraryDetailsMinHeight = 240;
const double kLibraryDetailsDefaultHeight = 300;
const double kLibraryWorkspaceMinWidth = 320;
const double kLibraryWorkspaceMinHeight = 220;
const double kLibraryPaneDividerWidth = 12;
const double kLibraryPaneStoredMaxWidth = 4096;

double clampLibraryPaneWidth(
  double width, {
  required double minWidth,
  required double maxWidth,
}) {
  final effectiveMax = maxWidth < minWidth ? minWidth : maxWidth;
  return width.clamp(minWidth, effectiveMax).toDouble();
}

double clampLibraryPaneHeight(
  double height, {
  required double minHeight,
  required double maxHeight,
}) {
  final effectiveMax = maxHeight < minHeight ? minHeight : maxHeight;
  return height.clamp(minHeight, effectiveMax).toDouble();
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

double resolveLibrarySidebarMaxWidth({
  required double viewportWidth,
  required double workspaceMinWidth,
  required bool hasRightDetails,
  required double rightDetailsWidth,
  required double minWidth,
}) {
  final reservedWidth = workspaceMinWidth +
      kLibraryPaneDividerWidth +
      (hasRightDetails ? rightDetailsWidth + kLibraryPaneDividerWidth : 0);
  return (viewportWidth - reservedWidth)
      .clamp(minWidth, kLibraryPaneStoredMaxWidth)
      .toDouble();
}

double resolveLibraryDetailsMaxWidth({
  required double viewportWidth,
  required double workspaceMinWidth,
  required bool hasSidebar,
  required double sidebarWidth,
}) {
  final reservedWidth = workspaceMinWidth +
      kLibraryPaneDividerWidth +
      (hasSidebar ? sidebarWidth + kLibraryPaneDividerWidth : 0);
  return (viewportWidth - reservedWidth)
      .clamp(kLibraryDetailsMinWidth, kLibraryPaneStoredMaxWidth)
      .toDouble();
}

double resolveLibraryDetailsMaxHeight({
  required double viewportHeight,
  required double workspaceMinHeight,
}) {
  return (viewportHeight - workspaceMinHeight - kLibraryPaneDividerWidth)
      .clamp(kLibraryDetailsMinHeight, kLibraryPaneStoredMaxWidth)
      .toDouble();
}
