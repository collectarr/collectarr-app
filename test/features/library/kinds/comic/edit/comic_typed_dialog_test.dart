import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/manual_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_segmented_choice_field.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'typed editor saves personal changes and explicitly cleared grading',
      (tester) async {
    tester.view.physicalSize = const Size(2000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final manual = ComicAddManualDraft();
    manual.values.seriesTitle = 'Fictional QA Series';
    final candidate =
        buildComicManualCandidate(manual, title: 'Original issue')!;
    addTearDown(manual.dispose);
    final record = LibraryEntryRecord(
        id: 'comic-copy',
        kind: CatalogMediaKind.comic,
        catalogData:
            candidate.kindCapability.mapTransport((item) => item.kindData),
        personalData: const {
          'quantity': 2,
          'grade': '9.4',
          'certification_number': 'QA-123',
          'key_comic': false,
          'reading': {'status': 'Read', 'rating': 8},
          'personal_notes': 'Keep this note'
        },
        updatedAt: DateTime.utc(2026));
    final personal = LibraryEntryEditDraft(record);
    addTearDown(personal.dispose);
    LibraryEditSelection? saved;
    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => TextButton(
                      onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => LibraryEntryEditScope(
                                draft: personal,
                                onCommit: (value) async => saved = value,
                                child: ComicLibraryEditDialog(
                                    request: LibraryEditDialogRequest(
                                  type: const ComicRegistration(),
                                  item: candidate,
                                  libraryEntry: null,
                                  accent: Colors.purple,
                                )),
                              )),
                      child: const Text('Open'))))),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    for (final name in [
      'Main',
      'Details',
      'Value',
      'Personal',
      'Custom Fields',
      'Covers',
      'My Images',
      'Creators',
      'Characters',
      'Plot',
      'Links'
    ]) {
      expect(find.text(name), findsWidgets);
    }
    await tester.tap(find.text('Value').first);
    await tester.pumpAndSettle();
    final certification = find.byWidgetPredicate((widget) =>
        widget is LibraryFormField && widget.label == 'Certification number');
    await tester.ensureVisible(certification);
    await tester.enterText(
        find.descendant(
            of: certification, matching: find.byType(TextFormField)),
        '');
    await tester.pumpAndSettle();
    expect(personal.values['certification_number'], isNull);
    await tester.tap(find.text('Personal').first);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
        of: find.byType(LibrarySegmentedChoiceField<bool>),
        matching: find.text('No')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();
    expect(saved, isNotNull);
    final reloaded = ComicPersonalData.fromJson(
        {...record.personalData, ...saved!.entryPersonalData!});
    expect(reloaded.details.certificationNumber, isNull);
    expect(reloaded.reading.status, 'Unread');
    expect(reloaded.reading.rating, 8);
    expect(reloaded.quantity, 2);
    expect(reloaded.personalNotes, 'Keep this note');
    final metadata = saved!.kindItem.kindCapability
        .mapTransport((item) => ComicCatalogItem.fromJson(item.kindData));
    expect(metadata.title, 'Original issue');
    expect(metadata.seriesTitle, 'Fictional QA Series');
    expect(record.personalData['certification_number'], 'QA-123');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
