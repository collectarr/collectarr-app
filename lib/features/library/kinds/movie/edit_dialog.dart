import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_custom_tab_builder.dart';
import 'package:flutter/material.dart';

const _movieCatalogItemTabs = [
  LibraryEditTabSpec(
    id: 'catalog_item',
    icon: Icons.movie,
    label: 'Catalog Item',
    sectionIds: ['catalog_snapshot'],
  ),
  LibraryEditTabSpec(
    id: 'edition',
    icon: Icons.info_outline,
    label: 'Edition details',
    sectionIds: ['edition_details'],
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
    icon: Icons.public,
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

const _movieCollectionItemTabs = [
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

class MovieLibraryCatalogItemEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const MovieLibraryCatalogItemEditPresentationBuilder()
      : super(
          useOwnedMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Watch tracking',
          ownedDigitalTrackingSectionTitle: 'Ownership details',
          ownedDigitalTrackingHint:
              'Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.',
          ownedTabs: _movieCatalogItemTabs,
          trackedTabs: _movieCatalogItemTabs,
          catalogTabs: _movieCatalogItemTabs,
          customTabBuilder: buildMovieCustomTabView,
        );
}

class MovieLibraryCollectionItemEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const MovieLibraryCollectionItemEditPresentationBuilder()
      : super(
          useOwnedMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Watch tracking',
          ownedDigitalTrackingSectionTitle: 'Ownership details',
          ownedDigitalTrackingHint:
              'Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.',
          ownedTabs: _movieCollectionItemTabs,
          trackedTabs: _movieCollectionItemTabs,
          catalogTabs: _movieCollectionItemTabs,
          customTabBuilder: buildMovieCustomTabView,
        );
}

const movieLibraryEditPresentation = LibraryEditPresentation(
  builder: MovieLibraryCatalogItemEditPresentationBuilder(),
  copyBuilder: MovieLibraryCollectionItemEditPresentationBuilder(),
);

class MovieLibraryEditDialog extends StatelessWidget {
  const MovieLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  Widget build(BuildContext context) {
    return LibraryEditRenderer.fromDraft(
      draft: LibraryEditShellState.fromRequest(request),
      onPrevious: request.onPrevious,
      onNext: request.onNext,
      scope: request.resolvedScope,
    );
  }
}

Widget buildMovieLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return MovieLibraryEditDialog(request: request);
}
