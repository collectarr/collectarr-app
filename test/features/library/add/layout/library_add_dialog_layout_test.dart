import 'package:collectarr_app/features/library/add/layout/library_add_dialog_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LibraryAddDialogLayout', () {
    test('clamps dialog dimensions to their supported ranges', () {
      expect(
        LibraryAddDialogLayout.clampDialogWidth(400),
        LibraryAddDialogLayout.minDialogWidth,
      );
      expect(
        LibraryAddDialogLayout.clampDialogWidth(2000),
        LibraryAddDialogLayout.maxDialogWidth,
      );
      expect(
        LibraryAddDialogLayout.clampDialogHeight(400),
        LibraryAddDialogLayout.minDialogHeight,
      );
      expect(
        LibraryAddDialogLayout.clampDialogHeight(1300),
        LibraryAddDialogLayout.maxDialogHeight,
      );
    });

    test('keeps enough room for the preview pane', () {
      expect(
        LibraryAddDialogLayout.clampResultsPaneWidth(
          totalWidth: 1000,
          requestedWidth: 200,
        ),
        LibraryAddDialogLayout.minResultsPaneWidth,
      );
      expect(
        LibraryAddDialogLayout.clampResultsPaneWidth(
          totalWidth: 1000,
          requestedWidth: 900,
        ),
        680,
      );
      expect(
        LibraryAddDialogLayout.clampResultsPaneWidth(
          totalWidth: 500,
          requestedWidth: 450,
        ),
        LibraryAddDialogLayout.minResultsPaneWidth,
      );
    });
  });
}
