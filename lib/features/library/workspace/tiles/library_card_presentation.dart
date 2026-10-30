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
    this.suggestionDetail,
    this.format,
    this.synopsis,
    this.seriesTitle,
    this.identifierCode,
    this.currency,
    this.contextFacts = const [],
    this.coverOverlayBuilder,
    this.compactBadges = const [],
    this.detailLine,
    this.valueLabel,
    this.headline,
    this.numberLabel,
    this.outlinedPill,
  });

  /// Kind-entry values projected for the shared card chrome. The card host
  /// renders these values but never reads semantic fields from an erased
  /// workspace DTO.
  final String? itemNumber;
  final String? variant;
  final DateTime? releaseDate;

  /// Second line of a toolbar search suggestion, such as a release year that
  /// is known even when the date is partial.
  final String? suggestionDetail;
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

  /// Muted line under the title, such as a full release date.
  final String? detailLine;

  /// Value pill in the bottom-right corner, such as "CIB | \$ 17.58".
  final String? valueLabel;

  /// Headlined cards: the line above the cover, such as a series title.
  final String? headline;

  /// Headlined cards: the large label under the cover, such as "#2A".
  final String? numberLabel;

  /// Headlined cards: an outlined pill under the number, such as a grade.
  final String? outlinedPill;
}

/// A single compact pill shown inside a card.
class LibraryCardBadge {
  const LibraryCardBadge({this.icon, required this.label});

  /// Leading icon; a badge without one is a plain secondary line.
  final IconData? icon;
  final String label;
}
