import 'package:collectarr_app/features/library/kinds/game_toy/game_toy_module.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/game_hardware_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart'
    show musicKindImport;

final Map<CatalogMediaKind, LibraryKindImportCapability> collectarrKindImports =
    Map.unmodifiable(<CatalogMediaKind, LibraryKindImportCapability>{
  CatalogMediaKind.music: musicKindImport,
  CatalogMediaKind.comic: comicKindImport,
  CatalogMediaKind.game: gameKindImport,
  CatalogMediaKind.gameHardware: gameHardwareKindImport,
  CatalogMediaKind.gameToy: gameToyKindImport,
});
