import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/media/comic_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/media/comic_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';

void main() {
  defineMediaEditContract<
      EditSchema<ComicCatalogMetadata, ComicMediaEditDraft>>(
    name: 'Comic',
    create: () => comicMediaEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('declares the Comic media tabs and field ordering', () {
    expect(comicMediaEditSchema.tabs.map((tab) => tab.id), [
      'main',
      'details',
      'creators',
      'characters',
      'links',
      'cover',
      'photos',
    ]);
    expect(
      [
        for (final tab in comicMediaEditSchema.tabs)
          for (final section in tab.sections)
            for (final field in section.fields) field.label,
      ].every((label) => label.isNotEmpty),
      isTrue,
    );
    expect(
      comicMediaEditSchema.tabs.first.sections.first.fields
          .map((field) => field.id),
      [
        'series',
        'issue_number',
        'variant',
        'edition_title',
        'barcode',
        'physical_format',
        'cover_date',
        'release_date',
      ],
    );
  });

  test('binds Comic vocabularies and preserves typed media values', () {
    final draft = ComicMediaEditDraft.fromMedia(
      const ComicMedia(
        title: 'Batman',
        publisher: 'DC Comics',
        issueNumber: '1',
        pageCount: 32,
        physicalFormatLabel: 'Single Issue',
      ),
    );
    addTearDown(draft.dispose);

    expect(draft.seriesTitle, 'Batman');
    expect(draft.publisher, 'DC Comics');
    expect(draft.pageCount, 32);
    expect(draft.physicalFormat, 'Single Issue');
    expect(
        comicMediaEditSchema.validate!(
            const ComicMedia(title: 'Batman'), draft),
        isNull);

    final format = _field('physical_format')
        as VocabularyEditField<ComicMediaEditDraft, String>;
    final publisher =
        _field('publisher') as VocabularyEditField<ComicMediaEditDraft, String>;
    expect(
      format.options.map((option) => option.value),
      ComicVocabularies.physicalFormat.builtIns,
    );
    expect(
      publisher.options.map((option) => option.value),
      ComicVocabularies.publisher.builtIns,
    );

    format.setValue(draft, 'Hardcover');
    publisher.setValue(draft, 'Marvel Comics');
    expect(format.value(draft), 'Hardcover');
    expect(publisher.value(draft), 'Marvel Comics');
    format.setValue(draft, null);
    expect(format.value(draft), '');

    final pageCount =
        _field('page_count') as NumberEditField<ComicMediaEditDraft>;
    pageCount.setValue(draft, 48);
    expect(pageCount.value(draft), 48);

    final genres = _field('genres')
        as MultiVocabularyEditField<ComicMediaEditDraft, String>;
    genres.setValues(draft, {'Action', 'Mystery'});
    expect(genres.values(draft), {'Action', 'Mystery'});

    final releaseDate =
        _field('release_date') as DateEditField<ComicMediaEditDraft>;
    releaseDate.setValue(draft, DateTime(2026, 4, 12));
    expect(releaseDate.value(draft), DateTime(2026, 4, 12));
  });

  test('reports invalid media values through schema validation', () {
    final draft = ComicMediaEditDraft.fromMedia(const ComicMedia(title: 'X'));
    addTearDown(draft.dispose);

    draft.pageCount = -1;
    expect(
      comicMediaEditSchema.validate!(const ComicMedia(title: 'X'), draft),
      'Page count cannot be negative',
    );

    draft.pageCount = null;
    draft.coverDateController.text = 'not-a-date';
    expect(
      comicMediaEditSchema.validate!(const ComicMedia(title: 'X'), draft),
      'Cover date is invalid',
    );
    draft.coverDateController.clear();
    draft.releaseDateController.text = 'not-a-date';
    expect(
      _field('release_date').validate(draft),
      'Release date is invalid',
    );
  });
}

EditFieldSpec<ComicMediaEditDraft> _field(String id) {
  return [
    for (final tab in comicMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
