import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:flutter/material.dart';

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

LibraryFormatBadgeDescriptor? gameFormatBadge(String? id, {String? label}) =>
    resolveLibraryFormatBadge(
      key: id,
      label: label,
      styleForKey: (key) => switch (key) {
        'physical-disc' => const FormatBadgeStyle(
            color: Color(0xFF1565C0), icon: Icons.album, shortLabel: 'Disc'),
        'cartridge' => const FormatBadgeStyle(
            color: Color(0xFF37474F), icon: Icons.memory, shortLabel: 'Cart'),
        'digital-game' => const FormatBadgeStyle(
            color: Color(0xFF00838F), icon: Icons.cloud_done),
        'collectors-edition' => const FormatBadgeStyle(
            color: Color(0xFFBF360C), icon: Icons.star, shortLabel: 'CE'),
        _ => fallbackFormatBadgeStyle,
      },
    );
