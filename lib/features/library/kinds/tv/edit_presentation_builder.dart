import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_custom_tab_builder.dart';
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
    sectionIds: ['tracking_personal', 'entries_fields', 'entry_notes'],
  ),
  LibraryEditTabSpec(
    id: 'episodes',
    icon: Icons.play_circle_outline,
    label: 'Episodes',
    sectionIds: ['tv_episodes'],
  ),
  LibraryEditTabSpec(
    id: 'episode_map',
    icon: Icons.route_outlined,
    label: 'Disc map',
    sectionIds: ['tv_episode_disc_map'],
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
    id: 'links',
    icon: Icons.public,
    label: 'Links',
    sectionIds: ['external_links'],
  ),
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.description_outlined,
    label: 'Plot',
    sectionIds: ['synopsis'],
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
];

class TvLibraryEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const TvLibraryEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Watch tracking',
          entryDigitalTrackingSectionTitle: 'EntryPolicy details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _tvAllTabs,
          trackedTabs: _tvMediaTabs,
          catalogTabs: _tvMediaTabs,
          customTabBuilder: buildTvCustomTabView,
        );
}

class TvLibraryMediaEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const TvLibraryMediaEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Watch tracking',
          entryDigitalTrackingSectionTitle: 'EntryPolicy details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _tvMediaTabs,
          trackedTabs: _tvMediaTabs,
          catalogTabs: _tvMediaTabs,
          customTabBuilder: buildTvCustomTabView,
        );
}

const tvLibraryEditPresentation = LibraryEditPresentation(
  builder: TvLibraryEditPresentationBuilder(),
  catalogItemBuilder: TvLibraryMediaEditPresentationBuilder(),
);
