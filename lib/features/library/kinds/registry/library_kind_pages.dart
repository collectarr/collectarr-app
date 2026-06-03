import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/page.dart';
import 'package:collectarr_app/features/library/kinds/book/page.dart';
import 'package:collectarr_app/features/library/kinds/comic/page.dart';
import 'package:collectarr_app/features/library/kinds/game/page.dart';
import 'package:collectarr_app/features/library/kinds/movie/page.dart';
import 'package:collectarr_app/features/library/kinds/music/page.dart';
import 'package:flutter/material.dart';

Widget buildLibraryKindPage({
  required LibraryTypeConfig type,
  required Widget topBar,
  required Color accent,
  required Uri routeUri,
}) {
  return switch (type.workspace.kind.apiValue) {
    'book' => BookLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
      ),
    'boardgame' => BoardGameLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
      ),
    'comic' => ComicLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
      ),
    'game' => GameLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
      ),
    'movie' => MovieLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
      ),
    'music' => MusicLibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
      ),
    _ => LibraryPage(
        type: type,
        topBar: topBar,
        accent: accent,
        routeUri: routeUri,
      ),
  };
}