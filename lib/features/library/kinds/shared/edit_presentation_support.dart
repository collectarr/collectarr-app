import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_presentation_builder.dart';

const genericLibraryEditPresentation = LibraryEditPresentation(
  builder: DefaultLibraryEditPresentationBuilder(),
);

const comicsLibraryEditPresentation = LibraryEditPresentation(
  builder: DefaultLibraryEditPresentationBuilder(
    showOwnedGradingSection: true,
  ),
);

const mangaLibraryEditPresentation = LibraryEditPresentation(
  builder: DefaultLibraryEditPresentationBuilder(
    showOwnedGradingSection: true,
  ),
);

const booksLibraryEditPresentation = LibraryEditPresentation(
  builder: BookLibraryEditPresentationBuilder(),
);

const musicLibraryEditPresentation = LibraryEditPresentation(
  builder: MusicLibraryEditPresentationBuilder(),
);