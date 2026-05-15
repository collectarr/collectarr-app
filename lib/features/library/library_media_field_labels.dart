import 'package:collectarr_app/features/library/library_type_config.dart';

class LibraryMediaFieldLabels {
  const LibraryMediaFieldLabels({
    required this.number,
    required this.publisher,
    required this.variant,
    required this.barcode,
  });

  final String number;
  final String publisher;
  final String variant;
  final String barcode;
}

LibraryMediaFieldLabels libraryMediaFieldLabels(LibraryTypeConfig type) {
  return switch (type.workspace.kind) {
    'movie' => const LibraryMediaFieldLabels(
        number: 'Edition no.',
        publisher: 'Studio',
        variant: 'Format / Edition',
        barcode: 'UPC / Barcode',
      ),
    'tv' => const LibraryMediaFieldLabels(
        number: 'Season / Volume',
        publisher: 'Network / Studio',
        variant: 'Format / Edition',
        barcode: 'UPC / Barcode',
      ),
    'anime' => const LibraryMediaFieldLabels(
        number: 'Season / Volume',
        publisher: 'Studio / Publisher',
        variant: 'Format / Edition',
        barcode: 'UPC / Barcode',
      ),
    'game' => const LibraryMediaFieldLabels(
        number: 'Version',
        publisher: 'Publisher / Studio',
        variant: 'Platform / Edition',
        barcode: 'UPC / Barcode',
      ),
    'boardgame' => const LibraryMediaFieldLabels(
        number: 'Edition',
        publisher: 'Publisher / Designer',
        variant: 'Expansion / Edition',
        barcode: 'Barcode',
      ),
    'book' => const LibraryMediaFieldLabels(
        number: 'Volume',
        publisher: 'Publisher',
        variant: 'Edition / Binding',
        barcode: 'ISBN / Barcode',
      ),
    'manga' => const LibraryMediaFieldLabels(
        number: 'Volume / Chapter',
        publisher: 'Publisher',
        variant: 'Edition / Variant',
        barcode: 'ISBN / Barcode',
      ),
    'music' => const LibraryMediaFieldLabels(
        number: 'Disc / Volume',
        publisher: 'Label / Artist',
        variant: 'Format / Edition',
        barcode: 'Barcode / Catalog no.',
      ),
    _ => const LibraryMediaFieldLabels(
        number: 'No. / Vol.',
        publisher: 'Publisher / Studio / Creator',
        variant: 'Edition / Variant / Format',
        barcode: 'Barcode / UPC / ISBN',
      ),
  };
}
