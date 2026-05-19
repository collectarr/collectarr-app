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

const musicPhysicalMediaFormats = [
  PhysicalMediaFormat(
    id: 'vinyl',
    label: 'Vinyl',
    mediaFamily: 'audio',
    variantType: 'physical',
    aliases: {'lp', 'record'},
  ),
  PhysicalMediaFormat(
    id: 'cd',
    label: 'CD',
    mediaFamily: 'audio',
    variantType: 'physical',
    aliases: {'compact disc'},
  ),
  PhysicalMediaFormat(
    id: 'cassette',
    label: 'Cassette',
    mediaFamily: 'audio',
    variantType: 'physical',
    aliases: {'tape'},
  ),
  PhysicalMediaFormat(
    id: 'digital-audio',
    label: 'Digital',
    mediaFamily: 'audio',
    variantType: 'digital',
  ),
];

const bookPhysicalMediaFormats = [
  PhysicalMediaFormat(
    id: 'hardcover',
    label: 'Hardcover',
    mediaFamily: 'print',
    variantType: 'physical',
    aliases: {'hardback', 'hc'},
  ),
  PhysicalMediaFormat(
    id: 'paperback',
    label: 'Paperback',
    mediaFamily: 'print',
    variantType: 'physical',
    aliases: {'softcover', 'pb', 'tpb', 'trade paperback'},
  ),
  PhysicalMediaFormat(
    id: 'mass-market',
    label: 'Mass Market Paperback',
    mediaFamily: 'print',
    variantType: 'physical',
    aliases: {'mmpb', 'mass market'},
  ),
  PhysicalMediaFormat(
    id: 'ebook',
    label: 'eBook',
    mediaFamily: 'print',
    variantType: 'digital',
    aliases: {'kindle', 'epub', 'digital book'},
  ),
  PhysicalMediaFormat(
    id: 'audiobook',
    label: 'Audiobook',
    mediaFamily: 'print',
    variantType: 'digital',
    aliases: {'audio book'},
  ),
];

const comicPhysicalMediaFormats = [
  PhysicalMediaFormat(
    id: 'single-issue',
    label: 'Single Issue',
    mediaFamily: 'print',
    variantType: 'physical',
    aliases: {'floppy', 'pamphlet'},
  ),
  PhysicalMediaFormat(
    id: 'trade-paperback',
    label: 'Trade Paperback',
    mediaFamily: 'print',
    variantType: 'physical',
    aliases: {'tpb', 'trade'},
  ),
  PhysicalMediaFormat(
    id: 'hardcover-comic',
    label: 'Hardcover',
    mediaFamily: 'print',
    variantType: 'physical',
    aliases: {'hc', 'deluxe'},
  ),
  PhysicalMediaFormat(
    id: 'omnibus',
    label: 'Omnibus',
    mediaFamily: 'print',
    variantType: 'physical',
  ),
  PhysicalMediaFormat(
    id: 'graphic-novel',
    label: 'Graphic Novel',
    mediaFamily: 'print',
    variantType: 'physical',
    aliases: {'gn'},
  ),
  PhysicalMediaFormat(
    id: 'digital-comic',
    label: 'Digital',
    mediaFamily: 'print',
    variantType: 'digital',
    aliases: {'comixology', 'digital comic'},
  ),
];

const gamePhysicalMediaFormats = [
  PhysicalMediaFormat(
    id: 'physical-disc',
    label: 'Physical Disc',
    mediaFamily: 'game',
    variantType: 'physical',
    aliases: {'disc', 'blu-ray disc'},
  ),
  PhysicalMediaFormat(
    id: 'cartridge',
    label: 'Cartridge',
    mediaFamily: 'game',
    variantType: 'physical',
    aliases: {'cart', 'game pak'},
  ),
  PhysicalMediaFormat(
    id: 'digital-game',
    label: 'Digital',
    mediaFamily: 'game',
    variantType: 'digital',
    aliases: {'download', 'digital download'},
  ),
  PhysicalMediaFormat(
    id: 'collectors-edition',
    label: "Collector's Edition",
    mediaFamily: 'game',
    variantType: 'physical',
    aliases: {'ce', 'special edition', 'limited edition'},
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
