import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

typedef LibraryCardBodyBuilder = Widget Function(
    BuildContext context, LibraryCardBodyData data);

/// Shared card mechanics supplied to a kind-owned body renderer.
/// The renderer owns the complete body; the workspace retains the surrounding
/// selection, pointer handling and hover controls. [buildCover] preserves the
/// workspace's image loading and kind-specific cover overlay.
class LibraryCardBodyData {
  const LibraryCardBodyData({
    required this.item,
    required this.presentation,
    required this.selected,
    this.active = false,
    required this.showHeadline,
    required this.titleColor,
    required this.detailColor,
    required this.mutedColor,
    required this.customFieldBadges,
    required this.coverWidth,
    required this.buildCover,
    required this.pillStatus,
    required this.coverStatus,
  });

  final Widget pillStatus;
  final Widget coverStatus;
  final LibraryProjectionView item;
  final LibraryCardPresentation presentation;
  final bool selected;
  final bool active;
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
    this.mobileTile,
    required this.horizontalBodyBuilder,
    required this.verticalBodyBuilder,
    required this.coverBodyBuilder,
    required this.flowBodyBuilder,
    required this.flowFooterBuilder,
    required this.shelfBodyBuilder,
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

  /// What the phone's List and Cards show; a kind without one shows its
  /// primary and secondary labels.
  final LibraryMobileTileContent? mobileTile;

  /// Complete kind-owned bodies, including explicitly selected shared templates.
  final LibraryCardBodyBuilder horizontalBodyBuilder;
  final LibraryCardBodyBuilder verticalBodyBuilder;
  final LibraryCardBodyBuilder coverBodyBuilder;
  final LibraryCardBodyBuilder flowBodyBuilder;
  final LibraryFlowFooterBuilder flowFooterBuilder;
  final LibraryCardBodyBuilder shelfBodyBuilder;
}

/// The kind-resolved lines of a phone List row or Cards tile.
class LibraryMobileTileContent {
  const LibraryMobileTileContent({
    required this.headline,
    this.subtitle,
    this.numberLabel,
    this.date,
    this.pill,
  });

  final String headline;
  final String? subtitle;
  final String? numberLabel;
  final String? date;
  final LibraryCardPill? pill;
}

/// An outlined pill of a lead segment, such as a grade, and a value.
class LibraryCardPill {
  const LibraryCardPill({
    this.lead,
    this.leadIcon,
    this.leadBackground,
    this.leadLetters,
    this.value,
    this.valueIcon,
  });

  final String? lead;
  final IconData? leadIcon;

  /// Fills the lead segment, whose text then turns dark.
  final Gradient? leadBackground;

  /// What the lead reads as when letters are preferred, such as a raw grade's
  /// NM for 9.4.
  final String? leadLetters;
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
    .join('  \u00b7  ');

enum LibraryItemContentView { cover, verticalCard, horizontalCard, flow, shelf }

/// Structural dispatch only: every content builder is supplied by the kind.
class LibraryItemContent extends StatelessWidget {
  const LibraryItemContent({super.key, required this.view, required this.data});
  final LibraryItemContentView view;
  final LibraryCardBodyData data;
  @override
  Widget build(BuildContext context) => switch (view) {
        LibraryItemContentView.cover =>
          data.presentation.coverBodyBuilder(context, data),
        LibraryItemContentView.verticalCard =>
          data.presentation.verticalBodyBuilder(context, data),
        LibraryItemContentView.horizontalCard =>
          data.presentation.horizontalBodyBuilder(context, data),
        LibraryItemContentView.flow =>
          data.presentation.flowBodyBuilder(context, data),
        LibraryItemContentView.shelf =>
          data.presentation.shelfBodyBuilder(context, data),
      };
}

class LibraryFlowFooterData {
  const LibraryFlowFooterData(
      {required this.index, required this.total, required this.accent});
  final int index;
  final int total;
  final Color accent;
}

typedef LibraryFlowFooterBuilder = Widget Function(
    BuildContext context, LibraryFlowFooterData data);
