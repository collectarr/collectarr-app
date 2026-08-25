import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a movie workspace item.
LibraryCardPresentation buildMovieCardPresentation(
  LibraryProjectionRuntime item, {
  required bool musicVertical,
}) {
  return LibraryCardPresentation(
    compactBadges: _movieCompactBadges(item),
  );
}

List<LibraryCardBadge> _movieCompactBadges(LibraryProjectionRuntime item) {
  final dto = item.dto;
  final badges = <LibraryCardBadge>[];
  final editionsPayload = item.source.catalogItem?.kindMetadata.toSyncPayload()['editions'] as List?;
  final firstEdition = editionsPayload != null && editionsPayload.isNotEmpty && editionsPayload.first is Map
      ? CatalogEdition.fromJson(Map<String, dynamic>.from(editionsPayload.first as Map))
      : null;
  final edition = item.node is LibraryReleaseNodeRef
      ? (item.node as LibraryReleaseNodeRef).edition
      : firstEdition;
  final format = dto.referenceFormatLabel?.trim() ??
      edition?.format?.trim() ??
      edition?.physicalFormatLabel?.trim();
  final region = edition?.region?.trim() ?? dto.country?.trim();

  if (format != null && format.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.album_outlined, label: format));
  }
  if (region != null && region.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.public_outlined, label: region));
  }
  return badges;
}
