import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/media/manga_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_values.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<MangaMedia, MangaCatalogFormValues>>(
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
    final original = MangaMedia(
      id: 'manga-1',
      title: 'Frieren',
      originalLanguage: 'Japanese',
      rawPayload: const {
        'genres': ['Fantasy'],
        'search_aliases': ['Frieren'],
        'provider_marker': 'preserve',
      },
      firstPublicationDate: DateTime(2020, 1, 1),
    );
    final values = mangaCatalogFormValuesFromMedia(original);

    _field('title').setValue(values, 'Frieren: Beyond Journey');
    _field('genres').setValue(values, 'Fantasy, Adventure');
    _field('status').setValue(values, 'Finished');
    _field('original_language').setValue(values, 'English');
    _field('search_aliases').setValue(values, 'Frieren, Sousou no Frieren');

    final updated = mangaMediaFromCatalogFormValues(
      original: original,
      values: values,
    );
    expect(updated.title, 'Frieren: Beyond Journey');
    expect(updated.rawPayload['genres'], ['Fantasy', 'Adventure']);
    expect(updated.rawPayload['status'], 'Finished');
    expect(updated.rawPayload['original_language'], 'English');
    expect(
        updated.rawPayload['search_aliases'], ['Frieren', 'Sousou no Frieren']);
    expect(updated.rawPayload['provider_marker'], 'preserve');
    expect(updated.firstPublicationDate, DateTime(2020, 1, 1));
  });

  test('requires a Manga title', () {
    const original = MangaMedia(id: 'manga-1', title: 'Frieren');
    final values = mangaCatalogFormValuesFromMedia(original)..title = ' ';
    expect(
      mangaMediaEditSchema.validate!(original, values),
      'Manga title is required',
    );
  });
}

LibraryTextFieldSpec<MangaCatalogFormValues> _field(String id) => [
      for (final tab in mangaMediaEditSchema.tabs)
        for (final section in tab.sections)
          for (final field in section.fields)
            if (field.id == id) field,
    ].single as LibraryTextFieldSpec<MangaCatalogFormValues>;
