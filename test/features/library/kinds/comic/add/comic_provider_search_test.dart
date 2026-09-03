import 'dart:convert';

import 'package:collectarr_app/features/library/kinds/comic/add/comic_provider_search.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockHttpAdapter implements HttpClientAdapter {
  _MockHttpAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('GCD integration maps provider-native issue search data', () async {
    final dio = Dio();
    dio.httpClientAdapter = _MockHttpAdapter((options) async {
      return ResponseBody.fromString(
        jsonEncode({
          'results': [
            {
              'id': 12345,
              'api_url': '/issue/12345/',
              'series_name': 'The Amazing Spider-Man (1963 series)',
              'descriptor': '300',
              'publication_date': 'May 1988',
              'price': '1.50 USD',
              'cover': 'https://example.test/gcd.jpg',
              'variant_of': null,
              'story_set': [
                {
                  'characters': 'Spider-Man; Venom (first appearance)',
                  'part_of_issue_story_arc': 'Venom',
                },
              ],
            },
          ],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
    final provider = GCDProvider(
      httpClient: ProviderHttpClient(
        provider: 'gcd',
        baseUrl: 'https://www.comics.org/api',
        dio: dio,
      ),
    );

    final candidates = await searchComicProvider(
      provider.toConnector(),
      query: 'Amazing Spider-Man #300',
      kind: 'comic',
      limit: 25,
    );

    expect(candidates, hasLength(1));
    final candidate = candidates.single;
    expect(candidate.providerItemId, '12345');
    expect(candidate.series?.seriesTitle, 'The Amazing Spider-Man');
    expect(candidate.issueNumber, '300');
    expect(candidate.candidateType, 'issue');
    expect(candidate.characterPreview, containsAll(['Spider-Man', 'Venom']));
    expect(candidate.storyArcPreview, contains('Venom'));
  });

  test('Comic Vine integration maps provider-native issue search data',
      () async {
    final dio = Dio();
    dio.httpClientAdapter = _MockHttpAdapter((options) async {
      return ResponseBody.fromString(
        jsonEncode({
          'results': [
            {
              'id': 160294,
              'name': 'The Zoo',
              'issue_number': '1',
              'volume': {
                'name': 'Absolute Batman',
                'start_year': '2024',
                'publisher': {'name': 'DC Comics'},
              },
              'image': {
                'scale_large': 'https://example.test/comicvine.jpg',
              },
            },
          ],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
    final provider = ComicVineProvider(
      credentials: const ComicVineCredentials(apiKey: 'test-key'),
      httpClient: ProviderHttpClient(
        provider: 'comicvine',
        baseUrl: 'https://comicvine.gamespot.com/api',
        dio: dio,
      ),
    );

    final candidates = await searchComicProvider(
      provider.toConnector(),
      query: 'Absolute Batman',
      kind: 'comic',
      limit: 25,
    );

    expect(candidates, hasLength(1));
    final candidate = candidates.single;
    expect(candidate.providerItemId, '4000-160294');
    expect(candidate.series?.seriesTitle, 'Absolute Batman');
    expect(candidate.series?.volumeStartYear, 2024);
    expect(candidate.issueNumber, '1');
    expect(candidate.publisher, 'DC Comics');
  });
}
