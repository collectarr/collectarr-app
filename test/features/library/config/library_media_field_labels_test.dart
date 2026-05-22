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

  test('music search labels use artist terminology', () {
    final musicLabels = libraryMediaSearchFieldLabels(musicLibraryConfig);
    final movieLabels = libraryMediaSearchFieldLabels(moviesLibraryConfig);

    expect(musicLabels.queryHint, 'Enter title, artist, creator, or keyword...');
    expect(musicLabels.emptySearchMessage,
        'Enter a title, artist, creator, or keyword.');
    expect(musicLabels.seriesHint, 'Artist...');
    expect(musicLabels.publisherHint, 'Label...');
    expect(movieLabels.seriesHint, 'Series...');
    expect(movieLabels.publisherHint, 'Studio...');
  });

  test('filter labels vary by media type', () {
    final musicLabels = libraryMediaFilterLabels(musicLibraryConfig);
    final movieLabels = libraryMediaFilterLabels(moviesLibraryConfig);
    final gameLabels = libraryMediaFilterLabels(gamesLibraryConfig);

    expect(musicLabels.series, 'Artist');
    expect(musicLabels.anySeries, 'Any artist');
    expect(musicLabels.publisher, 'Label');
    expect(movieLabels.publisher, 'Studio');
    expect(movieLabels.anyPublisher, 'Any studio');
    expect(gameLabels.publisher, 'Publisher / Studio');
  });

  test('group labels vary by media type', () {
    final musicLabels = libraryMediaGroupLabels(musicLibraryConfig);
    final movieLabels = libraryMediaGroupLabels(moviesLibraryConfig);

    expect(musicLabels.series, 'Artist');
    expect(musicLabels.seriesPlural, 'Artists');
    expect(musicLabels.unknownSeries, 'Unknown artist');
    expect(musicLabels.publisher, 'Label');
    expect(musicLabels.publisherPlural, 'Labels');
    expect(musicLabels.unknownPublisher, 'Unknown label');
    expect(movieLabels.publisher, 'Studio');
    expect(movieLabels.publisherPlural, 'Studios');
    expect(movieLabels.unknownPublisher, 'Unknown studio');
  });

  test('preview labels vary by media type', () {
    final musicLabels = libraryMediaPreviewLabels(musicLibraryConfig);
    final tvLabels = libraryMediaPreviewLabels(tvLibraryConfig);
    final bookLabels = libraryMediaPreviewLabels(booksLibraryConfig);

    expect(musicLabels.series, 'Artist');
    expect(musicLabels.itemCount, 'Releases');
    expect(tvLabels.series, 'Series');
    expect(tvLabels.itemCount, 'Seasons');
    expect(bookLabels.itemCount, 'Volumes');
  });
}
