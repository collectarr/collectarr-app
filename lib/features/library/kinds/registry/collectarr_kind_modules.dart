import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/generic/generic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';

export 'package:collectarr_app/features/library/kinds/generic/generic_kind_module.dart';

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

final bool _kindDecodersInitialized = _initDecoders();

bool _initDecoders() {
  LibraryKindMetadataDecoders.registerGlobalDecoder((mediaKind, json) {
    for (final module in collectarrKindModules) {
      if (module.kind == mediaKind && module.catalogCodec != null) {
        return module.catalogCodec!.decode(json);
      }
    }
    return EmptyKindMetadata(mediaKind);
  });
  return true;
}

void ensureLibraryKindDecodersInitialized() {
  final _ = _kindDecodersInitialized;
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
  throw ArgumentError('No LibraryKindRuntime registered for kind "$kind"');
}
