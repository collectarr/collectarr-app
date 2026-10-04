import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_custom_tab_builder.dart';
import 'package:flutter/material.dart';

const _comicMediaTabs = [
  LibraryEditTabSpec(
    id: 'main',
    icon: Icons.article,
    label: 'Main',
    sectionIds: ['catalog_snapshot'],
  ),
  LibraryEditTabSpec(
    id: 'details',
    icon: Icons.search,
    label: 'Details',
    sectionIds: ['catalog_details'],
  ),
  LibraryEditTabSpec(
    id: 'creators',
    icon: Icons.group,
    label: 'Creators',
    sectionIds: ['comic_creators'],
  ),
  LibraryEditTabSpec(
    id: 'characters',
    icon: Icons.face,
    label: 'Characters',
    sectionIds: ['comic_characters'],
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.public,
    label: 'Links',
    sectionIds: ['external_links'],
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.image,
    label: 'Covers',
    sectionIds: ['cover_images'],
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.photo_library,
    label: 'My Images',
    sectionIds: ['photos'],
  ),
];

const _comicCombinedTabs = [
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
    id: 'creators',
    icon: Icons.group,
    label: 'Creators',
    sectionIds: ['comic_creators'],
  ),
  LibraryEditTabSpec(
    id: 'characters',
    icon: Icons.face,
    label: 'Characters',
    sectionIds: ['comic_characters'],
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.public,
    label: 'Links',
    sectionIds: ['external_links'],
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.image,
    label: 'Covers',
    sectionIds: ['cover_images'],
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.photo_library,
    label: 'My Images',
    sectionIds: ['photos'],
  ),
  LibraryEditTabSpec(
    id: 'custom',
    icon: Icons.tune,
    label: 'Custom Fields',
    sectionIds: ['custom_fields'],
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
      'entries_fields',
      'purchase_fields',
      'sold_fields',
      'wishlist_reference',
      'entry_notes',
      'collection_fields_info',
    ],
  ),
];

const _comicEntryTabs = [
  ..._comicCombinedTabs,
  LibraryEditTabSpec(
    id: 'entry',
    icon: Icons.inventory_2,
    label: 'Entry',
    sectionIds: ['comic_entry'],
  ),
];

class ComicLibraryCombinedEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const ComicLibraryCombinedEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          trackingSectionTitle: 'Tracking edition',
          entryDigitalTrackingSectionTitle: 'Digital Entry Details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _comicEntryTabs,
          trackedTabs: _comicCombinedTabs,
          catalogTabs: _comicCombinedTabs,
          customTabBuilder: buildComicCustomTabView,
        );
}

class ComicLibraryCatalogItemEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const ComicLibraryCatalogItemEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          trackingSectionTitle: 'Tracking edition',
          entryDigitalTrackingSectionTitle: 'Digital Entry Details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _comicMediaTabs,
          trackedTabs: _comicMediaTabs,
          catalogTabs: _comicMediaTabs,
          customTabBuilder: buildComicCustomTabView,
        );
}

const comicsLibraryEditPresentation = LibraryEditPresentation(
  builder: ComicLibraryCombinedEditPresentationBuilder(),
  catalogItemBuilder: ComicLibraryCatalogItemEditPresentationBuilder(),
);
