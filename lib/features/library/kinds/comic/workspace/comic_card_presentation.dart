import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a comic workspace item.
LibraryCardPresentation buildComicCardPresentation(
  LibraryProjectionRuntime item, {
  required bool musicVertical,
}) {
  final comic = item.dto is ComicWorkspaceDto ? (item.dto as ComicWorkspaceDto).comic : null;
  final badges = <LibraryCardBadge>[];

  if (comic?.work.keyComic == true) {
    badges.add(
      LibraryCardBadge(
        icon: Icons.label_important,
        label: comic?.work.keyReason?.isNotEmpty == true
            ? comic!.work.keyReason!
            : 'Key item',
      ),
    );
  }

  final slabLabel = librarySlabMarkerLabel(
    comic?.publishing.rawOrSlabbed,
    comic?.publishing.gradingCompany,
  );
  if (slabLabel != null) {
    badges.add(
      LibraryCardBadge(icon: Icons.workspace_premium, label: slabLabel),
    );
  }

  Widget Function(Widget child)? overlay;
  if (comic?.publishing.rawOrSlabbed != null ||
      comic?.publishing.gradingCompany != null ||
      comic?.publishing.labelType != null) {
    overlay = (child) => SlabFrameOverlay.maybeWrap(
          rawOrSlabbed: comic?.publishing.rawOrSlabbed,
          gradingCompany: comic?.publishing.gradingCompany,
          grade: item.dto.grade,
          labelType: comic?.publishing.labelType,
          child: child,
        );
  }

  return LibraryCardPresentation(
    coverOverlayBuilder: overlay,
    compactBadges: badges,
  );
}
