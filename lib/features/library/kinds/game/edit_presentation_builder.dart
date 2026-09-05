import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_custom_tab_builder.dart';
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

const _gameOwnedTab = LibraryEditTabSpec(
  id: 'owned',
  icon: Icons.inventory_2,
  label: 'Owned',
  sectionIds: [],
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
  _gameOwnedTab,
  _gameReleaseIdentityTab,
  ..._gameMediaSecondaryTabs,
  ..._gameReleaseTabs,
];

class GameLibraryCombinedEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const GameLibraryCombinedEditPresentationBuilder()
      : super(
          showOwnershipReferenceSection: true,
          useOwnedMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Tracking edition',
          ownedDigitalTrackingSectionTitle: 'Ownership details',
          ownedDigitalTrackingHint:
              'Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.',
          ownershipReferenceTitle: 'Ownership reference',
          ownedBundleLabel: 'Owned bundle',
          ownedTabs: _gameCombinedTabs,
          trackedTabs: _gameCombinedTabs,
          catalogTabs: _gameCombinedTabs,
          customTabBuilder: buildGameCustomTabView,
        );
}

class GameLibraryMediaEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const GameLibraryMediaEditPresentationBuilder()
      : super(
          showOwnershipReferenceSection: true,
          useOwnedMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Tracking edition',
          ownedDigitalTrackingSectionTitle: 'Ownership details',
          ownedDigitalTrackingHint:
              'Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.',
          ownershipReferenceTitle: 'Ownership reference',
          ownedBundleLabel: 'Owned bundle',
          ownedTabs: _gameMediaTabs,
          trackedTabs: _gameMediaTabs,
          catalogTabs: _gameMediaTabs,
          customTabBuilder: buildGameCustomTabView,
        );
}

class GameLibraryReleaseEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const GameLibraryReleaseEditPresentationBuilder()
      : super(
          showOwnershipReferenceSection: true,
          useOwnedMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Tracking edition',
          ownedDigitalTrackingSectionTitle: 'Ownership details',
          ownedDigitalTrackingHint:
              'Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.',
          ownershipReferenceTitle: 'Ownership reference',
          ownedBundleLabel: 'Owned bundle',
          ownedTabs: _gameReleaseTabs,
          trackedTabs: _gameReleaseTabs,
          catalogTabs: _gameReleaseTabs,
          customTabBuilder: buildGameCustomTabView,
        );
}

const gameLibraryEditPresentation = LibraryEditPresentation(
  builder: GameLibraryCombinedEditPresentationBuilder(),
  mediaBuilder: GameLibraryMediaEditPresentationBuilder(),
  releaseBuilder: GameLibraryReleaseEditPresentationBuilder(),
);
