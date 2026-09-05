import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:flutter/material.dart';

const _animeOwnedTabs = [
  LibraryEditTabSpec(
    id: 'main',
    icon: Icons.article,
    label: 'Main',
    sectionIds: [
      'catalog_snapshot',
      'tracking_context',
      'ownership_reference',
      'owned_grading',
    ],
  ),
  LibraryEditTabSpec(
    id: 'value',
    icon: Icons.attach_money,
    label: 'Value',
    sectionIds: ['purchase', 'value_summary'],
  ),
  LibraryEditTabSpec(
    id: 'personal',
    icon: Icons.person,
    label: 'Personal',
    sectionIds: [
      'tracking_personal',
      'wishlist_reference',
      'owned_notes',
      'collection_fields_info',
    ],
  ),
  LibraryEditTabSpec(
    id: 'sold',
    icon: Icons.sell,
    label: 'Sold',
    sectionIds: ['sold_status', 'profit_loss'],
  ),
  LibraryEditTabSpec(
    id: 'custom',
    icon: Icons.tune,
    label: 'Custom',
    sectionIds: ['custom_fields'],
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.photo_library,
    label: 'Photos',
    sectionIds: ['photos'],
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
    id: 'personal',
    icon: Icons.person,
    label: 'Personal',
    sectionIds: ['tracking_personal', 'wishlist_reference'],
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
          showOwnershipReferenceSection: true,
          useOwnedMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Watch tracking',
          ownedDigitalTrackingSectionTitle: 'Ownership details',
          ownedDigitalTrackingHint:
              'Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.',
          ownershipReferenceTitle: 'Release / copy reference',
          ownedBundleLabel: 'Owned release bundle',
          ownedTabs: _animeOwnedTabs,
          trackedTabs: _animeTrackedTabs,
          catalogTabs: _animeCatalogTabs,
        );
}

const animeLibraryEditPresentation = LibraryEditPresentation(
  builder: AnimeLibraryEditPresentationBuilder(),
);
