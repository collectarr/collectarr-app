import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/page.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/page.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/page.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/page.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/game/page.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/page.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/page.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/page.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/kinds/tv/page.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';

Widget _buildKindAdd({
  required LibraryKindModule type,
  required LibraryAddDialogRequest request,
}) {
  return LibraryAddDialog(
    type: type,
    accent: request.accent,
    initialQuery: request.initialQuery,
    initialBarcode: request.initialBarcode,
  );
}

Future<LibraryEditSelection?> _openKindEdit({
  required BuildContext context,
  required LibraryEditDialogRequest request,
  required LibraryEditScope scope,
}) {
  return showLibraryEditDialog(
    context: context,
    request: request.copyWith(scope: scope),
  );
}

final class ComicRegistration implements LibraryKindRegistration {
  const ComicRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  LibraryKindIdentity get identity => comicKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) =>
      ComicLibraryPage(
        type: comicKindModule,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      );

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) =>
      _buildKindAdd(type: comicKindModule, request: request);

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.media,
      );

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.release,
      );

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.all,
      );
}

final class MangaRegistration implements LibraryKindRegistration {
  const MangaRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  LibraryKindIdentity get identity => mangaKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) =>
      MangaLibraryPage(
        type: mangaKindModule,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      );

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) =>
      _buildKindAdd(type: mangaKindModule, request: request);

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.media,
      );

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.release,
      );

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.all,
      );
}

final class BookRegistration implements LibraryKindRegistration {
  const BookRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  LibraryKindIdentity get identity => bookKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) =>
      BookLibraryPage(
        type: bookKindModule,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      );

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) =>
      _buildKindAdd(type: bookKindModule, request: request);

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.media,
      );

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.release,
      );

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.all,
      );
}

final class GameRegistration implements LibraryKindRegistration {
  const GameRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  LibraryKindIdentity get identity => gameKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) =>
      GameLibraryPage(
        type: gameKindModule,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      );

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) =>
      _buildKindAdd(type: gameKindModule, request: request);

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.media,
      );

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.release,
      );

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.all,
      );
}

final class BoardGameRegistration implements LibraryKindRegistration {
  const BoardGameRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  LibraryKindIdentity get identity => boardGameKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) =>
      BoardGameLibraryPage(
        type: boardGameKindModule,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      );

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) =>
      _buildKindAdd(type: boardGameKindModule, request: request);

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.media,
      );

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.release,
      );

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.all,
      );
}

final class MovieRegistration implements LibraryKindRegistration {
  const MovieRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  LibraryKindIdentity get identity => movieKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) =>
      MovieLibraryPage(
        type: movieKindModule,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      );

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) =>
      _buildKindAdd(type: movieKindModule, request: request);

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.media,
      );

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.release,
      );

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.all,
      );
}

final class TvRegistration implements LibraryKindRegistration {
  const TvRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  LibraryKindIdentity get identity => tvKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) =>
      TvLibraryPage(
        type: tvKindModule,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      );

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) =>
      _buildKindAdd(type: tvKindModule, request: request);

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.media,
      );

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.release,
      );

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.all,
      );
}

final class AnimeRegistration implements LibraryKindRegistration {
  const AnimeRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  LibraryKindIdentity get identity => animeKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) =>
      AnimeLibraryPage(
        type: animeKindModule,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      );

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) =>
      _buildKindAdd(type: animeKindModule, request: request);

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.media,
      );

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.release,
      );

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.all,
      );
}

final class MusicRegistration implements LibraryKindRegistration {
  const MusicRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  LibraryKindIdentity get identity => musicKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) =>
      MusicLibraryPage(
        type: musicKindModule,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      );

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) =>
      _buildKindAdd(type: musicKindModule, request: request);

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.media,
      );

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.release,
      );

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) =>
      _openKindEdit(
        context: context,
        request: request,
        scope: LibraryEditScope.all,
      );
}

const List<LibraryKindRegistration> collectarrKindRegistrations = [
  ComicRegistration(),
  MangaRegistration(),
  BookRegistration(),
  GameRegistration(),
  BoardGameRegistration(),
  MovieRegistration(),
  TvRegistration(),
  AnimeRegistration(),
  MusicRegistration(),
];

LibraryKindRegistration libraryKindRegistrationForKind(CatalogMediaKind kind) {
  return switch (kind) {
    CatalogMediaKind.comic => const ComicRegistration(),
    CatalogMediaKind.manga => const MangaRegistration(),
    CatalogMediaKind.book => const BookRegistration(),
    CatalogMediaKind.game => const GameRegistration(),
    CatalogMediaKind.boardgame => const BoardGameRegistration(),
    CatalogMediaKind.movie => const MovieRegistration(),
    CatalogMediaKind.tv => const TvRegistration(),
    CatalogMediaKind.anime => const AnimeRegistration(),
    CatalogMediaKind.music => const MusicRegistration(),
    CatalogMediaKind.unknown => throw ArgumentError(
        'No LibraryKindRegistration registered for unknown kind',
      ),
  };
}
