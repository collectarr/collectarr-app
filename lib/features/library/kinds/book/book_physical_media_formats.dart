import 'package:collectarr_app/features/library/config/physical_media_formats.dart';

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
