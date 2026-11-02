import 'package:collectarr_app/features/library/add/copy.dart';
import 'package:collectarr_app/features/library/add/models/target.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';

void main() {
  test('builds add labels from library type and target', () {
    expect(
      LibraryAddCopy.addToTargetLabel(
        count: 1,
        type: const ComicRegistration(),
        target: LibraryAddTarget.entry,
      ),
      'Add 1 Comic to Collection',
    );
    expect(
      LibraryAddCopy.addToTargetLabel(
        count: 3,
        type: const ComicRegistration(),
        target: LibraryAddTarget.wishlist,
      ),
      'Add 3 Comics to Wishlist',
    );
  });
}
