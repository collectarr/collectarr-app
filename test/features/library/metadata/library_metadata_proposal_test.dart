import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/config/comics_library_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/metadata_proposal_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test('creates and records proposal with resolved provider', () async {
    SharedPreferences.setMockInitialValues({});
    final api = _FakeProposalApiClient();

    final response = await createAndRecordLibraryMetadataProposal(
      api: api,
      type: comicsLibraryConfig,
      provider: 'comicvine',
      providerItemId: 'cv-42',
      query: 'Absolute Batman #1',
      title: 'Absolute Batman',
      summary: 'Provider candidate',
      imageUrl: 'https://example.test/cover.jpg',
      source: 'Unit test',
    );
    final records = await const MetadataProposalStore().read();

    expect(response['status'], 'pending');
    expect(api.provider, 'comicvine');
    expect(api.providerItemId, 'cv-42');
    expect(api.imageUrl, 'https://example.test/cover.jpg');
    expect(records.single.serverId, 'proposal-1');
    expect(records.single.provider, 'comicvine');
    expect(records.single.query, 'Absolute Batman #1');
    expect(records.single.title, 'Absolute Batman');
    expect(records.single.source, 'Unit test');
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
