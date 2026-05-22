import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library metadata query uses the library kind', () {
    final query = libraryMetadataSearchQuery(
      comicsLibraryConfig,
      query: 'Spider-Man',
      issueNumber: '1',
      barcode: '7596-060',
      limit: 10,
    );

    expect(query.kind, 'comic');
    expect(query.toQueryParameters(), {
      'q': 'Spider-Man',
      'kind': 'comic',
      'issue_number': '1',
      'barcode': '7596060',
      'limit': 10,
    });
  });

  test('library metadata search parses catalog items and sends kind', () async {
    final api = _FakeLibraryMetadataApiClient();

    final results = await searchLibraryMetadata(
      api,
      comicsLibraryConfig,
      query: 'Batman',
      limit: 5,
    );

    expect(api.lastSearchQuery?.kind, 'comic');
    expect(api.lastSearchQuery?.query, 'Batman');
    expect(results.single.id, 'comic-1');
    expect(results.single.kind, 'comic');
  });

  test('library barcode lookup sends the library kind', () async {
    final api = _FakeLibraryMetadataApiClient();

    final result = await lookupLibraryBarcode(
      api,
      comicsLibraryConfig,
      '7619-411',
    );

    expect(api.lastBarcode, '7619-411');
    expect(api.lastBarcodeKind, 'comic');
    expect(result.id, 'comic-1');
  });

  test('library provider search parses candidates with fallback kind',
      () async {
    final api = _FakeLibraryMetadataApiClient();

    final results = await searchLibraryProviderCandidates(
      api,
      comicsLibraryConfig,
      provider: 'gcd',
      query: 'Batman #1',
      series: 'Batman',
      issueNumber: '1',
      year: 1940,
    );

    expect(api.lastProvider, 'gcd');
    expect(api.lastProviderKind, 'comic');
    expect(api.lastProviderSeries, 'Batman');
    expect(api.lastProviderIssueNumber, '1');
    expect(api.lastProviderYear, 1940);
    expect(results.single.providerItemId, 'gcd-1');
    expect(results.single.kind, 'comic');
  });

  test('library provider search can let Core choose provider', () async {
    final api = _FakeLibraryMetadataApiClient();

    await searchLibraryProviderCandidates(
      api,
      comicsLibraryConfig,
      query: 'Batman #1',
    );

    expect(api.lastProvider, isNull);
    expect(api.lastProviderKind, 'comic');
  });
}

class _FakeLibraryMetadataApiClient extends ApiClient {
  _FakeLibraryMetadataApiClient() : super(baseUrl: 'http://unused');

  MetadataSearchQuery? lastSearchQuery;
  String? lastBarcode;
  String? lastBarcodeKind;
  String? lastProvider;
  String? lastProviderQuery;
  String? lastProviderKind;
  String? lastProviderSeries;
  String? lastProviderIssueNumber;
  int? lastProviderYear;

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
  Future<Map<String, dynamic>> lookupBarcode(String barcode,
      {String? kind}) async {
    lastBarcode = barcode;
    lastBarcodeKind = kind;
    return const {
      'id': 'comic-1',
      'kind': 'comic',
      'title': 'Batman',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> searchProvider({
    String? provider,
    required String query,
    String? kind,
    String? series,
    String? issueNumber,
    int? year,
  }) async {
    lastProvider = provider;
    lastProviderQuery = query;
    lastProviderKind = kind;
    lastProviderSeries = series;
    lastProviderIssueNumber = issueNumber;
    lastProviderYear = year;
    return const [
      {
        'provider': 'gcd',
        'provider_item_id': 'gcd-1',
        'title': 'Batman #1',
      },
    ];
  }
}
