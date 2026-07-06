import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/add/library_add_copy.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds add labels from library type and target', () {
    expect(
      LibraryAddCopy.addToTargetLabel(
        count: 1,
        type: comicsLibraryConfig,
        target: LibraryAddTarget.owned,
      ),
      'Add 1 Comic to Collection',
    );
    expect(
      LibraryAddCopy.addToTargetLabel(
        count: 3,
        type: comicsLibraryConfig,
        target: LibraryAddTarget.wishlist,
      ),
      'Add 3 Comics to Wishlist',
    );
  });
}
