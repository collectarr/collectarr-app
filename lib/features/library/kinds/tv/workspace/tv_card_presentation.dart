import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a tv workspace item.
LibraryCardPresentation buildTvCardPresentation(
  LibraryProjectionView item, {
  required bool coverFocused,
}) {
  final tvDto = item.dto is TvWorkspaceDto ? item.dto as TvWorkspaceDto : null;
  return LibraryCardPresentation(
    itemNumber: tvDto?.itemNumber,
    variant: tvDto?.variant,
    releaseDate: tvDto?.releaseDate,
    format: tvDto?.format,
    synopsis: tvDto?.synopsis,
    seriesTitle: tvDto?.seriesTitle,
    identifierCode: tvDto?.identifierCode,
    currency: tvDto?.currency,
    contextFacts: [
      tvDto?.publisher,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
    compactBadges: _tvCompactBadges(item),
  );
}

List<LibraryCardBadge> _tvCompactBadges(LibraryProjectionView item) {
  final dto = item.dto;
  final badges = <LibraryCardBadge>[];
  final format =
      dto is TvWorkspaceDto ? dto.referenceFormatLabel?.trim() : null;
  final region = dto is TvWorkspaceDto ? dto.country?.trim() : null;

  if (format != null && format.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.album_outlined, label: format));
  }
  if (region != null && region.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.public_outlined, label: region));
  }
  return badges;
}
