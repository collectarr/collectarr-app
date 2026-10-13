import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_media_custom_tab_builder.dart';
import 'package:flutter/material.dart';

const _animeEntryTabs = [
  LibraryEditTabSpec(
    id: 'main',
    icon: Icons.article,
    label: 'Main',
    sectionIds: [
      'catalog_snapshot',
      'tracking_context',
      'entries_reference',
      'entry_grading',
    ],
  ),
  LibraryEditTabSpec(
    id: 'value',
    icon: Icons.attach_money,
    label: 'Value',
    sectionIds: ['purchase', 'value_summary'],
  ),
  LibraryEditTabSpec(
    id: 'media',
    icon: Icons.article_outlined,
    label: 'Details',
  ),
  LibraryEditTabSpec(
    id: 'edition',
    icon: Icons.inventory_2_outlined,
    label: 'Edition',
  ),
  LibraryEditTabSpec(
    id: 'cast',
    icon: Icons.people_outline,
    label: 'Cast',
  ),
  LibraryEditTabSpec(
    id: 'crew',
    icon: Icons.work_outline,
    label: 'Crew',
  ),
  LibraryEditTabSpec(
    id: 'specs',
    icon: Icons.tune_outlined,
    label: 'Specs',
  ),
  LibraryEditTabSpec(
    id: 'sold',
    icon: Icons.sell,
    label: 'Sold',
    sectionIds: ['sold_status', 'profit_loss'],
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.image,
    label: 'Cover',
    sectionIds: ['cover_images'],
  ),
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.notes,
    label: 'Synopsis',
    sectionIds: ['synopsis'],
  ),
];

const _animeTrackedTabs = [
  LibraryEditTabSpec(
    id: 'main',
    icon: Icons.article,
    label: 'Main',
    sectionIds: ['catalog_snapshot', 'tracking_context'],
  ),
  LibraryEditTabSpec(
    id: 'media',
    icon: Icons.article_outlined,
    label: 'Details',
  ),
  LibraryEditTabSpec(
    id: 'edition',
    icon: Icons.inventory_2_outlined,
    label: 'Edition',
  ),
  LibraryEditTabSpec(
    id: 'cast',
    icon: Icons.people_outline,
    label: 'Cast',
  ),
  LibraryEditTabSpec(
    id: 'crew',
    icon: Icons.work_outline,
    label: 'Crew',
  ),
  LibraryEditTabSpec(
    id: 'specs',
    icon: Icons.tune_outlined,
    label: 'Specs',
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.image,
    label: 'Cover',
    sectionIds: ['cover_images'],
  ),
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.notes,
    label: 'Synopsis',
    sectionIds: ['synopsis'],
  ),
];

const _animeCatalogTabs = [
  LibraryEditTabSpec(
    id: 'main',
    icon: Icons.article,
    label: 'Main',
    sectionIds: ['catalog_snapshot'],
  ),
  LibraryEditTabSpec(
    id: 'media',
    icon: Icons.article_outlined,
    label: 'Details',
  ),
  LibraryEditTabSpec(
    id: 'edition',
    icon: Icons.inventory_2_outlined,
    label: 'Edition',
  ),
  LibraryEditTabSpec(
    id: 'cast',
    icon: Icons.people_outline,
    label: 'Cast',
  ),
  LibraryEditTabSpec(
    id: 'crew',
    icon: Icons.work_outline,
    label: 'Crew',
  ),
  LibraryEditTabSpec(
    id: 'specs',
    icon: Icons.tune_outlined,
    label: 'Specs',
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.image,
    label: 'Cover',
    sectionIds: ['cover_images'],
  ),
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.notes,
    label: 'Synopsis',
    sectionIds: ['synopsis'],
  ),
];

class AnimeLibraryEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const AnimeLibraryEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Watch tracking',
          entryDigitalTrackingSectionTitle: 'Digital Entry Details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _animeEntryTabs,
          trackedTabs: _animeTrackedTabs,
          catalogTabs: _animeCatalogTabs,
          customTabBuilder: buildAnimeMediaCustomTabView,
        );
}

const animeLibraryEditPresentation = LibraryEditPresentation(
  builder: AnimeLibraryEditPresentationBuilder(),
  sharedTabs: [
    LibraryEditTabContribution(
      tab: LibraryEditTabSpec(
        id: 'links',
        icon: Icons.public,
        label: 'Links',
      ),
      afterTabId: 'specs',
    ),
    LibraryEditTabContribution(
      tab: LibraryEditTabSpec(
        id: 'personal',
        icon: Icons.person,
        label: 'Personal',
        sectionIds: ['tracking_personal', 'wishlist_reference'],
      ),
      scope: LibraryEditTabTargetScope.tracked,
      afterTabId: 'main',
    ),
    LibraryEditTabContribution(
      tab: LibraryEditTabSpec(
        id: 'personal',
        icon: Icons.person,
        label: 'Personal',
        sectionIds: [
          'tracking_personal',
          'wishlist_reference',
          'entry_notes',
          'collection_fields_info',
        ],
      ),
      scope: LibraryEditTabTargetScope.libraryEntry,
      afterTabId: 'links',
    ),
    LibraryEditTabContribution(
      tab: LibraryEditTabSpec(
        id: 'custom',
        icon: Icons.tune,
        label: 'Custom',
        sectionIds: ['custom_fields'],
      ),
      scope: LibraryEditTabTargetScope.libraryEntry,
      afterTabId: 'sold',
    ),
    LibraryEditTabContribution(
      tab: LibraryEditTabSpec(
        id: 'photos',
        icon: Icons.photo_library,
        label: 'Photos',
        sectionIds: ['photos'],
      ),
      scope: LibraryEditTabTargetScope.libraryEntry,
      afterTabId: 'custom',
    ),
  ],
);
