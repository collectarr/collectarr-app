import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/release/boardgame_edition_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/release/boardgame_edition_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/edition/book_edition_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/edition/book_edition_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/release/comic_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/release/comic_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_release_edit_schema.dart';

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
  defineReleaseContract<BoardGameEdition>(
    name: 'BoardGame',
    create: () => BoardGameEdition.fromJson(
      const {'id': 'boardgame-edition-1', 'title': 'Deluxe Edition'},
    ),
    id: (release) => release.id,
    title: (release) => release.title,
  );
  defineReleaseContract<BookRelease>(
    name: 'Book',
    create: () => BookRelease.fromJson(
      const {'id': 'book-release-1', 'title': 'Hardcover Edition'},
    ),
    id: (release) => release.id,
    title: (release) => release.title,
  );
  defineReleaseContract<ComicRelease>(
    name: 'Comic',
    create: () => ComicRelease.fromJson(
      const {'id': 'comic-release-1', 'title': 'Collected Edition'},
    ),
    id: (release) => release.id,
    title: (release) => release.title,
  );
  defineReleaseContract<GameRelease>(
    name: 'Game',
    create: () => GameRelease.fromJson(
      const {'id': 'game-release-1', 'title': 'Launch Edition'},
    ),
    id: (release) => release.id,
    title: (release) => release.title,
  );
  defineReleaseContract<MovieRelease>(
    name: 'Movie',
    create: () => MovieRelease.fromJson(
      const {'id': 'movie-release-1', 'title': '4K Edition'},
    ),
    id: (release) => release.id.value,
    title: (release) => release.title,
  );
  defineReleaseContract<MusicRelease>(
    name: 'Music',
    create: () => MusicRelease.fromJson(
      const {'id': 'music-release-1', 'title': 'Remastered Edition'},
    ),
    id: (release) => release.id.value,
    title: (release) => release.title,
  );
  defineReleaseContract<TvRelease>(
    name: 'TV',
    create: () => TvRelease.fromJson(
      const {
        'id': 'tv-release-1',
        'series_id': 'tv-series-1',
        'title': 'Complete Series',
      },
    ),
    id: (release) => release.id,
    title: (release) => release.title,
  );

  defineReleaseEditContract<EditSchema<AnimeRelease, AnimeReleaseEditDraft>>(
    name: 'Anime',
    create: () => animeReleaseEditSchema,
    tabIds: _tabIds,
    fieldIds: _fieldIds,
  );
  defineReleaseEditContract<
      EditSchema<BoardGameEdition, BoardGameEditionEditDraft>>(
    name: 'BoardGame',
    create: () => boardGameEditionEditSchema,
    tabIds: _tabIds,
    fieldIds: _fieldIds,
  );
  defineReleaseEditContract<EditSchema<BookRelease, BookEditionEditDraft>>(
    name: 'Book',
    create: () => bookEditionEditSchema,
    tabIds: _tabIds,
    fieldIds: _fieldIds,
  );
  defineReleaseEditContract<EditSchema<ComicRelease, ComicReleaseEditDraft>>(
    name: 'Comic',
    create: () => comicReleaseEditSchema,
    tabIds: _tabIds,
    fieldIds: _fieldIds,
  );
  defineReleaseEditContract<EditSchema<GameRelease, GameReleaseEditDraft>>(
    name: 'Game',
    create: () => gameReleaseEditSchema,
    tabIds: _tabIds,
    fieldIds: _fieldIds,
  );
  defineReleaseEditContract<EditSchema<MovieRelease, MovieReleaseEditDraft>>(
    name: 'Movie',
    create: () => movieReleaseEditSchema,
    tabIds: _tabIds,
    fieldIds: _fieldIds,
  );
  defineReleaseEditContract<EditSchema<MusicRelease, MusicReleaseEditDraft>>(
    name: 'Music',
    create: () => musicReleaseEditSchema,
    tabIds: _tabIds,
    fieldIds: _fieldIds,
  );
  defineReleaseEditContract<EditSchema<TvRelease, TvReleaseEditDraft>>(
    name: 'TV',
    create: () => tvReleaseEditSchema,
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
