import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/config/library_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/game_hardware_module.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/game_toy_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';

/// Barcode's explicit semantic composition root.
///
/// The scanner returns a structural [ScannedCode]. Only the owning kind may
/// interpret that code as ISBN, UPC, catalog number, or another identifier.
final Map<CatalogMediaKind, LibraryBarcodeResolver>
    libraryBarcodeResolversByKind = {
  CatalogMediaKind.music: const MusicBarcodeResolver(),
  CatalogMediaKind.comic: const ComicBarcodeResolver(),
  CatalogMediaKind.game: const GameBarcodeResolver(),
  CatalogMediaKind.gameHardware: const GameHardwareBarcodeResolver(),
  CatalogMediaKind.gameToy: const GameToyBarcodeResolver(),
};
