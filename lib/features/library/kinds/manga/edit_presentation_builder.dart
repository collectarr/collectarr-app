import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_custom_tab_builder.dart';
import 'package:flutter/material.dart';

const _mangaCombinedTabs = [
  LibraryEditTabSpec(
    id: 'main',
    icon: Icons.article,
    label: 'Main',
    sectionIds: ['catalog_snapshot'],
  ),
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.notes,
    label: 'Plot',
    sectionIds: ['synopsis'],
  ),
  LibraryEditTabSpec(
    id: 'details',
    icon: Icons.search,
    label: 'Details',
    sectionIds: ['catalog_details'],
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
    label: 'Custom Fields',
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
    id: 'owned',
    icon: Icons.inventory_2,
    label: 'Owned',
    sectionIds: ['manga_owned'],
  ),
];

class MangaLibraryEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const MangaLibraryEditPresentationBuilder()
      : super(
          showOwnershipReferenceSection: true,
          useOwnedMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          trackingSectionTitle: 'Tracking edition',
          ownedDigitalTrackingSectionTitle: 'Ownership details',
          ownedDigitalTrackingHint:
              'Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.',
          ownershipReferenceTitle: 'Ownership reference',
          ownedBundleLabel: 'Owned bundle',
          ownedTabs: _mangaCombinedTabs,
          trackedTabs: _mangaCombinedTabs,
          catalogTabs: _mangaCombinedTabs,
          customTabBuilder: buildMangaCustomTabView,
        );
}

const mangaLibraryEditPresentation = LibraryEditPresentation(
  builder: MangaLibraryEditPresentationBuilder(),
);
