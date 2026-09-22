import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:flutter/material.dart';

/// Physical and digital formats supported by the TV kind.
const tvPhysicalMediaFormats = [
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

LibraryFormatBadgeDescriptor? tvFormatBadge(String? id, {String? label}) =>
    resolveLibraryFormatBadge(
      key: id,
      label: label,
      styleForKey: (key) => switch (key) {
        'dvd' =>
          const FormatBadgeStyle(color: Color(0xFFC62828), icon: Icons.album),
        'blu-ray' =>
          const FormatBadgeStyle(color: Color(0xFF1565C0), icon: Icons.album),
        '4k-uhd' => const FormatBadgeStyle(
            color: Color(0xFF6A1B9A), icon: Icons.album, shortLabel: '4K'),
        'vhs' => const FormatBadgeStyle(
            color: Color(0xFF37474F), icon: Icons.videocam),
        'laserdisc' => const FormatBadgeStyle(
            color: Color(0xFF4E342E), icon: Icons.album, shortLabel: 'LD'),
        'digital' => const FormatBadgeStyle(
            color: Color(0xFF00838F), icon: Icons.cloud_done),
        _ => fallbackFormatBadgeStyle,
      },
    );
