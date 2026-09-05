import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
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
import 'package:collectarr_app/features/library/kinds/generic/generic_kind_module.dart';
import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/page.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/page.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/page.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/page.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/generic/generic_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';

final List<LibraryKindRuntime> collectarrKindModules = [
  comicKindModule,
  mangaKindModule,
  bookKindModule,
  gameKindModule,
  boardGameKindModule,
  movieKindModule,
  tvKindModule,
  animeKindModule,
  musicKindModule,
];

typedef _LibraryKindPageBuilder = Widget Function({
  required LibraryKindRuntime type,
  required Widget topBar,
  required Color accent,
  required Uri routeUri,
  LibraryLayoutSnapshot? switchLayoutSnapshot,
});

/// The runtime is captured here, at the composition root, and is not exposed
/// by the page dispatch boundary.
final class _RuntimeLibraryKindRegistration implements LibraryKindRegistration {
  const _RuntimeLibraryKindRegistration({
    required LibraryKindRuntime runtime,
    required _LibraryKindPageBuilder pageBuilder,
  })  : _runtime = runtime,
        _pageBuilder = pageBuilder;

  final LibraryKindRuntime _runtime;
  final _LibraryKindPageBuilder _pageBuilder;

  _RuntimeLibraryKindRegistration bind(LibraryKindRuntime runtime) {
    return _RuntimeLibraryKindRegistration(
      runtime: runtime,
      pageBuilder: _pageBuilder,
    );
  }

  @override
  CatalogMediaKind get kind => _runtime.kind;

  @override
  LibraryKindIdentity get identity => _runtime.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    return _pageBuilder(
      type: _runtime,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    );
  }

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) {
    return LibraryAddDialog(
      type: request.type,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    );
  }

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: LibraryEditScope.media),
    );
  }

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: LibraryEditScope.release),
    );
  }
}

final _registrationTemplates = <_RuntimeLibraryKindRegistration>[
  _RuntimeLibraryKindRegistration(
    runtime: comicKindModule,
    pageBuilder: ({
      required type,
      required topBar,
      required accent,
      required routeUri,
      switchLayoutSnapshot,
    }) =>
        ComicLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  _RuntimeLibraryKindRegistration(
    runtime: mangaKindModule,
    pageBuilder: ({
      required type,
      required topBar,
      required accent,
      required routeUri,
      switchLayoutSnapshot,
    }) =>
        MangaLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  _RuntimeLibraryKindRegistration(
    runtime: bookKindModule,
    pageBuilder: ({
      required type,
      required topBar,
      required accent,
      required routeUri,
      switchLayoutSnapshot,
    }) =>
        BookLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  _RuntimeLibraryKindRegistration(
    runtime: gameKindModule,
    pageBuilder: ({
      required type,
      required topBar,
      required accent,
      required routeUri,
      switchLayoutSnapshot,
    }) =>
        GameLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  _RuntimeLibraryKindRegistration(
    runtime: boardGameKindModule,
    pageBuilder: ({
      required type,
      required topBar,
      required accent,
      required routeUri,
      switchLayoutSnapshot,
    }) =>
        BoardGameLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  _RuntimeLibraryKindRegistration(
    runtime: movieKindModule,
    pageBuilder: ({
      required type,
      required topBar,
      required accent,
      required routeUri,
      switchLayoutSnapshot,
    }) =>
        MovieLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  _RuntimeLibraryKindRegistration(
    runtime: tvKindModule,
    pageBuilder: ({
      required type,
      required topBar,
      required accent,
      required routeUri,
      switchLayoutSnapshot,
    }) =>
        TvLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  _RuntimeLibraryKindRegistration(
    runtime: animeKindModule,
    pageBuilder: ({
      required type,
      required topBar,
      required accent,
      required routeUri,
      switchLayoutSnapshot,
    }) =>
        AnimeLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  _RuntimeLibraryKindRegistration(
    runtime: musicKindModule,
    pageBuilder: ({
      required type,
      required topBar,
      required accent,
      required routeUri,
      switchLayoutSnapshot,
    }) =>
        MusicLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
];

/// Registrations are the only erased objects used by kind page dispatch.
final List<LibraryKindRegistration> collectarrKindRegistrations =
    List.unmodifiable(_registrationTemplates);

LibraryKindRegistration libraryKindRegistrationForRuntime(
  LibraryKindRuntime runtime,
) {
  for (final template in _registrationTemplates) {
    if (template.kind == runtime.kind) {
      return template.bind(runtime);
    }
  }
  return _RuntimeLibraryKindRegistration(
    runtime: runtime,
    pageBuilder: ({
      required type,
      required topBar,
      required accent,
      required routeUri,
      switchLayoutSnapshot,
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

Object? decodeLibraryKindMetadata(
  CatalogMediaKind mediaKind,
  Map<String, dynamic> json,
) {
  for (final module in collectarrKindModules) {
    if (module.kind == mediaKind && module.catalogMetadataDecoder != null) {
      return module.catalogMetadataDecoder!(json);
    }
  }
  return Map<String, dynamic>.from(json);
}

CatalogItem typedCatalogItemFromCatalogItem(CatalogItem item) {
  if (item.kindMetadata is! Map) return item;
  return item.withKindMetadata(
    decodeLibraryKindMetadata(item.mediaKind, item.payload),
  );
}

CatalogItem typedCatalogItemFromMap(Map<String, dynamic> json) {
  final item = CatalogItem.fromJson(json);
  return typedCatalogItemFromCatalogItem(item);
}

CatalogItem? typedCatalogItemFromUnknown(Object? item) {
  if (item is! CatalogItem) return null;
  return typedCatalogItemFromCatalogItem(item);
}

LibraryKindRuntime? lookupLibraryKind(CatalogMediaKind kind) {
  for (final module in collectarrKindModules) {
    if (module.kind == kind) {
      return module;
    }
  }
  return null;
}

LibraryKindRuntime libraryKindFor(CatalogMediaKind kind) {
  final module = lookupLibraryKind(kind);
  if (module != null) {
    return module;
  }
  if (kind.isUnknown) {
    return genericKindModule;
  }
  throw ArgumentError('No LibraryKindRuntime registered for kind "$kind"');
}
