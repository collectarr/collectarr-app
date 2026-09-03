import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/owned/comic_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/owned/comic_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/owned_edit_contract.dart';

void main() {
  final details = ComicOwnedDetails(
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

  defineOwnedEditContract<EditSchema<ComicOwnedDetails, ComicOwnedEditDraft>>(
    name: 'Comic',
    create: () => comicOwnedEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('declares owned collector sections and fields in order', () {
    expect(comicOwnedEditSchema.tabs.map((tab) => tab.id), ['owned']);
    expect(
        comicOwnedEditSchema.tabs.single.sections.map((section) => section.id),
        [
          'collector',
          'signature',
          'key_comic',
          'preservation',
        ]);
    expect(
      [
        for (final section in comicOwnedEditSchema.tabs.single.sections)
          for (final field in section.fields) field.label,
      ].every((label) => label.isNotEmpty),
      isTrue,
    );
  });

  test('round trips every Comic owned detail through the typed draft', () {
    final draft = ComicOwnedEditDraft.fromDetails(details);
    addTearDown(draft.dispose);

    expect(draft.toDetails(), details);
    expect(draft.toDetailsDraft().toDetails(), details);

    final pageQuality = _field('page_quality')
        as VocabularyEditField<ComicOwnedEditDraft, String>;
    final keyCategory = _field('key_category')
        as VocabularyEditField<ComicOwnedEditDraft, String>;
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
        _field('cover_price') as MoneyEditField<ComicOwnedEditDraft>;
    coverPrice.setCents(draft, 599);
    expect(pageQuality.value(draft), 'Cream');
    expect(keyCategory.value(draft), 'Origin');
    expect(coverPrice.cents(draft), 599);
  });

  test('hides key detail fields until the Comic is marked as key', () {
    final draft = ComicOwnedEditDraft.fromDetails(
      const ComicOwnedDetails(),
    );
    addTearDown(draft.dispose);

    expect(_field('key_reason').isVisible(draft), isFalse);
    expect(_field('key_category').isVisible(draft), isFalse);
    draft.keyComic = true;
    expect(_field('key_reason').isVisible(draft), isTrue);
    expect(_field('key_category').isVisible(draft), isTrue);
  });

  test('rejects a negative Comic cover price', () {
    final draft = ComicOwnedEditDraft.fromDetails(const ComicOwnedDetails());
    addTearDown(draft.dispose);
    draft.coverPriceCents = -1;

    expect(
      comicOwnedEditSchema.validate!(const ComicOwnedDetails(), draft),
      'Cover price cannot be negative',
    );
  });
}

EditFieldSpec<ComicOwnedEditDraft> _field(String id) {
  return [
    for (final tab in comicOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
