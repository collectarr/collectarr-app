import 'package:collectarr_app/features/library/workspace/tiles/card_templates.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/dto.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card_presentation.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a movie workspace item.
LibraryCardPresentation buildMovieCardPresentation(
  LibraryProjectionView item, {
  required bool coverFocused,
}) {
  final movieDto =
      item.dto is MovieWorkspaceDto ? item.dto as MovieWorkspaceDto : null;
  return LibraryCardPresentation(
    coverBodyBuilder: buildStandardCoverContent,
    flowBodyBuilder: buildStandardFlowContent,
    flowFooterBuilder: (context, data) => buildStandardFlowFooter(context, data,
        title: item.dto.primaryLabel,
        meta: libraryFlowSubtitle([
          movieDto?.seriesTitle,
          movieDto?.studio ?? movieDto?.publisher,
          libraryFlowDate(movieDto?.releaseDate),
          movieDto?.format
        ]),
        numberLabel: (movieDto?.itemNumber?.trim().isNotEmpty ?? false)
            ? '#${movieDto?.itemNumber}'
            : null),
    shelfBodyBuilder: buildStandardShelfContent,
    horizontalBodyBuilder: buildStandardHorizontalCardBody,
    verticalBodyBuilder: buildStandardVerticalCardBody,
    verticalSubtitle: movieDto?.format ??
        item.dto.secondaryLabel ??
        movieDto?.seriesTitle ??
        [movieDto?.studio ?? movieDto?.publisher]
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .firstOrNull,
    verticalSubtitleEmphasized: movieDto?.format != null,
    verticalTrailing: movieDto?.releaseDate?.year.toString(),
    flowSubtitle: libraryFlowSubtitle([
      if (movieDto?.itemNumber?.trim().isNotEmpty ?? false)
        '#${movieDto?.itemNumber}',
      movieDto?.format,
      movieDto?.releaseDate?.year.toString()
    ]),
    itemNumber: movieDto?.itemNumber,
    variant: movieDto?.variant,
    releaseDate: movieDto?.releaseDate,
    format: movieDto?.format,
    synopsis: movieDto?.synopsis,
    seriesTitle: movieDto?.seriesTitle,
    identifierCode: movieDto?.identifierCode,
    currency: movieDto?.currency,
    contextFacts: [
      movieDto?.studio ?? movieDto?.publisher,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
    compactBadges: _movieCompactBadges(item),
  );
}

List<LibraryCardBadge> _movieCompactBadges(LibraryProjectionView item) {
  final dto = item.dto;
  final badges = <LibraryCardBadge>[];
  final format =
      dto is MovieWorkspaceDto ? dto.referenceFormatLabel?.trim() : null;
  final region = dto is MovieWorkspaceDto ? dto.country?.trim() : null;

  if (format != null && format.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.album_outlined, label: format));
  }
  if (region != null && region.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.public_outlined, label: region));
  }
  return badges;
}
