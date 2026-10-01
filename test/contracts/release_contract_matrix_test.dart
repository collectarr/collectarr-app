import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_schema.dart';

import 'release_contract.dart';
import 'release_edit_contract.dart';

void main() {
  defineReleaseContract<AnimeRelease>(
    name: 'Anime',
    create: () => AnimeRelease.fromJson(
      const {'id': 'anime-release-1', 'title': 'Collector Edition'},
    ),
    id: (release) => release.id.value,
    title: (release) => release.title,
  );
  defineReleaseContract<MusicAlbum>(
    name: 'Music',
    create: () => MusicAlbum.fromJson(
      const {'id': 'music-release-1', 'title': 'Remastered Edition'},
    ),
    id: (release) => release.id.value,
    title: (release) => release.title,
  );

  defineReleaseEditContract<EditSchema<AnimeRelease, AnimeReleaseFormValues>>(
    name: 'Anime',
    create: () => animeReleaseEditSchema,
    tabIds: _tabIds,
    fieldIds: _fieldIds,
  );
  defineReleaseEditContract<EditSchema<MusicAlbum, MusicAlbumEditDraft>>(
    name: 'Music',
    create: () => musicAlbumEditSchema,
    tabIds: _tabIds,
    fieldIds: _fieldIds,
  );
}

Iterable<String> _tabIds<TModel, TDraft>(EditSchema<TModel, TDraft> schema) =>
    schema.tabs.map((tab) => tab.id);

Iterable<String> _fieldIds<TModel, TDraft>(
  EditSchema<TModel, TDraft> schema,
  String tabId,
) =>
    [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ];
