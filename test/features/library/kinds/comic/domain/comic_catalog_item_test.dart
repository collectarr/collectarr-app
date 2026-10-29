import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a stored full release date keeps its exact date', () {
    final stored = ComicCatalogItem(
      title: '',
      releaseDateParts: const PartialDate(year: 2024, month: 11, day: 13),
      releaseDate: DateTime.utc(2024, 11, 13),
    ).toJson();
    final item = ComicCatalogItem.fromJson(stored);
    expect(item.releaseDate, DateTime.utc(2024, 11, 13));
    expect(item.releaseDateParts,
        const PartialDate(year: 2024, month: 11, day: 13));
  });

  test('a stored partial release date has no exact date', () {
    final stored = ComicCatalogItem(
      title: '',
      releaseDateParts: const PartialDate(year: 2024, month: 5),
    ).toJson();
    expect(ComicCatalogItem.fromJson(stored).releaseDate, isNull);
  });
}
