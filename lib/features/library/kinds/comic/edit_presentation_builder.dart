import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:flutter/material.dart';

const _comicOwnedEditTabs = [
  LibraryEditTabSpec(id: 'main', icon: Icons.article, label: 'Main'),
  LibraryEditTabSpec(id: 'details', icon: Icons.search, label: 'Details'),
  LibraryEditTabSpec(id: 'value', icon: Icons.attach_money, label: 'Value'),
  LibraryEditTabSpec(id: 'personal', icon: Icons.person, label: 'Personal'),
  LibraryEditTabSpec(id: 'custom', icon: Icons.tune, label: 'Custom Fields'),
  LibraryEditTabSpec(id: 'cover', icon: Icons.image, label: 'Covers'),
  LibraryEditTabSpec(id: 'photos', icon: Icons.photo_library, label: 'My Images'),
  LibraryEditTabSpec(id: 'creators', icon: Icons.group, label: 'Creators'),
  LibraryEditTabSpec(id: 'characters', icon: Icons.face, label: 'Characters'),
  LibraryEditTabSpec(id: 'synopsis', icon: Icons.notes, label: 'Plot'),
  LibraryEditTabSpec(id: 'links', icon: Icons.link, label: 'Links'),
];

class ComicLibraryEditPresentationBuilder
    extends DefaultLibraryEditPresentationBuilder {
  const ComicLibraryEditPresentationBuilder()
      : super(
          showOwnedGradingSection: true,
          useOwnedMainArtworkLayout: true,
          useDetailsTab: true,
          useArtworkCoverTab: true,
          useArtworkPhotosTab: true,
          showOwnedCoverPriceField: false,
          ownedTabs: _comicOwnedEditTabs,
        );
}

const comicsLibraryEditPresentation = LibraryEditPresentation(
  builder: ComicLibraryEditPresentationBuilder(),
);
