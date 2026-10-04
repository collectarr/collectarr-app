import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_state.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_entry_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_constants.dart';
import '../../helpers/secure_storage_mock.dart';
import '../../helpers/test_data_factories.dart';
import '../../helpers/tracking_state_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    setUpSecureStorageMock();
    SharedPreferences.setMockInitialValues({});
  });

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
    await MovieEntryRepository(db).upsert(
      testMovieLibraryEntryFrom(testLibraryEntry(
        id: 'entry-1',
        itemId: 'movie-1',
        kind: 'movie',
        locationId: 'loc-a',
        updatedAt: DateTime.utc(2026, 5, 23),
      )),
    );

    final libraryEntry = testLibraryEntry(
      id: 'entry-1',
      itemId: 'movie-1',
      kind: 'movie',
      locationId: 'loc-a',
      updatedAt: DateTime.utc(2026, 5, 23),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: InspectorPersonalDetailsEditor(
              libraryEntry: testLibraryEntrySummary(libraryEntry),
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

    await tester
        .tap(find.widgetWithText(FilledButton, 'Apply personal changes'));
    await pumpUntilSettled(tester);

    final updated = (await MovieEntryRepository(db).listActive()).single;
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

    final trackingRepository = trackingRecordTestRepository(db);
    await trackingRepository.upsertStorageRecord(
      trackingRepository.create(
        id: 'tracking-1',
        catalogRef: testCatalogRef('movie-1', kind: 'movie'),
        sourceType: 'digital',
        status: 'Plan to watch',
        rating: 7,
        startedAt: DateTime.utc(2026, 5, 20),
        updatedAt: DateTime.utc(2026, 5, 23),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: InspectorTrackingDetailsEditor(
              trackingSummary: trackingSummaryFromRecord(
                MovieTrackingState(
                  id: 'tracking-1',
                  catalogRef: testCatalogRef('movie-1', kind: 'movie'),
                  sourceType: 'digital',
                  status: 'Plan to watch',
                  rating: 7,
                  startedAt: DateTime.utc(2026, 5, 20),
                  updatedAt: DateTime.utc(2026, 5, 23),
                ),
              ),
              profile: movieTrackingProfile,
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
    await tester
        .tap(find.widgetWithText(FilledButton, 'Apply tracking changes'));
    await pumpUntilSettled(tester);

    final updated = await readSingleTrackingState(db);
    expect(updated.sourceTypeApiValue, 'digital');
    expect(updated.rating, 7);
    expect(updated.catalogRef.id, 'movie-1');
    expect(updated.updatedAt.isAfter(DateTime.utc(2026, 5, 23)), isTrue);
  });
}
