/// Layout rules shared by the Add dialog shell and its resizable panes.
class LibraryAddDialogLayout {
  const LibraryAddDialogLayout._();

  static const defaultDialogWidth = 1320.0;
  static const defaultDialogHeight = 860.0;
  static const minDialogWidth = 760.0;
  static const maxDialogWidth = 1800.0;
  static const minDialogHeight = 560.0;
  static const maxDialogHeight = 1200.0;

  static const minResultsPaneWidth = 320.0;
  static const minPreviewPaneWidth = 320.0;

  static double clampDialogWidth(double width) {
    return width.clamp(minDialogWidth, maxDialogWidth).toDouble();
  }

  static double clampDialogHeight(double height) {
    return height.clamp(minDialogHeight, maxDialogHeight).toDouble();
  }

  static double clampResultsPaneWidth({
    required double totalWidth,
    required double requestedWidth,
  }) {
    final maxResultsWidth = (totalWidth - minPreviewPaneWidth).clamp(
      minResultsPaneWidth,
      totalWidth,
    );
    return requestedWidth
        .clamp(minResultsPaneWidth, maxResultsWidth)
        .toDouble();
  }
}
