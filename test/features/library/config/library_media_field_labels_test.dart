import 'package:collectarr_app/features/library/config/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('video libraries use physical edition terminology', () {
    final labels = libraryMediaPreviewLabels(const MovieRegistration());
    expect(labels.labelFor('publisher'), 'Studio');
    expect(labels.labelFor('variant'), 'Format / Edition');
    expect(labels.labelFor('barcode'), 'UPC / Barcode');
    expect(labels.labelFor('item_number'), 'Edition no.');
  });

  test('books and games use media-specific barcode and edition labels', () {
    expect(
        libraryMediaPreviewLabels(const BookRegistration()).labelFor('barcode'),
        'ISBN / Barcode');
    expect(
        libraryMediaPreviewLabels(const BookRegistration()).labelFor('variant'),
        'Edition / Binding');
    expect(
        libraryMediaPreviewLabels(const GameRegistration()).labelFor('variant'),
        'Platform / Edition');
    expect(
        libraryMediaPreviewLabels(const GameRegistration())
            .labelFor('publisher'),
        'Publisher / Studio');
  });

  test('music search labels use artist terminology', () {
    final musicLabels =
        libraryMediaSearchFieldLabels(const MusicRegistration());
    final movieLabels =
        libraryMediaSearchFieldLabels(const MovieRegistration());

    expect(musicLabels.queryHint, 'Enter album, artist, release, or label...');
    expect(musicLabels.emptySearchMessage,
        'Enter an album, artist, release, or label.');
    expect(movieLabels.queryHint, 'Enter title, creator, or keyword...');
  });

  test('filter labels vary by media type', () {
    final musicLabels = libraryMediaFilterLabels(const MusicRegistration());
    final movieLabels = libraryMediaFilterLabels(const MovieRegistration());
    final gameLabels = libraryMediaFilterLabels(const GameRegistration());

    expect(musicLabels.labelFor('series'), 'Artist');
    expect(musicLabels.labelFor('series_any'), 'Any artist');
    expect(musicLabels.labelFor('publisher'), 'Label');
    expect(movieLabels.labelFor('publisher'), 'Studio');
    expect(movieLabels.labelFor('publisher_any'), 'Any studio');
    expect(gameLabels.labelFor('publisher'), 'Publisher / Studio');
  });

  test('group labels vary by media type', () {
    final musicLabels = libraryMediaGroupLabels(const MusicRegistration());
    final movieLabels = libraryMediaGroupLabels(const MovieRegistration());

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
    final musicLabels = libraryMediaPreviewLabels(const MusicRegistration());
    final movieLabels = libraryMediaPreviewLabels(const MovieRegistration());
    final bookLabels = libraryMediaPreviewLabels(const BookRegistration());

    expect(musicLabels.labelFor('series'), 'Artist');
    expect(musicLabels.labelFor('item_count'), 'Releases');
    expect(movieLabels.labelFor('series'), 'Series');
    expect(movieLabels.labelFor('item_count'), 'Items');
    expect(bookLabels.labelFor('item_count'), 'Volumes');
  });

  test('stats labels and candidate layout vary by media type', () {
    expect(musicKindModule.presentation.statsLabels.labelFor('top_series'),
        'Top Artists');
    expect(musicKindModule.presentation.statsLabels.labelFor('top_publisher'),
        'Top Labels');
    expect(movieKindModule.presentation.statsLabels.labelFor('top_series'),
        'Top Franchises');
    expect(gameKindModule.presentation.statsLabels.labelFor('top_publisher'),
        'Top Publishers / Studios');
    expect(comicKindModule.metadata.usesTreeProviderCandidates, isTrue);
    expect(bookKindModule.metadata.usesTreeProviderCandidates, isFalse);
  });

  test('filter definitions are kind-owned and grade is not universal', () {
    final comicFilterIds = comicKindModule.presentation.filterDefinitions
        .map((definition) => definition.id)
        .toSet();
    final musicFilterIds = musicKindModule.presentation.filterDefinitions
        .map((definition) => definition.id)
        .toSet();

    expect(comicFilterIds, contains('grade'));
    expect(
      comicKindModule.presentation.filterDefinitions
          .firstWhere((definition) => definition.id == 'grade')
          .missingValueLabel,
      'Missing grade',
    );
    expect(musicFilterIds, isNot(contains('grade')));
  });
}
