import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/features/library/bundles/bundle_release_contents_section.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';

void main() {
  testWidgets('loads bundle contents lazily and renders grouped members', (
    tester,
  ) async {
    final api = _BundleApiClient([_detail()]);

    await tester.pumpWidget(_buildTestApp(api));

    expect(api.calls, 0);
    expect(find.text('Expand to load bundle members'), findsOneWidget);

    await tester.tap(find.text('Bundle contents'));
    await pumpUntilSettled(tester);

    expect(api.calls, 1);
    expect(find.text('3 items • 2 primary • 1 bonus'), findsOneWidget);
    expect(find.text('Collector Box'), findsOneWidget);
    expect(find.text('Box Set • Slipcase • Kodansha • 3 items'), findsOneWidget);
    expect(find.text('Disc 1'), findsOneWidget);
    expect(find.text('Bonus disc'), findsOneWidget);
    expect(find.text('Episode One #1'), findsOneWidget);
    expect(find.text('Episode Two #2'), findsOneWidget);
    expect(find.text('Interview Feature'), findsOneWidget);
  });

  testWidgets('shows retry after load failure and reloads successfully', (
    tester,
  ) async {
    final api = _BundleApiClient([
      StateError('backend offline'),
      _detail(title: 'Recovered Box'),
    ]);

    await tester.pumpWidget(_buildTestApp(api));

    await tester.tap(find.text('Bundle contents'));
    await pumpUntilSettled(tester);

    expect(api.calls, 1);
    expect(find.textContaining('Could not load bundle contents'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await pumpUntilSettled(tester);

    expect(api.calls, 2);
    expect(find.text('Recovered Box'), findsOneWidget);
  });
}

Widget _buildTestApp(ApiClient api) {
  return ProviderScope(
    overrides: [apiClientProvider.overrideWithValue(api)],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 640,
          child: BundleReleaseContentsSection(
            bundleReleaseId: 'bundle-1',
            accent: Colors.cyan,
          ),
        ),
      ),
    ),
  );
}

BundleReleaseDetail _detail({String title = 'Collector Box'}) {
  return BundleReleaseDetail(
    id: 'bundle-1',
    kind: 'anime',
    title: title,
    bundleType: 'Box Set',
    packagingType: 'Slipcase',
    publisher: 'Kodansha',
    contentSummary: const BundleReleaseContentSummary(
      totalItems: 3,
      primaryCount: 2,
      bonusCount: 1,
    ),
    members: const [
      BundleReleaseMember(
        itemId: 'ep-2',
        role: 'primary',
        quantity: 1,
        isPrimary: true,
        kind: 'anime',
        title: 'Episode Two',
        itemNumber: '2',
        sequenceNumber: 2,
        discNumber: 1,
      ),
      BundleReleaseMember(
        itemId: 'bonus-1',
        role: 'bonus',
        quantity: 1,
        isPrimary: false,
        kind: 'anime',
        title: 'Interview Feature',
        sequenceNumber: 1,
        discLabel: 'Bonus disc',
      ),
      BundleReleaseMember(
        itemId: 'ep-1',
        role: 'primary',
        quantity: 1,
        isPrimary: true,
        kind: 'anime',
        title: 'Episode One',
        itemNumber: '1',
        sequenceNumber: 1,
        discNumber: 1,
      ),
    ],
  );
}

class _BundleApiClient extends ApiClient {
  _BundleApiClient(this._responses);

  final List<Object> _responses;
  int calls = 0;

  @override
  Future<BundleReleaseDetail> getBundleRelease(String bundleReleaseId) async {
    final response = _responses[calls++];
    if (response is BundleReleaseDetail) {
      return response;
    }
    throw response;
  }
}
