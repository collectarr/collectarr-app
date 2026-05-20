import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes reusable add target labels', () {
    expect(LibraryAddTarget.owned.actionLabel, 'Add as owned');
    expect(LibraryAddTarget.owned.destinationLabel, 'Collection');
    expect(LibraryAddTarget.wishlist.actionLabel, 'Add to wishlist');
    expect(LibraryAddTarget.wishlist.destinationLabel, 'Wishlist');
  });
}
