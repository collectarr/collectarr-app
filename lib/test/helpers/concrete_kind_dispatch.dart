import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';

/// Test-only explicit dispatch for all production kinds.
///
/// Contract tests intentionally use concrete generated kind modules rather
/// than exercising the erased registry lookup they are meant to validate.
LibraryKindRegistration testKindRegistration(CatalogMediaKind kind) {
  return switch (kind) {
    CatalogMediaKind.anime => const AnimeRegistration(),
    CatalogMediaKind.boardgame => const BoardgameRegistration(),
    CatalogMediaKind.book => const BookRegistration(),
    CatalogMediaKind.comic => const ComicRegistration(),
    CatalogMediaKind.game => const GameRegistration(),
    CatalogMediaKind.manga => const MangaRegistration(),
    CatalogMediaKind.movie => const MovieRegistration(),
    CatalogMediaKind.music => const MusicRegistration(),
    CatalogMediaKind.tv => const TvRegistration(),
    CatalogMediaKind.unknown =>
      throw ArgumentError.value(kind, 'kind', 'Unsupported kind'),
  };
}

LibraryKindWorkspace testKindWorkspace(CatalogMediaKind kind) {
  return switch (kind) {
    CatalogMediaKind.anime => animeKindWorkspace,
    CatalogMediaKind.boardgame => boardGameKindWorkspace,
    CatalogMediaKind.book => bookKindWorkspace,
    CatalogMediaKind.comic => comicKindWorkspace,
    CatalogMediaKind.game => gameKindWorkspace,
    CatalogMediaKind.manga => mangaKindWorkspace,
    CatalogMediaKind.movie => movieKindWorkspace,
    CatalogMediaKind.music => musicKindWorkspace,
    CatalogMediaKind.tv => tvKindWorkspace,
    CatalogMediaKind.unknown =>
      throw ArgumentError.value(kind, 'kind', 'Unsupported kind'),
  };
}
