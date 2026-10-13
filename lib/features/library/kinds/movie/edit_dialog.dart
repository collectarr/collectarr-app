import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_custom_tab_builder.dart';
import 'package:flutter/material.dart';

const _movieCatalogItemTabs = [
  LibraryEditTabSpec(
    id: 'catalog_item',
    icon: Icons.movie,
    label: 'Main',
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
    id: 'specs',
    icon: Icons.tune_outlined,
    label: 'Specs',
    sectionIds: ['video_specs', 'hdr', 'audio_subtitles', 'features'],
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
];

const _movieLibraryEntryTabs = [
  ..._movieCatalogItemTabs,
];

class MovieLibraryCatalogItemEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const MovieLibraryCatalogItemEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Watch tracking',
          entryDigitalTrackingSectionTitle: 'Digital Entry Details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _movieCatalogItemTabs,
          trackedTabs: _movieCatalogItemTabs,
          catalogTabs: _movieCatalogItemTabs,
          customTabBuilder: buildMovieCustomTabView,
        );
}

class MovieLibraryEntryEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const MovieLibraryEntryEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Watch tracking',
          entryDigitalTrackingSectionTitle: 'Digital Entry Details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: _movieLibraryEntryTabs,
          trackedTabs: _movieLibraryEntryTabs,
          catalogTabs: _movieLibraryEntryTabs,
          customTabBuilder: buildMovieCustomTabView,
        );
}

const movieLibraryEditPresentation = LibraryEditPresentation(
  builder: MovieLibraryCatalogItemEditPresentationBuilder(),
  entryBuilder: MovieLibraryEntryEditPresentationBuilder(),
  sharedTabs: [
    LibraryEditTabContribution(
      tab: LibraryEditTabSpec(
        id: 'photos',
        icon: Icons.image,
        label: 'Images',
        sectionIds: ['photos'],
      ),
      afterTabId: 'cover',
    ),
    LibraryEditTabContribution(
      tab: LibraryEditTabSpec(
        id: 'personal',
        icon: Icons.person,
        label: 'Personal',
        sectionIds: [
          'entries_fields',
          'purchase_fields',
          'sold_fields',
          'wishlist_reference',
          'entry_notes',
          'collection_fields_info',
          'entries_reference',
          'entry_grading',
        ],
      ),
      scope: LibraryEditTabTargetScope.libraryEntry,
      afterTabId: 'photos',
    ),
    LibraryEditTabContribution(
      tab: LibraryEditTabSpec(
        id: 'custom',
        icon: Icons.edit_note,
        label: 'User Defined',
        sectionIds: ['custom_fields'],
      ),
      scope: LibraryEditTabTargetScope.libraryEntry,
      afterTabId: 'personal',
    ),
  ],
);

class MovieLibraryEditDialog extends StatelessWidget {
  const MovieLibraryEditDialog({super.key, required this.request});

  final LibraryEditDialogRequest request;

  @override
  Widget build(BuildContext context) {
    return LibraryEditRenderer.fromRequest(request: request);
  }
}

Widget buildMovieLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return MovieLibraryEditDialog(request: request);
}
