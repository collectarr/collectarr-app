import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a manga workspace item.
LibraryCardPresentation buildMangaCardPresentation(
  LibraryProjectionView item, {
  required bool musicVertical,
}) {
  final owned = item.source.typedOwnedItem;
  final mangaDetails = owned is MangaOwnedItem ? owned.details : null;
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

  if (owned is MangaOwnedItem && owned.grade?.trim().isNotEmpty == true) {
    badges.add(
      LibraryCardBadge(
        icon: Icons.workspace_premium,
        label: 'Grade ${owned.grade!.trim()}',
      ),
    );
  }

  Widget Function(Widget child)? overlay;
  if (mangaDetails?.gradingCompany != null &&
      owned is MangaOwnedItem && owned.grade != null) {
    overlay = (child) => SlabFrameOverlay.maybeWrap(
          rawOrSlabbed: 'slabbed',
          companyName: mangaDetails?.gradingCompany,
          scoreLabel: owned.grade,
          labelType: null,
          child: child,
        );
  }

  return LibraryCardPresentation(
    coverOverlayBuilder: overlay,
    compactBadges: badges,
  );
}
