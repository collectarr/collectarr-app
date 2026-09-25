import 'package:flutter/material.dart';

/// Describes how a specific kind should render a card.
///
/// The generic [LibraryWorkspaceCard] owns layout, hover, selection and
/// spacing. Each kind contributes a [LibraryCardPresentation] to
/// control what kind-specific data is shown.
class LibraryCardPresentation {
  const LibraryCardPresentation({
    this.itemNumber,
    this.variant,
    this.releaseDate,
    this.format,
    this.synopsis,
    this.seriesTitle,
    this.identifierCode,
    this.currency,
    this.contextFacts = const [],
    this.coverOverlayBuilder,
    this.compactBadges = const [],
  });

  /// Kind-owned values projected for the shared card chrome. The card host
  /// renders these values but never reads semantic fields from an erased
  /// workspace DTO.
  final String? itemNumber;
  final String? variant;
  final DateTime? releaseDate;
  final String? format;
  final String? synopsis;
  final String? seriesTitle;
  final String? identifierCode;
  final String? currency;

  /// Kind-resolved facts for the shared card subtitle/footer.
  ///
  /// The card host renders these values as opaque presentation data. It must
  /// not decide whether a value is a publisher, studio, author, artist, or
  /// developer for the selected kind.
  final List<String> contextFacts;

  /// Optional widget painted on top of the cover image (e.g. slab frame).
  final Widget Function(Widget child)? coverOverlayBuilder;

  /// Compact pill badges shown in the body area of the card.
  final List<LibraryCardBadge> compactBadges;
}

/// A single compact pill shown inside a card.
class LibraryCardBadge {
  const LibraryCardBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
