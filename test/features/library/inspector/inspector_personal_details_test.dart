import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';

void main() {
  testWidgets('personal details editor saves structured locations',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-a',
            name: 'Shelf A',
            sortOrder: const Value(1),
          ),
        );
    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-b',
            name: 'Shelf B',
            sortOrder: const Value(2),
          ),
        );
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'movie-1',
            locationId: const Value('loc-a'),
            updatedAt: DateTime.utc(2026, 5, 23),
          ),
        );

    final ownedItem = OwnedItem(
      id: 'owned-1',
      itemId: 'movie-1',
      locationId: 'loc-a',
      updatedAt: DateTime.utc(2026, 5, 23),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: InspectorPersonalDetailsEditor(
              ownedItem: ownedItem,
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);
    await tester.tap(find.byIcon(Icons.place));
    await pumpUntilSettled(tester);
    expect(find.text('Assign Location'), findsOneWidget);
    await tester.tap(find.text('Shelf B').last);
    await pumpUntilSettled(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await pumpUntilSettled(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Apply personal changes'));
    await pumpUntilSettled(tester);

    final updated = await db.select(db.ownedItemsCache).getSingle();
    expect(updated.locationId, 'loc-b');
  });

  testWidgets('tracking details editor saves tracked-only entries',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.trackingEntriesCache).insert(
          TrackingEntriesCacheCompanion.insert(
            id: 'tracking-1',
            itemId: 'movie-1',
            sourceType: const Value('digital'),
            status: const Value('Plan to watch'),
            rating: const Value(7),
            startedAt: Value(DateTime.utc(2026, 5, 20)),
            editionId: const Value('edition-stream'),
            variantId: const Value('variant-hd'),
            updatedAt: DateTime.utc(2026, 5, 23),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: InspectorTrackingDetailsEditor(
              itemId: 'movie-1',
              trackingEntry: TrackingEntry(
                id: 'tracking-1',
                itemId: 'movie-1',
                editionId: 'edition-stream',
                variantId: 'variant-hd',
                sourceType: 'digital',
                status: 'Plan to watch',
                rating: 7,
                startedAt: DateTime.utc(2026, 5, 20),
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              profile: videoTrackingProfile,
              editions: const [
                CatalogEdition(
                  id: 'edition-stream',
                  title: 'Streaming',
                  variants: [
                    CatalogVariant(
                      id: 'variant-hd',
                      name: 'HD',
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Apply tracking changes'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Apply tracking changes'));
    await pumpUntilSettled(tester);

    final updated = await db.select(db.trackingEntriesCache).getSingle();
    expect(updated.sourceType, 'digital');
    expect(updated.rating, 7);
    expect(updated.editionId, 'edition-stream');
    expect(updated.variantId, 'variant-hd');
    expect(updated.updatedAt.isAfter(DateTime.utc(2026, 5, 23)), isTrue);
  });

  testWidgets('tracking edition browser exposes edition and variant selection',
      (tester) async {
    String? selectedEditionId;
    String? selectedVariantId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return buildTrackingEditionBrowserForTesting(
                editions: const [
                  CatalogEdition(
                    id: 'edition-hc',
                    title: 'Hardcover',
                    physicalFormatLabel: 'HC',
                    publisher: 'Image',
                    variants: [
                      CatalogVariant(
                        id: 'variant-blue',
                        name: 'Blue foil',
                        physicalFormatLabel: 'Foil',
                      ),
                      CatalogVariant(
                        id: 'variant-red',
                        name: 'Red foil',
                        physicalFormatLabel: 'Foil',
                      ),
                    ],
                  ),
                ],
                selectedEditionId: selectedEditionId,
                selectedVariantId: selectedVariantId,
                accent: Colors.orange,
                onEditionSelected: (value) {
                  setState(() {
                    selectedEditionId = value;
                    selectedVariantId = null;
                  });
                },
                onVariantSelected: (value) {
                  setState(() => selectedVariantId = value);
                },
              );
            },
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Hardcover'), findsOneWidget);
    expect(find.text('Variants'), findsNothing);

    await tester.tap(find.text('Hardcover'));
    await pumpUntilSettled(tester);

    expect(selectedEditionId, 'edition-hc');
    expect(find.text('Variants'), findsOneWidget);
    expect(find.text('Blue foil'), findsOneWidget);
    expect(find.text('Red foil'), findsOneWidget);

    await tester.tap(find.text('Red foil'));
    await pumpUntilSettled(tester);

    expect(selectedVariantId, 'variant-red');

    await tester.tap(find.text('Primary'));
    await pumpUntilSettled(tester);

    expect(selectedEditionId, isNull);
    expect(selectedVariantId, isNull);
    expect(find.text('Variants'), findsNothing);
  });
}
