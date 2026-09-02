import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a game workspace item.
LibraryCardPresentation buildGameCardPresentation(
  LibraryProjectionRuntime item, {
  required bool musicVertical,
}) {
  return LibraryCardPresentation(
    compactBadges: _gameCompactBadges(item),
  );
}

List<LibraryCardBadge> _gameCompactBadges(LibraryProjectionRuntime item) {
  final dto = item.dto;
  final adapter = dto is WorkspaceDtoAdapter ? dto : null;

  final badges = <LibraryCardBadge>[];
  final releasePlatform = adapter?.referenceFormatLabel?.trim();
  final developer = adapter?.publisher?.trim();
  final ageRating = (item.source.catalogItem?.kindMetadata
          .toSyncPayload()['age_rating'] as String?)
      ?.trim();
  final completion = item.source.ownedItem?.collectionStatus?.trim() ??
      (item.source.isOwned ? 'Owned' : null);

  if (releasePlatform != null && releasePlatform.isNotEmpty) {
    badges.add(
      LibraryCardBadge(icon: Icons.album_outlined, label: releasePlatform),
    );
  }
  if (developer != null && developer.isNotEmpty) {
    badges.add(
      LibraryCardBadge(icon: Icons.code_outlined, label: developer),
    );
  }
  if (ageRating != null && ageRating.isNotEmpty) {
    badges.add(
      LibraryCardBadge(icon: Icons.shield_outlined, label: ageRating),
    );
  }
  if (completion != null && completion.isNotEmpty) {
    badges.add(
      LibraryCardBadge(icon: Icons.check_circle_outline, label: completion),
    );
  }
  return badges;
}
