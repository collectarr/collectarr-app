import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';

class LibraryCatalogKindDefaults {
  const LibraryCatalogKindDefaults({
    this.singularLabel,
    this.pluralLabel,
    this.mediaFamily = 'video',
    this.fallbackPhysicalFormats = const [],
  });

  final String? singularLabel;
  final String? pluralLabel;
  final String mediaFamily;
  final List<PhysicalMediaFormat> fallbackPhysicalFormats;
}

const _catalogKindDefaults = <String, LibraryCatalogKindDefaults>{
  'anime': LibraryCatalogKindDefaults(
    mediaFamily: 'video',
    fallbackPhysicalFormats: videoPhysicalMediaFormats,
  ),
  'boardgame': LibraryCatalogKindDefaults(
    singularLabel: 'Board Game',
    pluralLabel: 'Board Games',
    mediaFamily: 'game',
    fallbackPhysicalFormats: gamePhysicalMediaFormats,
  ),
  'book': LibraryCatalogKindDefaults(
    mediaFamily: 'print',
    fallbackPhysicalFormats: bookPhysicalMediaFormats,
  ),
  'comic': LibraryCatalogKindDefaults(
    mediaFamily: 'print',
    fallbackPhysicalFormats: comicPhysicalMediaFormats,
  ),
  'game': LibraryCatalogKindDefaults(
    mediaFamily: 'game',
    fallbackPhysicalFormats: gamePhysicalMediaFormats,
  ),
  'manga': LibraryCatalogKindDefaults(
    mediaFamily: 'print',
    fallbackPhysicalFormats: bookPhysicalMediaFormats,
  ),
  'movie': LibraryCatalogKindDefaults(
    mediaFamily: 'video',
    fallbackPhysicalFormats: videoPhysicalMediaFormats,
  ),
  'music': LibraryCatalogKindDefaults(
    singularLabel: 'Music',
    pluralLabel: 'Music',
    mediaFamily: 'audio',
    fallbackPhysicalFormats: musicPhysicalMediaFormats,
  ),
  'tv': LibraryCatalogKindDefaults(
    singularLabel: 'TV Show',
    pluralLabel: 'TV Shows',
    mediaFamily: 'video',
    fallbackPhysicalFormats: videoPhysicalMediaFormats,
  ),
};

LibraryCatalogKindDefaults? libraryCatalogKindDefaultsForKind(String kind) {
  return _catalogKindDefaults[kind.trim().toLowerCase()];
}

String catalogMediaFamilyForKind(String kind) {
  return libraryCatalogKindDefaultsForKind(kind)?.mediaFamily ?? 'video';
}

List<PhysicalMediaFormat> fallbackPhysicalMediaFormatsForKind(String kind) {
  return libraryCatalogKindDefaultsForKind(kind)?.fallbackPhysicalFormats ??
      const [];
}

String catalogDisplayPluralLabel(CatalogMediaType type) {
  return libraryCatalogKindDefaultsForKind(type.kind)?.pluralLabel ??
      type.pluralLabel;
}

CatalogMediaType normalizeCatalogMediaTypeDefaults(CatalogMediaType type) {
  final defaults = libraryCatalogKindDefaultsForKind(type.kind);
  if (defaults == null) {
    return type;
  }
  final singularLabel = defaults.singularLabel ?? type.singularLabel;
  final pluralLabel = defaults.pluralLabel ?? type.pluralLabel;
  if (type.singularLabel == singularLabel && type.pluralLabel == pluralLabel) {
    return type;
  }
  return CatalogMediaType(
    kind: type.kind,
    singularLabel: singularLabel,
    pluralLabel: pluralLabel,
    routeSegments: type.routeSegments,
    defaultProvider: type.defaultProvider,
    providers: type.providers,
    providerSearchPolicy: type.providerSearchPolicy,
    isTopLevel: type.isTopLevel,
    legacyOf: type.legacyOf,
    physicalFormats: type.physicalFormats,
  );
}