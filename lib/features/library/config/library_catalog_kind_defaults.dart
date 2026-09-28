import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/v1/catalog_item_v1_kind_identities.dart';

class LibraryCatalogKindDefaults {
  const LibraryCatalogKindDefaults({
    this.singularLabel,
    this.pluralLabel,
    required this.mediaFamily,
  });

  final String? singularLabel;
  final String? pluralLabel;
  final String mediaFamily;
}

LibraryCatalogKindDefaults? libraryCatalogKindDefaultsForKind(
    CatalogMediaKind kind) {
  final identity = catalogItemV1KindIdentities[kind];
  if (identity == null) return null;
  return LibraryCatalogKindDefaults(
    singularLabel:
        identity.normalizeCatalogLabels ? identity.singularLabel : null,
    pluralLabel: identity.normalizeCatalogLabels ? identity.pluralLabel : null,
    mediaFamily: identity.mediaFamily,
  );
}

String? catalogMediaFamilyForKind(CatalogMediaKind kind) {
  return libraryCatalogKindDefaultsForKind(kind)?.mediaFamily;
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
