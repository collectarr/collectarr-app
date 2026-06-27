import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

class BookLibraryMediaEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const BookLibraryMediaEditPresentationBuilder()
      : super(
          ownedTabs: const [
            LibraryEditTabSpec(
              id: 'main',
              icon: Icons.menu_book,
              label: 'Media',
            ),
            LibraryEditTabSpec(
              id: 'credits',
              icon: Icons.groups_2,
              label: 'Credits',
            ),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
            ),
            LibraryEditTabSpec(
              id: 'read_history',
              icon: Icons.auto_stories_outlined,
              label: 'Tracking',
            ),
            LibraryEditTabSpec(
              id: 'covers',
              icon: Icons.photo_camera_outlined,
              label: 'Covers',
            ),
            LibraryEditTabSpec(
              id: 'plot',
              icon: Icons.description_outlined,
              label: 'Plot',
            ),
            LibraryEditTabSpec(
              id: 'links',
              icon: Icons.public,
              label: 'Links',
            ),
          ],
          trackedTabs: const [
            LibraryEditTabSpec(
              id: 'main',
              icon: Icons.menu_book,
              label: 'Media',
            ),
            LibraryEditTabSpec(
              id: 'credits',
              icon: Icons.groups_2,
              label: 'Credits',
            ),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
            ),
            LibraryEditTabSpec(
              id: 'read_history',
              icon: Icons.auto_stories_outlined,
              label: 'Tracking',
            ),
            LibraryEditTabSpec(
              id: 'covers',
              icon: Icons.photo_camera_outlined,
              label: 'Covers',
            ),
            LibraryEditTabSpec(
              id: 'plot',
              icon: Icons.description_outlined,
              label: 'Plot',
            ),
            LibraryEditTabSpec(
              id: 'links',
              icon: Icons.public,
              label: 'Links',
            ),
          ],
          catalogTabs: const [
            LibraryEditTabSpec(
              id: 'main',
              icon: Icons.menu_book,
              label: 'Media',
            ),
            LibraryEditTabSpec(
              id: 'credits',
              icon: Icons.groups_2,
              label: 'Credits',
            ),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
            ),
            LibraryEditTabSpec(
              id: 'read_history',
              icon: Icons.auto_stories_outlined,
              label: 'Tracking',
            ),
            LibraryEditTabSpec(
              id: 'covers',
              icon: Icons.photo_camera_outlined,
              label: 'Covers',
            ),
            LibraryEditTabSpec(
              id: 'plot',
              icon: Icons.description_outlined,
              label: 'Plot',
            ),
            LibraryEditTabSpec(
              id: 'links',
              icon: Icons.public,
              label: 'Links',
            ),
          ],
        );

  @override
  List<LibraryEditTabSpec> buildTabs({
    required LibraryEditPresentationContext context,
  }) {
    return const [
      LibraryEditTabSpec(id: 'main', icon: Icons.menu_book, label: 'Media'),
      LibraryEditTabSpec(
        id: 'credits',
        icon: Icons.groups_2,
        label: 'Credits',
      ),
      LibraryEditTabSpec(
        id: 'custom',
        icon: Icons.edit_note,
        label: 'Custom Fields',
      ),
      LibraryEditTabSpec(
        id: 'read_history',
        icon: Icons.auto_stories_outlined,
        label: 'Tracking',
      ),
      LibraryEditTabSpec(
        id: 'covers',
        icon: Icons.photo_camera_outlined,
        label: 'Covers',
      ),
      LibraryEditTabSpec(
        id: 'plot',
        icon: Icons.description_outlined,
        label: 'Plot',
      ),
      LibraryEditTabSpec(id: 'links', icon: Icons.public, label: 'Links'),
    ];
  }

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'main' => ['book_details'],
      'credits' => ['book_credits'],
      'plot' => ['book_plot'],
      'covers' => ['book_cover_sources'],
      'links' => ['book_identifiers_links'],
      'custom' => ['book_custom_fields'],
      'read_history' => ['book_read_history'],
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

class BookLibraryReleaseEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const BookLibraryReleaseEditPresentationBuilder()
      : super(
          ownedTabs: const [
            LibraryEditTabSpec(
              id: 'details',
              icon: Icons.info_outline,
              label: 'Release',
            ),
            LibraryEditTabSpec(
              id: 'personal',
              icon: Icons.person_outline,
              label: 'Personal',
            ),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
            ),
            LibraryEditTabSpec(
              id: 'read_history',
              icon: Icons.auto_stories_outlined,
              label: 'Tracking',
            ),
            LibraryEditTabSpec(
              id: 'value',
              icon: Icons.attach_money,
              label: 'Value',
            ),
            LibraryEditTabSpec(
              id: 'photos',
              icon: Icons.image_outlined,
              label: 'My Images',
            ),
          ],
          trackedTabs: const [
            LibraryEditTabSpec(
              id: 'details',
              icon: Icons.info_outline,
              label: 'Release',
            ),
            LibraryEditTabSpec(
              id: 'personal',
              icon: Icons.person_outline,
              label: 'Personal',
            ),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
            ),
            LibraryEditTabSpec(
              id: 'read_history',
              icon: Icons.auto_stories_outlined,
              label: 'Tracking',
            ),
            LibraryEditTabSpec(
              id: 'value',
              icon: Icons.attach_money,
              label: 'Value',
            ),
            LibraryEditTabSpec(
              id: 'photos',
              icon: Icons.image_outlined,
              label: 'My Images',
            ),
          ],
          catalogTabs: const [
            LibraryEditTabSpec(
              id: 'details',
              icon: Icons.info_outline,
              label: 'Release',
            ),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
            ),
            LibraryEditTabSpec(
              id: 'read_history',
              icon: Icons.auto_stories_outlined,
              label: 'Tracking',
            ),
          ],
        );

  @override
  List<LibraryEditTabSpec> buildTabs({
    required LibraryEditPresentationContext context,
  }) {
    return switch (context.isOwned || context.isTrackingOnly || context.hasWishlistContext) {
      true => const [
          LibraryEditTabSpec(
            id: 'details',
            icon: Icons.info_outline,
            label: 'Release',
          ),
          LibraryEditTabSpec(
            id: 'personal',
            icon: Icons.person_outline,
            label: 'Personal',
          ),
          LibraryEditTabSpec(
            id: 'custom',
            icon: Icons.edit_note,
            label: 'Custom Fields',
          ),
          LibraryEditTabSpec(
            id: 'read_history',
            icon: Icons.auto_stories_outlined,
            label: 'Tracking',
          ),
          LibraryEditTabSpec(
            id: 'value',
            icon: Icons.attach_money,
            label: 'Value',
          ),
          LibraryEditTabSpec(
            id: 'photos',
            icon: Icons.image_outlined,
            label: 'My Images',
          ),
        ],
      false => const [
          LibraryEditTabSpec(
            id: 'details',
            icon: Icons.info_outline,
            label: 'Release',
          ),
          LibraryEditTabSpec(
            id: 'custom',
            icon: Icons.edit_note,
            label: 'Custom Fields',
          ),
          LibraryEditTabSpec(
            id: 'read_history',
            icon: Icons.auto_stories_outlined,
            label: 'Tracking',
          ),
        ],
    };
  }

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
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

class BookLibraryEditPresentationBuilder
    extends BookLibraryMediaEditPresentationBuilder {
  const BookLibraryEditPresentationBuilder();
}
