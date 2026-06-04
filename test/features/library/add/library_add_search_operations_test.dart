import 'package:collectarr_app/features/library/add/library_add_search_operations.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider query trims blanks and deduplicates case-insensitively', () {
    final query = buildLibraryAddProviderQuery([
      ' Batman ',
      '',
      '423',
      'batman',
      ' DC ',
      '423',
    ]);

    expect(query, 'Batman 423 DC');
  });

  test('provider debounce skips repeated signature within debounce window', () {
    final decision = evaluateLibraryAddProviderSearchDebounce(
      provider: 'comicvine',
      query: 'Batman 423',
      debounce: const Duration(milliseconds: 500),
      now: DateTime(2025, 1, 1, 12, 0, 0, 200),
      previousSignature: 'comicvine|batman 423',
      previousAt: DateTime(2025, 1, 1, 12, 0, 0),
    );

    expect(decision.shouldSkip, isTrue);
    expect(decision.signature, 'comicvine|batman 423');
  });

  test('provider debounce allows new signature or expired debounce window', () {
    final changedQueryDecision = evaluateLibraryAddProviderSearchDebounce(
      provider: 'comicvine',
      query: 'Batman 424',
      debounce: const Duration(milliseconds: 500),
      now: DateTime(2025, 1, 1, 12, 0, 0, 200),
      previousSignature: 'comicvine|batman 423',
      previousAt: DateTime(2025, 1, 1, 12, 0, 0),
    );
    final expiredDecision = evaluateLibraryAddProviderSearchDebounce(
      provider: 'comicvine',
      query: 'Batman 423',
      debounce: const Duration(milliseconds: 500),
      now: DateTime(2025, 1, 1, 12, 0, 1),
      previousSignature: 'comicvine|batman 423',
      previousAt: DateTime(2025, 1, 1, 12, 0, 0),
    );

    expect(changedQueryDecision.shouldSkip, isFalse);
    expect(expiredDecision.shouldSkip, isFalse);
  });

  test(
      'provider search falls back to aggregate endpoint on missing bearer token',
      () async {
    final api = _FallbackProviderApiClient();
    final results = await runLibraryAddProviderSearch(
      api: api,
      type: comicsLibraryConfig,
      provider: 'comicvine',
      query: 'Batman',
      rerankHints: const LibraryAddLocalRerankHints(query: 'Batman'),
    );

    expect(api.calls, ['comicvine', null]);
    expect(results, isNotEmpty);
    expect(results.first.provider, 'comicvine');
  });
}

class _FallbackProviderApiClient extends ApiClient {
  _FallbackProviderApiClient() : super(baseUrl: 'http://unused');

  final List<String?> calls = [];

  @override
  Future<List<Map<String, dynamic>>> searchProvider({
    String? provider,
    required String query,
    String? kind,
    String? series,
    String? issueNumber,
    int? year,
  }) async {
    calls.add(provider);
    if (provider != null) {
      final requestOptions =
          RequestOptions(path: '/metadata/providers/$provider/search');
      throw DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {'code': 'missing_bearer_token'},
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return const [
      {
        'provider': 'comicvine',
        'provider_item_id': 'cv-1',
        'title': 'Batman #1',
      },
    ];
  }
}
