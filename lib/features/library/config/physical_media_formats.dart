import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/models/library_add_release_option.dart';

class PhysicalMediaFormat {
  const PhysicalMediaFormat({
    required this.id,
    required this.label,
    required this.mediaFamily,
    required this.variantType,
    this.aliases = const {},
  });

  final String id;
  final String label;
  final String mediaFamily;
  final String variantType;
  final Set<String> aliases;

  factory PhysicalMediaFormat.fromCatalog(CatalogPhysicalFormat format) {
    return PhysicalMediaFormat(
      id: format.id,
      label: format.label,
      mediaFamily: format.mediaFamily,
      variantType: format.variantType,
      aliases: format.aliases.toSet(),
    );
  }
}

List<PhysicalMediaFormat> physicalMediaFormatsFromCatalog(
  Iterable<CatalogMediaType> mediaTypes, {
  CatalogMediaKind? kind,
  required String mediaFamily,
}) {
  final normalizedMediaFamily = mediaFamily.trim().toLowerCase();
  final formatsById = <String, PhysicalMediaFormat>{};
  for (final type in mediaTypes) {
    if (kind != null && type.kind != kind.apiValue) {
      continue;
    }
    for (final format in type.physicalFormats) {
      if (format.mediaFamily == normalizedMediaFamily) {
        formatsById.putIfAbsent(
          format.id,
          () => PhysicalMediaFormat.fromCatalog(format),
        );
      }
    }
  }
  return formatsById.values.toList(growable: false);
}

PhysicalMediaFormat? physicalMediaFormatById(
  String id, {
  required Iterable<PhysicalMediaFormat> formats,
}) {
  final normalized = id.trim().toLowerCase();
  for (final format in formats) {
    if (format.id == normalized) {
      return format;
    }
    if (format.aliases.contains(normalized)) {
      return format;
    }
  }
  return null;
}

PhysicalMediaFormat? physicalMediaFormatByLabelOrId(
  String? value, {
  required Iterable<PhysicalMediaFormat> formats,
}) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  for (final format in formats) {
    if (format.id == normalized || format.label.toLowerCase() == normalized) {
      return format;
    }
    if (format.aliases.contains(normalized)) {
      return format;
    }
  }
  return null;
}

bool isDigitalPhysicalMediaFormat(
  String? id, {
  String? label,
  required Iterable<PhysicalMediaFormat> formats,
}) {
  return digitalPhysicalMediaFormatFlag(
        id,
        label: label,
        formats: formats,
      ) ??
      false;
}

bool? digitalPhysicalMediaFormatFlag(
  String? id, {
  String? label,
  required Iterable<PhysicalMediaFormat> formats,
}) {
  final format = physicalMediaFormatById(
        id ?? '',
        formats: formats,
      ) ??
      physicalMediaFormatByLabelOrId(
        label,
        formats: formats,
      );
  return format == null ? null : format.variantType == 'digital';
}

/// Technical release/format resolution shared by kind-owned semantics.
///
/// This helper deliberately receives primitive identity and explicit values;
/// it does not inspect an Owned domain object or decide which kind's formats
/// are valid.
bool? resolveDigitalMediaFormatFlag({
  required bool? explicitDigital,
  required String? editionId,
  required String? variantId,
  required List<LibraryAddReleaseOption> releases,
  String? fallbackFormat,
  String? fallbackLabel,
  required Iterable<PhysicalMediaFormat> formats,
}) {
  if (explicitDigital != null) {
    return explicitDigital;
  }

  LibraryAddReleaseOption? matchedRelease;
  LibraryAddVariantOption? matchedVariant;
  if (editionId != null) {
    for (final release in releases) {
      if (release.id == editionId) {
        matchedRelease = release;
        break;
      }
    }
  }
  if (variantId != null) {
    final releasePool = matchedRelease == null
        ? releases
        : <LibraryAddReleaseOption>[matchedRelease];
    for (final release in releasePool) {
      for (final variant in release.variants) {
        if (variant.id == variantId) {
          matchedRelease ??= release;
          matchedVariant = variant;
          break;
        }
      }
      if (matchedVariant != null) {
        break;
      }
    }
  }

  final variantFlag = digitalPhysicalMediaFormatFlag(
    matchedVariant?.formatId,
    label: matchedVariant?.formatLabel ?? matchedVariant?.name,
    formats: formats,
  );
  if (variantFlag != null) {
    return variantFlag;
  }

  final editionFlag = digitalPhysicalMediaFormatFlag(
    matchedRelease?.formatId,
    label: matchedRelease?.formatLabel ?? matchedRelease?.title,
    formats: formats,
  );
  if (editionFlag != null) {
    return editionFlag;
  }

  return digitalPhysicalMediaFormatFlag(
    fallbackFormat,
    label: fallbackLabel,
    formats: formats,
  );
}
