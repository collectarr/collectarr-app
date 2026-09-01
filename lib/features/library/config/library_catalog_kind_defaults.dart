import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_physical_media_formats.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';

class LibraryCatalogKindDefaults {
  const LibraryCatalogKindDefaults({
    this.singularLabel,
    this.pluralLabel,
    this.mediaFamily = 'video',
    this.trackingProfile = readingTrackingProfile,
  });

  final String? singularLabel;
  final String? pluralLabel;
  final String mediaFamily;
  final MediaTrackingProfile trackingProfile;
}

const _catalogKindDefaults = <String, LibraryCatalogKindDefaults>{
  'anime': LibraryCatalogKindDefaults(
    mediaFamily: 'video',
    trackingProfile: videoTrackingProfile,
  ),
  'boardgame': LibraryCatalogKindDefaults(
    singularLabel: 'Board Game',
    pluralLabel: 'Board Games',
    mediaFamily: 'game',
    trackingProfile: gameTrackingProfile,
  ),
  'book': LibraryCatalogKindDefaults(
    mediaFamily: 'print',
    trackingProfile: readingTrackingProfile,
  ),
  'comic': LibraryCatalogKindDefaults(
    mediaFamily: 'print',
    trackingProfile: readingTrackingProfile,
  ),
  'game': LibraryCatalogKindDefaults(
    mediaFamily: 'game',
    trackingProfile: gameTrackingProfile,
  ),
  'manga': LibraryCatalogKindDefaults(
    mediaFamily: 'print',
    trackingProfile: readingTrackingProfile,
  ),
  'movie': LibraryCatalogKindDefaults(
    mediaFamily: 'video',
    trackingProfile: videoTrackingProfile,
  ),
  'music': LibraryCatalogKindDefaults(
    singularLabel: 'Music',
    pluralLabel: 'Music',
    mediaFamily: 'audio',
    trackingProfile: listeningTrackingProfile,
  ),
  'tv': LibraryCatalogKindDefaults(
    singularLabel: 'TV Show',
    pluralLabel: 'TV Shows',
    mediaFamily: 'video',
    trackingProfile: videoTrackingProfile,
  ),
};

LibraryCatalogKindDefaults? libraryCatalogKindDefaultsForKind(
    CatalogMediaKind kind) {
  return _catalogKindDefaults[kind.apiValue];
}

String catalogMediaFamilyForKind(CatalogMediaKind kind) {
  return libraryCatalogKindDefaultsForKind(kind)?.mediaFamily ?? 'video';
}

MediaTrackingProfile catalogTrackingProfileForKind(CatalogMediaKind kind) {
  return libraryCatalogKindDefaultsForKind(kind)?.trackingProfile ??
      readingTrackingProfile;
}

String catalogDisplayLabel(
  String value,
  CatalogMediaKind fallback, {
  bool plural = false,
  String emptyFallbackLabel = 'Library',
}) {
  final trimmed = value.trim();
  if (trimmed.isNotEmpty) {
    return trimmed;
  }
  final label = catalogTitleFromToken(
    fallback.apiValue,
    emptyLabel: emptyFallbackLabel,
  );
  return plural ? '${label}s' : label;
}

String catalogTitleFromToken(String value, {String emptyLabel = ''}) {
  final parts = value
      .trim()
      .split(RegExp(r'[_-]+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return emptyLabel;
  }
  return [
    for (final part in parts)
      if (part.length == 1)
        part.toUpperCase()
      else
        '${part[0].toUpperCase()}${part.substring(1)}',
  ].join(' ');
}

List<PhysicalMediaFormat> fallbackPhysicalMediaFormatsForKind(
    CatalogMediaKind kind) {
  return kindFallbackPhysicalMediaFormats(kind);
}

String catalogDisplayPluralLabel(CatalogMediaType type) {
  return libraryCatalogKindDefaultsForKind(type.mediaKind)?.pluralLabel ??
      type.pluralLabel;
}

CatalogMediaType normalizeCatalogMediaTypeDefaults(CatalogMediaType type) {
  final defaults = libraryCatalogKindDefaultsForKind(type.mediaKind);
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
    physicalFormats: type.physicalFormats,
  );
}
