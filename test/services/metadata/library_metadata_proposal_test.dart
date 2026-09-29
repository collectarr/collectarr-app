import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_proposal.dart';
import 'package:collectarr_app/features/library/metadata/metadata_proposal_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('manual Add catalog data is submitted unchanged for review', () async {
    SharedPreferences.setMockInitialValues({});
    final api = _FakeProposalApiClient();
    const catalogItem = <String, dynamic>{
      'title': 'Lupus Dei',
      'artist': 'Powerwolf',
      'release_date': '2017',
      'genres': ['Heavy Metal', 'Power Metal'],
      'mediums': [
        {
          'position': 1,
          'tracks': [
            {'position': 1, 'title': 'Fire & Forgive'},
          ],
        },
      ],
    };

    final response = await createAndRecordLibraryMetadataProposal(
      api: api,
      kind: 'music',
      catalogItem: catalogItem,
      source: 'Manual Add form',
    );

    expect(response['status'], 'pending');
    expect(api.kind, 'music');
    expect(api.catalogItem, catalogItem);

    final records = await const MetadataProposalStore().read();
    expect(records, hasLength(1));
    expect(records.single.serverId, 'proposal-1');
    expect(records.single.kind, 'music');
    expect(records.single.title, 'Lupus Dei');
    expect(records.single.source, 'Manual Add form');
  });
}

class _FakeProposalApiClient extends ApiClient {
  _FakeProposalApiClient() : super(baseUrl: 'http://unused');

  String? kind;
  Map<String, dynamic>? catalogItem;

  @override
  Future<Map<String, dynamic>> createCatalogItemProposal({
    required String kind,
    required Map<String, dynamic> catalogItem,
  }) async {
    this.kind = kind;
    this.catalogItem = catalogItem;
    return const {'id': 'proposal-1', 'status': 'pending'};
  }
}
