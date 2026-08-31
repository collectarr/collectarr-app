import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/settings/provider_csv_import_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses IMDb CSV exports into ProviderPersonalEntry', () {
    const csv = '''
const,Title,Title type,You rated,Year,Release Date
tt0133093,The Matrix,movie,9,1999,1999-03-31
tt0944947,Game of Thrones,tvSeries,8,2011,2011-04-17
''';

    final service = ProviderCsvImportService();
    final entries = service.parseFileBytes(
      Uint8List.fromList(utf8.encode(csv)),
      fileName: 'imdb.csv',
      provider: ProviderId.imdb,
    );

    expect(entries, hasLength(2));
    expect(entries[0].remoteItemId, 'tt0133093');
    expect(entries[0].title, 'The Matrix');
    expect(entries[0].kind, CatalogMediaKind.movie);
    expect(entries[0].rating, 90.0);
    expect(entries[0].externalIds['imdb'], 'tt0133093');
    expect(entries[1].remoteItemId, 'tt0944947');
    expect(entries[1].kind, CatalogMediaKind.tv);
  });

  test('parses Goodreads CSV exports into ProviderPersonalEntry book rows', () {
    const csv = '''
Book Id,Title,Author,My Rating,Exclusive Shelf,Date Read
1,Foundation,Isaac Asimov,4,read,2024-01-02
''';

    final service = ProviderCsvImportService();
    final entries = service.parseFileBytes(
      Uint8List.fromList(utf8.encode(csv)),
      fileName: 'goodreads.csv',
      provider: ProviderId.goodReads,
    );

    expect(entries, hasLength(1));
    expect(entries[0].remoteItemId, '1');
    expect(entries[0].title, 'Foundation');
    expect(entries[0].kind, CatalogMediaKind.book);
    expect(entries[0].status, ProviderEntryStatus.completed);
    expect(entries[0].rating, 80.0);
  });
}
