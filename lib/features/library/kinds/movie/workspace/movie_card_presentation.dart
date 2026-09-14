import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a movie workspace item.
LibraryCardPresentation buildMovieCardPresentation(
  LibraryProjectionView item, {
  required bool musicVertical,
}) {
  final movieDto =
      item.dto is MovieWorkspaceDto ? item.dto as MovieWorkspaceDto : null;
  return LibraryCardPresentation(
    itemNumber: movieDto?.itemNumber,
    variant: movieDto?.variant,
    releaseDate: movieDto?.releaseDate,
    format: movieDto?.format,
    compactBadges: _movieCompactBadges(item),
  );
}

List<LibraryCardBadge> _movieCompactBadges(LibraryProjectionView item) {
  final dto = item.dto;
  final badges = <LibraryCardBadge>[];
  final catalog = item.source.catalogData;
  final firstEdition = catalog is MovieWorkspaceCatalogData
      ? catalog.metadata?.editions.firstOrNull
      : null;
  final edition = item.node is LibraryReleaseNodeRef
      ? (item.node as LibraryReleaseNodeRef).edition
      : firstEdition;
  final format = dto is MovieWorkspaceDto
      ? dto.referenceFormatLabel?.trim() ??
          edition?.format?.trim() ??
          edition?.physicalFormatLabel?.trim()
      : edition?.format?.trim() ?? edition?.physicalFormatLabel?.trim();
  final region = edition?.region?.trim() ??
      (dto is MovieWorkspaceDto ? dto.country?.trim() : null);

  if (format != null && format.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.album_outlined, label: format));
  }
  if (region != null && region.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.public_outlined, label: region));
  }
  return badges;
}
