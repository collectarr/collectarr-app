import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';
import '../../contracts/owned_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<AnimeMedia, AnimeMediaEditDraft>>(
    name: 'Anime media',
    create: () => animeMediaEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );
  defineMediaEditContract<EditSchema<AnimeRelease, AnimeReleaseEditDraft>>(
    name: 'Anime release',
    create: () => animeReleaseEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );
  defineOwnedEditContract<EditSchema<AnimeOwnedDetails, AnimeOwnedEditDraft>>(
    name: 'Anime',
    create: () => animeOwnedEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('edits typed Anime media and preserves its nested graph', () {
    final original = AnimeMedia(
      id: const AnimeMediaId('anime-1'),
      title: 'Cowboy Bebop',
      animeType: 'TV Series',
      episodeCount: 26,
      episodes: const [],
      releases: const [],
      rawPayload: const {
        'genres': ['Action'],
        'studios': ['Sunrise'],
        'season': 'Spring',
        'season_year': 1998,
      },
    );
    final draft = AnimeMediaEditDraft.fromMedia(original);
    addTearDown(draft.dispose);

    (_mediaField('title') as TextEditField<AnimeMediaEditDraft>)
        .setValue(draft, 'Cowboy Bebop: Complete');
    (_mediaField('genres') as TextEditField<AnimeMediaEditDraft>)
        .setValue(draft, 'Action, Sci-Fi');
    (_mediaField('episode_count') as NumberEditField<AnimeMediaEditDraft>)
        .setValue(draft, 26);
    (_mediaField('end_date') as DateEditField<AnimeMediaEditDraft>)
        .setValue(draft, DateTime(1999, 4, 24));

    final updated = draft.toMedia();
    expect(updated.id, original.id);
    expect(updated.title, 'Cowboy Bebop: Complete');
    expect(updated.episodeCount, 26);
    expect(updated.endDate, DateTime(1999, 4, 24));
    expect(updated.episodes, original.episodes);
    expect(updated.rawPayload['genres'], ['Action', 'Sci-Fi']);
    expect(animeMediaEditSchema.validate!(original, draft), isNull);

    draft.title = '';
    expect(
      animeMediaEditSchema.validate!(original, draft),
      'Anime title is required',
    );
  });

  test('edits typed Anime release without shared video fields', () {
    final original = const AnimeRelease(
      id: AnimeReleaseId('release-1'),
      seriesId: AnimeMediaId('anime-1'),
      title: 'Collector Edition',
      format: 'Blu-ray',
      regionCode: 'Region A / Region 1',
      audioTracks: ['Japanese'],
    );
    final draft = AnimeReleaseEditDraft.fromRelease(original);
    addTearDown(draft.dispose);

    final format = _releaseField('format')
        as VocabularyEditField<AnimeReleaseEditDraft, String>;
    final region = _releaseField('region')
        as VocabularyEditField<AnimeReleaseEditDraft, String>;
    expect(
      format.options.map((option) => option.value),
      AnimeVocabularies.physicalFormat.builtIns,
    );
    expect(
      region.options.map((option) => option.value),
      AnimeVocabularies.region.builtIns,
    );

    (_releaseField('title') as TextEditField<AnimeReleaseEditDraft>)
        .setValue(draft, 'Collector Edition Remastered');
    format.setValue(draft, '4K Ultra HD Blu-ray');
    region.setValue(draft, 'Region Free');
    (_releaseField('audio_tracks') as TextEditField<AnimeReleaseEditDraft>)
        .setValue(draft, 'Japanese, English');
    (_releaseField('media_count') as NumberEditField<AnimeReleaseEditDraft>)
        .setValue(draft, 4);

    final updated = draft.toRelease();
    expect(updated.id, original.id);
    expect(updated.seriesId, original.seriesId);
    expect(updated.title, 'Collector Edition Remastered');
    expect(updated.format, '4K Ultra HD Blu-ray');
    expect(updated.regionCode, 'Region Free');
    expect(updated.audioTracks, ['Japanese', 'English']);
    expect(updated.mediaCount, 4);
    expect(animeReleaseEditSchema.validate!(original, draft), isNull);

    draft.title = '';
    expect(
      animeReleaseEditSchema.validate!(original, draft),
      'Release title is required',
    );
  });

  test('round trips Anime owned details through the typed schema', () {
    const original = AnimeOwnedDetails(
      features: 'Commentary',
      hdrFormats: ['HDR10'],
      boxSetName: 'Collector Box',
      region: 'Region A / Region 1',
      packaging: 'Digipak',
    );
    final draft = AnimeOwnedEditDraft.fromDetails(original);
    addTearDown(draft.dispose);

    (_ownedField('features') as TextEditField<AnimeOwnedEditDraft>)
        .setValue(draft, 'Commentary and artbook');
    final hdr = _ownedField('hdr_formats')
        as MultiVocabularyEditField<AnimeOwnedEditDraft, String>;
    expect(hdr.options, isNotEmpty);
    hdr.setValues(draft, {'HDR10', 'Dolby Vision'});
    (_ownedField('packaging')
            as VocabularyEditField<AnimeOwnedEditDraft, String>)
        .setValue(draft, 'Digipak');

    expect(
      draft.toDetails(),
      const AnimeOwnedDetails(
        features: 'Commentary and artbook',
        hdrFormats: ['HDR10', 'Dolby Vision'],
        boxSetName: 'Collector Box',
        region: 'Region A / Region 1',
        packaging: 'Digipak',
      ),
    );
  });
}

EditFieldSpec<AnimeMediaEditDraft> _mediaField(String id) {
  return [
    for (final tab in animeMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<AnimeReleaseEditDraft> _releaseField(String id) {
  return [
    for (final tab in animeReleaseEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<AnimeOwnedEditDraft> _ownedField(String id) {
  return [
    for (final tab in animeOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
