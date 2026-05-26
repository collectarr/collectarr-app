import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/library/generic/reading_queue_dialog.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';

void main() {
  late LocalDatabase db;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  testWidgets('reading queue dialog filters queued items and returns selection', (
    tester,
  ) async {
    await ReadingQueueRepository(db).addToQueue('owned-1');
    await ReadingQueueRepository(db).addToQueue('owned-2');

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
                    OwnedItem(
                      id: 'owned-1',
                      itemId: 'book-1',
                      readStatus: 'Reading',
                      updatedAt: DateTime.utc(2026, 1, 1),
                    ),
                    OwnedItem(
                      id: 'owned-2',
                      itemId: 'book-2',
                      personalNotes: 'Signed copy',
                      updatedAt: DateTime.utc(2026, 1, 1),
                    ),
                  ],
                  catalogItemsById: {
                    'book-1': CatalogItem(
                      id: 'book-1',
                      kind: 'book',
                      title: 'Dune',
                    ),
                    'book-2': CatalogItem(
                      id: 'book-2',
                      kind: 'book',
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
