import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/library/kinds/book/integrations/import/mapped_csv_importer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const importer = BookMappedCsvImporter();
  test('Books CSV preserves edition, credits and personal data', () {
    const keys = [
      'title',
      'isbn',
      'author',
      'publication_date',
      'pages',
      'genre',
      'condition',
      'purchase_price',
      'signed_by'
    ];
    const row = [
      'A Book',
      '9780000000000',
      'First | Second',
      '2020-05',
      '240',
      'Fantasy | Adventure',
      'Good',
      '12.50',
      'First'
    ];
    final rows = importer.parse([row, row],
        mappings: {for (var i = 0; i < keys.length; i++) i: keys[i]},
        multiValueDelimiter: '|');
    final again = importer.parse([row, row],
        mappings: {for (var i = 0; i < keys.length; i++) i: keys[i]},
        multiValueDelimiter: '|');
    expect(rows.map((r) => r.itemId), again.map((r) => r.itemId));
    expect(rows.map((r) => r.itemId).toSet(), hasLength(2));
    final record = rows.first.fullEntryPayload!;
    final catalog = record['catalog_data'] as Map;
    final personal = record['personal_data'] as Map;
    expect(catalog['isbn'], '9780000000000');
    expect(catalog['page_count'], 240);
    expect(catalog['release_date_parts'], {'year': 2020, 'month': 5});
    expect(catalog['genres'], ['Fantasy', 'Adventure']);
    expect((catalog['creators'] as List).length, 2);
    expect(personal['condition'], 'Good');
    expect(personal['price_paid_cents'], 1250);
    expect(personal['signed_by'], 'First');
  });

  test('Books CSV requires a title in each row', () {
    expect(
        () => importer.parse([
              ['']
            ], mappings: {
              0: 'title'
            }, multiValueDelimiter: '|'),
        throwsA(isA<LibraryImportFormatException>()));
  });

  test('Books CSV rejects invalid values instead of importing partial data',
      () {
    expect(
        () => importer.parse([
              ['Book', 'bad']
            ], mappings: {
              0: 'title',
              1: 'pages'
            }, multiValueDelimiter: '|'),
        throwsA(isA<LibraryImportFormatException>()));
  });
}
