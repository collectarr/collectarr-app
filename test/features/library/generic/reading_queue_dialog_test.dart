import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
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
    const libraryEntryRef1 = LibraryEntryRef(
      kind: CatalogMediaKind.book,
      id: LibraryEntryId('entry-1'),
    );
    const libraryEntryRef2 = LibraryEntryRef(
      kind: CatalogMediaKind.book,
      id: LibraryEntryId('entry-2'),
    );
    await ReadingQueueRepository(db).addToQueue(libraryEntryRef1);
    await ReadingQueueRepository(db).addToQueue(libraryEntryRef2);

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
                  libraryEntries: [
                    LibraryEntrySummary(
                      ref: const LibraryEntryRef(
                        kind: CatalogMediaKind.book,
                        id: LibraryEntryId('entry-1'),
                      ),
                      title: 'Dune',
                      catalogRef: testCatalogRef('book-1', kind: 'book'),
                    ),
                    LibraryEntrySummary(
                      ref: const LibraryEntryRef(
                        kind: CatalogMediaKind.book,
                        id: LibraryEntryId('entry-2'),
                      ),
                      title: 'Foundation',
                      catalogRef: testCatalogRef('book-2', kind: 'book'),
                      notes: 'Signed copy',
                      hasNotes: true,
                    ),
                  ],
                  trackingSummaries: [
                    TrackingSummary(
                      id: 'tracking-1',
                      catalogRef: testCatalogRef('book-1', kind: 'book'),
                      libraryEntryRef: LibraryEntryRef.fromKey('book:entry-1'),
                      status: MediaTrackingStatus.inProgress,
                      updatedAt: DateTime.utc(2026, 1, 1),
                    ),
                  ],
                  catalogSummariesByRef: {
                    testCatalogRef('book-1', kind: 'book'):
                        CatalogDisplaySummary.root(
                      id: 'book-1',
                      kind: CatalogMediaKind.book,
                      primaryLabel: 'Dune',
                    ),
                    testCatalogRef('book-2', kind: 'book'):
                        CatalogDisplaySummary.root(
                      id: 'book-2',
                      kind: CatalogMediaKind.book,
                      primaryLabel: 'Foundation',
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
