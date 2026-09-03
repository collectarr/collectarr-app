import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a manga workspace item.
LibraryCardPresentation buildMangaCardPresentation(
  LibraryProjectionRuntime item, {
  required bool musicVertical,
}) {
  final mangaDetails = item.source.ownedItem?.details as MangaOwnedDetails?;
  final badges = <LibraryCardBadge>[];

  if (mangaDetails?.signedBy != null && mangaDetails!.signedBy!.isNotEmpty) {
    badges.add(
      LibraryCardBadge(
        icon: Icons.draw_outlined,
        label: 'Signed',
      ),
    );
  }

  if (mangaDetails?.obiStripPresent == true) {
    badges.add(
      const LibraryCardBadge(
        icon: Icons.bookmark_outline,
        label: 'Obi',
      ),
    );
  }

  Widget Function(Widget child)? overlay;
  if (mangaDetails?.gradingCompany != null && item.source.grade != null) {
    overlay = (child) => SlabFrameOverlay.maybeWrap(
          rawOrSlabbed: 'slabbed',
          gradingCompany: mangaDetails?.gradingCompany,
          grade: item.source.grade,
          labelType: null,
          child: child,
        );
  }

  return LibraryCardPresentation(
    coverOverlayBuilder: overlay,
    compactBadges: badges,
  );
}
