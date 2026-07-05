import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/edit/default_kind_edit_dialog.dart';
import 'package:flutter/material.dart';

const _movieMediaTabs = [
  LibraryEditTabSpec(
    id: 'media',
    icon: Icons.movie,
    label: 'Media',
    sectionIds: ['catalog_snapshot'],
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
    id: 'read_history',
    icon: Icons.auto_stories_outlined,
    label: 'Tracking',
    sectionIds: ['tracking_context', 'tracking_personal'],
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
    id: 'photos',
    icon: Icons.image,
    label: 'Images',
    sectionIds: ['photos'],
  ),
];

const _movieReleaseTabs = [
  LibraryEditTabSpec(
    id: 'edition',
    icon: Icons.info_outline,
    label: 'Edition Details',
    sectionIds: ['release_details', 'ownership_reference', 'box_set'],
  ),
  LibraryEditTabSpec(
    id: 'personal',
    icon: Icons.person,
    label: 'Personal',
    sectionIds: [
      'ownership_fields',
      'purchase_fields',
      'sold_fields',
      'wishlist_reference',
      'owned_notes',
      'collection_fields_info',
      'ownership_reference',
      'owned_grading',
    ],
  ),
  LibraryEditTabSpec(
    id: 'read_history',
    icon: Icons.auto_stories_outlined,
    label: 'Tracking',
    sectionIds: ['tracking_context', 'tracking_personal'],
  ),
  LibraryEditTabSpec(
    id: 'custom',
    icon: Icons.edit_note,
    label: 'User Defined',
    sectionIds: ['custom_fields'],
  ),
  LibraryEditTabSpec(
    id: 'specs',
    icon: Icons.info_outline,
    label: 'Edition Details',
    sectionIds: ['video_specs', 'hdr', 'audio_subtitles', 'features'],
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
];

const _movieCombinedTabs = [
  ..._movieMediaTabs,
  ..._movieReleaseTabs,
];

class MovieLibraryCombinedEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const MovieLibraryCombinedEditPresentationBuilder()
      : super(
          trackingSectionTitle: 'Watch tracking',
          ownershipReferenceTitle: 'Release / copy reference',
          ownedBundleLabel: 'Owned release bundle',
          ownedTabs: _movieCombinedTabs,
          trackedTabs: _movieCombinedTabs,
          catalogTabs: _movieCombinedTabs,
        );
}

class MovieLibraryMediaEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const MovieLibraryMediaEditPresentationBuilder()
      : super(
          trackingSectionTitle: 'Watch tracking',
          ownershipReferenceTitle: 'Release / copy reference',
          ownedBundleLabel: 'Owned release bundle',
          ownedTabs: _movieMediaTabs,
          trackedTabs: _movieMediaTabs,
          catalogTabs: _movieMediaTabs,
        );
}

class MovieLibraryReleaseEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const MovieLibraryReleaseEditPresentationBuilder()
      : super(
          trackingSectionTitle: 'Watch tracking',
          ownershipReferenceTitle: 'Release / copy reference',
          ownedBundleLabel: 'Owned release bundle',
          ownedTabs: _movieReleaseTabs,
          trackedTabs: _movieReleaseTabs,
          catalogTabs: _movieReleaseTabs,
        );
}

const movieLibraryEditPresentation = LibraryEditPresentation(
  builder: MovieLibraryCombinedEditPresentationBuilder(),
  mediaBuilder: MovieLibraryMediaEditPresentationBuilder(),
  releaseBuilder: MovieLibraryReleaseEditPresentationBuilder(),
);

class MovieLibraryEditDialog extends StatelessWidget {
  const MovieLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  Widget build(BuildContext context) {
    return buildDefaultKindEditDialog(request: request);
  }
}

Widget buildMovieLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return MovieLibraryEditDialog(request: request);
}
