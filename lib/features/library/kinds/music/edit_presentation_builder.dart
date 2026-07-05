import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

List<String> _musicPersonalSections(
  LibraryEditPresentationContext context,
) {
  return [
    'music_collection_or_tracking',
    if (context.hasWishlistContext) 'music_wishlist_reference',
    if (context.isOwned) 'music_purchase_value',
    if (context.isOwned) 'music_profit_loss',
    if (context.isOwned) 'music_personal_notes',
  ];
}

const _musicMediaTabs = [
  LibraryEditTabSpec(
    id: 'main',
    icon: Icons.music_note_outlined,
    label: 'Main',
    sectionIds: ['music_release_identity', 'music_identifiers_release', 'music_genres'],
  ),
  LibraryEditTabSpec(
    id: 'details',
    icon: Icons.info_outline,
    label: 'Details',
    sectionIds: ['music_format_audio_details', 'music_album_notes'],
  ),
  LibraryEditTabSpec(
    id: 'classical',
    icon: Icons.piano_outlined,
    label: 'Classical',
    sectionIds: [
      'music_classical_metadata',
      'music_composer',
      'music_conductor',
      'music_orchestra',
      'music_chorus',
    ],
  ),
  LibraryEditTabSpec(
    id: 'people',
    icon: Icons.groups_2_outlined,
    label: 'People',
    sectionIds: [
      'music_primary_artist',
      'music_songwriter',
      'music_producer',
      'music_engineer',
      'music_musician',
    ],
  ),
  LibraryEditTabSpec(
    id: 'tracks',
    icon: Icons.format_list_numbered_outlined,
    label: 'Tracks',
    sectionIds: ['music_track_listing'],
  ),
  LibraryEditTabSpec(
    id: 'covers',
    icon: Icons.camera_alt_outlined,
    label: 'Covers',
    sectionIds: ['music_remote_cover_assets'],
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image_outlined,
    label: 'My Images',
    sectionIds: ['music_local_images'],
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.language_outlined,
    label: 'Links',
    sectionIds: ['music_metadata_source_notes', 'music_identifiers'],
  ),
];

const _musicReleaseTabs = [
  LibraryEditTabSpec(
    id: 'main',
    icon: Icons.music_note_outlined,
    label: 'Main',
    sectionIds: ['music_release_identity', 'music_identifiers_release', 'music_genres'],
  ),
  LibraryEditTabSpec(
    id: 'details',
    icon: Icons.info_outline,
    label: 'Details',
    sectionIds: ['music_format_audio_details', 'music_album_notes'],
  ),
  LibraryEditTabSpec(
    id: 'personal',
    icon: Icons.person_outline,
    label: 'Personal',
    sectionIdsForContext: _musicPersonalSections,
  ),
  LibraryEditTabSpec(
    id: 'custom',
    icon: Icons.edit_note_outlined,
    label: 'Custom Fields',
    sectionIds: ['music_custom_fields'],
  ),
  LibraryEditTabSpec(
    id: 'covers',
    icon: Icons.camera_alt_outlined,
    label: 'Covers',
    sectionIds: ['music_remote_cover_assets'],
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image_outlined,
    label: 'My Images',
    sectionIds: ['music_local_images'],
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.language_outlined,
    label: 'Links',
    sectionIds: ['music_metadata_source_notes', 'music_identifiers'],
  ),
];

const _musicCombinedTabs = [
  ..._musicMediaTabs,
  ..._musicReleaseTabs,
];

class MusicLibraryCombinedEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const MusicLibraryCombinedEditPresentationBuilder()
      : super(
          ownedTabs: _musicCombinedTabs,
          trackedTabs: _musicCombinedTabs,
          catalogTabs: _musicCombinedTabs,
        );
}

class MusicLibraryReleaseEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const MusicLibraryReleaseEditPresentationBuilder()
      : super(
          ownedTabs: _musicReleaseTabs,
          trackedTabs: _musicReleaseTabs,
          catalogTabs: _musicReleaseTabs,
        );

  @override
  LibraryEditFooterSpec buildFooter({
    required LibraryEditPresentationContext context,
  }) {
    return LibraryEditFooterSpec(
      label: context.isOwned
          ? 'Music catalog + collection'
          : context.isTrackingOnly
              ? 'Music catalog + tracking'
              : 'Music catalog snapshot',
      fieldIds: [
        'title_sort',
        if (context.isOwned) 'user_tags',
      ],
    );
  }
}

class MusicLibraryMediaEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const MusicLibraryMediaEditPresentationBuilder()
      : super(
          ownedTabs: _musicMediaTabs,
          trackedTabs: _musicMediaTabs,
          catalogTabs: _musicMediaTabs,
        );
}

const musicLibraryEditPresentation = LibraryEditPresentation(
  builder: MusicLibraryCombinedEditPresentationBuilder(),
  mediaBuilder: MusicLibraryMediaEditPresentationBuilder(),
  releaseBuilder: MusicLibraryReleaseEditPresentationBuilder(),
);
