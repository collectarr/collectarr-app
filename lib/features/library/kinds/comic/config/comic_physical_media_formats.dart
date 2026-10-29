import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:flutter/material.dart';

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

LibraryFormatBadgeDescriptor? comicFormatBadge(String? id, {String? label}) =>
    resolveLibraryFormatBadge(
      key: id,
      label: label,
      styleForKey: (key) => switch (key) {
        'single-issue' => const FormatBadgeStyle(
            color: Color(0xFFC62828),
            icon: Icons.description,
            shortLabel: 'Issue'),
        'trade-paperback' => const FormatBadgeStyle(
            color: Color(0xFF558B2F), icon: Icons.menu_book, shortLabel: 'TPB'),
        'hardcover-comic' => const FormatBadgeStyle(
            color: Color(0xFF4E342E), icon: Icons.menu_book, shortLabel: 'HC'),
        'omnibus' => const FormatBadgeStyle(
            color: Color(0xFF283593), icon: Icons.menu_book),
        'graphic-novel' => const FormatBadgeStyle(
            color: Color(0xFF00695C), icon: Icons.menu_book, shortLabel: 'GN'),
        'digital-comic' => const FormatBadgeStyle(
            color: Color(0xFF00838F), icon: Icons.tablet_android),
        _ => fallbackFormatBadgeStyle,
      },
    );
