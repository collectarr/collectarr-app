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

  test('declares only persisted Comic issue and publication values', () {
    final draft = ComicAddManualDraft();
    addTearDown(draft.dispose);
    expect(comicAddSchema.title!(draft), 'Manual comic issue');
    expect(comicAddSchema.sections.map((section) => section.id), [
      'issue',
      'publication',
    ]);
    final fieldIds = [
      for (final section in comicAddSchema.sections)
        for (final field in section.fields) field.id,
    ];
    expect(
        fieldIds,
        containsAll(<String>[
          'issue_number',
          'variant',
          'edition_title',
          'barcode',
          'physical_format',
          'cover_date',
          'release_date',
          'publisher',
          'imprint',
          'series_group',
          'page_count',
          'cover_image_url',
        ]));
    expect(fieldIds, isNot(contains('gradingCompany')));
  });

  test('binds Comic vocabularies and keeps values typed', () {
    final draft = ComicAddManualDraft();
    addTearDown(draft.dispose);
    expect(comicAddSchema.validate!(draft), isNull);

    final format = _field('physical_format')
        as LibraryVocabularyFieldSpec<ComicAddManualDraft, String>;
    final publisher = _field('publisher')
        as LibraryVocabularyFieldSpec<ComicAddManualDraft, String>;
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
    expect(draft.values.physicalFormatLabel, 'Single Issue');
    expect(draft.values.publisher, 'Image Comics');

    final coverDate =
        _field('cover_date') as LibraryDateFieldSpec<ComicAddManualDraft>;
    coverDate.setValue(draft, DateTime(2026, 4, 1));
    expect(draft.values.coverDate, DateTime(2026, 4, 1));

    final issueNumber =
        _field('issue_number') as LibraryTextFieldSpec<ComicAddManualDraft>;
    issueNumber.setValue(draft, '12');
    expect(draft.values.issueNumber, '12');

    final pageCount =
        _field('page_count') as LibraryNumberFieldSpec<ComicAddManualDraft>;
    pageCount.setValue(draft, -1);
    expect(comicAddSchema.validate!(draft), 'Page count cannot be negative');
  });
}

LibraryFieldSpec<ComicAddManualDraft> _field(String id) {
  return [
    for (final section in comicAddSchema.sections)
      for (final field in section.fields)
        if (field.id == id) field,
  ].single;
}
