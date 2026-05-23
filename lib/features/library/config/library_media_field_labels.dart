import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';

export 'package:collectarr_app/features/library/config/library_media_presentation_models.dart'
    show
        LibraryMediaFieldLabels,
        LibraryMediaFilterLabels,
        LibraryMediaGroupLabels,
        LibraryMediaPresentation,
    LibraryMediaPreviewLabels,
        LibraryMediaSearchFieldLabels;

LibraryMediaFieldLabels libraryMediaFieldLabels(LibraryTypeConfig type) {
  return type.presentation.fieldLabels;
}

LibraryMediaSearchFieldLabels libraryMediaSearchFieldLabels(
  LibraryTypeConfig type,
) {
  return type.presentation.searchFieldLabels;
}

LibraryMediaFilterLabels libraryMediaFilterLabels(LibraryTypeConfig type) {
  return type.presentation.filterLabels;
}

LibraryMediaGroupLabels libraryMediaGroupLabels(LibraryTypeConfig type) {
  return type.presentation.groupLabels;
}

LibraryMediaPreviewLabels libraryMediaPreviewLabels(LibraryTypeConfig type) {
  return type.presentation.previewLabels;
}
