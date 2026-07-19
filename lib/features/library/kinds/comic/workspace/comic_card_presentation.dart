import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:flutter/material.dart';


/// Builds the [LibraryCardPresentation] for a comic workspace entry.
LibraryCardPresentation buildComicCardPresentation(
  LibraryWorkspaceEntry entry, {
  required bool musicVertical,
}) {
  final comic = entry.comic;
  final badges = <LibraryCardBadge>[];

  if (comic?.keyComic == true) {
    badges.add(
      LibraryCardBadge(
        icon: Icons.label_important,
        label: comic?.keyReason?.isNotEmpty == true
            ? comic!.keyReason!
            : 'Key item',
      ),
    );
  }

  final slabLabel = librarySlabMarkerLabel(
    comic?.rawOrSlabbed,
    comic?.gradingCompany,
  );
  if (slabLabel != null) {
    badges.add(
      LibraryCardBadge(icon: Icons.workspace_premium, label: slabLabel),
    );
  }

  Widget? overlay;
  if (comic?.rawOrSlabbed != null ||
      comic?.gradingCompany != null ||
      comic?.labelType != null) {
    overlay = (child) => SlabFrameOverlay.maybeWrap(
          rawOrSlabbed: comic?.rawOrSlabbed,
          gradingCompany: comic?.gradingCompany,
          grade: entry.grade,
          labelType: comic?.labelType,
          child: child,
        );
  }

  return LibraryCardPresentation(
    coverOverlayBuilder: overlay,
    compactBadges: badges,
  );
}
