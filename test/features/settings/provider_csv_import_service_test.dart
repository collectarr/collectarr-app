import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/features/imports/framework/import_models.dart';
import 'package:collectarr_app/features/settings/provider_csv_import_service.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses IMDb CSV exports into normalized rows', () {
    const csv = '''
const,Title,Title type,You rated,Year,Release Date
tt0133093,The Matrix,movie,9,1999,1999-03-31
tt0944947,Game of Thrones,tvSeries,8,2011,2011-04-17
''';

    final service = ProviderCsvImportService();
    final rows = service.parseFileBytes(
      Uint8List.fromList(utf8.encode(csv)),
      fileName: 'imdb.csv',
      provider: ProviderImportId.imdb,
    );

    expect(rows, hasLength(2));
    expect(rows[0].sourceId, 'tt0133093');
    expect(rows[0].title, 'The Matrix');
    expect(rows[0].mediaKind, 'movie');
    expect(rows[0].rating, 90);
    expect(rows[0].externalIds['imdb'], 'tt0133093');
    expect(rows[1].sourceId, 'tt0944947');
    expect(rows[1].mediaKind, 'tv');
  });

  test('parses Goodreads CSV exports into normalized book rows', () {
    const csv = '''
Book Id,Title,Author,My Rating,Exclusive Shelf,Date Read
1,Foundation,Isaac Asimov,4,read,2024-01-02
''';

    final service = ProviderCsvImportService();
    final rows = service.parseFileBytes(
      Uint8List.fromList(utf8.encode(csv)),
      fileName: 'goodreads.csv',
      provider: ProviderImportId.goodReads,
    );

    expect(rows, hasLength(1));
    expect(rows[0].sourceId, '1');
    expect(rows[0].title, 'Foundation');
    expect(rows[0].mediaKind, 'book');
    expect(rows[0].status, ImportItemStatus.completed);
    expect(rows[0].rating, 80);
  });
}
