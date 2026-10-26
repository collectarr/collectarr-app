import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_state.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fixtures/test_constants.dart';
import '../../../support/fakes/secure_storage_mock.dart';
import '../../../support/builders/library_entry_builder.dart';
import '../../../support/builders/tracking_summary_builder.dart';
import '../../../support/fixtures/tracking_state_test_helpers.dart';

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
    await MusicEntryRepository(db).upsert(
      testMusicLibraryEntryFrom(testLibraryEntry(
        id: 'entry-1',
        itemId: 'music-1',
        kind: 'music',
        locationId: 'loc-a',
        updatedAt: DateTime.utc(2026, 5, 23),
      )),
    );

    final libraryEntry = testLibraryEntry(
      id: 'entry-1',
      itemId: 'music-1',
      kind: 'music',
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

    final updated = (await MusicEntryRepository(db).listActive()).single;
    expect(updated.personal.locationId, 'loc-b');
  });

  testWidgets('tracking details editor saves tracked-only entries',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await MusicEntryRepository(db).upsert(
      testMusicLibraryEntryFrom(testLibraryEntry(
        id: 'music-1',
        itemId: 'music-1',
        kind: 'music',
        updatedAt: DateTime.utc(2026, 5, 23),
      )),
    );

    final trackingRepository = trackingRecordTestRepository(db);
    await trackingRepository.upsertStorageRecord(
      trackingRepository.create(
        id: 'tracking-1',
        libraryEntryRef: LibraryEntryRef.fromKey('music:music-1'),
        sourceType: 'digital',
        status: 'Want to listen',
        rating: 7,
        notes: 'Existing note',
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
                MusicTrackingState(
                  id: 'tracking-1',
                  libraryEntryRef: LibraryEntryRef.fromKey('music:music-1'),
                  sourceType: 'digital',
                  status: 'Want to listen',
                  rating: 7,
                  notes: 'Existing note',
                  startedAt: DateTime.utc(2026, 5, 20),
                  updatedAt: DateTime.utc(2026, 5, 23),
                ),
              ),
              profile: musicTrackingProfile,
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
    expect(updated.libraryEntryRef.id.value, 'music-1');
    expect(updated.updatedAt.isAfter(DateTime.utc(2026, 5, 23)), isTrue);
    expect(updated.notes, 'Existing note');
    final notes = find.byWidgetPredicate((widget) =>
        widget is TextField && widget.decoration?.hintText == 'Tracking notes');
    await tester.ensureVisible(notes);
    await tester.enterText(notes, '');
    await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Apply tracking changes'));
    await tester
        .tap(find.widgetWithText(FilledButton, 'Apply tracking changes'));
    await pumpUntilSettled(tester);
    final cleared = await readSingleTrackingState(db);
    expect(cleared.notes, isNull);
    expect(cleared.rating, 7);
    expect(cleared.sourceTypeApiValue, 'digital');
  });
}
