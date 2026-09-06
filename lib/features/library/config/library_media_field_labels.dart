import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

export 'package:collectarr_app/features/library/config/library_media_presentation_models.dart'
    show
        LibraryMediaFilterLabels,
        LibraryMediaGroupLabels,
        LibraryMediaPresentation,
        LibraryMediaPreviewLabels,
        LibraryMediaSearchFieldLabels;

LibraryMediaSearchFieldLabels libraryMediaSearchFieldLabels(
  LibraryKindModule type,
) {
  return type.presentation.searchFieldLabels;
}

LibraryMediaFilterLabels libraryMediaFilterLabels(LibraryKindModule type) {
  return type.presentation.filterLabels;
}

LibraryMediaGroupLabels libraryMediaGroupLabels(LibraryKindModule type) {
  return type.presentation.groupLabels;
}

LibraryMediaPreviewLabels libraryMediaPreviewLabels(LibraryKindModule type) {
  return type.presentation.previewLabels;
}
