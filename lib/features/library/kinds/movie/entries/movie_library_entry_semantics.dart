import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_fields.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryEntryFormatHint resolveMovieEntryFormatHint(
  CatalogSearchCandidate item,
) {
  final metadata = item.movieCatalogFields.metadata;
  final format = metadata?.physicalFormat;
  return (
    format: format,
    label: moviePhysicalMediaFormatLabel(format) ??
        (item.movieCatalogFields.titleExtension ?? metadata?.editionTitle)
            ?.trim(),
  );
}

bool? resolveMovieEntryDigitalFlag(
  LibraryEntrySummary? libraryEntry, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: libraryEntry?.isDigital,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? moviePhysicalMediaFormats : formats,
  );
}
