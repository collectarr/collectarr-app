import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';
import '../../contracts/owned_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<MovieMedia, MovieMediaEditDraft>>(
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
  defineMediaEditContract<EditSchema<MovieRelease, MovieReleaseEditDraft>>(
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
    final draft = MovieMediaEditDraft.fromMedia(original);
    addTearDown(draft.dispose);

    (_mediaField('title') as TextEditField<MovieMediaEditDraft>)
        .setValue(draft, 'The Matrix Reloaded');
    (_mediaField('genres') as TextEditField<MovieMediaEditDraft>)
        .setValue(draft, 'Science fiction, Action');
    (_mediaField('runtime_minutes') as NumberEditField<MovieMediaEditDraft>)
        .setValue(draft, 138);
    (_mediaField('release_date') as DateEditField<MovieMediaEditDraft>)
        .setValue(draft, DateTime(2003, 5, 7));

    final updated = draft.toMedia();
    expect(updated.id, original.id);
    expect(updated.title, 'The Matrix Reloaded');
    expect(updated.runtimeMinutes, 138);
    expect(updated.releaseDate, DateTime(2003, 5, 7));
    expect(updated.rawPayload['genres'], ['Science fiction', 'Action']);
    expect(movieMediaEditSchema.validate!(original, draft), isNull);

    draft.runtimeMinutesController.text = '-1';
    expect(
      movieMediaEditSchema.validate!(original, draft),
      'Runtime cannot be negative',
    );
    draft.runtimeMinutesController.text = '138';
    draft.releaseDateController.text = 'not-a-date';
    expect(
      movieMediaEditSchema.validate!(original, draft),
      'Release date is invalid',
    );
  });

  test('edits a typed Movie release without video draft fields', () {
    final original = const MovieRelease(
      id: MovieReleaseId('release-1'),
      title: 'Original Edition',
      workId: 'movie-1',
      format: 'Blu-ray',
      region: 'Region A / Region 1',
    );
    final draft = MovieReleaseEditDraft.fromRelease(original);
    addTearDown(draft.dispose);

    final format = _releaseField('format')
        as VocabularyEditField<MovieReleaseEditDraft, String>;
    final region = _releaseField('region')
        as VocabularyEditField<MovieReleaseEditDraft, String>;
    expect(
      format.options.map((option) => option.value),
      MovieVocabularies.physicalFormat.builtIns,
    );
    expect(
      region.options.map((option) => option.value),
      MovieVocabularies.region.builtIns,
    );
    (_releaseField('title') as TextEditField<MovieReleaseEditDraft>)
        .setValue(draft, 'Collector Edition');
    format.setValue(draft, '4K Ultra HD Blu-ray');
    region.setValue(draft, 'Region Free (All Regions)');
    (_releaseField('release_date') as DateEditField<MovieReleaseEditDraft>)
        .setValue(draft, DateTime(2026, 5, 2));

    final updated = draft.toRelease();
    expect(updated.id, original.id);
    expect(updated.workId, original.workId);
    expect(updated.title, 'Collector Edition');
    expect(updated.format, '4K Ultra HD Blu-ray');
    expect(updated.region, 'Region Free (All Regions)');
    expect(updated.releaseDate, DateTime(2026, 5, 2));
    expect(movieReleaseEditSchema.validate!(original, draft), isNull);

    draft.title = '';
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

    (_ownedField('features') as TextEditField<MovieOwnedEditDraft>)
        .setValue(draft, 'Commentary and deleted scenes');
    final hdr = _ownedField('hdr_formats')
        as MultiVocabularyEditField<MovieOwnedEditDraft, String>;
    expect(
      hdr.options.map((option) => option.value),
      MovieVocabularies.hdr.builtIns,
    );
    hdr.setValues(draft, {'HDR10', 'Dolby Vision'});
    (_ownedField('packaging')
            as VocabularyEditField<MovieOwnedEditDraft, String>)
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

EditFieldSpec<MovieMediaEditDraft> _mediaField(String id) {
  return [
    for (final tab in movieMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<MovieReleaseEditDraft> _releaseField(String id) {
  return [
    for (final tab in movieReleaseEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<MovieOwnedEditDraft> _ownedField(String id) {
  return [
    for (final tab in movieOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
