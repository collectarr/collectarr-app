import 'package:collectarr_app/features/library/config/physical_media_formats.dart';

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
