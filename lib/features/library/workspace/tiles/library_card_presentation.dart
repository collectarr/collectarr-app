import 'package:flutter/material.dart';

/// Describes how a specific kind should render a card.
///
/// The generic [LibraryWorkspaceCard] owns layout, hover, selection and
/// spacing.  Each kind module contributes a [LibraryCardPresentation] to
/// control what kind-specific data is shown.
class LibraryCardPresentation {
  const LibraryCardPresentation({
    this.cardVariant = LibraryCardVariant.standard,
    this.coverOverlayBuilder,
    this.compactBadges = const [],
  });

  /// Which high-level layout variant the card should use.
  final LibraryCardVariant cardVariant;

  /// Optional widget painted on top of the cover image (e.g. slab frame).
  final Widget Function(Widget child)? coverOverlayBuilder;

  /// Compact pill badges shown in the body area of the card.
  final List<LibraryCardBadge> compactBadges;
}

/// Selects the layout template used by [LibraryWorkspaceCard].
enum LibraryCardVariant {
  /// Standard cover + metadata body layout (all kinds unless overridden).
  standard,

  /// Album / tracklist specific layout (music).
  musicHorizontal,

  /// Album / tracklist specific compact grid layout (music vertical).
  musicVertical,
}

/// A single compact pill shown inside a card.
class LibraryCardBadge {
  const LibraryCardBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
