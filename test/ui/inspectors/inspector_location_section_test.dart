import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/inspector/inspector_location_section.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factories.dart';

void main() {
  testWidgets('cancel keeps the current location assignment', (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-1',
            name: 'Office Shelf',
            sortOrder: const Value(1),
          ),
        );
    await ComicOwnedRepository(db).upsert(
      testComicOwnedItemFrom(testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        kind: 'comic',
        locationId: 'loc-1',
        updatedAt: DateTime.utc(2026, 5, 22),
      )),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorLocationSection(
            ownedRef: const OwnedItemRef(
              kind: CatalogMediaKind.comic,
              id: OwnedItemId('owned-1'),
            ),
            db: db,
            accent: Colors.orange,
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Office Shelf'), findsOneWidget);

    await tester.tap(find.text('Office Shelf'));
    await pumpUntilSettled(tester);

    expect(find.text('Assign Location'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await pumpUntilSettled(tester);

    final owned = (await ComicOwnedRepository(db).listActive()).single;

    expect(owned.locationId, 'loc-1');
    expect(find.text('Office Shelf'), findsOneWidget);
  });
}
