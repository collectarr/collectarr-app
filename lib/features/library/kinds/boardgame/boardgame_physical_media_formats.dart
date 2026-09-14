import 'package:collectarr_app/features/library/config/physical_media_formats.dart';

/// Physical and digital formats supported by BoardGame.
const boardGamePhysicalMediaFormats = [
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
