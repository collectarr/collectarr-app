import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a manga workspace item.
LibraryCardPresentation buildMangaCardPresentation(
  LibraryProjectionRuntime item, {
  required bool musicVertical,
}) {
  final mangaDetails = item.source.ownedItem?.mangaDetails;
  final badges = <LibraryCardBadge>[];

  if (mangaDetails?.keyComic == true) {
    badges.add(
      LibraryCardBadge(
        icon: Icons.label_important,
        label: mangaDetails?.keyReason?.isNotEmpty == true
            ? mangaDetails!.keyReason!
            : 'Key volume',
      ),
    );
  }

  Widget Function(Widget child)? overlay;
  if (mangaDetails?.rawOrSlabbed != null ||
      mangaDetails?.gradingCompany != null ||
      mangaDetails?.labelType != null ||
      item.source.grade != null) {
    overlay = (child) => SlabFrameOverlay.maybeWrap(
          rawOrSlabbed: mangaDetails?.rawOrSlabbed,
          gradingCompany: mangaDetails?.gradingCompany,
          grade: item.source.grade,
          labelType: mangaDetails?.labelType,
          child: child,
        );
  }

  return LibraryCardPresentation(
    coverOverlayBuilder: overlay,
    compactBadges: badges,
  );
}
