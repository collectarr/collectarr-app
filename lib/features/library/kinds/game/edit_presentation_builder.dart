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
    'entries_reference',
    'entry_grading',
  ],
);

const _gameEntryTab = LibraryEditTabSpec(
  id: 'entry',
  icon: Icons.inventory_2,
  label: 'Personal',
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

const _gamePersonalAndValueTabs = [
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
      'entry_notes',
      'collection_fields_info',
    ],
  ),
  LibraryEditTabSpec(
    id: 'custom',
    icon: Icons.edit_note,
    label: 'Custom Fields',
    sectionIds: ['custom_fields'],
  ),
];

const _gameEditionDetailsTab = LibraryEditTabSpec(
  id: 'edition',
  icon: Icons.album_outlined,
  label: 'Edition Details',
  sectionIds: ['release_identity'],
);

const _gameCombinedTabs = [
  _gameMainTab,
  _gameEntryTab,
  _gameEditionDetailsTab,
  ..._gameMediaSecondaryTabs,
  ..._gamePersonalAndValueTabs,
];

class GameLibraryCombinedEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const GameLibraryCombinedEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Tracking edition',
          entryDigitalTrackingSectionTitle: 'EntryPolicy details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _gameCombinedTabs,
          trackedTabs: _gameCombinedTabs,
          catalogTabs: _gameCombinedTabs,
          customTabBuilder: buildGameCustomTabView,
        );
}

const gameLibraryEditPresentation = LibraryEditPresentation(
  builder: GameLibraryCombinedEditPresentationBuilder(),
);
