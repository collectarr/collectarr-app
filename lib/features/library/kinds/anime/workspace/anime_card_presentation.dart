import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
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
  final edition = item.node is LibraryReleaseNodeRef
      ? (item.node as LibraryReleaseNodeRef).edition
      : firstEdition;
  final format = dto is AnimeWorkspaceDto
      ? dto.referenceFormatLabel?.trim() ??
          edition?.format?.trim() ??
          edition?.physicalFormatLabel?.trim()
      : edition?.format?.trim() ?? edition?.physicalFormatLabel?.trim();
  final region = edition?.region?.trim() ??
      (dto is AnimeWorkspaceDto ? dto.country?.trim() : null);

  if (format != null && format.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.album_outlined, label: format));
  }
  if (region != null && region.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.public_outlined, label: region));
  }
  return badges;
}
