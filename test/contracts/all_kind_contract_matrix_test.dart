import 'dart:io';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/registry/owned_details_exports.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every active kind is checked through its typed module signature', () {
    _checkTypedKind<ComicWorkspaceDto, ComicOwnedDetails,
        ComicOwnedDetailsDraft>(
      name: 'Comic',
      kind: CatalogMediaKind.comic,
      spec: comicKindModule,
      contractFiles: const [
        'test/domain/comic/comic_core_mapper_test.dart',
        'test/domain/comic/comic_repository_test.dart',
        'test/domain/comic/comic_local_mapper_test.dart',
        'test/domain/comic/comic_workspace_contract_test.dart',
        'test/domain/comic/comic_add_schema_test.dart',
        'test/domain/comic/comic_media_edit_schema_test.dart',
      ],
    );
    _checkTypedKind<MangaWorkspaceDto, MangaOwnedDetails,
        MangaOwnedDetailsDraft>(
      name: 'Manga',
      kind: CatalogMediaKind.manga,
      spec: mangaKindModule,
      contractFiles: const [
        'test/domain/manga/manga_core_mapper_test.dart',
        'test/domain/manga/manga_repository_test.dart',
        'test/domain/manga/manga_local_mapper_test.dart',
        'test/domain/manga/manga_add_schema_test.dart',
        'test/domain/manga/manga_media_edit_schema_test.dart',
      ],
    );
    _checkTypedKind<BookWorkspaceDto, BookOwnedDetails, BookOwnedDetailsDraft>(
      name: 'Book',
      kind: CatalogMediaKind.book,
      spec: bookKindModule,
      contractFiles: const [
        'test/domain/book/book_core_mapper_test.dart',
        'test/domain/book/book_repository_test.dart',
        'test/domain/book/book_local_mapper_test.dart',
        'test/domain/book/book_add_schema_test.dart',
        'test/domain/book/book_edit_schema_test.dart',
        'test/domain/book/book_workspace_projection_test.dart',
      ],
    );
    _checkTypedKind<GameWorkspaceDto, GameOwnedDetails, GameOwnedDetailsDraft>(
      name: 'Game',
      kind: CatalogMediaKind.game,
      spec: gameKindModule,
      contractFiles: const [
        'test/domain/game/game_core_mapper_test.dart',
        'test/domain/game/game_repository_test.dart',
        'test/domain/game/game_local_mapper_test.dart',
        'test/domain/game/game_add_schema_test.dart',
        'test/domain/game/game_edit_schema_test.dart',
        'test/domain/game/game_workspace_projection_test.dart',
      ],
    );
    _checkTypedKind<BoardGameWorkspaceDto, BoardgameOwnedDetails,
        BoardgameOwnedDetailsDraft>(
      name: 'BoardGame',
      kind: CatalogMediaKind.boardgame,
      spec: boardGameKindModule,
      contractFiles: const [
        'test/domain/boardgame/boardgame_core_mapper_test.dart',
        'test/domain/boardgame/boardgame_repository_test.dart',
        'test/domain/boardgame/boardgame_local_mapper_test.dart',
        'test/domain/boardgame/boardgame_edit_schema_test.dart',
        'test/domain/boardgame/boardgame_workspace_projection_test.dart',
      ],
    );
    _checkTypedKind<MovieWorkspaceDto, MovieOwnedDetails,
        MovieOwnedDetailsDraft>(
      name: 'Movie',
      kind: CatalogMediaKind.movie,
      spec: movieKindModule,
      contractFiles: const [
        'test/domain/movie/movie_core_mapper_test.dart',
        'test/domain/movie/movie_repository_test.dart',
        'test/domain/movie/movie_local_mapper_test.dart',
        'test/domain/movie/movie_add_schema_test.dart',
        'test/domain/movie/movie_edit_schema_test.dart',
        'test/domain/movie/movie_workspace_projection_test.dart',
      ],
    );
    _checkTypedKind<TvWorkspaceDto, TvOwnedDetails, TvOwnedDetailsDraft>(
      name: 'TV',
      kind: CatalogMediaKind.tv,
      spec: tvKindModule,
      contractFiles: const [
        'test/domain/tv/tv_domain_mapper_test.dart',
        'test/domain/tv/tv_local_mapper_repository_test.dart',
        'test/domain/tv/tv_add_schema_test.dart',
        'test/domain/tv/tv_edit_schema_test.dart',
        'test/domain/tv/tv_workspace_projection_test.dart',
      ],
    );
    _checkTypedKind<AnimeWorkspaceDto, AnimeOwnedDetails,
        AnimeOwnedDetailsDraft>(
      name: 'Anime',
      kind: CatalogMediaKind.anime,
      spec: animeKindModule,
      contractFiles: const [
        'test/domain/anime/anime_core_mapper_test.dart',
        'test/domain/anime/anime_local_mapper_repository_test.dart',
        'test/domain/anime/anime_add_schema_test.dart',
        'test/domain/anime/anime_edit_schema_test.dart',
        'test/domain/anime/anime_hierarchy_workspace_test.dart',
      ],
    );
    _checkTypedKind<MusicWorkspaceDto, MusicOwnedDetails,
        MusicOwnedDetailsDraft>(
      name: 'Music',
      kind: CatalogMediaKind.music,
      spec: musicKindModule,
      contractFiles: const [
        'test/domain/music/music_core_mapper_test.dart',
        'test/domain/music/music_local_mapper_repository_test.dart',
        'test/domain/music/music_add_edit_schema_test.dart',
        'test/domain/music/music_workspace_test.dart',
      ],
    );
  });
}

void _checkTypedKind<
    TDto extends LibraryWorkspaceDto,
    TDetails extends OwnedItemDetails,
    TDetailsDraft extends OwnedDetailsDraft>({
  required String name,
  required CatalogMediaKind kind,
  required LibraryKindSpec<TDto, TDetails, TDetailsDraft> spec,
  required List<String> contractFiles,
}) {
  final fields = spec.fields;
  final projector = spec.projector;
  final details = spec.ownedDetailsCodec.defaultDetails();
  final encoded = spec.ownedDetailsCodec.toJson(details);

  expect(spec.identity.kind, kind, reason: '$name identity must be typed');
  expect(fields.kindNamespace, kind.apiValue);
  expect(fields.fields, isNotEmpty, reason: '$name needs fields');
  expect(fields.columns, isNotEmpty, reason: '$name needs columns');
  expect(fields.sorts, isNotEmpty, reason: '$name needs sorts');
  expect(fields.groups, isNotEmpty, reason: '$name needs groups');
  expect(projector, isNotNull, reason: '$name needs a typed projector');
  expect(spec.add.kind, kind);
  expect(spec.add.createInitialDraft(), isNotNull);
  expect(spec.add.createManualDraft(), isNotNull);
  expect(spec.edit.createDraft, isNotNull);
  expect(spec.ownedDetailsCodec.fromJson(encoded), isA<TDetails>());
  expect(spec.facets, isNotNull, reason: '$name needs facet definitions');

  for (final path in contractFiles) {
    expect(
      File(path).existsSync(),
      isTrue,
      reason: '$name contract coverage is missing: $path',
    );
  }
}
