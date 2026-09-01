import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library metadata search parses results into metadata items', () async {
    final api = _FakeLibraryMetadataApiClient();

    final results = await searchLibraryMetadata(
      api,
      comicKindModule,
      query: 'Batman',
      series: 'Batman',
      issueNumber: '1',
      year: 1940,
    );

    expect(api.lastSearchQuery?.query, 'Batman');
    expect(api.lastSearchQuery?.kind, 'comic');
    expect(api.lastSearchQuery?.series, 'Batman');
    expect(api.lastSearchQuery?.issueNumber, '1');
    expect(api.lastSearchQuery?.year, 1940);
    expect(results.single.id, 'comic-1');
  });

  test('library barcode lookup parses result into metadata item', () async {
    final api = _FakeLibraryMetadataApiClient();

    final result = await lookupLibraryBarcode(
      api,
      comicKindModule,
      '7619-411',
    );

    expect(api.lastBarcode, '7619-411');
    expect(api.lastBarcodeKind, 'comic');
    expect(result.id, 'comic-1');
  });
}

class _FakeLibraryMetadataApiClient extends ApiClient {
  _FakeLibraryMetadataApiClient() : super(baseUrl: 'http://unused');

  MetadataSearchQuery? lastSearchQuery;
  String? lastBarcode;
  String? lastBarcodeKind;

  @override
  Future<List<Map<String, dynamic>>> searchMetadata(
    MetadataSearchQuery query,
  ) async {
    lastSearchQuery = query;
    return const [
      {
        'id': 'comic-1',
        'kind': 'comic',
        'title': 'Batman',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> lookupBarcode(
    String barcode, {
    String? kind,
  }) async {
    lastBarcode = barcode;
    lastBarcodeKind = kind;
    return const {
      'id': 'comic-1',
      'kind': 'comic',
      'title': 'Batman',
    };
  }
}
