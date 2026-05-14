import 'package:collectarr_app/features/library/metadata/metadata_proposal_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('metadata proposal store records server response locally', () async {
    const store = MetadataProposalStore();

    await store.recordResponse(
      response: const {'id': 'proposal-1', 'status': 'pending'},
      provider: 'gcd',
      query: 'Batman #1',
      title: 'Batman',
      source: 'CSV import',
    );

    final records = await store.read();

    expect(records, hasLength(1));
    expect(records.single.serverId, 'proposal-1');
    expect(records.single.provider, 'gcd');
    expect(records.single.query, 'Batman #1');
    expect(records.single.title, 'Batman');
    expect(records.single.status, 'pending');
    expect(records.single.source, 'CSV import');

    await store.clear();
    expect(await store.read(), isEmpty);
  });
}
