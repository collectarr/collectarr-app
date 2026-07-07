import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

const _gameMainTab = LibraryEditTabSpec(
  id: 'main',
  icon: Icons.sports_esports,
  label: 'Main',
  sectionIds: [
    'catalog_snapshot',
    'tracking_context',
    'ownership_reference',
    'owned_grading',
  ],
);

const _gameMediaSecondaryTabs = [
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.description_outlined,
    label: 'Description',
    sectionIds: ['synopsis'],
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.public,
    label: 'Links',
    sectionIds: ['external_links'],
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.photo_camera_outlined,
    label: 'Covers',
    sectionIds: ['cover_images'],
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image_outlined,
    label: 'My Images',
    sectionIds: ['photos'],
  ),
];

const _gameMediaTabs = [
  _gameMainTab,
  ..._gameMediaSecondaryTabs,
];

const _gameReleaseTabs = [
  LibraryEditTabSpec(
    id: 'value',
    icon: Icons.attach_money,
    label: 'Value',
    sectionIds: ['purchase', 'value_summary', 'sold_status', 'profit_loss'],
  ),
  LibraryEditTabSpec(
    id: 'personal',
    icon: Icons.person_outline,
    label: 'Personal',
    sectionIds: [
      'tracking_personal',
      'wishlist_reference',
      'owned_notes',
      'collection_fields_info',
    ],
  ),
  LibraryEditTabSpec(
    id: 'custom',
    icon: Icons.edit_note,
    label: 'Custom Fields',
    sectionIds: ['custom_fields'],
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.photo_camera_outlined,
    label: 'Covers',
    sectionIds: ['cover_images'],
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image_outlined,
    label: 'My Images',
    sectionIds: ['photos'],
  ),
];

const _gameReleaseIdentityTab = LibraryEditTabSpec(
  id: 'release',
  icon: Icons.album_outlined,
  label: 'Release',
  sectionIds: ['release_identity'],
);

const _gameCombinedTabs = [
  _gameMainTab,
  _gameReleaseIdentityTab,
  ..._gameMediaSecondaryTabs,
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
}

class GameLibraryMediaEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const GameLibraryMediaEditPresentationBuilder()
      : super(
          ownedTabs: _gameMediaTabs,
          trackedTabs: _gameMediaTabs,
          catalogTabs: _gameMediaTabs,
        );
}

class GameLibraryReleaseEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const GameLibraryReleaseEditPresentationBuilder()
      : super(
          ownedTabs: _gameReleaseTabs,
          trackedTabs: _gameReleaseTabs,
          catalogTabs: _gameReleaseTabs,
        );
}

const gameLibraryEditPresentation = LibraryEditPresentation(
  builder: GameLibraryCombinedEditPresentationBuilder(),
  mediaBuilder: GameLibraryMediaEditPresentationBuilder(),
  releaseBuilder: GameLibraryReleaseEditPresentationBuilder(),
);
