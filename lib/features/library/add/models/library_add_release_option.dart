import 'package:flutter/foundation.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';

/// Structural release data rendered by the shared Add shell.
///
/// The owning kind maps its transport release into this option. The Add host
/// uses only stable identifiers and presentation values; it never interprets
/// a catalog edition or variant.
@immutable
final class LibraryAddReleaseOption {
  const LibraryAddReleaseOption({
    required this.id,
    required this.title,
    this.formatId,
    this.formatLabel,
    this.formatBadge,
    this.releaseDate,
    this.coverImageUrl,
    this.identifierCode,
    this.variants = const <LibraryAddVariantOption>[],
  });

  final String id;
  final String title;
  final String? formatId;
  final String? formatLabel;
  final LibraryFormatBadgeDescriptor? formatBadge;
  final DateTime? releaseDate;
  final String? coverImageUrl;
  final String? identifierCode;
  final List<LibraryAddVariantOption> variants;
}

@immutable
final class LibraryAddVariantOption {
  const LibraryAddVariantOption({
    required this.id,
    required this.name,
    this.coverImageUrl,
    this.identifierCode,
    this.formatId,
    this.formatLabel,
    this.formatBadge,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String? coverImageUrl;
  final String? identifierCode;
  final String? formatId;
  final String? formatLabel;
  final LibraryFormatBadgeDescriptor? formatBadge;
  final bool isPrimary;
}
