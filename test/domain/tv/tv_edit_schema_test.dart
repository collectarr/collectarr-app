import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_release_media_edit_controller.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';
import '../../contracts/owned_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<TvSeries, TvMediaEditDraft>>(
    name: 'TV media',
    create: () => tvMediaEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );
  defineMediaEditContract<EditSchema<TvRelease, TvReleaseEditDraft>>(
    name: 'TV release',
    create: () => tvReleaseEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );
  defineOwnedEditContract<EditSchema<TvOwnedDetails, TvOwnedEditDraft>>(
    name: 'TV',
    create: () => tvOwnedEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('edits a typed TV series without the shared video draft', () {
    final original = TvSeries(
      id: 'series-1',
      title: 'The Expanse',
      originalAirDate: DateTime.utc(2015, 12, 14),
      rawPayload: const {
        'genres': ['Science fiction'],
        'streaming_service': 'Prime Video',
      },
    );
    final draft = TvMediaEditDraft.fromSeries(original);
    addTearDown(draft.dispose);

    (_mediaField('title') as TextEditField<TvMediaEditDraft>)
        .setValue(draft, 'The Expanse: Remastered');
    (_mediaField('genres') as TextEditField<TvMediaEditDraft>)
        .setValue(draft, 'Science fiction, Drama');
    (_mediaField('end_date') as DateEditField<TvMediaEditDraft>)
        .setValue(draft, DateTime.utc(2022, 1, 14));

    final updated = draft.toSeries();
    expect(updated.title, 'The Expanse: Remastered');
    expect(updated.endDate, DateTime(2022, 1, 14));
    expect(updated.rawPayload['genres'], ['Science fiction', 'Drama']);
    expect(tvMediaEditSchema.validate!(original, draft), isNull);

    draft.title = '';
    expect(
      tvMediaEditSchema.validate!(original, draft),
      'Series title is required',
    );
  });

  test('edits a typed TV release and preserves its graph', () {
    final original = const TvRelease(
      id: 'release-1',
      seriesId: 'series-1',
      title: 'Complete Series',
      format: 'Blu-ray',
      regionCode: 'Region A / Region 1',
      media: [
        TvReleaseMedia(id: 'media-1', releaseId: 'release-1'),
      ],
    );
    final draft = TvReleaseEditDraft.fromRelease(original);
    addTearDown(draft.dispose);

    final format = _releaseField('format')
        as VocabularyEditField<TvReleaseEditDraft, String>;
    final region = _releaseField('region')
        as VocabularyEditField<TvReleaseEditDraft, String>;
    format.setValue(draft, '4K Ultra HD Blu-ray');
    region.setValue(draft, 'Region Free');
    (_releaseField('title') as TextEditField<TvReleaseEditDraft>)
        .setValue(draft, 'Collector Edition');

    final updated = draft.toRelease();
    expect(updated.title, 'Collector Edition');
    expect(updated.format, '4K Ultra HD Blu-ray');
    expect(updated.regionCode, 'Region Free');
    expect(updated.media.single.id, 'media-1');
    expect(tvReleaseEditSchema.validate!(original, draft), isNull);

    draft.title = '';
    expect(
      tvReleaseEditSchema.validate!(original, draft),
      'Release title is required',
    );
  });

  test('round trips TV owned details through the typed schema', () {
    const original = TvOwnedDetails(
      features: 'Commentary',
      hdrFormats: ['HDR10'],
      boxSetName: 'Collection',
      region: 'Region A / Region 1',
      packaging: 'Steelbook Season',
    );
    final draft = TvOwnedEditDraft.fromDetails(original);
    addTearDown(draft.dispose);

    (_ownedField('features') as TextEditField<TvOwnedEditDraft>)
        .setValue(draft, 'Commentary and deleted scenes');
    final hdr = _ownedField('hdr_formats')
        as MultiVocabularyEditField<TvOwnedEditDraft, String>;
    expect(hdr.options, isNotEmpty);
    hdr.setValues(draft, {'HDR10', 'Dolby Vision'});
    (_ownedField('packaging') as VocabularyEditField<TvOwnedEditDraft, String>)
        .setValue(draft, 'Steelbook Season');

    expect(
      draft.toDetails(),
      const TvOwnedDetails(
        features: 'Commentary and deleted scenes',
        hdrFormats: ['HDR10', 'Dolby Vision'],
        boxSetName: 'Collection',
        region: 'Region A / Region 1',
        packaging: 'Steelbook Season',
      ),
    );
  });

  test('TV release-media editor owns fallback discs and episode mapping', () {
    final item = CatalogItem(
      identity: const LibraryItemIdentity(
        id: 'series-1',
        mediaKind: CatalogMediaKind.tv,
      ),
      kindMetadata: const TvSeriesMetadata(title: 'The Expanse'),
    );
    final editor = TvReleaseMediaEditController(
      item: item,
      initialDiscCount: 2,
    );
    final episode = const TvEpisode(
      id: 'episode-1',
      seriesId: 'series-1',
      seasonId: 'season-1',
      seasonNumber: 1,
      episodeNumber: 1,
      title: 'Dulcinea',
    );
    final series = TvSeries(
      id: 'series-1',
      title: 'The Expanse',
      seasons: [
        TvSeason(
          id: 'season-1',
          seriesId: 'series-1',
          seasonNumber: 1,
          episodes: [episode],
        ),
      ],
    );

    editor.primeTvSeriesDraft(series);

    expect(editor.tvReleaseMediaDraft, hasLength(2));
    expect(
      editor.discAssignmentForEpisode(
        episodeId: episode.id,
        seasonNumber: 1,
        episodeNumber: 1,
      ),
      1,
    );
    editor.updateTvEpisodeDiscAssignment(
      episode.id,
      seasonNumber: 1,
      episodeNumber: 1,
      discNumber: 2,
    );
    expect(
      editor.discAssignmentForEpisode(
        episodeId: episode.id,
        seasonNumber: 1,
        episodeNumber: 1,
      ),
      2,
    );
    expect(editor.tvEpisodeLabel(episode), 'S01E01 Dulcinea');
  });
}

EditFieldSpec<TvMediaEditDraft> _mediaField(String id) {
  return [
    for (final tab in tvMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<TvReleaseEditDraft> _releaseField(String id) {
  return [
    for (final tab in tvReleaseEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}

EditFieldSpec<TvOwnedEditDraft> _ownedField(String id) {
  return [
    for (final tab in tvOwnedEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
