import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

const _musicMediaTabs = [
  LibraryEditTabSpec(id: 'main', icon: Icons.music_note_outlined, label: 'Main'),
  LibraryEditTabSpec(id: 'details', icon: Icons.info_outline, label: 'Details'),
  LibraryEditTabSpec(
    id: 'classical',
    icon: Icons.piano_outlined,
    label: 'Classical',
  ),
  LibraryEditTabSpec(
    id: 'people',
    icon: Icons.groups_2_outlined,
    label: 'People',
  ),
  LibraryEditTabSpec(
    id: 'tracks',
    icon: Icons.format_list_numbered_outlined,
    label: 'Tracks',
  ),
  LibraryEditTabSpec(
    id: 'covers',
    icon: Icons.camera_alt_outlined,
    label: 'Covers',
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image_outlined,
    label: 'My Images',
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.language_outlined,
    label: 'Links',
  ),
];

const _musicReleaseTabs = [
  LibraryEditTabSpec(id: 'main', icon: Icons.music_note_outlined, label: 'Main'),
  LibraryEditTabSpec(id: 'details', icon: Icons.info_outline, label: 'Details'),
  LibraryEditTabSpec(id: 'personal', icon: Icons.person_outline, label: 'Personal'),
  LibraryEditTabSpec(
    id: 'custom',
    icon: Icons.edit_note_outlined,
    label: 'Custom Fields',
  ),
  LibraryEditTabSpec(
    id: 'covers',
    icon: Icons.camera_alt_outlined,
    label: 'Covers',
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image_outlined,
    label: 'My Images',
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.language_outlined,
    label: 'Links',
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

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'main' => ['music_release_identity', 'music_identifiers_release', 'music_genres'],
      'details' => ['music_format_audio_details', 'music_album_notes'],
      'classical' => [
          'music_classical_metadata',
          'music_composer',
          'music_conductor',
          'music_orchestra',
          'music_chorus',
        ],
      'tracks' => ['music_track_listing'],
      'people' => [
          'music_primary_artist',
          'music_songwriter',
          'music_producer',
          'music_engineer',
          'music_musician',
        ],
      'covers' => ['music_remote_cover_assets'],
      'photos' => ['music_local_images'],
      'links' => ['music_metadata_source_notes', 'music_identifiers'],
      'personal' => [
          'music_collection_or_tracking',
          if (context.hasWishlistContext) 'music_wishlist_reference',
          if (context.isOwned) 'music_purchase_value',
          if (context.isOwned) 'music_profit_loss',
          if (context.isOwned) 'music_personal_notes',
        ],
      'custom' => ['music_custom_fields'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
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
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'main' => ['music_release_identity', 'music_identifiers_release', 'music_genres'],
      'details' => ['music_format_audio_details', 'music_album_notes'],
      'personal' => [
          'music_collection_or_tracking',
          if (context.hasWishlistContext) 'music_wishlist_reference',
          if (context.isOwned) 'music_purchase_value',
          if (context.isOwned) 'music_profit_loss',
          if (context.isOwned) 'music_personal_notes',
        ],
      'custom' => ['music_custom_fields'],
      'covers' => ['music_remote_cover_assets'],
      'photos' => ['music_local_images'],
      'links' => ['music_metadata_source_notes', 'music_identifiers'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }

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

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'main' => ['music_release_identity', 'music_identifiers_release', 'music_genres'],
      'details' => ['music_format_audio_details', 'music_album_notes'],
      'classical' => [
          'music_classical_metadata',
          'music_composer',
          'music_conductor',
          'music_orchestra',
          'music_chorus',
        ],
      'tracks' => ['music_track_listing'],
      'people' => [
          'music_primary_artist',
          'music_songwriter',
          'music_producer',
          'music_engineer',
          'music_musician',
        ],
      'covers' => ['music_remote_cover_assets'],
      'photos' => ['music_local_images'],
      'links' => ['music_metadata_source_notes', 'music_identifiers'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
}

const musicLibraryEditPresentation = LibraryEditPresentation(
  builder: MusicLibraryCombinedEditPresentationBuilder(),
  mediaBuilder: MusicLibraryMediaEditPresentationBuilder(),
  releaseBuilder: MusicLibraryReleaseEditPresentationBuilder(),
);
