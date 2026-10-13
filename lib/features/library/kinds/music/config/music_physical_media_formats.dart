import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:flutter/material.dart';

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

LibraryFormatBadgeDescriptor? musicFormatBadge(
  String? id, {
  String? label,
}) =>
    resolveLibraryFormatBadge(
      key: id,
      label: label,
      styleForKey: (key) => switch (key) {
        'vinyl' =>
          const FormatBadgeStyle(color: Color(0xFF212121), icon: Icons.album),
        'cd' =>
          const FormatBadgeStyle(color: Color(0xFF546E7A), icon: Icons.album),
        'cassette' => const FormatBadgeStyle(
            color: Color(0xFF5D4037), icon: Icons.settings_input_svideo),
        'digital-audio' => const FormatBadgeStyle(
            color: Color(0xFF00838F), icon: Icons.cloud_done),
        _ => fallbackFormatBadgeStyle,
      },
    );
