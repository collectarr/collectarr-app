import '../../../support/fakes/music_catalog_api_fake.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library metadata search parses results into metadata items', () async {
    final api = MusicCatalogApiFake();

    final results = await searchLibraryMetadata(
      api,
      musicKindIdentity.kind,
      query: 'Batman',
      series: 'Batman',
      issueNumber: '1',
      year: 1940,
    );

    expect(api.lastSearchQuery?.query, 'Batman');
    expect(api.lastSearchQuery?.kind, 'music');
    expect(api.lastSearchQuery?.series, 'Batman');
    expect(api.lastSearchQuery?.issueNumber, isNull);
    expect(api.lastSearchQuery?.year, 1940);
    expect(results.single.reference.id, 'music-1');
    expect(results.single.kindCapability.toImportTransport().payload.keys,
        isNot(contains('created_at')));
    expect(results.single.kindCapability.toImportTransport().payload.keys,
        isNot(contains('updated_at')));
  });

  test('library barcode lookup parses result into metadata item', () async {
    final api = MusicCatalogApiFake();

    final result = await lookupLibraryBarcode(
      api,
      musicKindIdentity.kind,
      '012-345-678-905',
    );

    expect(api.lastBarcode, '012345678905');
    expect(api.lastBarcodeKind, 'music');
    expect(result.reference.id, 'music-1');
  });
}
