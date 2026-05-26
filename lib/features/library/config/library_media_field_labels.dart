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

/// Derives field labels from the canonical [MediaEditFields] and
/// [ReleaseEditFields] on [LibraryTypeConfig].  Callers that only need a
/// subset should access `type.mediaFields` / `type.releaseFields` directly.
LibraryMediaFieldLabels libraryMediaFieldLabels(LibraryTypeConfig type) {
  return LibraryMediaFieldLabels(
    number: type.mediaFields.numberLabel,
    publisher: type.mediaFields.publisherLabel,
    variant: type.releaseFields.variantLabel,
    barcode: type.releaseFields.barcodeLabel,
  );
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
