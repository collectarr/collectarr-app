import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/config/barcode_resolver.dart';

/// Barcode's explicit semantic composition root.
///
/// The scanner returns a structural [ScannedCode]. Only the owning kind may
/// interpret that code as ISBN, UPC, catalog number, or another identifier.
final Map<CatalogMediaKind, LibraryBarcodeResolver>
    libraryBarcodeResolversByKind = {
  CatalogMediaKind.music: const RetailBarcodeResolver(CatalogMediaKind.music),
  CatalogMediaKind.book: const BookIsbnResolver(),
  CatalogMediaKind.comic: const ComicBarcodeResolver(),
  CatalogMediaKind.game: const RetailBarcodeResolver(CatalogMediaKind.game),
  CatalogMediaKind.gameHardware:
      const RetailBarcodeResolver(CatalogMediaKind.gameHardware),
  CatalogMediaKind.gameToy:
      const RetailBarcodeResolver(CatalogMediaKind.gameToy),
};
