import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';

/// Test-only explicit dispatch for all production kinds.
///
/// Contract tests intentionally use concrete generated kind modules rather
/// than exercising the erased registry lookup they are meant to validate.
LibraryKindModule testKindModule(CatalogMediaKind kind) {
  return switch (kind) {
    CatalogMediaKind.anime => animeKindModule,
    CatalogMediaKind.boardgame => boardGameKindModule,
    CatalogMediaKind.book => bookKindModule,
    CatalogMediaKind.comic => comicKindModule,
    CatalogMediaKind.game => gameKindModule,
    CatalogMediaKind.manga => mangaKindModule,
    CatalogMediaKind.movie => movieKindModule,
    CatalogMediaKind.music => musicKindModule,
    CatalogMediaKind.tv => tvKindModule,
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
