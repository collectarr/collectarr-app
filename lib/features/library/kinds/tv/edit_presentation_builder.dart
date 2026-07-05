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
            LibraryEditTabSpec(id: 'media', icon: Icons.tv, label: 'Main'),
            LibraryEditTabSpec(
              id: 'release_media',
              icon: Icons.album_outlined,
              label: 'Edition Details',
            ),
            LibraryEditTabSpec(
              id: 'episode_map',
              icon: Icons.route_outlined,
              label: 'Disc / episode nesting',
            ),
            LibraryEditTabSpec(id: 'personal', icon: Icons.person, label: 'Personal'),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'User Defined',
            ),
            LibraryEditTabSpec(id: 'cover', icon: Icons.camera_alt, label: 'Covers'),
            LibraryEditTabSpec(id: 'photos', icon: Icons.image, label: 'Images'),
            LibraryEditTabSpec(
              id: 'synopsis',
              icon: Icons.description_outlined,
              label: 'Plot',
            ),
            LibraryEditTabSpec(id: 'cast', icon: Icons.people, label: 'Cast'),
            LibraryEditTabSpec(id: 'crew', icon: Icons.people_outline, label: 'Crew'),
            LibraryEditTabSpec(id: 'links', icon: Icons.language, label: 'Links'),
          ],
          trackedTabs: const [
            LibraryEditTabSpec(id: 'media', icon: Icons.tv, label: 'Main'),
            LibraryEditTabSpec(
              id: 'release_media',
              icon: Icons.album_outlined,
              label: 'Edition Details',
            ),
            LibraryEditTabSpec(
              id: 'episode_map',
              icon: Icons.route_outlined,
              label: 'Disc / episode nesting',
            ),
            LibraryEditTabSpec(id: 'personal', icon: Icons.person, label: 'Personal'),
            LibraryEditTabSpec(id: 'cover', icon: Icons.camera_alt, label: 'Covers'),
            LibraryEditTabSpec(id: 'photos', icon: Icons.image, label: 'Images'),
            LibraryEditTabSpec(
              id: 'synopsis',
              icon: Icons.description_outlined,
              label: 'Plot',
            ),
            LibraryEditTabSpec(id: 'cast', icon: Icons.people, label: 'Cast'),
            LibraryEditTabSpec(id: 'crew', icon: Icons.people_outline, label: 'Crew'),
            LibraryEditTabSpec(id: 'links', icon: Icons.language, label: 'Links'),
          ],
          catalogTabs: const [
            LibraryEditTabSpec(id: 'media', icon: Icons.tv, label: 'Main'),
            LibraryEditTabSpec(
              id: 'release_media',
              icon: Icons.album_outlined,
              label: 'Edition Details',
            ),
            LibraryEditTabSpec(
              id: 'episode_map',
              icon: Icons.route_outlined,
              label: 'Disc / episode nesting',
            ),
            LibraryEditTabSpec(id: 'synopsis', icon: Icons.description_outlined, label: 'Plot'),
            LibraryEditTabSpec(id: 'cast', icon: Icons.people, label: 'Cast'),
            LibraryEditTabSpec(id: 'crew', icon: Icons.people_outline, label: 'Crew'),
            LibraryEditTabSpec(id: 'links', icon: Icons.language, label: 'Links'),
            LibraryEditTabSpec(id: 'cover', icon: Icons.camera_alt, label: 'Covers'),
          ],
        );

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    return switch (tabId) {
      'media' => ['catalog_snapshot'],
      'release_media' => ['release_details', 'video_specs'],
      'episode_map' => ['tv_episode_disc_map'],
      'cast' => ['cast_list'],
      'crew' => ['crew_list'],
      'personal' => ['tracking_personal', 'ownership_fields', 'owned_notes'],
      'custom' => ['custom_fields'],
      'cover' => ['cover_images'],
      'photos' => ['photos'],
      'synopsis' => ['synopsis'],
      'links' => ['external_links'],
      _ => const <String>[],
    };
  }
}

const tvLibraryEditPresentation = LibraryEditPresentation(
  builder: TvLibraryEditPresentationBuilder(),
);
