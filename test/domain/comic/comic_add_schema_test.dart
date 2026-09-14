import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/add_contract.dart';

void main() {
  defineAddContract<AddSchema<ComicAddManualDraft>>(
    name: 'Comic',
    create: () => comicAddSchema,
    fieldIds: (schema) => [
      for (final section in schema.sections)
        for (final field in section.fields) field.id,
    ],
    label: (schema, fieldId) => [
      for (final section in schema.sections)
        for (final field in section.fields)
          if (field.id == fieldId) field.label,
    ].single,
  );

  test('organizes Comic Add fields into the manual pane sections', () {
    final draft = ComicAddManualDraft();
    addTearDown(draft.dispose);
    expect(comicAddSchema.title!(draft), 'Manual comic issue');
    expect(comicAddSchema.sections.map((section) => section.id), [
      'main',
      'collector',
    ]);
    expect(comicAddSchema.sections.map((section) => section.label), [
      'Main',
      'Collector',
    ]);

    final fieldIds = [
      for (final section in comicAddSchema.sections)
        for (final field in section.fields) field.id,
    ];
    expect(fieldIds, [
      'number',
      'variant',
      'barcode',
      'format',
      'coverDate',
      'publisher',
      'coverImageUrl',
      'rawOrSlabbed',
      'gradingCompany',
      'certificationNumber',
      'labelType',
      'pageQuality',
      'signedBy',
      'graderNotes',
    ]);
  });

  test('binds Comic vocabularies and preserves typed draft values', () {
    final draft = ComicAddManualDraft();
    addTearDown(draft.dispose);

    expect(comicAddSchema.validate!(draft), isNull);
    expect(comicAddSchema.sections.every((section) => section.isVisible(draft)),
        isTrue);

    final format =
        _field('format') as VocabularyAddField<ComicAddManualDraft, String>;
    final publisher =
        _field('publisher') as VocabularyAddField<ComicAddManualDraft, String>;
    expect(
      format.options.map((option) => option.value),
      ComicVocabularies.physicalFormat.builtIns,
    );
    expect(
      publisher.options.map((option) => option.value),
      ComicVocabularies.publisher.builtIns,
    );

    format.updateValue(draft, 'Single Issue');
    publisher.updateValue(draft, 'Image Comics');
    expect(format.currentValue(draft), 'Single Issue');
    expect(publisher.currentValue(draft), 'Image Comics');

    final coverDate =
        _field('coverDate') as NumberAddField<ComicAddManualDraft>;
    coverDate.setValue(draft, 2026);
    expect(coverDate.value(draft), 2026);

    for (final entry in const {
      'number': '1',
      'variant': 'Direct',
      'barcode': '1234567890',
      'coverImageUrl': 'https://example.com/cover.jpg',
      'rawOrSlabbed': 'Slabbed',
      'gradingCompany': 'CGC',
      'certificationNumber': '123456',
      'labelType': 'Signature Series',
      'pageQuality': 'White',
      'signedBy': 'Stan Lee',
      'graderNotes': 'Clean and centered',
    }.entries) {
      final field = _field(entry.key) as TextAddField<ComicAddManualDraft>;
      field.setValue(draft, entry.value);
      expect(field.value(draft), entry.value);
    }
  });
}

AddFieldSpec<ComicAddManualDraft> _field(String id) {
  return [
    for (final section in comicAddSchema.sections)
      for (final field in section.fields)
        if (field.id == id) field,
  ].single;
}
