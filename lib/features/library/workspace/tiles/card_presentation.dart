import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

typedef LibraryCardBodyBuilder = Widget Function(
    BuildContext context, LibraryCardBodyData data);

/// Shared card mechanics supplied to an optional kind-owned body renderer.
/// The renderer owns the complete body; the workspace retains the surrounding
/// selection, pointer handling and hover controls. [buildCover] preserves the
/// workspace's image loading and kind-specific cover overlay.
class LibraryCardBodyData {
  const LibraryCardBodyData({
    required this.item,
    required this.presentation,
    required this.selected,
    required this.showHeadline,
    required this.titleColor,
    required this.detailColor,
    required this.mutedColor,
    required this.customFieldBadges,
    required this.coverWidth,
    required this.buildCover,
  });

  final LibraryProjectionView item;
  final LibraryCardPresentation presentation;
  final bool selected;
  final bool showHeadline;
  final Color titleColor;
  final Color detailColor;
  final Color mutedColor;
  final List<String> customFieldBadges;
  final double coverWidth;
  final Widget Function({required Alignment alignment}) buildCover;
}

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
    this.flowSubtitle,
    this.verticalSubtitle,
    this.verticalSubtitleEmphasized = false,
    this.verticalTrailing,
    this.horizontalBodyBuilder,
    this.verticalBodyBuilder,
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

  /// Wraps the cover image, such as a slabbed comic in its slab.
  final Widget Function(Widget child)? coverOverlayBuilder;

  /// Compact pill badges shown in the body area of the card.
  final List<LibraryCardBadge> compactBadges;

  /// Muted line under the title, such as a full release date.
  final String? detailLine;

  /// Value pill in the bottom-right corner, such as "CIB | \$ 17.58".
  final String? valueLabel;

  /// The kind-resolved metadata line used beneath a Flow cover.
  final String? flowSubtitle;

  /// Explicit content slots for the shared vertical card template.
  final String? verticalSubtitle;
  final bool verticalSubtitleEmphasized;
  final String? verticalTrailing;

  /// Optional complete kind-owned bodies; each orientation falls back to the
  /// shared renderer independently when its builder is absent.
  final LibraryCardBodyBuilder? horizontalBodyBuilder;
  final LibraryCardBodyBuilder? verticalBodyBuilder;
}

/// An outlined pill of a lead segment, such as a grade, and a value.
class LibraryCardPill {
  const LibraryCardPill({
    this.lead,
    this.leadIcon,
    this.leadBackground,
    this.value,
    this.valueIcon,
  });

  final String? lead;
  final IconData? leadIcon;

  /// Fills the lead segment, whose text then turns dark.
  final Gradient? leadBackground;
  final String? value;
  final IconData? valueIcon;
}

/// A single compact pill shown inside a card.
class LibraryCardBadge {
  const LibraryCardBadge({this.icon, required this.label});

  /// Leading icon; a badge without one is a plain secondary line.
  final IconData? icon;
  final String label;
}

/// Joins already resolved Flow labels without assigning meaning to any field.
String libraryFlowSubtitle(Iterable<String?> labels) => labels
    .whereType<String>()
    .where((label) => label.trim().isNotEmpty)
    .join('  ?  ');
