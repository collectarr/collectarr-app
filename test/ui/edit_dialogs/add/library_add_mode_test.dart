import 'package:collectarr_app/features/library/add/library_add_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps reusable add dialog modes stable', () {
    expect(
      LibraryAddMode.values,
      [
        LibraryAddMode.addSeries,
        LibraryAddMode.addIssue,
        LibraryAddMode.barcode,
        LibraryAddMode.pullList,
        LibraryAddMode.browseMedia,
      ],
    );
  });
}
