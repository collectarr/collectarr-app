import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/edit/default_kind_edit_dialog.dart';
import 'package:flutter/material.dart';

const _movieMediaTabs = [
  LibraryEditTabSpec(id: 'media', icon: Icons.movie, label: 'Media'),
  LibraryEditTabSpec(id: 'synopsis', icon: Icons.description_outlined, label: 'Plot'),
  LibraryEditTabSpec(id: 'cast', icon: Icons.people, label: 'Cast'),
  LibraryEditTabSpec(id: 'crew', icon: Icons.people_outline, label: 'Crew'),
  LibraryEditTabSpec(
    id: 'read_history',
    icon: Icons.auto_stories_outlined,
    label: 'Tracking',
  ),
  LibraryEditTabSpec(id: 'links', icon: Icons.language, label: 'Links'),
  LibraryEditTabSpec(id: 'cover', icon: Icons.camera_alt, label: 'Covers'),
  LibraryEditTabSpec(id: 'photos', icon: Icons.image, label: 'Images'),
];

const _movieReleaseTabs = [
  LibraryEditTabSpec(
    id: 'edition',
    icon: Icons.info_outline,
    label: 'Edition Details',
  ),
  LibraryEditTabSpec(id: 'personal', icon: Icons.person, label: 'Personal'),
  LibraryEditTabSpec(
    id: 'read_history',
    icon: Icons.auto_stories_outlined,
    label: 'Tracking',
  ),
  LibraryEditTabSpec(id: 'custom', icon: Icons.edit_note, label: 'User Defined'),
  LibraryEditTabSpec(id: 'specs', icon: Icons.info_outline, label: 'Edition Details'),
  LibraryEditTabSpec(id: 'cover', icon: Icons.camera_alt, label: 'Covers'),
  LibraryEditTabSpec(id: 'photos', icon: Icons.image, label: 'Images'),
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

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'media' => ['catalog_snapshot'],
      'edition' => ['release_details', 'ownership_reference', 'box_set'],
      'specs' => ['video_specs', 'hdr', 'audio_subtitles', 'features'],
      'cast' => ['cast_list'],
      'crew' => ['crew_list'],
      'read_history' => ['tracking_context', 'tracking_personal'],
      'cover' => ['cover_images'],
      'synopsis' => ['synopsis'],
      'links' => ['external_links'],
      'personal' => [
          'ownership_fields',
          'purchase_fields',
          'sold_fields',
          'wishlist_reference',
          'owned_notes',
          'collection_fields_info',
          'ownership_reference',
          'owned_grading',
        ],
      'custom' => ['custom_fields'],
      'photos' => ['photos'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
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

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'media' => ['catalog_snapshot'],
      'cast' => ['cast_list'],
      'crew' => ['crew_list'],
      'read_history' => ['tracking_context', 'tracking_personal'],
      'cover' => ['cover_images'],
      'synopsis' => ['synopsis'],
      'links' => ['external_links'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
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

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'edition' => ['release_details', 'ownership_reference', 'box_set'],
      'read_history' => ['tracking_context', 'tracking_personal'],
      'personal' => [
          'ownership_fields',
          'purchase_fields',
          'sold_fields',
          'wishlist_reference',
          'owned_notes',
          'collection_fields_info',
          'ownership_reference',
          'owned_grading',
        ],
      'custom' => ['custom_fields'],
      'specs' => ['video_specs', 'hdr', 'audio_subtitles', 'features'],
      'cover' => ['cover_images'],
      'photos' => ['photos'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
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
