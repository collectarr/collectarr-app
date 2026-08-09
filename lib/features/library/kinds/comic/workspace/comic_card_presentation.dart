import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a comic workspace item.
LibraryCardPresentation buildComicCardPresentation(
  LibraryProjectionRuntime item, {
  required bool musicVertical,
}) {
  final typedDetails = item.source.ownedItem?.typedDetails;
  final comicDetails = typedDetails is ComicOwnedDetails ? typedDetails : null;
  final badges = <LibraryCardBadge>[];

  if (comicDetails?.keyComic == true) {
    badges.add(
      LibraryCardBadge(
        icon: Icons.label_important,
        label: comicDetails?.keyReason?.isNotEmpty == true
            ? comicDetails!.keyReason!
            : 'Key item',
      ),
    );
  }

  Widget Function(Widget child)? overlay;
  if (comicDetails?.rawOrSlabbed != null ||
      comicDetails?.gradingCompany != null ||
      comicDetails?.labelType != null ||
      item.dto.grade != null) {
    overlay = (child) => SlabFrameOverlay.maybeWrap(
          rawOrSlabbed: comicDetails?.rawOrSlabbed,
          gradingCompany: comicDetails?.gradingCompany,
          grade: item.dto.grade,
          labelType: comicDetails?.labelType,
          child: child,
        );
  }

  return LibraryCardPresentation(
    coverOverlayBuilder: overlay,
    compactBadges: badges,
  );
}
