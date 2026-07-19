import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a game workspace entry.
LibraryCardPresentation buildGameCardPresentation(
  LibraryWorkspaceEntry entry, {
  required bool musicVertical,
}) {
  return LibraryCardPresentation(
    compactBadges: _gameCompactBadges(entry),
  );
}

List<LibraryCardBadge> _gameCompactBadges(LibraryWorkspaceEntry entry) {
  if (entry.mediaType != 'game') return const [];

  final badges = <LibraryCardBadge>[];
  final releasePlatform = entry.referenceFormatLabel?.trim();
  final developer = _compactGameDeveloperLabel(entry);
  final ageRating = entry.ageRating?.trim();
  final completion = _compactGameCompletionLabel(entry);
  final hardware = _compactHardwareLabel(entry);

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
  if (hardware != null && hardware.isNotEmpty) {
    badges.add(
      LibraryCardBadge(
        icon: Icons.videogame_asset_outlined,
        label: hardware,
      ),
    );
  }
  return badges;
}

String? _compactGameDeveloperLabel(LibraryWorkspaceEntry entry) {
  final creators = entry.creators ?? const <Map<String, dynamic>>[];
  String? fallbackName;
  for (final creator in creators) {
    final rawName =
        (creator['name'] ?? creator['display_name'] ?? '').toString().trim();
    if (rawName.isEmpty) continue;
    fallbackName ??= rawName;
    final role =
        (creator['role'] ?? creator['type'] ?? '').toString().toLowerCase();
    if (role.contains('developer') ||
        role.contains('publisher') ||
        role.contains('studio')) {
      return rawName;
    }
  }
  return fallbackName;
}

String? _compactGameCompletionLabel(LibraryWorkspaceEntry entry) {
  final status = entry.collectionStatus?.trim();
  if (status != null && status.isNotEmpty) return status;
  return entry.isOwned ? 'Owned' : null;
}

String? _compactHardwareLabel(LibraryWorkspaceEntry entry) {
  final game = entry.game;
  if (game == null) return null;
  final parts = <String>[
    if (game.toySubtype?.trim().isNotEmpty == true) game.toySubtype!.trim(),
    if (game.toyType?.trim().isNotEmpty == true) game.toyType!.trim(),
  ];
  if (parts.isEmpty) return null;
  return parts.join(' / ');
}
