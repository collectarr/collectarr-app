import 'package:collectarr_app/core/models/catalog_search_hit.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_alpha_jump_bar.dart';
import 'package:collectarr_app/features/library/workspace/table/library_column_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Synthetic entity with fields:
/// - specimen_code (primary identifier & display label)
/// - epoch
/// - curator
/// Explicitly contains NO 'title' field anywhere.
final class SyntheticSpecimen {
  const SyntheticSpecimen({
    required this.id,
    required this.specimenCode,
    required this.epoch,
    required this.curator,
  });

  final String id;
  final String specimenCode;
  final String epoch;
  final String curator;
}

final class SyntheticSpecimenDto implements LibraryWorkspaceDto {
  const SyntheticSpecimenDto(this.specimen);

  final SyntheticSpecimen specimen;

  @override
  String get primaryLabel => specimen.specimenCode;

  @override
  String? get secondaryLabel => specimen.curator;

  @override
  String? get imageUrl => null;

  Iterable<String> get searchTokens => [
        specimen.specimenCode,
        specimen.epoch,
        specimen.curator,
      ];
}

final class SyntheticSpecimenDraft {
  SyntheticSpecimenDraft({
    this.specimenCode = '',
    this.epoch = '',
    this.curator = '',
  });

  String specimenCode;
  String epoch;
  String curator;
}

void main() {
  group('Synthetic kind without title (specimen_code, epoch, curator)', () {
    test(
        '1. Creation: Add form schema validates specimen_code without demanding title',
        () {
      final schema = LibraryFormSchema<SyntheticSpecimenDraft>(
        title: (draft) => 'Add Specimen ${draft.specimenCode}',
        validate: (draft) => draft.specimenCode.trim().isEmpty
            ? 'Specimen code is required'
            : null,
        sections: [
          LibraryFormSectionSpec<SyntheticSpecimenDraft>(
            id: 'general',
            label: 'General',
            fields: [
              LibraryTextFieldSpec<SyntheticSpecimenDraft>(
                id: 'specimen_code',
                label: 'Specimen Code',
                value: (draft) => draft.specimenCode,
                setValue: (draft, val) => draft.specimenCode = val,
                validator: (draft) => draft.specimenCode.trim().isEmpty
                    ? 'Specimen code required'
                    : null,
              ),
              LibraryTextFieldSpec<SyntheticSpecimenDraft>(
                id: 'epoch',
                label: 'Epoch',
                value: (draft) => draft.epoch,
                setValue: (draft, val) => draft.epoch = val,
              ),
              LibraryTextFieldSpec<SyntheticSpecimenDraft>(
                id: 'curator',
                label: 'Curator',
                value: (draft) => draft.curator,
                setValue: (draft, val) => draft.curator = val,
              ),
            ],
          ),
        ],
      );

      final emptyDraft = SyntheticSpecimenDraft();
      expect(schema.validate!(emptyDraft), 'Specimen code is required');

      final validDraft = SyntheticSpecimenDraft(
        specimenCode: 'SPEC-001',
        epoch: 'Jurassic',
        curator: 'Dr. Alan Grant',
      );
      expect(schema.validate!(validDraft), isNull);
      expect(schema.title!(validDraft), 'Add Specimen SPEC-001');
    });

    test(
        '2. Editing: Edit schema tracks dirty state and validates without title',
        () {
      final initial = SyntheticSpecimen(
        id: 'spec-1',
        specimenCode: 'SPEC-001',
        epoch: 'Jurassic',
        curator: 'Dr. Alan Grant',
      );

      final schema = EditSchema<SyntheticSpecimen, SyntheticSpecimenDraft>(
        title: (model) => 'Edit ${model.specimenCode}',
        isDirty: (model, draft) =>
            model.specimenCode != draft.specimenCode ||
            model.epoch != draft.epoch ||
            model.curator != draft.curator,
        validate: (model, draft) =>
            draft.specimenCode.trim().isEmpty ? 'Specimen code required' : null,
        tabs: [
          EditTabSpec<SyntheticSpecimenDraft>(
            id: 'details',
            label: 'Details',
            sections: [
              LibraryFormSectionSpec<SyntheticSpecimenDraft>(
                id: 'main',
                label: 'Main',
                fields: [
                  LibraryTextFieldSpec<SyntheticSpecimenDraft>(
                    id: 'specimen_code',
                    label: 'Specimen Code',
                    value: (draft) => draft.specimenCode,
                    setValue: (draft, val) => draft.specimenCode = val,
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final draft = SyntheticSpecimenDraft(
        specimenCode: initial.specimenCode,
        epoch: initial.epoch,
        curator: initial.curator,
      );

      expect(schema.isDirty!(initial, draft), isFalse);
      expect(schema.validate!(initial, draft), isNull);

      draft.epoch = 'Cretaceous';
      expect(schema.isDirty!(initial, draft), isTrue);
      expect(schema.title!(initial), 'Edit SPEC-001');

      draft.specimenCode = '';
      expect(schema.validate!(initial, draft), 'Specimen code required');
    });

    test(
        '3. Display & Presentation: primaryLabel and alpha jump bar work without title',
        () {
      final specimen = SyntheticSpecimen(
        id: 'spec-1',
        specimenCode: 'Tracer-99',
        epoch: 'Devonian',
        curator: 'Mary Anning',
      );
      final dto = SyntheticSpecimenDto(specimen);

      // Primary presentation projection uses primaryLabel
      expect(dto.primaryLabel, 'Tracer-99');

      // Alpha jump bar resolves directly from primaryLabel
      final letter =
          LibraryAlphaJumpBar.normalizedLetterForTitle(dto.primaryLabel);
      expect(letter, 'T');
    });

    testWidgets(
        '4. Column Chooser: does not force or lock title for synthetic kind',
        (tester) async {
      Set<String>? savedColumns;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  savedColumns = await showDialog<Set<String>>(
                    context: context,
                    builder: (_) => LibraryColumnChooserDialog(
                      availableColumns: const [
                        'specimen_code',
                        'epoch',
                        'curator'
                      ],
                      selectedColumns: const {'specimen_code', 'epoch'},
                      defaultColumns: const {'specimen_code'},
                      primaryColumn: 'specimen_code',
                      columnLabel: (col) => col.toUpperCase(),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify available columns
      expect(find.text('SPECIMEN_CODE'), findsWidgets);
      expect(find.text('EPOCH'), findsWidgets);
      expect(find.text('CURATOR'), findsWidgets);
      expect(find.text('TITLE'), findsNothing);

      // Tap Save button
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedColumns, contains('specimen_code'));
      expect(savedColumns, contains('epoch'));
      expect(savedColumns, isNot(contains('title')));
    });

    test('5. Search: CatalogSearchHit decodes synthetic kind without title',
        () {
      final hit = CatalogSearchHit.fromJson({
        'id': 'spec-101',
        'kind': 'book',
        'primary_label': 'SPEC-101',
        'epoch': 'Jurassic',
        'curator': 'Dr. Alan Grant',
      });

      expect(hit.ref.id, 'spec-101');
      expect(hit.primaryLabel, 'SPEC-101');
      expect(hit.title, 'SPEC-101');
      expect(hit.toJson()['primary_label'], 'SPEC-101');
    });
  });
}
