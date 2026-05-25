import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/features/library/bundles/item_bundle_release_browser_section.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';

void main() {
  testWidgets('loads collected editions lazily and renders selected contents', (
    tester,
  ) async {
    final api = _BundleBrowserApiClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(api)],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 720,
              child: ItemBundleReleaseBrowserSection(
                itemId: 'book-1',
                accent: Colors.cyan,
              ),
            ),
          ),
        ),
      ),
    );

    expect(api.summaryCalls, 0);
    expect(api.detailCalls, 0);
    expect(find.text('Expand to load collected editions'), findsOneWidget);

    await tester.tap(find.text('Collected editions'));
    await pumpUntilSettled(tester);

    expect(api.summaryCalls, 1);
    expect(api.detailCalls, 1);
    expect(find.text('1 collected edition'), findsOneWidget);
    expect(find.text('Akira Omnibus (3 items)'), findsOneWidget);
    expect(find.text('Akira Omnibus'), findsWidgets);
    expect(find.text('Box Set • Slipcase • Kodansha • 3 items'), findsOneWidget);
    expect(find.text('Volume 1 #1'), findsOneWidget);
    expect(find.text('Volume 2 #2'), findsOneWidget);
  });
}

class _BundleBrowserApiClient extends ApiClient {
  int summaryCalls = 0;
  int detailCalls = 0;

  @override
  Future<List<BundleReleaseSummary>> getItemBundleReleases(String itemId) async {
    summaryCalls += 1;
    return const [
      BundleReleaseSummary(
        id: 'bundle-1',
        kind: 'book',
        title: 'Akira Omnibus',
        bundleType: 'Box Set',
        packagingType: 'Slipcase',
        publisher: 'Kodansha',
        contentSummary: BundleReleaseContentSummary(
          totalItems: 3,
          primaryCount: 3,
          bonusCount: 0,
        ),
      ),
    ];
  }

  @override
  Future<BundleReleaseDetail> getBundleRelease(String bundleReleaseId) async {
    detailCalls += 1;
    return const BundleReleaseDetail(
      id: 'bundle-1',
      kind: 'book',
      title: 'Akira Omnibus',
      bundleType: 'Box Set',
      packagingType: 'Slipcase',
      publisher: 'Kodansha',
      contentSummary: BundleReleaseContentSummary(
        totalItems: 3,
        primaryCount: 3,
        bonusCount: 0,
      ),
      members: [
        BundleReleaseMember(
          itemId: 'vol-1',
          role: 'primary',
          quantity: 1,
          isPrimary: true,
          kind: 'book',
          title: 'Volume 1',
          itemNumber: '1',
          sequenceNumber: 1,
        ),
        BundleReleaseMember(
          itemId: 'vol-2',
          role: 'primary',
          quantity: 1,
          isPrimary: true,
          kind: 'book',
          title: 'Volume 2',
          itemNumber: '2',
          sequenceNumber: 2,
        ),
        BundleReleaseMember(
          itemId: 'vol-3',
          role: 'primary',
          quantity: 1,
          isPrimary: true,
          kind: 'book',
          title: 'Volume 3',
          itemNumber: '3',
          sequenceNumber: 3,
        ),
      ],
    );
  }
}