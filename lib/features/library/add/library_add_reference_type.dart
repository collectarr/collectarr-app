import 'package:collectarr_app/core/models/catalog_item.dart';

enum LibraryAddReferenceType { media, edition, bundleRelease }

extension LibraryAddReferenceTypeLabels on LibraryAddReferenceType {
  String labelForMediaKind(CatalogMediaKind mediaKind) {
    return switch (this) {
      LibraryAddReferenceType.media =>
        mediaKind == CatalogMediaKind.music ? 'Album' : 'Media',
      LibraryAddReferenceType.edition => 'Edition',
      LibraryAddReferenceType.bundleRelease => 'Bundle',
    };
  }

  String helperLabelForMediaKind(CatalogMediaKind mediaKind) {
    return switch (this) {
      LibraryAddReferenceType.media => mediaKind == CatalogMediaKind.music
          ? 'Track or save the album itself.'
          : 'Track or save the canonical item itself.',
        LibraryAddReferenceType.edition => mediaKind == CatalogMediaKind.music
          ? 'Attach ownership to an album edition. Pick a variant only if you want one exact format or pressing.'
          : 'Attach ownership to a specific edition. Pick a variant only if you want one exact physical version.',
      LibraryAddReferenceType.bundleRelease => 'Attach ownership to a bundle that contains this item',
    };
  }
}