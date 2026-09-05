import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_custom_tab_builder.dart';
import 'package:flutter/material.dart';

List<String> _bookReleasePersonalSections(
  LibraryEditPresentationContext context,
) {
  return [
    'book_personal_tracking',
    if (context.hasWishlistContext) 'book_wishlist_reference',
    if (context.isOwned)
      'book_collection_notes'
    else if (!context.hasWishlistContext)
      'book_collection_fields_info',
  ];
}

class BookLibraryMediaEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const BookLibraryMediaEditPresentationBuilder()
      : super(
          showOwnershipReferenceSection: true,
          useOwnedMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Tracking edition',
          ownedDigitalTrackingSectionTitle: 'Ownership details',
          ownedDigitalTrackingHint:
              'Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.',
          ownershipReferenceTitle: 'Ownership reference',
          ownedBundleLabel: 'Owned bundle',
          ownedTabs: const [
            LibraryEditTabSpec(
              id: 'main',
              icon: Icons.menu_book,
              label: 'Main',
              sectionIds: ['book_details'],
            ),
            LibraryEditTabSpec(
              id: 'credits',
              icon: Icons.groups_2,
              label: 'Credits',
              sectionIds: ['book_credits'],
            ),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
              sectionIds: ['book_custom_fields'],
            ),
            LibraryEditTabSpec(
              id: 'read_history',
              icon: Icons.auto_stories_outlined,
              label: 'Tracking',
              sectionIds: ['book_read_history'],
            ),
            LibraryEditTabSpec(
              id: 'covers',
              icon: Icons.photo_camera_outlined,
              label: 'Covers',
              sectionIds: ['book_cover_sources'],
            ),
            LibraryEditTabSpec(
              id: 'plot',
              icon: Icons.description_outlined,
              label: 'Plot',
              sectionIds: ['book_plot'],
            ),
            LibraryEditTabSpec(
              id: 'links',
              icon: Icons.public,
              label: 'Links',
              sectionIds: ['book_identifiers_links'],
            ),
          ],
          trackedTabs: const [
            LibraryEditTabSpec(
              id: 'main',
              icon: Icons.menu_book,
              label: 'Main',
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
              label: 'Main',
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
          customTabBuilder: buildBookCustomTabView,
        );

  @override
  List<LibraryEditTabSpec> buildTabs({
    required LibraryEditPresentationContext context,
  }) {
    return [
      LibraryEditTabSpec(
        id: 'main',
        icon: Icons.menu_book,
        label: 'Main',
        sectionIds: ['book_details'],
      ),
      LibraryEditTabSpec(
        id: 'credits',
        icon: Icons.groups_2,
        label: 'Credits',
        sectionIds: ['book_credits'],
      ),
      LibraryEditTabSpec(
        id: 'custom',
        icon: Icons.edit_note,
        label: 'Custom Fields',
        sectionIds: ['book_custom_fields'],
      ),
      LibraryEditTabSpec(
        id: 'read_history',
        icon: Icons.auto_stories_outlined,
        label: 'Tracking',
        sectionIds: ['book_read_history'],
      ),
      LibraryEditTabSpec(
        id: 'covers',
        icon: Icons.photo_camera_outlined,
        label: 'Covers',
        sectionIds: ['book_cover_sources'],
      ),
      LibraryEditTabSpec(
        id: 'plot',
        icon: Icons.description_outlined,
        label: 'Plot',
        sectionIds: ['book_plot'],
      ),
      LibraryEditTabSpec(
        id: 'links',
        icon: Icons.public,
        label: 'Links',
        sectionIds: ['book_identifiers_links'],
      ),
      if (context.isOwned)
        const LibraryEditTabSpec(
          id: 'owned',
          icon: Icons.inventory_2,
          label: 'Owned',
        ),
    ];
  }
}

class BookLibraryReleaseEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const BookLibraryReleaseEditPresentationBuilder()
      : super(
          showOwnershipReferenceSection: true,
          useOwnedMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Tracking edition',
          ownedDigitalTrackingSectionTitle: 'Ownership details',
          ownedDigitalTrackingHint:
              'Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.',
          ownershipReferenceTitle: 'Ownership reference',
          ownedBundleLabel: 'Owned bundle',
          ownedTabs: const [
            LibraryEditTabSpec(
              id: 'details',
              icon: Icons.info_outline,
              label: 'Release',
              sectionIds: ['book_contents'],
            ),
            LibraryEditTabSpec(
              id: 'personal',
              icon: Icons.person_outline,
              label: 'Personal',
              sectionIdsForContext: _bookReleasePersonalSections,
            ),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
              sectionIds: ['book_custom_fields'],
            ),
            LibraryEditTabSpec(
              id: 'read_history',
              icon: Icons.auto_stories_outlined,
              label: 'Tracking',
              sectionIds: ['book_read_history'],
            ),
            LibraryEditTabSpec(
              id: 'value',
              icon: Icons.attach_money,
              label: 'Value',
              sectionIds: ['book_value'],
            ),
            LibraryEditTabSpec(
              id: 'photos',
              icon: Icons.image_outlined,
              label: 'My Images',
              sectionIds: ['book_photos'],
            ),
          ],
          trackedTabs: const [
            LibraryEditTabSpec(
              id: 'details',
              icon: Icons.info_outline,
              label: 'Release',
              sectionIds: ['book_contents'],
            ),
            LibraryEditTabSpec(
              id: 'personal',
              icon: Icons.person_outline,
              label: 'Personal',
              sectionIdsForContext: _bookReleasePersonalSections,
            ),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
              sectionIds: ['book_custom_fields'],
            ),
            LibraryEditTabSpec(
              id: 'read_history',
              icon: Icons.auto_stories_outlined,
              label: 'Tracking',
              sectionIds: ['book_read_history'],
            ),
            LibraryEditTabSpec(
              id: 'value',
              icon: Icons.attach_money,
              label: 'Value',
              sectionIds: ['book_value'],
            ),
            LibraryEditTabSpec(
              id: 'photos',
              icon: Icons.image_outlined,
              label: 'My Images',
              sectionIds: ['book_photos'],
            ),
          ],
          catalogTabs: const [
            LibraryEditTabSpec(
              id: 'details',
              icon: Icons.info_outline,
              label: 'Release',
              sectionIds: ['book_contents'],
            ),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
              sectionIds: ['book_custom_fields'],
            ),
            LibraryEditTabSpec(
              id: 'read_history',
              icon: Icons.auto_stories_outlined,
              label: 'Tracking',
              sectionIds: ['book_read_history'],
            ),
          ],
        );

  @override
  List<LibraryEditTabSpec> buildTabs({
    required LibraryEditPresentationContext context,
  }) {
    return switch (context.isOwned ||
        context.isTrackingOnly ||
        context.hasWishlistContext) {
      true => const [
          LibraryEditTabSpec(
            id: 'details',
            icon: Icons.info_outline,
            label: 'Release',
            sectionIds: ['book_contents'],
          ),
          LibraryEditTabSpec(
            id: 'personal',
            icon: Icons.person_outline,
            label: 'Personal',
            sectionIdsForContext: _bookReleasePersonalSections,
          ),
          LibraryEditTabSpec(
            id: 'custom',
            icon: Icons.edit_note,
            label: 'Custom Fields',
            sectionIds: ['book_custom_fields'],
          ),
          LibraryEditTabSpec(
            id: 'read_history',
            icon: Icons.auto_stories_outlined,
            label: 'Tracking',
            sectionIds: ['book_read_history'],
          ),
          LibraryEditTabSpec(
            id: 'value',
            icon: Icons.attach_money,
            label: 'Value',
            sectionIds: ['book_value'],
          ),
          LibraryEditTabSpec(
            id: 'photos',
            icon: Icons.image_outlined,
            label: 'My Images',
            sectionIds: ['book_photos'],
          ),
        ],
      false => const [
          LibraryEditTabSpec(
            id: 'details',
            icon: Icons.info_outline,
            label: 'Release',
            sectionIds: ['book_contents'],
          ),
          LibraryEditTabSpec(
            id: 'custom',
            icon: Icons.edit_note,
            label: 'Custom Fields',
            sectionIds: ['book_custom_fields'],
          ),
          LibraryEditTabSpec(
            id: 'read_history',
            icon: Icons.auto_stories_outlined,
            label: 'Tracking',
            sectionIds: ['book_read_history'],
          ),
        ],
    };
  }
}
