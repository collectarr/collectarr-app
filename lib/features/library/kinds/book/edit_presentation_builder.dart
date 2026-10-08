import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_edit_presentation_builder_base.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_custom_tab_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

class BookCatalogItemEditPresentationBuilder
    extends LibraryEditPresentationBuilderBase {
  const BookCatalogItemEditPresentationBuilder()
      : super(
          useEntryMainArtworkLayout: false,
          useDetailsTab: false,
          useArtworkCoverTab: false,
          useArtworkPhotosTab: false,
          trackingSectionTitle: 'Tracking book',
          entryDigitalTrackingSectionTitle: 'Digital Entry Details',
          entryDigitalTrackingHint:
              'Digital items keep tracking, notes, and value fields, while physical media fields stay disabled.',
          entryTabs: const [
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
          ],
          customTabBuilder: buildBookCustomTabView,
        );

  @override
  String buildDialogTitle({
    required CatalogSearchCandidate kindItem,
  }) {
    String? creator;
    creator = kindItem.kindCapability.mapTransport((transport) {
      final metadata = BookCatalogMetadata.fromJson(transport.kindData);
      for (final credit in metadata.creators) {
        final name = credit.name.trim();
        if (name.isNotEmpty) return name;
      }
      return null;
    });
    final baseTitle = super.buildDialogTitle(kindItem: kindItem);
    return creator == null ? baseTitle : '$baseTitle / $creator';
  }

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
      if (context.isEntry)
        const LibraryEditTabSpec(
          id: 'entry',
          icon: Icons.inventory_2,
          label: 'Entry',
        ),
    ];
  }
}
