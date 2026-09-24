import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';
import '../../contracts/owned_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<MovieMedia, MovieCatalogFormValues>>(
    name: 'Movie media',
    create: () => movieMediaEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );
  defineMediaEditContract<EditSchema<MovieRelease, MovieCatalogFormValues>>(
    name: 'Movie release',
    create: () => movieReleaseEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );
  defineOwnedEditContract<EditSchema<MovieOwnedDetails, MovieOwnedEditDraft>>(
    name: 'Movie',
    create: () => movieOwnedEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('edits every Movie media field through a typed draft', () {
    final original = MovieMedia(
      id: const MovieMediaId('movie-1'),
      title: 'The Matrix',
      sortTitle: 'Matrix, The',
      runtimeMinutes: 136,
      rawPayload: const {
        'genres': ['Science fiction']
      },
    );
    final draft = movieCatalogFormValuesFromMedia(original);

    (_mediaField('title') as LibraryTextFieldSpec<MovieCatalogFormValues>)
        .setValue(draft, 'The Matrix Reloaded');
    (_mediaField('genres') as LibraryTextFieldSpec<MovieCatalogFormValues>)
        .setValue(draft, 'Science fiction, Action');
    (_mediaField('runtime_minutes')
            as LibraryNumberFieldSpec<MovieCatalogFormValues>)
        .setValue(draft, 138);
    (_mediaField('work_release_date')
            as LibraryDateFieldSpec<MovieCatalogFormValues>)
        .setValue(draft, DateTime(2003, 5, 7));

    final updated = movieMediaFromCatalogFormValues(
      original: original,
      values: draft,
    );
    expect(updated.id, original.id);
    expect(updated.title, 'The Matrix Reloaded');
    expect(updated.runtimeMinutes, 138);
    expect(updated.releaseDate, DateTime(2003, 5, 7));
    expect(updated.rawPayload['genres'], ['Science fiction', 'Action']);
    expect(movieMediaEditSchema.validate!(original, draft), isNull);

    draft.runtimeMinutes = -1;
    expect(
      movieMediaEditSchema.validate!(original, draft),
      'Runtime cannot be negative',
    );
    draft.runtimeMinutes = 138;
    expect(movieMediaEditSchema.validate!(original, draft), isNull);
  });

  test('edits a typed Movie release without video draft fields', () {
    final original = const MovieRelease(
      id: MovieReleaseId('release-1'),
      title: 'Original Edition',
      workId: 'movie-1',
      format: 'Blu-ray',
      region: 'Region A / Region 1',
    );
    final draft = movieCatalogFormValuesFromRelease(original);

    final format = _releaseField('format')
        as LibraryVocabularyFieldSpec<MovieCatalogFormValues, String>;
    final region = _releaseField('region')
        as LibraryVocabularyFieldSpec<MovieCatalogFormValues, String>;
    expect(
      format.options.map((option) => option.value),
      MovieVocabularies.physicalFormat.builtIns,
    );
    expect(
      region.options.map((option) => option.value),
      MovieVocabularies.region.builtIns,
    );
    (_releaseField('release_title')
            as LibraryTextFieldSpec<MovieCatalogFormValues>)
        .setValue(draft, 'Collector Edition');
    format.setValue(draft, '4K Ultra HD Blu-ray');
    region.setValue(draft, 'Region Free (All Regions)');
    (_releaseField('release_date')
            as LibraryDateFieldSpec<MovieCatalogFormValues>)
        .setValue(draft, DateTime(2026, 5, 2));

    final updated = movieReleaseFromCatalogFormValues(
      original: original,
      values: draft,
    );
    expect(updated.id, original.id);
    expect(updated.workId, original.workId);
    expect(updated.title, 'Collector Edition');
    expect(updated.format, '4K Ultra HD Blu-ray');
    expect(updated.region, 'Region Free (All Regions)');
    expect(updated.releaseDate, DateTime(2026, 5, 2));
    expect(movieReleaseEditSchema.validate!(original, draft), isNull);

    draft.releaseTitle = '';
    expect(
      movieReleaseEditSchema.validate!(original, draft),
      'Release title is required',
    );
  });

  test('round trips Movie owned details through the typed schema', () {
    final original = const MovieOwnedDetails(
      features: 'Commentary',
      hdrFormats: ['HDR10'],
      boxSetName: 'Collection',
      region: 'Region A / Region 1',
      packaging: 'Steelbook',
    );
    final draft = MovieOwnedEditDraft.fromDetails(original);
    addTearDown(draft.dispose);

    (_ownedField('features') as LibraryTextFieldSpec<MovieOwnedEditDraft>)
        .setValue(draft, 'Commentary and deleted scenes');
    final hdr = _ownedField('hdr_formats')
        as LibraryMultiVocabularyFieldSpec<MovieOwnedEditDraft, String>;
    expect(
      hdr.options.map((option) => option.value),
      MovieVocabularies.hdr.builtIns,
    );
    hdr.setValues(draft, {'HDR10', 'Dolby Vision'});
    (_ownedField('packaging')
            as LibraryVocabularyFieldSpec<MovieOwnedEditDraft, String>)
        .setValue(draft, 'Steelbook');

    expect(
      draft.toDetails(),
      const MovieOwnedDetails(
        features: 'Commentary and deleted scenes',
        hdrFormats: ['HDR10', 'Dolby Vision'],
        boxSetName: 'Collection',
        region: 'Region A / Region 1',
        packaging: 'Steelbook',
      ),
    );
  });
}

LibraryFieldSpec<MovieCatalogFormValues> _mediaField(String id) {
  return [
    for (final tab in movieMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

LibraryFieldSpec<MovieCatalogFormValues> _releaseField(String id) {
  return [
    for (final tab in movieReleaseEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

LibraryFieldSpec<MovieOwnedEditDraft> _ownedField(String id) {
  return [
    for (final tab in movieOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
