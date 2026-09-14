import 'package:collectarr_app/features/library/config/physical_media_formats.dart';

/// Physical and digital formats supported by the Movie kind.
const moviePhysicalMediaFormats = [
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
