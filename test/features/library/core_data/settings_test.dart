import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/core_data/settings.dart';
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

  test('a field set apart from its tab overrides it', () {
    const settings = CoreDataSettings(
      fieldTabs: {'label': 'main', 'genres': 'main', 'discs': 'details'},
      skippedTabs: {'main'},
      keptDownloads: {'genres'},
      tabUpdateModes: {'details': CoreUpdateMode.replace},
      updateModes: {'discs': CoreUpdateMode.skip},
    );

    expect(settings.downloads('label'), isFalse);
    expect(settings.downloads('genres'), isTrue);
    expect(settings.downloads('title'), isTrue);
    expect(settings.modeFor('discs'), CoreUpdateMode.skip);
    expect(settings.modeFor('label'), CoreUpdateMode.update);
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

  testWidgets('dialog saves a tab switched to No on the Add tab',
      (tester) async {
    await pumpDialog(tester, CatalogMediaKind.music);

    expect(find.text('Add/Update from Core Settings'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);

    // The first No belongs to the Main tab's own row.
    await tester.tap(find.text('No').first);
    await tester.pump();
    await tester.tap(find.byKey(const Key('core_data_settings.save')));
    await tester.pumpAndSettle();

    final saved = await CoreDataSettings.load(CatalogMediaKind.music);
    expect(saved.skippedTabs, {'main'});
    expect(saved.downloads('label'), isFalse);
    expect(saved.downloads('discs'), isTrue);
  });

  testWidgets('dialog groups the fields under their edit tabs',
      (tester) async {
    await pumpDialog(tester, CatalogMediaKind.music);

    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Disc Credits'), findsOneWidget);
    expect(find.text('Back Cover'), findsOneWidget);
    expect(find.text('Title'), findsNothing);
    expect(tester.getTopLeft(find.text('Label')).dx,
        greaterThan(tester.getTopLeft(find.text('Main')).dx));

    await tester.tap(find.text('Update from Core'));
    await tester.pump();
    expect(find.text('Title'), findsOneWidget);
  });

  testWidgets('dialog says so when Core has no catalog for the kind',
      (tester) async {
    await pumpDialog(tester, CatalogMediaKind.movie);

    expect(find.text('Core has no catalog for this kind yet.'), findsOneWidget);
    expect(find.text('Download'), findsNothing);
  });

  testWidgets('Comics lists the reference fields in the editor order',
      (tester) async {
    await pumpDialog(tester, CatalogMediaKind.comic);

    expect(find.text('Variant Description'), findsOneWidget);
    expect(find.text('No. of Pages'), findsOneWidget);
    expect(find.text('Cover price cents'), findsNothing);
    expect(tester.getTopLeft(find.text('Variant Description')).dy,
        lessThan(tester.getTopLeft(find.text('Story Arc')).dy));
  });
}
