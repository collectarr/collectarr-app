import 'package:collectarr_app/features/library/config/library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';

export 'package:collectarr_app/features/library/config/library_media_presentation.dart'
    show
        LibraryMediaFieldLabels,
        LibraryMediaFilterLabels,
        LibraryMediaGroupLabels,
        LibraryMediaPresentation,
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
