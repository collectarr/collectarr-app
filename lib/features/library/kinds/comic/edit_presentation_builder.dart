import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
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
    icon: Icons.link,
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

const _comicReleaseTabs = [
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
    id: 'synopsis',
    icon: Icons.notes,
    label: 'Plot',
    sectionIds: ['synopsis'],
  ),
  LibraryEditTabSpec(
    id: 'personal',
    icon: Icons.person,
    label: 'Personal',
    sectionIds: [
      'tracking_personal',
      'ownership_fields',
      'purchase_fields',
      'sold_fields',
      'wishlist_reference',
      'owned_notes',
      'collection_fields_info',
    ],
  ),
];

const _comicCombinedTabs = [
  ..._comicMediaTabs,
  ..._comicReleaseTabs,
];

class ComicLibraryCombinedEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const ComicLibraryCombinedEditPresentationBuilder()
      : super(
          showOwnedGradingSection: true,
          showsComicCollectorFields: true,
          useOwnedMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          showOwnedCoverPriceField: false,
          ownedTabs: _comicCombinedTabs,
          trackedTabs: _comicCombinedTabs,
          catalogTabs: _comicCombinedTabs,
        );
}

class ComicLibraryMediaEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const ComicLibraryMediaEditPresentationBuilder()
      : super(
          showOwnedGradingSection: true,
          useOwnedMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          showOwnedCoverPriceField: false,
          ownedTabs: _comicMediaTabs,
          trackedTabs: _comicMediaTabs,
          catalogTabs: _comicMediaTabs,
        );
}

class ComicLibraryReleaseEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const ComicLibraryReleaseEditPresentationBuilder()
      : super(
          showOwnedGradingSection: true,
          useOwnedMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          showOwnedCoverPriceField: false,
          ownedTabs: _comicReleaseTabs,
          trackedTabs: _comicReleaseTabs,
          catalogTabs: _comicReleaseTabs,
        );
}

const comicsLibraryEditPresentation = LibraryEditPresentation(
  builder: ComicLibraryCombinedEditPresentationBuilder(),
  mediaBuilder: ComicLibraryMediaEditPresentationBuilder(),
  releaseBuilder: ComicLibraryReleaseEditPresentationBuilder(),
);
