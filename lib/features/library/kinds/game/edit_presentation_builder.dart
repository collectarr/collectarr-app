import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

const _gameMediaTabs = [
  LibraryEditTabSpec(
    id: 'main',
    icon: Icons.sports_esports,
    label: 'Main',
  ),
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.description_outlined,
    label: 'Description',
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.public,
    label: 'Links',
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.photo_camera_outlined,
    label: 'Covers',
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image_outlined,
    label: 'My Images',
  ),
];

const _gameReleaseTabs = [
  LibraryEditTabSpec(
    id: 'value',
    icon: Icons.attach_money,
    label: 'Value',
  ),
  LibraryEditTabSpec(
    id: 'personal',
    icon: Icons.person_outline,
    label: 'Personal',
  ),
  LibraryEditTabSpec(
    id: 'custom',
    icon: Icons.edit_note,
    label: 'Custom Fields',
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.photo_camera_outlined,
    label: 'Covers',
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image_outlined,
    label: 'My Images',
  ),
];

const _gameCombinedTabs = [
  ..._gameMediaTabs,
  ..._gameReleaseTabs,
];

class GameLibraryCombinedEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const GameLibraryCombinedEditPresentationBuilder()
      : super(
          ownedTabs: _gameCombinedTabs,
          trackedTabs: _gameCombinedTabs,
          catalogTabs: _gameCombinedTabs,
        );

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'main' => [
          'catalog_snapshot',
          'tracking_context',
          'ownership_reference',
          'owned_grading',
        ],
      'value' => ['purchase', 'value_summary', 'sold_status', 'profit_loss'],
      'personal' => [
          'tracking_personal',
          'wishlist_reference',
          'owned_notes',
          'collection_fields_info',
        ],
      'custom' => ['custom_fields'],
      'cover' => ['cover_images'],
      'photos' => ['photos'],
      'synopsis' => ['synopsis'],
      'links' => ['external_links'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
}

class GameLibraryMediaEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const GameLibraryMediaEditPresentationBuilder()
      : super(
          ownedTabs: _gameMediaTabs,
          trackedTabs: _gameMediaTabs,
          catalogTabs: _gameMediaTabs,
        );

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'main' => [
          'catalog_snapshot',
          'tracking_context',
          'ownership_reference',
          'owned_grading',
        ],
      'cover' => ['cover_images'],
      'synopsis' => ['synopsis'],
      'links' => ['external_links'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
}

class GameLibraryReleaseEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const GameLibraryReleaseEditPresentationBuilder()
      : super(
          ownedTabs: _gameReleaseTabs,
          trackedTabs: _gameReleaseTabs,
          catalogTabs: _gameReleaseTabs,
        );

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'value' => ['purchase', 'value_summary', 'sold_status', 'profit_loss'],
      'personal' => [
          'tracking_personal',
          'wishlist_reference',
          'owned_notes',
          'collection_fields_info',
        ],
      'custom' => ['custom_fields'],
      'cover' => ['cover_images'],
      'photos' => ['photos'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
}

class GameLibraryEditPresentationBuilder
    extends GameLibraryCombinedEditPresentationBuilder {
  const GameLibraryEditPresentationBuilder();
}

const gameLibraryEditPresentation = LibraryEditPresentation(
  builder: GameLibraryCombinedEditPresentationBuilder(),
  mediaBuilder: GameLibraryMediaEditPresentationBuilder(),
  releaseBuilder: GameLibraryReleaseEditPresentationBuilder(),
);
