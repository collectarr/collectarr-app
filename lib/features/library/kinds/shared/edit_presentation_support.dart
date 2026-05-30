import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_presentation_builder.dart';
import 'package:flutter/material.dart';

const _comicOwnedEditTabs = [
  LibraryEditTabSpec(id: 'main', icon: Icons.article, label: 'Main'),
  LibraryEditTabSpec(id: 'cover', icon: Icons.image, label: 'Cover'),
  LibraryEditTabSpec(id: 'synopsis', icon: Icons.notes, label: 'Synopsis'),
  LibraryEditTabSpec(id: 'custom', icon: Icons.tune, label: 'Custom'),
  LibraryEditTabSpec(id: 'photos', icon: Icons.photo_library, label: 'Photos'),
];

const genericLibraryEditPresentation = LibraryEditPresentation(
  builder: DefaultLibraryEditPresentationBuilder(),
);

const comicsLibraryEditPresentation = LibraryEditPresentation(
  builder: DefaultLibraryEditPresentationBuilder(
    showOwnedGradingSection: true,
    ownedTabs: _comicOwnedEditTabs,
  ),
);

const booksLibraryEditPresentation = LibraryEditPresentation(
  builder: BookLibraryEditPresentationBuilder(),
);

const musicLibraryEditPresentation = LibraryEditPresentation(
  builder: MusicLibraryEditPresentationBuilder(),
);