import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a game workspace item.
LibraryCardPresentation buildGameCardPresentation(
  LibraryProjectionView item, {
  required bool musicVertical,
}) {
  final gameDto =
      item.dto is GameWorkspaceDto ? item.dto as GameWorkspaceDto : null;
  return LibraryCardPresentation(
    itemNumber: gameDto?.itemNumber,
    variant: gameDto?.variant,
    releaseDate: gameDto?.releaseDate,
    format: gameDto?.format,
    compactBadges: _gameCompactBadges(item),
  );
}

List<LibraryCardBadge> _gameCompactBadges(LibraryProjectionView item) {
  final dto = item.dto;
  final gameDto = dto is GameWorkspaceDto ? dto : null;

  final badges = <LibraryCardBadge>[];
  final releasePlatform = gameDto?.referenceFormatLabel?.trim();
  final developer = gameDto?.publisher?.trim();
  final gameCatalog = item.source.catalogData;
  final ageRating = gameCatalog is GameWorkspaceCatalogData
      ? gameCatalog.metadata?.ageRating?.trim()
      : null;
  final owned =
      GameOwnedItemProjection.fromDispatch(item.source.ownedItemDispatch);
  final completion = owned is GameOwnedItem
      ? owned.collectionStatus?.trim() ?? (item.source.isOwned ? 'Owned' : null)
      : (item.source.isOwned ? 'Owned' : null);

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
