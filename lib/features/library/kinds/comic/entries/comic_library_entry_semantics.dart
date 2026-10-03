import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_fields.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryEntryFormatHint resolveComicEntryFormatHint(
  CatalogSearchCandidate item,
) {
  final metadata = item.comicCatalogFields.metadata;
  final format = metadata?.physicalFormat;
  return (
    format: format,
    label: format ??
        (item.comicCatalogFields.titleExtension ?? metadata?.editionTitle)
            ?.trim(),
  );
}

bool? resolveComicEntryDigitalFlag(
  LibraryEntrySummary? libraryEntry, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: libraryEntry?.isDigital,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? comicPhysicalMediaFormats : formats,
  );
}
