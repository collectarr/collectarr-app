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

const videoPhysicalMediaFormats = [
  PhysicalMediaFormat(
    id: 'dvd',
    label: 'DVD',
    mediaFamily: 'video',
    variantType: 'physical',
  ),
  PhysicalMediaFormat(
    id: 'blu-ray',
    label: 'Blu-ray',
    mediaFamily: 'video',
    variantType: 'physical',
    aliases: {'bluray', 'blu ray'},
  ),
  PhysicalMediaFormat(
    id: '4k-uhd',
    label: '4K UHD',
    mediaFamily: 'video',
    variantType: 'physical',
    aliases: {'4k', 'uhd', '4k blu-ray', '4k bluray', 'ultra hd'},
  ),
  PhysicalMediaFormat(
    id: 'vhs',
    label: 'VHS',
    mediaFamily: 'video',
    variantType: 'physical',
  ),
  PhysicalMediaFormat(
    id: 'laserdisc',
    label: 'LaserDisc',
    mediaFamily: 'video',
    variantType: 'physical',
  ),
  PhysicalMediaFormat(
    id: 'digital',
    label: 'Digital',
    mediaFamily: 'video',
    variantType: 'digital',
  ),
];

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
  Iterable<PhysicalMediaFormat> formats = videoPhysicalMediaFormats,
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
  Iterable<PhysicalMediaFormat> formats = videoPhysicalMediaFormats,
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
