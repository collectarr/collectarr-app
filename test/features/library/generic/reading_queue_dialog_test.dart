import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/library/generic/reading_queue_dialog.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';
import '../../../helpers/test_data_factories.dart';

void main() {
  late LocalDatabase db;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  testWidgets('reading queue dialog filters queued items and returns selection',
      (
    tester,
  ) async {
    const ownedRef1 = OwnedItemRef(
      kind: CatalogMediaKind.book,
      id: OwnedItemId('owned-1'),
    );
    const ownedRef2 = OwnedItemRef(
      kind: CatalogMediaKind.book,
      id: OwnedItemId('owned-2'),
    );
    await ReadingQueueRepository(db).addToQueue(ownedRef1);
    await ReadingQueueRepository(db).addToQueue(ownedRef2);

    String? selectedItemId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showReadingQueueDialog(
                  context: context,
                  db: db,
                  mediaKind: 'book',
                  ownedItems: [
                    OwnedItemSummary(
                      ref: const OwnedItemRef(
                        kind: CatalogMediaKind.book,
                        id: OwnedItemId('owned-1'),
                      ),
                      title: 'Dune',
                      catalogRef: testCatalogRef('book-1', kind: 'book'),
                    ),
                    OwnedItemSummary(
                      ref: const OwnedItemRef(
                        kind: CatalogMediaKind.book,
                        id: OwnedItemId('owned-2'),
                      ),
                      title: 'Foundation',
                      catalogRef: testCatalogRef('book-2', kind: 'book'),
                      notes: 'Signed copy',
                      hasNotes: true,
                    ),
                  ],
                  trackingSummaries: [
                    TrackingSummary.fromEntry(TrackingLifecycle(
                      id: 'tracking-1',
                      catalogRef: testCatalogRef('book-1', kind: 'book'),
                      ownedRef: OwnedItemRef.fromKey('book:owned-1'),
                      status: MediaTrackingStatus.inProgress,
                      updatedAt: DateTime.utc(2026, 1, 1),
                    )),
                  ],
                  catalogSummariesByRef: {
                    testCatalogRef('book-1', kind: 'book'):
                        CatalogDisplaySummary.work(
                      id: 'book-1',
                      kind: CatalogMediaKind.book,
                      title: 'Dune',
                    ),
                    testCatalogRef('book-2', kind: 'book'):
                        CatalogDisplaySummary.work(
                      id: 'book-2',
                      kind: CatalogMediaKind.book,
                      title: 'Foundation',
                    ),
                  },
                  onSelectItem: (itemId) => selectedItemId = itemId,
                );
              },
              child: const Text('Open queue'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open queue'));
    await pumpUntilSettled(tester);

    expect(find.text('2/2 items'), findsOneWidget);
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Foundation'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'signed');
    await pumpUntilSettled(tester);

    expect(find.text('1/2 items'), findsOneWidget);
    expect(find.text('Foundation'), findsOneWidget);
    expect(find.text('Dune'), findsNothing);

    await tester.tap(find.text('Foundation'));
    await pumpUntilSettled(tester);

    expect(selectedItemId, 'book-2');
  });
}
