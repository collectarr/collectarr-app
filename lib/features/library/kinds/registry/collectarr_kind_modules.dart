import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart'
    as comic_add;
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart'
    as movie_add;
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final comicKindModule = LibraryKindModule(
  type: comicsLibraryConfig,
  mediaAdapter: comicsMediaAdapter,
  add: LibraryKindAddModule(registerBuilders: comic_add.registerComicAddBuilders),
  providerMapper: const DefaultLibraryKindProviderMapper(),
);

final mangaKindModule = LibraryKindModule(
  type: mangaLibraryConfig,
  mediaAdapter: mangaMediaAdapter,
  providerMapper: const DefaultLibraryKindProviderMapper(),
);

final bookKindModule = LibraryKindModule(
  type: booksLibraryConfig,
  mediaAdapter: booksMediaAdapter,
  providerMapper: const DefaultLibraryKindProviderMapper(),
);

final gameKindModule = LibraryKindModule(
  type: gamesLibraryConfig,
  mediaAdapter: gamesMediaAdapter,
  providerMapper: const DefaultLibraryKindProviderMapper(),
);

final boardGameKindModule = LibraryKindModule(
  type: boardGamesLibraryConfig,
  mediaAdapter: boardGamesMediaAdapter,
  providerMapper: const DefaultLibraryKindProviderMapper(),
);

final movieKindModule = LibraryKindModule(
  type: moviesLibraryConfig,
  mediaAdapter: moviesMediaAdapter,
  add: LibraryKindAddModule(registerBuilders: movie_add.registerMovieAddBuilders),
  providerMapper: const DefaultLibraryKindProviderMapper(),
);

final tvKindModule = LibraryKindModule(
  type: tvLibraryConfig,
  mediaAdapter: tvMediaAdapter,
  providerMapper: const DefaultLibraryKindProviderMapper(),
);

final animeKindModule = LibraryKindModule(
  type: animeLibraryConfig,
  mediaAdapter: animeMediaAdapter,
  providerMapper: const DefaultLibraryKindProviderMapper(),
);

final musicKindModule = LibraryKindModule(
  type: musicLibraryConfig,
  mediaAdapter: musicMediaAdapter,
  providerMapper: const DefaultLibraryKindProviderMapper(),
);

final collectarrKindModules = <LibraryKindModule>[
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
