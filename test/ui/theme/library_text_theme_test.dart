import 'package:collectarr_app/ui/theme/library_text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Library text roles expose the supported semantic sizes', () {
    final textTheme = ThemeData().textTheme;

    expect(textTheme.libraryDialogTitle.fontSize, 15);
    expect(textTheme.libraryDetailTitle.fontSize, 16);
    expect(textTheme.libraryBody.fontSize, 13);
    expect(textTheme.libraryMeta.fontSize, 12);
    expect(textTheme.libraryCaption.fontSize, 11);
    expect(textTheme.libraryMicro.fontSize, 10);
    expect(textTheme.libraryChromeTitle.fontSize, 14);
    expect(textTheme.libraryHeaderSubtitle.fontSize, 11.5);
  });
}
