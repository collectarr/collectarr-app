import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

class MusicLibraryEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const MusicLibraryEditPresentationBuilder()
      : super(
          ownedTabs: const [
            LibraryEditTabSpec(id: 'main', icon: Icons.album_outlined, label: 'Main'),
            LibraryEditTabSpec(id: 'classical', icon: Icons.piano_outlined, label: 'Classical'),
            LibraryEditTabSpec(id: 'tracks', icon: Icons.queue_music_outlined, label: 'Tracks'),
            LibraryEditTabSpec(id: 'details_personal', icon: Icons.library_music_outlined, label: 'Details / Personal'),
            LibraryEditTabSpec(id: 'people', icon: Icons.groups_2_outlined, label: 'People'),
            LibraryEditTabSpec(id: 'covers', icon: Icons.image_outlined, label: 'Covers'),
            LibraryEditTabSpec(id: 'notes', icon: Icons.notes_outlined, label: 'Notes'),
            LibraryEditTabSpec(id: 'links', icon: Icons.link_outlined, label: 'Links'),
          ],
          trackedTabs: const [
            LibraryEditTabSpec(id: 'main', icon: Icons.album_outlined, label: 'Main'),
            LibraryEditTabSpec(id: 'classical', icon: Icons.piano_outlined, label: 'Classical'),
            LibraryEditTabSpec(id: 'tracks', icon: Icons.queue_music_outlined, label: 'Tracks'),
            LibraryEditTabSpec(id: 'details_personal', icon: Icons.library_music_outlined, label: 'Details / Personal'),
            LibraryEditTabSpec(id: 'people', icon: Icons.groups_2_outlined, label: 'People'),
            LibraryEditTabSpec(id: 'covers', icon: Icons.image_outlined, label: 'Covers'),
            LibraryEditTabSpec(id: 'notes', icon: Icons.notes_outlined, label: 'Notes'),
            LibraryEditTabSpec(id: 'links', icon: Icons.link_outlined, label: 'Links'),
          ],
          catalogTabs: const [
            LibraryEditTabSpec(id: 'main', icon: Icons.album_outlined, label: 'Main'),
            LibraryEditTabSpec(id: 'classical', icon: Icons.piano_outlined, label: 'Classical'),
            LibraryEditTabSpec(id: 'tracks', icon: Icons.queue_music_outlined, label: 'Tracks'),
            LibraryEditTabSpec(id: 'details_personal', icon: Icons.library_music_outlined, label: 'Details / Personal'),
            LibraryEditTabSpec(id: 'people', icon: Icons.groups_2_outlined, label: 'People'),
            LibraryEditTabSpec(id: 'covers', icon: Icons.image_outlined, label: 'Covers'),
            LibraryEditTabSpec(id: 'notes', icon: Icons.notes_outlined, label: 'Notes'),
            LibraryEditTabSpec(id: 'links', icon: Icons.link_outlined, label: 'Links'),
          ],
        );

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'main' => ['music_release_identity', 'music_identifiers_release', 'music_genres'],
      'classical' => ['music_classical_metadata', 'music_composer', 'music_conductor', 'music_orchestra', 'music_chorus'],
      'tracks' => ['music_track_listing'],
      'details_personal' => [
          'music_collection_or_tracking',
          if (context.hasWishlistContext) 'music_wishlist_reference',
          if (context.isOwned) 'music_purchase_value',
          if (context.isOwned) 'music_profit_loss',
          if (context.hasCustomFields) 'music_custom_fields',
        ],
      'people' => ['music_primary_artist', 'music_credits'],
      'covers' => ['music_remote_cover_assets', 'music_local_images'],
      'notes' => [
          'music_album_notes',
          if (context.isOwned) 'music_personal_notes',
        ],
      'links' => ['music_identifiers', 'music_metadata_source_notes'],
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