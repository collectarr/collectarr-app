import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

class VideoLibraryEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const VideoLibraryEditPresentationBuilder()
      : super(
          trackingSectionTitle: 'Watch tracking',
          ownershipReferenceTitle: 'Release / copy reference',
          ownedBundleLabel: 'Owned release bundle',
          ownedTabs: const [
            LibraryEditTabSpec(
              id: 'media',
              icon: Icons.movie,
              label: 'Main',
              sectionIds: ['catalog_snapshot'],
            ),
            LibraryEditTabSpec(
              id: 'edition',
              icon: Icons.info_outline,
              label: 'Edition',
              sectionIds: ['release_details', 'ownership_reference', 'box_set'],
            ),
            LibraryEditTabSpec(
              id: 'discs',
              icon: Icons.format_list_numbered,
              label: 'Episodes',
              sectionIds: ['episodes'],
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
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
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
              label: 'My Images',
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
            LibraryEditTabSpec(
              id: 'specs',
              icon: Icons.info_outline,
              label: 'Edition Specs',
              sectionIds: ['video_specs', 'hdr', 'audio_subtitles', 'features'],
            ),
          ],
          trackedTabs: const [
            LibraryEditTabSpec(
              id: 'media',
              icon: Icons.movie,
              label: 'Main',
              sectionIds: ['catalog_snapshot'],
            ),
            LibraryEditTabSpec(
              id: 'edition',
              icon: Icons.info_outline,
              label: 'Edition',
              sectionIds: ['release_details', 'ownership_reference', 'box_set'],
            ),
            LibraryEditTabSpec(
              id: 'discs',
              icon: Icons.format_list_numbered,
              label: 'Episodes',
              sectionIds: ['episodes'],
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
            LibraryEditTabSpec(
              id: 'cover',
              icon: Icons.camera_alt,
              label: 'Covers',
              sectionIds: ['cover_images'],
            ),
            LibraryEditTabSpec(
              id: 'photos',
              icon: Icons.image,
              label: 'My Images',
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
            LibraryEditTabSpec(
              id: 'specs',
              icon: Icons.info_outline,
              label: 'Edition Specs',
              sectionIds: ['video_specs', 'hdr', 'audio_subtitles', 'features'],
            ),
          ],
          catalogTabs: const [
            LibraryEditTabSpec(
              id: 'media',
              icon: Icons.movie,
              label: 'Main',
              sectionIds: ['catalog_snapshot'],
            ),
            LibraryEditTabSpec(
              id: 'edition',
              icon: Icons.info_outline,
              label: 'Edition',
              sectionIds: ['release_details', 'ownership_reference', 'box_set'],
            ),
            LibraryEditTabSpec(
              id: 'discs',
              icon: Icons.format_list_numbered,
              label: 'Episodes',
              sectionIds: ['episodes'],
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
            LibraryEditTabSpec(
              id: 'specs',
              icon: Icons.info_outline,
              label: 'Edition Specs',
              sectionIds: ['video_specs', 'hdr', 'audio_subtitles', 'features'],
            ),
          ],
        );
}

const videoLibraryEditPresentation = LibraryEditPresentation(
  builder: VideoLibraryEditPresentationBuilder(),
);
