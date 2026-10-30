import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/import/comic_mapped_csv_importer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const importer = ComicMappedCsvImporter();
  test('preserves distinct publication, grading and personal CSV fields', () {
    const keys = [
      'series',
      'title',
      'subtitle',
      'issue',
      'variant',
      'variant_description',
      'age',
      'age_rating',
      'cover_date',
      'release_date',
      'quantity',
      'grade',
      'key',
      'raw_or_slabbed',
      'certification_number',
      'read',
      'read_date',
      'writer'
    ];
    const row = [
      'Example Series',
      'Issue Title',
      'Issue Subtitle',
      '1/2',
      'B',
      'Foil',
      'Modern',
      'Teen',
      '2024',
      '2024-05',
      '2',
      '9.8',
      'Major',
      'Slabbed',
      '12345',
      'Yes',
      '2024-06-01',
      'Example Writer'
    ];
    final records = importer.parse([
      row
    ], mappings: {
      for (var i = 0; i < keys.length; i++) i: keys[i],
    }, multiValueDelimiter: '|');
    final record = records.single.fullEntryPayload!;
    final catalog = record['catalog_data'] as Map;
    final personal = record['personal_data'] as Map;
    expect(catalog['series_title'], 'Example Series');
    expect(catalog['title'], 'Issue Title');
    expect(catalog['subtitle'], 'Issue Subtitle');
    expect(catalog['issue_number'], '1/2');
    expect(catalog['variant'], 'B');
    expect(catalog['variant_description'], 'Foil');
    expect(catalog['publication_age'], 'Modern');
    expect(catalog['age_rating'], 'Teen');
    expect(catalog['cover_date'], {'year': 2024});
    expect(catalog['release_date_parts'], {'year': 2024, 'month': 5});
    expect(personal['quantity'], 2);
    expect(personal['grade'], '9.8');
    expect(personal['key_comic'], true);
    expect(personal['key_severity'], 'Major');
    expect(personal['certification_number'], '12345');
    expect((personal['reading'] as Map)['status'], 'Read');
    // The review row names the issue as the reference list does.
    expect(records.single.kindDisplayTitle, 'Example Series #1/2B');
    expect(records.single.kindDisplaySubtitle, 'Issue Title');
  });

  test('series-only CSV is deterministic and cannot drop additional copies',
      () {
    final rows = importer.parse([
      ['Example Series'],
      ['Example Series']
    ], mappings: {
      0: 'series'
    }, multiValueDelimiter: '|');
    final repeat = importer.parse([
      ['Example Series'],
      ['Example Series']
    ], mappings: {
      0: 'series'
    }, multiValueDelimiter: '|');
    expect(rows.map((row) => row.itemId), repeat.map((row) => row.itemId));
    expect(rows.map((row) => row.itemId).toSet(), hasLength(2));
    expect(rows.first.title, 'Example Series');
    expect(rows.first.kindDisplaySubtitle, isNull);
    // An empty Title stays empty instead of copying the Series.
    final catalog = rows.first.fullEntryPayload!['catalog_data'] as Map;
    expect(catalog['title'], '');
  });

  test('invalid key significance fails before importing any record', () {
    expect(
        () => importer.parse([
              ['Example', 'Unknown']
            ], mappings: {
              0: 'series',
              1: 'key'
            }, multiValueDelimiter: '|'),
        throwsA(isA<LibraryImportFormatException>()));
  });
}
