import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a comic workspace item.
LibraryCardPresentation buildComicCardPresentation(
  LibraryProjectionView item, {
  required bool coverFocused,
}) {
  final comicDto =
      item.dto is ComicWorkspaceDto ? item.dto as ComicWorkspaceDto : null;
  final libraryEntry = item.dto is ComicWorkspaceDto
      ? (item.dto as ComicWorkspaceDto).libraryEntry
      : null;
  final comicDetails = libraryEntry?.personal.details;
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

  if (libraryEntry?.personal.grade?.trim().isNotEmpty == true) {
    badges.add(
      LibraryCardBadge(
        icon: Icons.workspace_premium,
        label: 'Grade ${libraryEntry!.personal.grade!.trim()}',
      ),
    );
  }

  Widget Function(Widget child)? overlay;
  if (comicDetails?.rawOrSlabbed != null ||
      comicDetails?.gradingCompany != null ||
      comicDetails?.labelType != null ||
      libraryEntry?.personal.grade != null) {
    overlay = (child) => SlabFrameOverlay.maybeWrap(
          rawOrSlabbed: comicDetails?.rawOrSlabbed,
          companyName: comicDetails?.gradingCompany,
          scoreLabel: libraryEntry?.personal.grade,
          labelType: comicDetails?.labelType,
          child: child,
        );
  }

  return LibraryCardPresentation(
    itemNumber: comicDto?.itemNumber,
    variant: comicDto?.variant,
    releaseDate: comicDto?.releaseDate,
    format: comicDto?.format,
    synopsis: comicDto?.synopsis,
    seriesTitle: comicDto?.seriesTitle,
    identifierCode: comicDto?.identifierCode,
    currency: comicDto?.currency,
    contextFacts: [
      comicDto?.artist,
      comicDto?.publisher,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
    coverOverlayBuilder: overlay,
    compactBadges: badges,
  );
}
