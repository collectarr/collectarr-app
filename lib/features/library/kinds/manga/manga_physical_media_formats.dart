import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:flutter/material.dart';

/// Physical and digital formats supported by Manga.
const mangaPhysicalMediaFormats = [
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

LibraryFormatBadgeDescriptor? mangaFormatBadge(String? id, {String? label}) =>
    resolveLibraryFormatBadge(
      key: id,
      label: label,
      styleForKey: (key) => switch (key) {
        'hardcover' => const FormatBadgeStyle(
            color: Color(0xFF4E342E), icon: Icons.menu_book, shortLabel: 'HC'),
        'paperback' => const FormatBadgeStyle(
            color: Color(0xFF558B2F), icon: Icons.menu_book, shortLabel: 'PB'),
        'mass-market' => const FormatBadgeStyle(
            color: Color(0xFF827717),
            icon: Icons.menu_book,
            shortLabel: 'MMPB'),
        'ebook' => const FormatBadgeStyle(
            color: Color(0xFF00838F), icon: Icons.tablet_android),
        'audiobook' => const FormatBadgeStyle(
            color: Color(0xFF6A1B9A), icon: Icons.headphones),
        _ => fallbackFormatBadgeStyle,
      },
    );
