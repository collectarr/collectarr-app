import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/controller.dart';
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
    final controller =
        ComicEditController(item: original, itemImages: const []);
    controller.initialize();
    addTearDown(controller.dispose);
    controller.seriesTitleController.text = 'A different series';
    controller.subtitleController.text = 'New subtitle';
    controller.variantDescriptionController.text = 'Foil cover';
    final updated = controller.buildMetadata(original);
    expect(updated.title, 'The issue title');
    expect(updated.seriesTitle, 'A different series');
    expect(updated.subtitle, 'New subtitle');
    expect(updated.variantDescription, 'Foil cover');
    expect(updated.editionTitle, 'Collected edition');
    controller.subtitleController.clear();
    controller.variantDescriptionController.clear();
    final cleared = controller.buildMetadata(updated);
    expect(cleared.subtitle, isNull);
    expect(cleared.variantDescription, isNull);
    controller.coverDateParts = const PartialDate(year: 2020);
    controller.releaseDateParts = const PartialDate(year: 2020, month: 5);
    final dated = controller.buildMetadata(cleared);
    expect(dated.coverDateParts, const PartialDate(year: 2020));
    expect(dated.releaseDateParts, const PartialDate(year: 2020, month: 5));
    expect(dated.coverDate, isNull);
    expect(dated.releaseDate, isNull);
    controller.coverDateParts = null;
    controller.releaseDateParts = null;
    final undated = controller.buildMetadata(dated);
    expect(undated.coverDateParts, isNull);
    expect(undated.releaseDateParts, isNull);
  });
}
