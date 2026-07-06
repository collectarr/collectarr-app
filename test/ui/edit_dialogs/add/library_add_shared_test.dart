import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('queued ingest derives short id and status label', () {
    const ingest = LibraryQueuedProviderIngest(
      id: '123456789abc',
      status: 'running',
    );

    expect(ingest.shortId, '12345678');
    expect(ingest.statusLabel, 'Running');
  });

  testWidgets('cover scan prefill banner renders extracted hints', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryCoverScanPrefillBanner(
            result: LibraryCoverScanResult(
              query: 'Batman',
              issueNumber: '1',
              publisher: 'DC',
              year: 2011,
              confidenceLabel: 'high',
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
    expect(find.textContaining('Batman'), findsOneWidget);
    expect(find.textContaining('#1'), findsOneWidget);
    expect(find.textContaining('high confidence'), findsOneWidget);
  });
}