import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

const _tvMediaTabs = [
  LibraryEditTabSpec(
    id: 'media',
    icon: Icons.tv,
    label: 'Main',
    sectionIds: ['catalog_snapshot'],
  ),
  LibraryEditTabSpec(
    id: 'personal',
    icon: Icons.person,
    label: 'Personal',
    sectionIds: ['tracking_personal', 'ownership_fields', 'owned_notes'],
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.camera_alt,
    label: 'Covers',
    sectionIds: ['cover_images'],
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image,
    label: 'Images',
    sectionIds: ['photos'],
  ),
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.description_outlined,
    label: 'Plot',
    sectionIds: ['synopsis'],
  ),
  LibraryEditTabSpec(
    id: 'cast',
    icon: Icons.people,
    label: 'Cast',
    sectionIds: ['cast_list'],
  ),
  LibraryEditTabSpec(
    id: 'crew',
    icon: Icons.people_outline,
    label: 'Crew',
    sectionIds: ['crew_list'],
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.language,
    label: 'Links',
    sectionIds: ['external_links'],
  ),
];

const _tvReleaseTabs = [
  LibraryEditTabSpec(
    id: 'media',
    icon: Icons.tv,
    label: 'Main',
    sectionIds: ['catalog_snapshot'],
  ),
  LibraryEditTabSpec(
    id: 'release_media',
    icon: Icons.album_outlined,
    label: 'Edition Details',
    sectionIds: ['release_details', 'video_specs'],
  ),
  LibraryEditTabSpec(
    id: 'episode_map',
    icon: Icons.route_outlined,
    label: 'Disc / episode nesting',
    sectionIds: ['tv_episode_disc_map'],
  ),
  LibraryEditTabSpec(
    id: 'personal',
    icon: Icons.person,
    label: 'Personal',
    sectionIds: ['tracking_personal', 'ownership_fields', 'owned_notes'],
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.camera_alt,
    label: 'Covers',
    sectionIds: ['cover_images'],
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image,
    label: 'Images',
    sectionIds: ['photos'],
  ),
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.description_outlined,
    label: 'Plot',
    sectionIds: ['synopsis'],
  ),
  LibraryEditTabSpec(
    id: 'cast',
    icon: Icons.people,
    label: 'Cast',
    sectionIds: ['cast_list'],
  ),
  LibraryEditTabSpec(
    id: 'crew',
    icon: Icons.people_outline,
    label: 'Crew',
    sectionIds: ['crew_list'],
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.language,
    label: 'Links',
    sectionIds: ['external_links'],
  ),
];

const _tvAllTabs = [
  ..._tvMediaTabs,
  LibraryEditTabSpec(
    id: 'release_media',
    icon: Icons.album_outlined,
    label: 'Edition Details',
    sectionIds: ['release_details', 'video_specs'],
  ),
  LibraryEditTabSpec(
    id: 'episode_map',
    icon: Icons.route_outlined,
    label: 'Disc / episode nesting',
    sectionIds: ['tv_episode_disc_map'],
  ),
];

class TvLibraryEditPresentationBuilder extends DefaultLibraryEditPresentationBuilder {
  const TvLibraryEditPresentationBuilder()
      : super(
          trackingSectionTitle: 'Watch tracking',
          ownershipReferenceTitle: 'Release / copy reference',
          ownedBundleLabel: 'Owned release bundle',
          ownedTabs: _tvAllTabs,
          trackedTabs: _tvMediaTabs,
          catalogTabs: _tvMediaTabs,
        );
}

class TvLibraryMediaEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const TvLibraryMediaEditPresentationBuilder()
      : super(
          trackingSectionTitle: 'Watch tracking',
          ownershipReferenceTitle: 'Release / copy reference',
          ownedBundleLabel: 'Owned release bundle',
          ownedTabs: _tvMediaTabs,
          trackedTabs: _tvMediaTabs,
          catalogTabs: _tvMediaTabs,
        );
}

class TvLibraryReleaseEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const TvLibraryReleaseEditPresentationBuilder()
      : super(
          trackingSectionTitle: 'Watch tracking',
          ownershipReferenceTitle: 'Release / copy reference',
          ownedBundleLabel: 'Owned release bundle',
          ownedTabs: _tvReleaseTabs,
          trackedTabs: _tvReleaseTabs,
          catalogTabs: _tvReleaseTabs,
        );
}

const tvLibraryEditPresentation = LibraryEditPresentation(
  builder: TvLibraryEditPresentationBuilder(),
  mediaBuilder: TvLibraryMediaEditPresentationBuilder(),
  releaseBuilder: TvLibraryReleaseEditPresentationBuilder(),
);
