import 'dart:convert';
import 'dart:io';

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
  group('OpenLibraryProvider', () {
    test('exposes correct descriptor metadata', () {
      final provider = OpenLibraryProvider();
      expect(provider.name, 'openlibrary');
      expect(provider.descriptor.displayName, 'Open Library');
      expect(provider.descriptor.kind, 'book');
      expect(provider.descriptor.supportedKinds, ['book']);
      expect(provider.descriptor.requiresUserKey, isFalse);
      expect(provider.isConfigured, isTrue);
      expect(provider.statusMessage, contains('without an API key'));
    });

    test('search parses docs and formats summary', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path, '/search.json');
        expect(options.queryParameters['q'], 'The Hobbit');
        return ResponseBody.fromString(
          jsonEncode({
            'docs': [
              {
                'key': '/works/OL27479W',
                'title': 'The Hobbit',
                'author_name': ['J.R.R. Tolkien'],
                'first_publish_year': 1937,
                'edition_key': ['OL82563M'],
                'publisher': ['George Allen & Unwin'],
                'cover_i': 12345,
              }
            ]
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = ProviderHttpClient(
        provider: 'openlibrary',
        baseUrl: 'https://openlibrary.org',
        dio: dio,
      );
      final provider = OpenLibraryProvider(httpClient: client);

      final results = await provider.search('The Hobbit');
      expect(results, hasLength(1));
      final item = results.first;
      expect(item.provider, 'openlibrary');
      expect(item.providerItemId, 'OL82563M');
      expect(item.title, 'The Hobbit');
      expect(item.summary, 'J.R.R. Tolkien · 1937 · George Allen & Unwin');
      expect(item.imageUrl, 'https://covers.openlibrary.org/b/id/12345-L.jpg');
    });

    test('searchByBarcode formats ISBN query', () async {
      String? queriedQ;
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        queriedQ = options.queryParameters['q']?.toString();
        return ResponseBody.fromString(
          jsonEncode({'docs': <dynamic>[]}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final client = ProviderHttpClient(
        provider: 'openlibrary',
        baseUrl: 'https://openlibrary.org',
        dio: dio,
      );
      final provider = OpenLibraryProvider(httpClient: client);

      await provider.searchByBarcode('978-0-261-10235-4');
      expect(queriedQ, 'isbn:9780261102354');
    });

    test('fetchItem fetches edition and work and outputs valid envelope',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter((options) async {
        if (options.path.contains('/books/OL82563M.json')) {
          return ResponseBody.fromString(
            jsonEncode({
              'key': '/books/OL82563M',
              'title': 'The Fellowship of the Ring',
              'subtitle': 'Being the First Part of The Lord of the Rings',
              'description': 'The first volume of the epic high-fantasy novel.',
              'number_of_pages': 423,
              'publishers': ['George Allen & Unwin'],
              'isbn_13': ['9780261102354'],
              'covers': [12345],
              'works': [
                {'key': '/works/OL27479W'}
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else if (options.path.contains('/works/OL27479W.json')) {
          return ResponseBody.fromString(
            jsonEncode({
              'key': '/works/OL27479W',
              'title': 'The Fellowship of the Ring',
              'subjects': ['Fantasy', 'Adventure'],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final client = ProviderHttpClient(
        provider: 'openlibrary',
        baseUrl: 'https://openlibrary.org',
        dio: dio,
      );
      final provider = OpenLibraryProvider(httpClient: client);

      final envelope = await provider.fetchItem('OL82563M');
      expect(envelope.schemaVersion, 'v1');
      expect(envelope.provider, 'openlibrary');
      expect(envelope.kind, 'book');
      expect(envelope.normalized['title'], 'The Fellowship of the Ring');
      expect(envelope.normalized['subtitle'],
          'Being the First Part of The Lord of the Rings');
      expect(envelope.normalized['page_count'], 423);
      expect(envelope.normalized['publisher'], 'George Allen & Unwin');
      expect(envelope.normalized['isbn'], '9780261102354');
      expect(
          envelope.normalized['genres'], containsAll(['Fantasy', 'Adventure']));
      expect(envelope.images, hasLength(1));
      expect(envelope.images.first.url,
          'https://covers.openlibrary.org/b/id/12345-L.jpg');
      expect(envelope.attribution.required, isTrue);
    });

    test('validates parity with Core golden fixture for Open Library', () {
      final fixturesFile =
          File('tool/core_contracts/golden-provider-envelopes.json');
      expect(fixturesFile.existsSync(), isTrue);

      final jsonList =
          jsonDecode(fixturesFile.readAsStringSync()) as List<dynamic>;
      final olFixtureRaw = jsonList.firstWhere(
        (f) => f is Map && f['provider'] == 'openlibrary',
        orElse: () => null,
      );
      expect(olFixtureRaw, isNotNull);

      final goldenEnvelope = NormalizedProviderEnvelopeV1.fromJson(
        Map<String, dynamic>.from(olFixtureRaw as Map),
      );

      final provider = OpenLibraryProvider();
      final normalized = provider.normalize(
        workRaw: {
          'key': '/works/OL27479W',
          'title': 'The Fellowship of the Ring',
          'subjects': ['Fantasy', 'Adventure'],
        },
        editionRaw: {
          'key': '/books/OL82563M',
          'title': 'The Fellowship of the Ring',
          'subtitle': 'Being the First Part of The Lord of the Rings',
          'description': 'The first volume of the epic high-fantasy novel.',
          'number_of_pages': 423,
          'publishers': ['George Allen & Unwin'],
          'isbn_13': ['9780261102354'],
          'covers': [12345],
          'works': [
            {'key': '/works/OL27479W'}
          ],
        },
      );

      expect(normalized['title'], goldenEnvelope.normalized['title']);
      expect(normalized['subtitle'], goldenEnvelope.normalized['subtitle']);
      expect(normalized['synopsis'], goldenEnvelope.normalized['synopsis']);
      expect(normalized['page_count'], goldenEnvelope.normalized['page_count']);
      expect(normalized['publisher'], goldenEnvelope.normalized['publisher']);
      expect(normalized['isbn'], goldenEnvelope.normalized['isbn']);
      expect(normalized['genres'], goldenEnvelope.normalized['genres']);
      expect(normalized['cover_image_url'],
          goldenEnvelope.normalized['cover_image_url']);
    });
  });
}
