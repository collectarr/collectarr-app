import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

const _boardGameTabs = [
  LibraryEditTabSpec(
    id: 'main',
    icon: Icons.casino_outlined,
    label: 'Main',
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
];

class BoardGameLibraryEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const BoardGameLibraryEditPresentationBuilder()
      : super(
          ownedTabs: _boardGameTabs,
          trackedTabs: _boardGameTabs,
          catalogTabs: _boardGameTabs,
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
      'cover' => ['cover_images'],
      'synopsis' => ['synopsis'],
      'links' => ['external_links'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }
}

const boardGamesLibraryEditPresentation = LibraryEditPresentation(
  builder: BoardGameLibraryEditPresentationBuilder(),
  mediaBuilder: BoardGameLibraryEditPresentationBuilder(),
  releaseBuilder: BoardGameLibraryEditPresentationBuilder(),
);
