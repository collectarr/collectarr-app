import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves default and explicit proposal providers from library config',
      () {
    expect(
      resolveLibraryMetadataProposalProvider(comicsLibraryConfig),
      'gcd',
    );
    expect(
      resolveLibraryMetadataProposalProvider(
        comicsLibraryConfig,
        provider: 'comicvine',
      ),
      'comicvine',
    );
  });

  test('rejects unsupported proposal providers for the library type', () {
    expect(
      () => resolveLibraryMetadataProposalProvider(
        comicsLibraryConfig,
        provider: 'openlibrary',
      ),
      throwsArgumentError,
    );
  });

  test('creates proposal with resolved default provider', () async {
    final api = _FakeProposalApiClient();

    final response = await createLibraryMetadataProposal(
      api: api,
      type: comicsLibraryConfig,
      query: 'Batman #1',
      title: 'Batman',
      summary: 'Missing comic metadata',
    );

    expect(response['status'], 'pending');
    expect(api.provider, 'gcd');
    expect(api.query, 'Batman #1');
    expect(api.title, 'Batman');
    expect(api.summary, 'Missing comic metadata');
  });
}

class _FakeProposalApiClient extends ApiClient {
  _FakeProposalApiClient() : super(baseUrl: 'http://unused');

  String? provider;
  String? providerItemId;
  String? query;
  String? title;
  String? summary;
  String? imageUrl;

  @override
  Future<Map<String, dynamic>> createMetadataProposal({
    required String provider,
    required String query,
    String? providerItemId,
    String? title,
    String? summary,
    String? imageUrl,
  }) async {
    this.provider = provider;
    this.providerItemId = providerItemId;
    this.query = query;
    this.title = title;
    this.summary = summary;
    this.imageUrl = imageUrl;
    return const {'id': 'proposal-1', 'status': 'pending'};
  }
}
