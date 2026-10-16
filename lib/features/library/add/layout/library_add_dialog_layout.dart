/// Layout rules shared by the Add dialog shell.
class LibraryAddDialogLayout {
  const LibraryAddDialogLayout._();

  /// One column of results, as in the reference.
  static const defaultDialogWidth = 690.0;

  /// Fills the window height; the dialog clamps it to the space available.
  static const defaultDialogHeight = maxDialogHeight;
  static const minDialogWidth = 520.0;
  static const maxDialogWidth = 1800.0;
  static const minDialogHeight = 560.0;
  static const maxDialogHeight = 1200.0;

  static double clampDialogWidth(double width) {
    return width.clamp(minDialogWidth, maxDialogWidth).toDouble();
  }

  static double clampDialogHeight(double height) {
    return height.clamp(minDialogHeight, maxDialogHeight).toDouble();
  }
}
