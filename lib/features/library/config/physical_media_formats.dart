import 'package:collectarr_app/core/models/media_catalog.dart';

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
  String? kind,
  String mediaFamily = 'video',
}) {
  final normalizedKind = kind?.trim().toLowerCase();
  final normalizedMediaFamily = mediaFamily.trim().toLowerCase();
  final formatsById = <String, PhysicalMediaFormat>{};
  for (final type in mediaTypes) {
    if (normalizedKind != null && type.kind != normalizedKind) {
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

String? ownedCopyTypeLabel(bool? isDigital) {
  if (isDigital == null) {
    return null;
  }
  return isDigital ? 'Digital copy' : 'Physical copy';
}
