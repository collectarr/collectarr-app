import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/add_contract.dart';

void main() {
  defineAddContract<AddSchema<BookAddManualDraft>>(
    name: 'Book',
    create: () => bookAddSchema,
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

  test('declares Book edition, publication, and ownership sections', () {
    final draft = BookAddManualDraft();
    addTearDown(draft.dispose);

    expect(bookAddSchema.title!(draft), 'Manual book');
    expect(bookAddSchema.sections.map((section) => section.id), [
      'edition',
      'publication',
      'ownership',
    ]);
    expect(
      [
        for (final section in bookAddSchema.sections)
          for (final field in section.fields) field.id,
      ],
      containsAll(<String>[
        'number',
        'barcode',
        'format',
        'publication_year',
        'publisher',
        'page_count',
        'authors',
        'language',
        'signed_by',
      ]),
    );
  });

  test('binds Book vocabularies and validates manual values', () {
    final draft = BookAddManualDraft();
    addTearDown(draft.dispose);

    final format =
        _field('format') as VocabularyAddField<BookAddManualDraft, String>;
    final publisher =
        _field('publisher') as VocabularyAddField<BookAddManualDraft, String>;
    final language =
        _field('language') as VocabularyAddField<BookAddManualDraft, String>;
    expect(
      format.options.map((option) => option.value),
      BookVocabularies.format.builtIns,
    );
    expect(
      publisher.options.map((option) => option.value),
      BookVocabularies.publisher.builtIns,
    );
    expect(
      language.options.map((option) => option.value),
      BookVocabularies.language.builtIns,
    );

    format.updateValue(draft, 'Hardcover');
    publisher.updateValue(draft, 'Penguin Random House');
    language.updateValue(draft, 'English');
    expect(format.currentValue(draft), 'Hardcover');
    expect(publisher.currentValue(draft), 'Penguin Random House');
    expect(language.currentValue(draft), 'English');

    final releaseDate =
        _field('release_date') as DateAddField<BookAddManualDraft>;
    releaseDate.setValue(draft, DateTime(2026, 4, 12));
    expect(releaseDate.value(draft), DateTime(2026, 4, 12));
    expect(bookAddSchema.validate!(draft), isNull);

    final pageCount =
        _field('page_count') as NumberAddField<BookAddManualDraft>;
    pageCount.setValue(draft, -1);
    expect(bookAddSchema.validate!(draft), 'Page count cannot be negative');
    pageCount.setValue(draft, 240);
    draft.releaseDateController.text = 'not-a-date';
    expect(bookAddSchema.validate!(draft), 'Release date is invalid');
  });
}

AddFieldSpec<BookAddManualDraft> _field(String id) {
  return [
    for (final section in bookAddSchema.sections)
      for (final field in section.fields)
        if (field.id == id) field,
  ].single;
}
