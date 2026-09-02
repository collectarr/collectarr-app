import 'package:collectarr_app/features/library/config/physical_media_formats.dart';

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
