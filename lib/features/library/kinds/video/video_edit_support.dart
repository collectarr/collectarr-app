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
                id: 'media', icon: Icons.movie, label: 'Main'),
            LibraryEditTabSpec(
                id: 'edition', icon: Icons.info_outline, label: 'Edition'),
            LibraryEditTabSpec(
                id: 'discs', icon: Icons.format_list_numbered, label: 'Episodes'),
            LibraryEditTabSpec(
                id: 'personal', icon: Icons.person, label: 'Personal'),
            LibraryEditTabSpec(
                id: 'custom', icon: Icons.edit_note, label: 'Custom Fields'),
            LibraryEditTabSpec(
                id: 'cover', icon: Icons.camera_alt, label: 'Covers'),
            LibraryEditTabSpec(
                id: 'photos', icon: Icons.image, label: 'My Images'),
            LibraryEditTabSpec(
                id: 'synopsis', icon: Icons.description_outlined, label: 'Plot'),
            LibraryEditTabSpec(
                id: 'cast', icon: Icons.people, label: 'Cast'),
            LibraryEditTabSpec(
                id: 'crew', icon: Icons.people_outline, label: 'Crew'),
            LibraryEditTabSpec(
                id: 'links', icon: Icons.language, label: 'Links'),
            LibraryEditTabSpec(
                id: 'specs', icon: Icons.info_outline, label: 'Edition Specs'),
          ],
          trackedTabs: const [
            LibraryEditTabSpec(
                id: 'media', icon: Icons.movie, label: 'Main'),
            LibraryEditTabSpec(
                id: 'edition', icon: Icons.info_outline, label: 'Edition'),
            LibraryEditTabSpec(
                id: 'discs', icon: Icons.format_list_numbered, label: 'Episodes'),
            LibraryEditTabSpec(
                id: 'personal', icon: Icons.person, label: 'Personal'),
            LibraryEditTabSpec(
                id: 'cover', icon: Icons.camera_alt, label: 'Covers'),
            LibraryEditTabSpec(
                id: 'photos', icon: Icons.image, label: 'My Images'),
            LibraryEditTabSpec(
                id: 'synopsis', icon: Icons.description_outlined, label: 'Plot'),
            LibraryEditTabSpec(
                id: 'cast', icon: Icons.people, label: 'Cast'),
            LibraryEditTabSpec(
                id: 'crew', icon: Icons.people_outline, label: 'Crew'),
            LibraryEditTabSpec(
                id: 'links', icon: Icons.language, label: 'Links'),
            LibraryEditTabSpec(
                id: 'specs', icon: Icons.info_outline, label: 'Edition Specs'),
          ],
          catalogTabs: const [
            LibraryEditTabSpec(
                id: 'media', icon: Icons.movie, label: 'Main'),
            LibraryEditTabSpec(
                id: 'edition', icon: Icons.info_outline, label: 'Edition'),
            LibraryEditTabSpec(
                id: 'discs', icon: Icons.format_list_numbered, label: 'Episodes'),
            LibraryEditTabSpec(
                id: 'synopsis', icon: Icons.description_outlined, label: 'Plot'),
            LibraryEditTabSpec(
                id: 'cast', icon: Icons.people, label: 'Cast'),
            LibraryEditTabSpec(
                id: 'crew', icon: Icons.people_outline, label: 'Crew'),
            LibraryEditTabSpec(
                id: 'links', icon: Icons.language, label: 'Links'),
            LibraryEditTabSpec(
                id: 'cover', icon: Icons.camera_alt, label: 'Covers'),
            LibraryEditTabSpec(
                id: 'specs', icon: Icons.info_outline, label: 'Edition Specs'),
          ],
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
      'main' => [
        'tracking_context',
        'ownership_reference',
        'owned_grading',
      ],
      'value' => ['purchase', 'value_summary'],
      'personal' => [
        'tracking_personal',
        'ownership_fields',
        'purchase_fields',
        'sold_fields',
        'wishlist_reference',
        'owned_notes',
        'collection_fields_info',
      ],
      'sold' => ['sold_status', 'profit_loss'],
      'custom' => ['custom_fields'],
      'photos' => ['photos'],
      'cover' => ['cover_images'],
      'synopsis' => ['synopsis'],
      'discs' => ['episodes'],
      'links' => ['external_links'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
}

const videoLibraryEditPresentation = LibraryEditPresentation(
  builder: VideoLibraryEditPresentationBuilder(),
);
