import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:flutter/material.dart';

/// Delegate carrying all parent layout properties/state so kind-specific
/// custom card builders can render without referencing the parent widget class directly.
abstract class LibraryWorkspaceCardDelegate {
  LibraryProjectionView get item;
  bool get selected;
  VoidCallback get onTap;
  VoidCallback? get onDoubleTap;
  GestureTapUpCallback? get onSecondaryTapUp;
  Color get selectedColor;
  Color get accentColor;
  Color get mutedTextColor;
  double get coverWidth;
  bool get selectionMode;
  VoidCallback? get onSelectionToggleTap;
  VoidCallback? get onEditTap;
  List<String> get customFieldBadges;

  Color get selectedTitleColor;
  Color get mutedColor;
  int? get coverCacheWidth;
  LibraryMetadataPresentation? get metadataPresentation;
  List<String> get referenceHierarchy;
}

/// Describes how a specific kind should render a card.
///
/// The generic [LibraryWorkspaceCard] owns layout, hover, selection and
/// spacing. Each kind contributes a [LibraryCardPresentation] to
/// control what kind-specific data is shown.
class LibraryCardPresentation {
  const LibraryCardPresentation({
    this.cardVariant = LibraryCardVariant.standard,
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
    this.customCardBuilder,
  });

  /// Which high-level layout variant the card should use.
  final LibraryCardVariant cardVariant;

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

  /// Optional custom builder for kind-specific layouts (e.g. music horizontal/vertical).
  final Widget Function(
    BuildContext context,
    LibraryWorkspaceCardDelegate delegate,
  )? customCardBuilder;
}

/// Selects the layout template used by [LibraryWorkspaceCard].
enum LibraryCardVariant {
  /// Standard cover + metadata body layout (all kinds unless overridden).
  standard,

  /// Album / tracklist specific layout (music).
  musicHorizontal,

  /// Album / tracklist specific compact grid layout (music vertical).
  coverFocused,
}

/// A single compact pill shown inside a card.
class LibraryCardBadge {
  const LibraryCardBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
