import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_creator.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_character.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/catalog_form_adapters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('series edits preserve issue title and independent publication fields',
      () {
    const ref = CatalogItemRef(kind: CatalogMediaKind.comic, id: 'issue-1');
    const original = ComicCatalogItem(
      id: ref,
      title: 'The issue title',
      seriesTitle: 'The series',
      subtitle: 'Original subtitle',
      variantDescription: 'Regular Edition',
      editionTitle: 'Collected edition',
    );
    final controller = comicCatalogItemFormValuesFrom(original);
    controller.seriesTitle = 'A different series';
    controller.subtitle = 'New subtitle';
    controller.variantDescription = 'Foil cover';
    final updated =
        comicCatalogItemFromFormValues(original: original, values: controller);
    expect(updated.title, 'The issue title');
    expect(updated.seriesTitle, 'A different series');
    expect(updated.subtitle, 'New subtitle');
    expect(updated.variantDescription, 'Foil cover');
    expect(updated.editionTitle, 'Collected edition');
    controller.subtitle = '';
    controller.variantDescription = '';
    final cleared =
        comicCatalogItemFromFormValues(original: updated, values: controller);
    expect(cleared.subtitle, isNull);
    expect(cleared.variantDescription, isNull);
    controller.coverDateParts = const PartialDate(year: 2020);
    controller.releaseDateParts = const PartialDate(year: 2020, month: 5);
    final dated =
        comicCatalogItemFromFormValues(original: cleared, values: controller);
    expect(dated.coverDateParts, const PartialDate(year: 2020));
    expect(dated.releaseDateParts, const PartialDate(year: 2020, month: 5));
    expect(dated.coverDate, isNull);
    expect(dated.releaseDate, isNull);
    controller.coverDateParts = null;
    controller.releaseDateParts = null;
    final undated =
        comicCatalogItemFromFormValues(original: dated, values: controller);
    expect(undated.coverDateParts, isNull);
    expect(undated.releaseDateParts, isNull);
  });

  test('key comic, credits and appearances survive a JSON round-trip', () {
    const item = ComicCatalogItem(
      title: 'Issue',
      isKeyComic: true,
      creators: [
        ComicCreator(name: 'Core Writer', role: 'Writer', personId: 'p-1'),
        ComicCreator(name: 'Typed Inker', role: 'Inker'),
      ],
      characters: [
        ComicCharacter(name: 'Core Hero', characterId: 'c-1'),
        ComicCharacter(name: 'Typed Sidekick'),
      ],
    );
    final reloaded = ComicCatalogItem.fromJson(item.toJson());
    expect(reloaded.isKeyComic, isTrue);
    expect([
      for (final c in reloaded.creators) (c.name, c.personId)
    ], [
      ('Core Writer', 'p-1'),
      ('Typed Inker', null),
    ]);
    expect([
      for (final c in reloaded.characters) (c.name, c.characterId)
    ], [
      ('Core Hero', 'c-1'),
      ('Typed Sidekick', null),
    ]);
  });
}
