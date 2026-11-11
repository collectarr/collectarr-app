import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/sections/entry_personal_section.dart';
import 'package:collectarr_app/features/library/entries/record.dart';
import 'package:collectarr_app/features/library/ui/primitives/dropdown_pick_field.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('location picker keeps IDs out of the dropdown after selecting',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = LocationRepository(db);
    final room = await repository.create(name: 'Room');
    final shelf = await repository.create(name: 'Shelf', parentId: room.id);
    final draft = LibraryEntryEditDraft(LibraryEntryRecord(
      id: 'music-location-test',
      kind: CatalogMediaKind.music,
      catalogData: {'title': 'Test album'},
      personalData: {'location_id': room.id},
      updatedAt: DateTime.utc(2026),
    ));
    addTearDown(draft.dispose);

    Future<void> settle() async {
      await tester.pump();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: ThemeData(platform: TargetPlatform.windows),
        home: Scaffold(body: LibraryEntryStatusStrip(draft: draft)),
      ),
    ));
    await settle();
    final location = find.byWidgetPredicate((widget) =>
        widget is LibraryDropdownPickField<String> &&
        widget.label == 'Location');
    final field =
        find.descendant(of: location, matching: find.byType(TextFormField));
    String text() => tester.widget<TextFormField>(field).controller!.text;

    await tester.tap(find.byTooltip('Select Location'));
    await settle();
    await tester.tap(find.text('Room › Shelf').last);
    await settle();
    expect(draft.text('location_id'), shelf.id);
    expect(text(), 'Room › Shelf');

    await tester.tap(find.byTooltip('Pick Location'));
    await settle();
    expect(find.text(shelf.id), findsNothing);
    expect(find.text(room.id), findsNothing);
    expect(find.text('Room › Shelf'), findsNWidgets(2));
    await tester.tap(find.text('Room'));
    await settle();
    expect(draft.text('location_id'), room.id);
    expect(text(), 'Room');

    await tester.tap(find.byTooltip('Select Location'));
    await settle();
    await tester.tap(find.text('No Location'));
    await settle();
    expect(draft.values['location_id'], isNull);
    expect(text(), isEmpty);
    await tester.tap(find.byTooltip('Select Location'));
    await settle();
    await tester.tap(find.widgetWithText(FilledButton, 'New Location'));
    await settle();
    final name = find
        .byWidgetPredicate((widget) => widget is TextField && widget.autofocus);
    await tester.enterText(name, 'Attic');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await settle();
    await tester.tap(find.text('Attic'));
    await settle();
    final created = (await tester.runAsync(repository.getAll))!
        .singleWhere((location) => location.name == 'Attic');
    expect(draft.text('location_id'), created.id);
    expect(text(), 'Attic');
    await tester.tap(find.byTooltip('Pick Location'));
    await settle();
    expect(find.text(created.id), findsNothing);
    expect(find.text('Attic'), findsNWidgets(2));
    await tester.tap(find.text('Room'));
    await settle();
    expect(tester.takeException(), isNull);
  });
}
