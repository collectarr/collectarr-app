import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

class TvLibraryEditPresentationBuilder extends DefaultLibraryEditPresentationBuilder {
  const TvLibraryEditPresentationBuilder()
      : super(
          trackingSectionTitle: 'Watch tracking',
          ownershipReferenceTitle: 'Release / copy reference',
          ownedBundleLabel: 'Owned release bundle',
          ownedTabs: const [
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
              id: 'custom',
              icon: Icons.edit_note,
              label: 'User Defined',
              sectionIds: ['custom_fields'],
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
          ],
          trackedTabs: const [
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
          ],
          catalogTabs: const [
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
            LibraryEditTabSpec(
              id: 'cover',
              icon: Icons.camera_alt,
              label: 'Covers',
              sectionIds: ['cover_images'],
            ),
          ],
        );
}

const tvLibraryEditPresentation = LibraryEditPresentation(
  builder: TvLibraryEditPresentationBuilder(),
);
