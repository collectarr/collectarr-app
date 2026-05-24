import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

class BookLibraryEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const BookLibraryEditPresentationBuilder()
      : super(
          ownedTabs: const [
            LibraryEditTabSpec(id: 'details', icon: Icons.menu_book, label: 'Details'),
            LibraryEditTabSpec(id: 'credits', icon: Icons.groups_2, label: 'Credits & Characters'),
            LibraryEditTabSpec(id: 'contents', icon: Icons.format_list_numbered, label: 'Contents'),
            LibraryEditTabSpec(id: 'plot_notes', icon: Icons.notes, label: 'Plot & Notes'),
            LibraryEditTabSpec(id: 'covers', icon: Icons.image, label: 'Covers'),
            LibraryEditTabSpec(id: 'links', icon: Icons.link, label: 'Links'),
            LibraryEditTabSpec(id: 'personal', icon: Icons.person, label: 'Personal'),
            LibraryEditTabSpec(id: 'photos', icon: Icons.photo_library, label: 'Photos'),
          ],
          trackedTabs: const [
            LibraryEditTabSpec(id: 'details', icon: Icons.menu_book, label: 'Details'),
            LibraryEditTabSpec(id: 'credits', icon: Icons.groups_2, label: 'Credits & Characters'),
            LibraryEditTabSpec(id: 'contents', icon: Icons.format_list_numbered, label: 'Contents'),
            LibraryEditTabSpec(id: 'plot_notes', icon: Icons.notes, label: 'Plot & Notes'),
            LibraryEditTabSpec(id: 'covers', icon: Icons.image, label: 'Covers'),
            LibraryEditTabSpec(id: 'links', icon: Icons.link, label: 'Links'),
            LibraryEditTabSpec(id: 'personal', icon: Icons.person, label: 'Personal'),
          ],
          catalogTabs: const [
            LibraryEditTabSpec(id: 'details', icon: Icons.menu_book, label: 'Details'),
            LibraryEditTabSpec(id: 'credits', icon: Icons.groups_2, label: 'Credits & Characters'),
            LibraryEditTabSpec(id: 'contents', icon: Icons.format_list_numbered, label: 'Contents'),
            LibraryEditTabSpec(id: 'plot_notes', icon: Icons.notes, label: 'Plot & Notes'),
            LibraryEditTabSpec(id: 'covers', icon: Icons.image, label: 'Covers'),
            LibraryEditTabSpec(id: 'links', icon: Icons.link, label: 'Links'),
          ],
        );

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'details' => ['book_details'],
      'credits' => ['book_credits'],
      'contents' => ['book_contents'],
      'plot_notes' => [
          'book_plot',
          if (context.isOwned) 'book_notes',
        ],
      'covers' => ['book_cover_sources'],
      'links' => [
          'book_identifiers_links',
          if (context.hasCustomFields) 'book_custom_fields',
        ],
      'personal' => [
          'book_personal_tracking',
          if (context.isOwned) 'book_collection_notes' else 'book_collection_fields_info',
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