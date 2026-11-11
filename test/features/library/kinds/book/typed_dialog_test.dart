import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/models.dart';
import 'package:collectarr_app/features/library/edit/draft/entry_edit_draft.dart';
import 'package:collectarr_app/features/library/entries/record.dart';
import 'package:collectarr_app/features/library/kinds/book/add/manual_candidate.dart';
import 'package:collectarr_app/features/library/kinds/book/add/manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/ui/primitives/segmented_choice_field.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/ui/primitives/formatted_text_form_control.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Books typed editor traverses all tabs and saves dust jacket changes',
      (tester) async {
    tester.view.physicalSize = const Size(2000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final manual = BookAddManualDraft();
    manual.values.seriesTitle = 'Fictional QA Series';
    final candidate =
        buildBookManualCandidate(manual, title: 'Original issue')!;
    addTearDown(manual.dispose);
    final record = LibraryEntryRecord(
        id: 'book-copy',
        kind: CatalogMediaKind.book,
        catalogData:
            candidate.kindCapability.mapTransport((item) => item.kindData),
        personalData: const {
          'condition': 'Good',
          'dust_jacket_present': false,
          'dust_jacket_condition': 'Fair',
          'personal_notes': 'Keep this note',
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
                                child: Builder(
                                    builder: (context) =>
                                        buildBookItemEditDialog(
                                            context,
                                            LibraryEditDialogRequest(
                                              type: const BookRegistration(),
                                              item: candidate,
                                              libraryEntry: null,
                                              accent: Colors.purple,
                                            ))),
                              )),
                      child: const Text('Open'))))),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    for (final name in [
      'Main',
      'Details',
      'Credits',
      'Personal',
      'Custom Fields',
      'Read History',
      'Value',
      'Covers',
      'My Images',
      'Plot',
      'Links',
    ]) {
      expect(find.text(name), findsWidgets);
      await tester.ensureVisible(find.text(name).first);
      await tester.tap(find.text(name).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: name);
      if (name == 'Plot') {
        expect(find.byType(LibraryFormattedTextFormControl), findsOneWidget);
      }
      if (name == 'Details') {
        expect(find.byType(LibraryFormGroup), findsNWidgets(4));
      }
      if (name == 'Personal') {
        final condition = tester.getTopLeft(find.text('Book Condition').first);
        final rating = tester.getTopLeft(find.text('My Rating').first);
        final jacket = tester.getTopLeft(find.text('Dust Jacket').first);
        final jacketCondition =
            tester.getTopLeft(find.text('Dust Jacket Condition').first);
        expect(rating.dx, greaterThan(condition.dx));
        expect(jacketCondition.dx, greaterThan(jacket.dx));
        expect((jacketCondition.dy - jacket.dy).abs(), lessThan(2));
      }
      if (name == 'Details') {
        expect(find.text('Additional metadata'), findsNothing);
        final edition = tester.getTopLeft(find.text('Edition').first);
        final classification =
            tester.getTopLeft(find.text('Classification').first);
        final dimensions = tester.getTopLeft(find.text('Dimensions').first);
        final original = tester.getTopLeft(find.text('Original').first);
        final printed = tester.getTopLeft(find.text('Printed By').first);
        final paper = tester.getTopLeft(find.text('Paper Type').first);
        expect(printed.dx, greaterThan(paper.dx));
        final width = tester.getTopLeft(find.text('Width (mm)').first);
        final height = tester.getTopLeft(find.text('Height (mm)').first);
        expect(height.dx, greaterThan(width.dx));
        expect((height.dy - width.dy).abs(), lessThan(2));
        expect(classification.dx, greaterThan(edition.dx));
        expect(dimensions.dy, greaterThan(edition.dy));
        expect(original.dy, greaterThan(classification.dy));
      }
    }
    await tester.ensureVisible(find.text('Personal').first);
    await tester.tap(find.text('Personal').first);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
        of: find.byType(LibrarySegmentedChoiceField<bool>),
        matching: find.text('Yes')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();
    expect(saved, isNotNull);
    final reloaded = BookPersonalData.fromJson(
        {...record.personalData, ...saved!.entryPersonalData!});
    expect(reloaded.details.dustJacketPresent, isTrue);
    expect(reloaded.details.dustJacketCondition, 'Fair');
    expect(reloaded.condition, 'Good');
    expect(reloaded.personalNotes, 'Keep this note');
    final metadata = saved!.kindItem.kindCapability
        .mapTransport((item) => BookCatalogMetadata.fromJson(item.kindData));
    expect(metadata.title, 'Original issue');
    expect(metadata.seriesTitle, 'Fictional QA Series');
    expect(record.personalData['dust_jacket_present'], isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }, variant: TargetPlatformVariant({TargetPlatform.windows}));
}
