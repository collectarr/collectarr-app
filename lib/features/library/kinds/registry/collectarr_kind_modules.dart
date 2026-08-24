import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';

final bool _kindDecodersInitialized = _initDecoders();

bool _initDecoders() {
  LibraryKindMetadataDecoders.registerGlobalDecoder((mediaKind, json) {
    return switch (mediaKind) {
      CatalogMediaKind.comic => ComicCatalogMetadata.fromJson(json),
      CatalogMediaKind.manga => MangaMetadata.fromJson(json),
      CatalogMediaKind.anime => AnimeMetadata.fromJson(json),
      CatalogMediaKind.movie => MovieCatalogMetadata.fromJson(json),
      CatalogMediaKind.tv => TvSeriesMetadata.fromJson(json),
      CatalogMediaKind.music => MusicCatalogMetadata.fromJson(json),
      CatalogMediaKind.game => GameCatalogMetadata.fromJson(json),
      CatalogMediaKind.book => BookCatalogMetadata.fromJson(json),
      CatalogMediaKind.boardgame => BoardGameMetadata.fromJson(json),
      _ => EmptyKindMetadata(mediaKind),
    };
  });
  return true;
}

final List<LibraryKindRuntime> collectarrKindModules = [
  if (_kindDecodersInitialized) ...[
    comicKindModule,
    mangaKindModule,
    bookKindModule,
    gameKindModule,
    boardGameKindModule,
    movieKindModule,
    tvKindModule,
    animeKindModule,
    musicKindModule,
  ],
];

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
  throw ArgumentError('No LibraryKindRuntime registered for kind "$kind"');
}
