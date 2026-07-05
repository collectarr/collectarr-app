import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

const _boardGameTabs = [
  LibraryEditTabSpec(
    id: 'main',
    icon: Icons.casino_outlined,
    label: 'Main',
    sectionIds: [
      'catalog_snapshot',
      'tracking_context',
      'ownership_reference',
      'owned_grading',
    ],
  ),
  LibraryEditTabSpec(
    id: 'synopsis',
    icon: Icons.description_outlined,
    label: 'Description',
    sectionIds: ['synopsis'],
  ),
  LibraryEditTabSpec(
    id: 'links',
    icon: Icons.public,
    label: 'Links',
    sectionIds: ['external_links'],
  ),
  LibraryEditTabSpec(
    id: 'cover',
    icon: Icons.photo_camera_outlined,
    label: 'Covers',
    sectionIds: ['cover_images'],
  ),
  LibraryEditTabSpec(
    id: 'photos',
    icon: Icons.image_outlined,
    label: 'My Images',
    sectionIds: ['photos'],
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
}

const boardGamesLibraryEditPresentation = LibraryEditPresentation(
  builder: BoardGameLibraryEditPresentationBuilder(),
  mediaBuilder: BoardGameLibraryEditPresentationBuilder(),
  releaseBuilder: BoardGameLibraryEditPresentationBuilder(),
);
