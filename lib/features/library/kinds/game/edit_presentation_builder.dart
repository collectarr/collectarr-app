import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

class GameLibraryEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const GameLibraryEditPresentationBuilder()
      : super(
          ownedTabs: const [
            LibraryEditTabSpec(
              id: 'main',
              icon: Icons.sports_esports,
              label: 'Main',
            ),
            LibraryEditTabSpec(
              id: 'value',
              icon: Icons.attach_money,
              label: 'Value',
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
              id: 'cover',
              icon: Icons.photo_camera_outlined,
              label: 'Covers',
            ),
            LibraryEditTabSpec(
              id: 'photos',
              icon: Icons.image_outlined,
              label: 'My Images',
            ),
            LibraryEditTabSpec(
              id: 'synopsis',
              icon: Icons.description_outlined,
              label: 'Description',
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
              icon: Icons.sports_esports,
              label: 'Main',
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
              id: 'cover',
              icon: Icons.photo_camera_outlined,
              label: 'Covers',
            ),
            LibraryEditTabSpec(
              id: 'synopsis',
              icon: Icons.description_outlined,
              label: 'Description',
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
              icon: Icons.sports_esports,
              label: 'Main',
            ),
            LibraryEditTabSpec(
              id: 'custom',
              icon: Icons.edit_note,
              label: 'Custom Fields',
            ),
            LibraryEditTabSpec(
              id: 'cover',
              icon: Icons.photo_camera_outlined,
              label: 'Covers',
            ),
            LibraryEditTabSpec(
              id: 'synopsis',
              icon: Icons.description_outlined,
              label: 'Description',
            ),
            LibraryEditTabSpec(
              id: 'links',
              icon: Icons.public,
              label: 'Links',
            ),
          ],
        );

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final sections = switch (tabId) {
      'main' => [
          'catalog_snapshot',
          'tracking_context',
          'ownership_reference',
          'owned_grading',
        ],
      'value' => [
          'purchase',
          'value_summary',
          'sold_status',
          'profit_loss',
        ],
      'personal' => [
          'tracking_personal',
          'wishlist_reference',
          'owned_notes',
          'collection_fields_info',
        ],
      'custom' => ['custom_fields'],
      'photos' => ['photos'],
      'cover' => ['cover_images'],
      'synopsis' => ['synopsis'],
      'links' => ['external_links'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
}

const gameLibraryEditPresentation = LibraryEditPresentation(
  builder: GameLibraryEditPresentationBuilder(),
);
