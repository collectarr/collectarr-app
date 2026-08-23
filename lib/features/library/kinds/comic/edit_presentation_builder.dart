import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
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
    sectionIds: ['personal_value'],
  ),
  LibraryEditTabSpec(
    id: 'personal',
    icon: Icons.person,
    label: 'Personal',
    sectionIds: ['personal_details'],
  ),
  LibraryEditTabSpec(
    id: 'sold',
    icon: Icons.sell,
    label: 'Sold',
    sectionIds: ['personal_sold'],
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
    id: 'custom',
    icon: Icons.tune,
    label: 'Custom Fields',
    sectionIds: ['custom_fields'],
  ),
  LibraryEditTabSpec(
    id: 'value',
    icon: Icons.attach_money,
    label: 'Value',
    sectionIds: ['personal_value'],
  ),
  LibraryEditTabSpec(
    id: 'personal',
    icon: Icons.person,
    label: 'Personal',
    sectionIds: ['personal_details'],
  ),
  LibraryEditTabSpec(
    id: 'sold',
    icon: Icons.sell,
    label: 'Sold',
    sectionIds: ['personal_sold'],
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

class ComicLibraryCombinedEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const ComicLibraryCombinedEditPresentationBuilder()
      : super(
          showOwnedGradingSection: true,
          useOwnedMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          showOwnedCoverPriceField: false,
          ownedTabs: _comicCombinedTabs,
          trackedTabs: _comicCombinedTabs,
          catalogTabs: _comicCombinedTabs,
          customTabBuilder: buildComicCustomTabView,
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
          customTabBuilder: buildComicCustomTabView,
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
          customTabBuilder: buildComicCustomTabView,
        );
}

const comicsLibraryEditPresentation = LibraryEditPresentation(
  builder: ComicLibraryCombinedEditPresentationBuilder(),
  mediaBuilder: ComicLibraryMediaEditPresentationBuilder(),
  releaseBuilder: ComicLibraryReleaseEditPresentationBuilder(),
);
