import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tooltips use the active font family alongside form controls', () {
    final theme = buildLibraryTheme();

    expect(theme.tooltipTheme.textStyle?.fontFamily,
        theme.textTheme.controlText.fontFamily);
    expect(theme.tooltipTheme.textStyle?.fontFamily, appFontFamily);
  });

  test('Library text roles expose the supported semantic sizes', () {
    final textTheme = ThemeData().textTheme;

    expect(textTheme.libraryDialogTitle.fontSize, 18);
    expect(textTheme.libraryDetailTitle.fontSize, 16);
    expect(textTheme.libraryBody.fontSize, 14);
    expect(textTheme.libraryMeta.fontSize, 13);
    expect(textTheme.libraryCaption.fontSize, 13);
    expect(textTheme.libraryChromeTitle.fontSize, 14);
  });
}
