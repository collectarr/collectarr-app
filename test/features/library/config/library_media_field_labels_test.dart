import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('video libraries use physical edition terminology', () {
    expect(movieKindModule.edit.mediaFields.publisherLabel, 'Studio');
    expect(movieKindModule.edit.releaseFields.variantLabel, 'Format / Edition');
    expect(movieKindModule.edit.releaseFields.barcodeLabel, 'UPC / Barcode');
    expect(movieKindModule.edit.mediaFields.numberLabel, 'Edition no.');
  });

  test('books and games use media-specific barcode and edition labels', () {
    expect(bookKindModule.edit.releaseFields.barcodeLabel, 'ISBN / Barcode');
    expect(bookKindModule.edit.releaseFields.variantLabel, 'Edition / Binding');
    expect(
        gameKindModule.edit.releaseFields.variantLabel, 'Platform / Edition');
    expect(
        gameKindModule.edit.mediaFields.publisherLabel, 'Publisher / Studio');
  });

  test('music search labels use artist terminology', () {
    final musicLabels = libraryMediaSearchFieldLabels(musicLibraryConfig);
    final movieLabels = libraryMediaSearchFieldLabels(moviesLibraryConfig);

    expect(musicLabels.queryHint, 'Enter album, artist, release, or label...');
    expect(musicLabels.emptySearchMessage,
        'Enter an album, artist, release, or label.');
    expect(movieLabels.queryHint, 'Enter title, creator, or keyword...');
  });

  test('filter labels vary by media type', () {
    final musicLabels = libraryMediaFilterLabels(musicLibraryConfig);
    final movieLabels = libraryMediaFilterLabels(moviesLibraryConfig);
    final gameLabels = libraryMediaFilterLabels(gamesLibraryConfig);

    expect(musicLabels.labelFor('series'), 'Artist');
    expect(musicLabels.labelFor('series_any'), 'Any artist');
    expect(musicLabels.labelFor('publisher'), 'Label');
    expect(movieLabels.labelFor('publisher'), 'Studio');
    expect(movieLabels.labelFor('publisher_any'), 'Any studio');
    expect(gameLabels.labelFor('publisher'), 'Publisher / Studio');
  });

  test('group labels vary by media type', () {
    final musicLabels = libraryMediaGroupLabels(musicLibraryConfig);
    final movieLabels = libraryMediaGroupLabels(moviesLibraryConfig);

    expect(musicLabels.labelFor('series'), 'Artist');
    expect(musicLabels.labelFor('series_plural'), 'Artists');
    expect(musicLabels.labelFor('unknown_series'), 'Unknown artist');
    expect(musicLabels.labelFor('publisher'), 'Label');
    expect(musicLabels.labelFor('publisher_plural'), 'Labels');
    expect(musicLabels.labelFor('unknown_publisher'), 'Unknown label');
    expect(movieLabels.labelFor('publisher'), 'Studio');
    expect(movieLabels.labelFor('publisher_plural'), 'Studios');
    expect(movieLabels.labelFor('unknown_publisher'), 'Unknown studio');
  });

  test('preview labels vary by media type', () {
    final musicLabels = libraryMediaPreviewLabels(musicLibraryConfig);
    final movieLabels = libraryMediaPreviewLabels(moviesLibraryConfig);
    final bookLabels = libraryMediaPreviewLabels(booksLibraryConfig);

    expect(musicLabels.labelFor('series'), 'Artist');
    expect(musicLabels.labelFor('item_count'), 'Releases');
    expect(movieLabels.labelFor('series'), 'Series');
    expect(movieLabels.labelFor('item_count'), 'Items');
    expect(bookLabels.labelFor('item_count'), 'Volumes');
  });

  test('stats labels and candidate layout vary by media type', () {
    expect(musicLibraryConfig.presentation.statsLabels.labelFor('top_series'),
        'Top Artists');
    expect(
        musicLibraryConfig.presentation.statsLabels.labelFor('top_publisher'),
        'Top Labels');
    expect(moviesLibraryConfig.presentation.statsLabels.labelFor('top_series'),
        'Top Franchises');
    expect(
        gamesLibraryConfig.presentation.statsLabels.labelFor('top_publisher'),
        'Top Publishers / Studios');
    expect(comicsLibraryConfig.presentation.usesTreeProviderCandidates, isTrue);
    expect(booksLibraryConfig.presentation.usesTreeProviderCandidates, isFalse);
  });

  test('filter definitions are kind-owned and grade is not universal', () {
    final comicFilterIds = comicsLibraryConfig.presentation.filterDefinitions
        .map((definition) => definition.id)
        .toSet();
    final musicFilterIds = musicLibraryConfig.presentation.filterDefinitions
        .map((definition) => definition.id)
        .toSet();

    expect(comicFilterIds, contains('grade'));
    expect(
      comicsLibraryConfig.presentation.filterDefinitions
          .firstWhere((definition) => definition.id == 'grade')
          .missingValueLabel,
      'Missing grade',
    );
    expect(musicFilterIds, isNot(contains('grade')));
  });
}
