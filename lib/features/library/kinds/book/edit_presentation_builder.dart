import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:flutter/material.dart';

class BookLibraryEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const BookLibraryEditPresentationBuilder()
      : super(
          ownedTabs: const [
            LibraryEditTabSpec(
                id: 'main', icon: Icons.menu_book, label: 'Media'),
            LibraryEditTabSpec(
                id: 'details', icon: Icons.info_outline, label: 'Release'),
            LibraryEditTabSpec(
                id: 'credits', icon: Icons.groups_2, label: 'Credits'),
            LibraryEditTabSpec(
                id: 'personal', icon: Icons.person_outline, label: 'Personal'),
            LibraryEditTabSpec(
                id: 'custom', icon: Icons.edit_note, label: 'Custom Fields'),
            LibraryEditTabSpec(
                id: 'read_history',
                icon: Icons.auto_stories_outlined,
                label: 'Tracking'),
            LibraryEditTabSpec(
                id: 'value', icon: Icons.attach_money, label: 'Value'),
            LibraryEditTabSpec(
                id: 'covers',
                icon: Icons.photo_camera_outlined,
                label: 'Covers'),
            LibraryEditTabSpec(
                id: 'photos', icon: Icons.image_outlined, label: 'My Images'),
            LibraryEditTabSpec(
                id: 'plot', icon: Icons.description_outlined, label: 'Plot'),
            LibraryEditTabSpec(id: 'links', icon: Icons.public, label: 'Links'),
          ],
          trackedTabs: const [
            LibraryEditTabSpec(
                id: 'main', icon: Icons.menu_book, label: 'Media'),
            LibraryEditTabSpec(
                id: 'details', icon: Icons.info_outline, label: 'Release'),
            LibraryEditTabSpec(
                id: 'credits', icon: Icons.groups_2, label: 'Credits'),
            LibraryEditTabSpec(
                id: 'personal', icon: Icons.person_outline, label: 'Personal'),
            LibraryEditTabSpec(
                id: 'custom', icon: Icons.edit_note, label: 'Custom Fields'),
            LibraryEditTabSpec(
                id: 'read_history',
                icon: Icons.auto_stories_outlined,
                label: 'Tracking'),
            LibraryEditTabSpec(
                id: 'covers',
                icon: Icons.photo_camera_outlined,
                label: 'Covers'),
            LibraryEditTabSpec(
                id: 'plot', icon: Icons.description_outlined, label: 'Plot'),
            LibraryEditTabSpec(id: 'links', icon: Icons.public, label: 'Links'),
          ],
          catalogTabs: const [
            LibraryEditTabSpec(
                id: 'main', icon: Icons.menu_book, label: 'Media'),
            LibraryEditTabSpec(
                id: 'details', icon: Icons.info_outline, label: 'Release'),
            LibraryEditTabSpec(
                id: 'credits', icon: Icons.groups_2, label: 'Credits'),
            LibraryEditTabSpec(
                id: 'custom', icon: Icons.edit_note, label: 'Custom Fields'),
            LibraryEditTabSpec(
                id: 'covers',
                icon: Icons.photo_camera_outlined,
                label: 'Covers'),
            LibraryEditTabSpec(
                id: 'plot', icon: Icons.description_outlined, label: 'Plot'),
            LibraryEditTabSpec(id: 'links', icon: Icons.public, label: 'Links'),
          ],
        );

  @override
  List<LibraryEditTabSpec> buildTabs({
    required LibraryEditPresentationContext context,
  }) {
    final tabs = super.buildTabs(context: context);
    if (context.scope == LibraryEditScope.media) {
      const allowed = {
        'main',
        'credits',
        'custom',
        'covers',
        'plot',
        'links',
      };
      return tabs
          .where((tab) => allowed.contains(tab.id))
          .toList(growable: false);
    }
    if (context.scope == LibraryEditScope.release) {
      const allowed = {
        'details',
        'personal',
        'custom',
        'read_history',
        'value',
        'photos',
      };
      return tabs
          .where((tab) => allowed.contains(tab.id))
          .toList(growable: false);
    }
    return tabs;
  }

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    if (context.scope == LibraryEditScope.media) {
      final sections = switch (tabId) {
        'main' => ['book_details'],
        'credits' => ['book_credits'],
        'plot' => ['book_plot'],
        'covers' => ['book_cover_sources'],
        'links' => ['book_identifiers_links'],
        'custom' => ['book_custom_fields'],
        _ => const <String>[],
      };
      return List<String>.unmodifiable(sections);
    }
    if (context.scope == LibraryEditScope.release) {
      final sections = switch (tabId) {
        'details' => ['book_contents'],
        'read_history' => ['book_read_history'],
        'value' => ['book_value'],
        'personal' => [
            'book_personal_tracking',
            if (context.hasWishlistContext) 'book_wishlist_reference',
            if (context.isOwned)
              'book_collection_notes'
            else if (!context.hasWishlistContext)
              'book_collection_fields_info',
          ],
        'custom' => ['book_custom_fields'],
        'photos' => ['book_photos'],
        _ => const <String>[],
      };
      return List<String>.unmodifiable(sections);
    }
    final sections = switch (tabId) {
      'main' => ['book_details'],
      'details' => ['book_contents'],
      'credits' => ['book_credits'],
      'plot' => ['book_plot', if (context.isOwned) 'book_notes'],
      'covers' => ['book_cover_sources'],
      'links' => ['book_identifiers_links'],
      'custom' => ['book_custom_fields'],
      'read_history' => ['book_read_history'],
      'value' => ['book_value'],
      'personal' => [
          'book_personal_tracking',
          if (context.hasWishlistContext) 'book_wishlist_reference',
          if (context.isOwned)
            'book_collection_notes'
          else if (!context.hasWishlistContext)
            'book_collection_fields_info',
        ],
      'photos' => ['book_photos'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }

  @override
  LibraryEditFooterSpec buildFooter({
    required LibraryEditPresentationContext context,
  }) {
    return LibraryEditFooterSpec(
      fieldIds: [
        'book_title',
        'book_volume',
        'title_sort',
        'series_tags',
        if (context.isOwned) 'user_tags',
      ],
    );
  }
}
