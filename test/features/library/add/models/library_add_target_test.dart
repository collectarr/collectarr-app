import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes reusable add target labels', () {
    expect(LibraryAddTarget.entry.actionLabel, 'Add as entry');
    expect(LibraryAddTarget.entry.destinationLabel, 'Collection');
    expect(LibraryAddTarget.wishlist.actionLabel, 'Add to wishlist');
    expect(LibraryAddTarget.wishlist.destinationLabel, 'Wishlist');
    expect(LibraryAddTarget.track.actionLabel, 'Track item');
    expect(LibraryAddTarget.track.destinationLabel, 'Tracking');
  });
}
