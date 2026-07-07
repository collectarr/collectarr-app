import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/anime/page.dart';
import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/page.dart';
import 'package:collectarr_app/features/library/kinds/book/page.dart';
import 'package:collectarr_app/features/library/kinds/comic/page.dart';
import 'package:collectarr_app/features/library/kinds/game/page.dart';
import 'package:collectarr_app/features/library/kinds/manga/page.dart';
import 'package:collectarr_app/features/library/kinds/movie/page.dart';
import 'package:collectarr_app/features/library/kinds/music/page.dart';
import 'package:collectarr_app/features/library/kinds/tv/page.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';

Widget buildLibraryKindPage({
  required LibraryTypeConfig type,
  required Widget topBar,
  required Color accent,
  required Uri routeUri,
  LibraryLayoutSnapshot? switchLayoutSnapshot,
}) {
  return switch (type.workspace.kind.apiValue) {
    'book' => BookLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      ),
    'boardgame' => BoardGameLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      ),
    'comic' => ComicLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      ),
    'manga' => MangaLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      ),
    'game' => GameLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      ),
    'movie' => MovieLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      ),
    'tv' => TvLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      ),
    'anime' => AnimeLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      ),
    'music' => MusicLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      ),
    _ => GenericLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
      ),
  };
}
