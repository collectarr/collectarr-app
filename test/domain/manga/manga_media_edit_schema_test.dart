import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/media/manga_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/media/manga_media_edit_schema.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<MangaMedia, MangaMediaEditDraft>>(
    name: 'Manga',
    create: () => mangaMediaEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('declares canonical Manga media tabs and field ordering', () {
    expect(mangaMediaEditSchema.tabs.map((tab) => tab.id), [
      'identity',
      'publication',
    ]);
    expect(
      [
        for (final tab in mangaMediaEditSchema.tabs)
          for (final section in tab.sections)
            for (final field in section.fields) field.label,
      ].every((label) => label.isNotEmpty),
      isTrue,
    );
  });

  test('binds and round trips canonical Manga media values', () {
    final draft = MangaMediaEditDraft.fromMedia(
      MangaMedia(
        id: 'manga-1',
        title: 'Frieren',
        originalLanguage: 'Japanese',
        rawPayload: const {
          'genres': ['Fantasy'],
        },
        firstPublicationDate: DateTime(2020, 1, 1),
      ),
    );
    addTearDown(draft.dispose);

    _field('title').setValue(draft, 'Frieren: Beyond Journey');
    _field('genres').setValue(draft, 'Fantasy, Adventure');
    _field('status').setValue(draft, 'Finished');
    _field('original_language').setValue(draft, 'English');
    _field('search_aliases').setValue(draft, 'Frieren, Sousou no Frieren');

    final updated = draft.toMedia();
    expect(updated.title, 'Frieren: Beyond Journey');
    expect(updated.rawPayload['genres'], ['Fantasy', 'Adventure']);
    expect(updated.status, 'Finished');
    expect(updated.originalLanguage, 'English');
    expect(
        updated.rawPayload['search_aliases'], ['Frieren', 'Sousou no Frieren']);
    expect(updated.firstPublicationDate, DateTime(2020, 1, 1));
  });

  test('rejects invalid canonical Manga publication dates', () {
    final draft = MangaMediaEditDraft.fromMedia(
      const MangaMedia(id: 'manga-1', title: 'Frieren'),
    );
    addTearDown(draft.dispose);

    draft.firstPublicationDateController.text = 'not-a-date';
    expect(
      mangaMediaEditSchema.validate!(
        const MangaMedia(id: 'manga-1', title: 'Frieren'),
        draft,
      ),
      'Publication date is invalid',
    );
  });
}

LibraryTextFieldSpec<MangaMediaEditDraft> _field(String id) {
  return [
    for (final tab in mangaMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single as LibraryTextFieldSpec<MangaMediaEditDraft>;
}
