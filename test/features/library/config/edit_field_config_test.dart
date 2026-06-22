import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every registered kind has non-empty field labels', () {
    for (final type in collectarrLibraryTypes.types) {
      expect(type.mediaFields.numberLabel, isNotEmpty,
          reason: '${type.singularLabel} mediaFields.numberLabel is empty');
      expect(type.mediaFields.publisherLabel, isNotEmpty,
          reason: '${type.singularLabel} mediaFields.publisherLabel is empty');
      expect(type.releaseFields.variantLabel, isNotEmpty,
          reason: '${type.singularLabel} releaseFields.variantLabel is empty');
      expect(type.releaseFields.barcodeLabel, isNotEmpty,
          reason: '${type.singularLabel} releaseFields.barcodeLabel is empty');
    }
  });

  test('print media kinds enable page count, imprint, and series group', () {
    for (final type in [comicsLibraryConfig, booksLibraryConfig]) {
      expect(type.mediaFields.showPageCount, isTrue,
          reason: '${type.singularLabel} should show page count');
      expect(type.mediaFields.showImprint, isTrue,
          reason: '${type.singularLabel} should show imprint');
      expect(type.mediaFields.showSeriesGroup, isTrue,
          reason: '${type.singularLabel} should show series group');
    }
  });

  test('non-print media kinds disable book-specific fields', () {
    for (final type in [
      moviesLibraryConfig,
      gamesLibraryConfig,
      boardGamesLibraryConfig,
      musicLibraryConfig,
    ]) {
      expect(type.mediaFields.showPageCount, isFalse,
          reason: '${type.singularLabel} should not show page count');
      expect(type.mediaFields.showImprint, isFalse,
          reason: '${type.singularLabel} should not show imprint');
      expect(type.mediaFields.showSeriesGroup, isFalse,
          reason: '${type.singularLabel} should not show series group');
    }
  });

  test('top-level library registry exposes split manga/anime/tv kinds', () {
    expect(
      collectarrLibraryTypes.supportedKinds,
      containsAll(['comic', 'manga', 'movie', 'tv', 'anime']),
    );
  });

  test('merged movie and comic configs expose the kept labels', () {
    expect(moviesLibraryConfig.mediaFields.publisherLabel, 'Studio');
    expect(comicsLibraryConfig.mediaFields.publisherLabel,
        'Publisher / Studio / Creator');
  });

  test('MediaEditFields.print constructor sets all print flags', () {
    const fields = MediaEditFields.print(numberLabel: 'Issue');
    expect(fields.showPageCount, isTrue);
    expect(fields.showImprint, isTrue);
    expect(fields.showSeriesGroup, isTrue);
    expect(fields.numberLabel, 'Issue');
    expect(fields.publisherLabel, 'Publisher');
  });

  test('field config labels are the single source of truth for display labels',
      () {
    // Verify that the labels on mediaFields/releaseFields are the single
    // source of truth for all display label needs.
    expect(moviesLibraryConfig.mediaFields.publisherLabel, 'Studio');
    expect(moviesLibraryConfig.releaseFields.variantLabel, 'Format / Edition');
    expect(moviesLibraryConfig.releaseFields.barcodeLabel, 'UPC / Barcode');

    expect(booksLibraryConfig.releaseFields.barcodeLabel, 'ISBN / Barcode');
    expect(gamesLibraryConfig.releaseFields.variantLabel, 'Platform / Edition');
    expect(musicLibraryConfig.mediaFields.publisherLabel, 'Label');
  });
}
