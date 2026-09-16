import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for an anime workspace item.
LibraryCardPresentation buildAnimeCardPresentation(
  LibraryProjectionView item, {
  required bool musicVertical,
}) {
  final animeDto =
      item.dto is AnimeWorkspaceDto ? item.dto as AnimeWorkspaceDto : null;
  return LibraryCardPresentation(
    itemNumber: animeDto?.itemNumber,
    variant: animeDto?.variant,
    releaseDate: animeDto?.releaseDate,
    format: animeDto?.format,
    synopsis: animeDto?.synopsis,
    seriesTitle: animeDto?.seriesTitle,
    identifierCode: animeDto?.identifierCode,
    currency: animeDto?.currency,
    compactBadges: _animeCompactBadges(item),
  );
}

List<LibraryCardBadge> _animeCompactBadges(LibraryProjectionView item) {
  final dto = item.dto;
  final badges = <LibraryCardBadge>[];
  final catalog = item.source.catalogData;
  final firstEdition = catalog is AnimeWorkspaceCatalogData
      ? catalog.metadata?.editions.firstOrNull
      : null;
  final release = item.node is LibraryReleaseRef
      ? (item.node as LibraryReleaseRef).release
      : null;
  final format = dto is AnimeWorkspaceDto
      ? dto.referenceFormatLabel?.trim() ??
          release?.formatLabel?.trim() ??
          firstEdition?.format?.trim() ??
          firstEdition?.physicalFormatLabel?.trim()
      : release?.formatLabel?.trim() ??
          firstEdition?.format?.trim() ??
          firstEdition?.physicalFormatLabel?.trim();
  final region = (release == null ? firstEdition?.region : null)?.trim() ??
      (dto is AnimeWorkspaceDto ? dto.country?.trim() : null);

  if (format != null && format.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.album_outlined, label: format));
  }
  if (region != null && region.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.public_outlined, label: region));
  }
  return badges;
}
