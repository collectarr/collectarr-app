import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/core_data/core_data_settings.dart';
import 'package:collectarr_app/features/settings/core_data_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  testWidgets('dialog saves a field switched to No on the Add tab',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
            home: Scaffold(
                body: CoreDataSettingsDialog(
      accent: Colors.orange,
      kind: CatalogMediaKind.music,
    )))));
    await tester.pumpAndSettle();

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
}
