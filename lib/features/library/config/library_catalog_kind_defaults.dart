import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';

class LibraryCatalogKindDefaults {
  const LibraryCatalogKindDefaults({
    this.singularLabel,
    this.pluralLabel,
    this.mediaFamily = 'video',
    this.trackingProfile = readingTrackingProfile,
    this.fallbackPhysicalFormats = const [],
  });

  final String? singularLabel;
  final String? pluralLabel;
  final String mediaFamily;
  final MediaTrackingProfile trackingProfile;
  final List<PhysicalMediaFormat> fallbackPhysicalFormats;
}

const _catalogKindDefaults = <String, LibraryCatalogKindDefaults>{
  'anime': LibraryCatalogKindDefaults(
    mediaFamily: 'video',
    trackingProfile: videoTrackingProfile,
    fallbackPhysicalFormats: videoPhysicalMediaFormats,
  ),
  'boardgame': LibraryCatalogKindDefaults(
    singularLabel: 'Board Game',
    pluralLabel: 'Board Games',
    mediaFamily: 'game',
    trackingProfile: gameTrackingProfile,
    fallbackPhysicalFormats: gamePhysicalMediaFormats,
  ),
  'book': LibraryCatalogKindDefaults(
    mediaFamily: 'print',
    trackingProfile: readingTrackingProfile,
    fallbackPhysicalFormats: bookPhysicalMediaFormats,
  ),
  'comic': LibraryCatalogKindDefaults(
    mediaFamily: 'print',
    trackingProfile: readingTrackingProfile,
    fallbackPhysicalFormats: comicPhysicalMediaFormats,
  ),
  'game': LibraryCatalogKindDefaults(
    mediaFamily: 'game',
    trackingProfile: gameTrackingProfile,
    fallbackPhysicalFormats: gamePhysicalMediaFormats,
  ),
  'manga': LibraryCatalogKindDefaults(
    mediaFamily: 'print',
    trackingProfile: readingTrackingProfile,
    fallbackPhysicalFormats: bookPhysicalMediaFormats,
  ),
  'movie': LibraryCatalogKindDefaults(
    mediaFamily: 'video',
    trackingProfile: videoTrackingProfile,
    fallbackPhysicalFormats: videoPhysicalMediaFormats,
  ),
  'music': LibraryCatalogKindDefaults(
    singularLabel: 'Music',
    pluralLabel: 'Music',
    mediaFamily: 'audio',
    trackingProfile: listeningTrackingProfile,
    fallbackPhysicalFormats: musicPhysicalMediaFormats,
  ),
  'tv': LibraryCatalogKindDefaults(
    singularLabel: 'TV Show',
    pluralLabel: 'TV Shows',
    mediaFamily: 'video',
    trackingProfile: videoTrackingProfile,
    fallbackPhysicalFormats: videoPhysicalMediaFormats,
  ),
};

LibraryCatalogKindDefaults? libraryCatalogKindDefaultsForKind(String kind) {
  return _catalogKindDefaults[kind.trim().toLowerCase()];
}

String catalogMediaFamilyForKind(String kind) {
  return libraryCatalogKindDefaultsForKind(kind)?.mediaFamily ?? 'video';
}

MediaTrackingProfile catalogTrackingProfileForKind(String kind) {
  return libraryCatalogKindDefaultsForKind(kind)?.trackingProfile ??
      readingTrackingProfile;
}

String catalogDisplayLabel(
  String value,
  String fallback, {
  bool plural = false,
  String emptyFallbackLabel = 'Library',
}) {
  final trimmed = value.trim();
  if (trimmed.isNotEmpty) {
    return trimmed;
  }
  final label = catalogTitleFromToken(
    fallback,
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