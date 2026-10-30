import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/core_data/core_data_settings.dart';
import 'package:collectarr_app/features/settings/core_data_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Add from Core drops only the fields the user turned off', () {
    const settings = CoreDataSettings(skippedDownloads: {'label', 'title'});

    final kept = settings.withoutSkippedDownloads({
      'title': 'A',
      'label': 'L',
      'genres': const ['Rock']
    });

    expect(kept, {
      'title': 'A',
      'genres': const ['Rock']
    });
    expect(settings.downloads('label'), isFalse);
    expect(settings.downloads('title'), isTrue);
  });

  test('Update from Core follows each field mode', () {
    const settings = CoreDataSettings(updateModes: {
      'artist': CoreUpdateMode.skip,
      'label': CoreUpdateMode.replace,
    }, skippedDownloads: {
      'country'
    });

    final updated = settings.applyUpdate(
      entryData: {
        'artist': 'Mine',
        'label': 'Old',
        'genres': const <String>[],
        'barcode': '123',
        'country': null,
      },
      coreData: {
        'id': 'new-id',
        'artist': 'Core',
        'label': 'New',
        'genres': const ['Rock'],
        'barcode': '999',
        'country': 'UK',
        'catalog_number': null,
      },
    );

    expect(updated, {
      'artist': 'Mine', // skipped
      'label': 'New', // replaced
      'genres': const ['Rock'], // filled because it was empty
      'barcode': '123', // kept: update only fills empty fields
      'country': null, // not downloaded
    });
  });

  test('settings round-trip per kind', () async {
    await const CoreDataSettings(
        skippedDownloads: {'label'},
        updateModes: {'artist': CoreUpdateMode.replace}).save(
      CatalogMediaKind.music,
    );

    final music = await CoreDataSettings.load(CatalogMediaKind.music);
    final book = await CoreDataSettings.load(CatalogMediaKind.book);

    expect(music.skippedDownloads, {'label'});
    expect(music.modeFor('artist'), CoreUpdateMode.replace);
    expect(book.skippedDownloads, isEmpty);
  });

  test('skipping tracks keeps discs but drops their tracks on Add', () {
    const settings = CoreDataSettings(skippedDownloads: {'discs.tracks'});
    final result = settings.withoutSkippedDownloads({
      'title': 'A',
      'discs': [
        {
          'disc_number': 1,
          'tracks': [1, 2]
        },
      ],
    });
    expect(result['discs'], [
      {'disc_number': 1},
    ]);
  });

  test('tracks follow their own update mode inside replaced discs', () {
    const settings = CoreDataSettings(
      updateModes: {
        'discs': CoreUpdateMode.replace,
        'discs.tracks': CoreUpdateMode.skip
      },
    );
    final result = settings.applyUpdate(
      entryData: {
        'discs': [
          {
            'disc_number': 1,
            'tracks': ['old']
          },
        ],
      },
      coreData: {
        'discs': [
          {
            'disc_number': 1,
            'title': 'New',
            'tracks': ['new']
          },
        ],
      },
    );
    expect(result['discs'], [
      {
        'disc_number': 1,
        'title': 'New',
        'tracks': ['old']
      },
    ]);
  });

  Future<void> pumpDialog(WidgetTester tester, CatalogMediaKind kind) async {
    tester.view.physicalSize = const Size(1280, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: CoreDataSettingsDialog(accent: Colors.orange, kind: kind))));
    await tester.pumpAndSettle();
  }

  testWidgets('dialog saves a field switched to No on the Add tab',
      (tester) async {
    await pumpDialog(tester, CatalogMediaKind.music);

    expect(find.text('Add/Update from Core Settings'), findsOneWidget);
    expect(find.text('Add from Core'), findsOneWidget);
    expect(find.text('Update from Core'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);

    final noButtons = find.text('No');
    await tester.tap(noButtons.first);
    await tester.pump();
    await tester.tap(find.byKey(const Key('core_data_settings.save')));
    await tester.pumpAndSettle();

    final saved = await CoreDataSettings.load(CatalogMediaKind.music);
    expect(saved.skippedDownloads, hasLength(1));
  });

  testWidgets('dialog lists the lists Core describes, with their nested lists',
      (tester) async {
    await pumpDialog(tester, CatalogMediaKind.music);

    expect(find.text('Discs'), findsOneWidget);
    expect(find.text('Tracks'), findsOneWidget);
    expect(find.text('Credits'), findsNWidgets(2));
    expect(find.text('External links'), findsOneWidget);
    expect(find.text('Back cover image url'), findsOneWidget);
    expect(find.text('Title'), findsNothing);
    expect(tester.getTopLeft(find.text('Tracks')).dx,
        greaterThan(tester.getTopLeft(find.text('Discs')).dx));

    await tester.tap(find.text('Update from Core'));
    await tester.pump();
    expect(find.text('Title'), findsOneWidget);
  });

  testWidgets('dialog says so when Core has no catalog for the kind',
      (tester) async {
    await pumpDialog(tester, CatalogMediaKind.book);

    expect(find.text('Core has no catalog for this kind yet.'), findsOneWidget);
    expect(find.text('Download'), findsNothing);
  });

  testWidgets('Comics lists the reference fields in the editor order',
      (tester) async {
    await pumpDialog(tester, CatalogMediaKind.comic);

    expect(find.text('Variant Description'), findsOneWidget);
    expect(find.text('No. of Pages'), findsOneWidget);
    expect(find.text('Cover price cents'), findsNothing);
    expect(tester.getTopLeft(find.text('Subtitle')).dy,
        lessThan(tester.getTopLeft(find.text('Format')).dy));
  });
}
