// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration_adapter.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/generic/generic_kind_module.dart';
import 'package:collectarr_app/features/library/generic/page.dart';
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
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/page.dart';

final List<LibraryKindRegistration> collectarrKindRegistrations = [
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.anime,
    module: animeKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) =>
        AnimeLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.boardgame,
    module: boardGameKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) =>
        BoardGameLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.book,
    module: bookKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) =>
        BookLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.comic,
    module: comicKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) =>
        ComicLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.game,
    module: gameKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) =>
        GameLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.manga,
    module: mangaKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) =>
        MangaLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.movie,
    module: movieKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) =>
        MovieLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.music,
    module: musicKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) =>
        MusicLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.tv,
    module: tvKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) =>
        TvLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
];

LibraryKindRegistration libraryKindRegistrationForKind(CatalogMediaKind kind) {
  for (final registration in collectarrKindRegistrations) {
    if (registration.kind == kind) return registration;
  }
  if (kind == CatalogMediaKind.unknown) {
    return LibraryKindRegistrationAdapter(
      kind: CatalogMediaKind.unknown,
      module: genericKindModule,
      pageBuilder: ({
        required LibraryKindModule type,
        required Widget topBar,
        required Color accent,
        required Uri routeUri,
        LibraryLayoutSnapshot? switchLayoutSnapshot,
      }) =>
          GenericLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      ),
    );
  }
  throw ArgumentError(
    'No LibraryKindRegistration registered for kind "$kind"',
  );
}
