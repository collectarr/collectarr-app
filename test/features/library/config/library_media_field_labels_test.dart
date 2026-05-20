import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/config/planned_library_configs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('video libraries use physical edition terminology', () {
    final movieLabels = libraryMediaFieldLabels(moviesLibraryConfig);
    final tvLabels = libraryMediaFieldLabels(tvLibraryConfig);

    expect(movieLabels.publisher, 'Studio');
    expect(movieLabels.variant, 'Format / Edition');
    expect(movieLabels.barcode, 'UPC / Barcode');
    expect(tvLabels.number, 'Season / Volume');
  });

  test('books and games use media-specific barcode and edition labels', () {
    final bookLabels = libraryMediaFieldLabels(booksLibraryConfig);
    final gameLabels = libraryMediaFieldLabels(gamesLibraryConfig);

    expect(bookLabels.barcode, 'ISBN / Barcode');
    expect(bookLabels.variant, 'Edition / Binding');
    expect(gameLabels.variant, 'Platform / Edition');
    expect(gameLabels.publisher, 'Publisher / Studio');
  });
}
