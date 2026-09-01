import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every registered kind has non-empty field labels', () {
    for (final module in collectarrKindModules) {
      expect(module.edit.mediaFields.numberLabel, isNotEmpty,
          reason:
              '${module.identity.singularLabel} mediaFields.numberLabel is empty');
      expect(module.edit.mediaFields.publisherLabel, isNotEmpty,
          reason:
              '${module.identity.singularLabel} mediaFields.publisherLabel is empty');
      expect(module.edit.releaseFields.variantLabel, isNotEmpty,
          reason:
              '${module.identity.singularLabel} releaseFields.variantLabel is empty');
      expect(module.edit.releaseFields.barcodeLabel, isNotEmpty,
          reason:
              '${module.identity.singularLabel} releaseFields.barcodeLabel is empty');
    }
  });

  test('print media kinds enable page count, imprint, and series group', () {
    for (final module in [comicKindModule, bookKindModule]) {
      expect(module.edit.mediaFields.showPageCount, isTrue,
          reason: '${module.identity.singularLabel} should show page count');
      expect(module.edit.mediaFields.showImprint, isTrue,
          reason: '${module.identity.singularLabel} should show imprint');
      expect(module.edit.mediaFields.showSeriesGroup, isTrue,
          reason: '${module.identity.singularLabel} should show series group');
    }
  });

  test('non-print media kinds disable book-specific fields', () {
    for (final module in [
      movieKindModule,
      gameKindModule,
      boardGameKindModule,
      musicKindModule,
    ]) {
      expect(module.edit.mediaFields.showPageCount, isFalse,
          reason:
              '${module.identity.singularLabel} should not show page count');
      expect(module.edit.mediaFields.showImprint, isFalse,
          reason: '${module.identity.singularLabel} should not show imprint');
      expect(module.edit.mediaFields.showSeriesGroup, isFalse,
          reason:
              '${module.identity.singularLabel} should not show series group');
    }
  });

  test('top-level library registry exposes split manga/anime/tv kinds', () {
    expect(
      defaultLibraryKindRegistry.allRuntimes
          .map((runtime) => runtime.kind.apiValue),
      containsAll(['comic', 'manga', 'movie', 'tv', 'anime']),
    );
  });

  test('merged movie and comic configs expose the kept labels', () {
    expect(movieKindModule.edit.mediaFields.publisherLabel, 'Studio');
    expect(comicKindModule.edit.mediaFields.publisherLabel,
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
    expect(movieKindModule.edit.mediaFields.publisherLabel, 'Studio');
    expect(movieKindModule.edit.releaseFields.variantLabel, 'Format / Edition');
    expect(movieKindModule.edit.releaseFields.barcodeLabel, 'UPC / Barcode');

    expect(bookKindModule.edit.releaseFields.barcodeLabel, 'ISBN / Barcode');
    expect(
        gameKindModule.edit.releaseFields.variantLabel, 'Platform / Edition');
    expect(musicKindModule.edit.mediaFields.publisherLabel, 'Label');
  });
}
