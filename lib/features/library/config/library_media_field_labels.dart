import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';

export 'package:collectarr_app/features/library/config/library_media_presentation_models.dart'
    show
        LibraryPresentationLabels,
        LibraryMediaPresentation,
        LibraryMediaPreviewLabels,
        LibraryMediaSearchFieldLabels;

LibraryMediaSearchFieldLabels libraryMediaSearchFieldLabels(
  LibraryKindRegistration type,
) {
  return libraryPresentationForKind(type.kind).searchFieldLabels;
}

LibraryPresentationLabels libraryMediaFilterLabels(
    LibraryKindRegistration type) {
  return libraryPresentationForKind(type.kind).filterLabels;
}

LibraryPresentationLabels libraryMediaGroupLabels(
    LibraryKindRegistration type) {
  return libraryPresentationForKind(type.kind).groupLabels;
}

LibraryMediaPreviewLabels libraryMediaPreviewLabels(
    LibraryKindRegistration type) {
  return libraryPresentationForKind(type.kind).previewLabels;
}
