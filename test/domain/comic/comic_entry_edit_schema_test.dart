import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/entry/comic_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/entry/comic_entry_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/entry_edit_contract.dart';

void main() {
  final details = ComicEntryDetails(
    rawOrSlabbed: 'Slabbed',
    gradingCompany: 'CGC',
    graderNotes: 'Centered and clean',
    signedBy: 'Stan Lee',
    labelType: 'Signature Series',
    customLabel: 'First print',
    pageQuality: 'White',
    certificationNumber: '123456',
    keyComic: true,
    keyReason: 'First appearance',
    keyCategory: '1st appearance',
    keySeverity: 'Major',
    coverPriceCents: 399,
    lastBagBoardDate: DateTime(2025, 1, 15),
  );

  defineEntryEditContract<EditSchema<ComicEntryDetails, ComicEntryEditDraft>>(
    name: 'Comic',
    create: () => comicEntryEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('declares entry collector sections and fields in order', () {
    expect(comicEntryEditSchema.tabs.map((tab) => tab.id), ['entry']);
    expect(
        comicEntryEditSchema.tabs.single.sections.map((section) => section.id),
        [
          'collector',
          'signature',
          'key_comic',
          'preservation',
        ]);
    expect(
      [
        for (final section in comicEntryEditSchema.tabs.single.sections)
          for (final field in section.fields) field.label,
      ].every((label) => label.isNotEmpty),
      isTrue,
    );
  });

  test('round trips every Comic entry detail through the typed draft', () {
    final draft = ComicEntryEditDraft.fromDetails(details);
    addTearDown(draft.dispose);

    expect(draft.toDetails(), details);
    expect(draft.toDetailsDraft().toDetails(), details);

    final pageQuality = _field('page_quality')
        as LibraryVocabularyFieldSpec<ComicEntryEditDraft, String>;
    final keyCategory = _field('key_category')
        as LibraryVocabularyFieldSpec<ComicEntryEditDraft, String>;
    expect(
      pageQuality.options.map((option) => option.value),
      ComicVocabularies.pageQuality.builtIns,
    );
    expect(
      keyCategory.options.map((option) => option.value),
      ComicVocabularies.keyCategory.builtIns,
    );

    pageQuality.setValue(draft, 'Cream');
    keyCategory.setValue(draft, 'Origin');
    final coverPrice =
        _field('cover_price') as LibraryMoneyFieldSpec<ComicEntryEditDraft>;
    coverPrice.setCents(draft, 599);
    expect(pageQuality.value(draft), 'Cream');
    expect(keyCategory.value(draft), 'Origin');
    expect(coverPrice.cents(draft), 599);
  });

  test('hides key detail fields until the Comic is marked as key', () {
    final draft = ComicEntryEditDraft.fromDetails(
      const ComicEntryDetails(),
    );
    addTearDown(draft.dispose);

    expect(_field('key_reason').isVisible(draft), isFalse);
    expect(_field('key_category').isVisible(draft), isFalse);
    draft.keyComic = true;
    expect(_field('key_reason').isVisible(draft), isTrue);
    expect(_field('key_category').isVisible(draft), isTrue);
  });

  test('rejects a negative Comic cover price', () {
    final draft = ComicEntryEditDraft.fromDetails(const ComicEntryDetails());
    addTearDown(draft.dispose);
    draft.coverPriceCents = -1;

    expect(
      comicEntryEditSchema.validate!(const ComicEntryDetails(), draft),
      'Cover price cannot be negative',
    );
  });
}

LibraryFieldSpec<ComicEntryEditDraft> _field(String id) {
  return [
    for (final tab in comicEntryEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
